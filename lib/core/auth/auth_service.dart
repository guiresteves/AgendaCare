import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class InstitutionalDomainAuthException implements Exception {
  const InstitutionalDomainAuthException([
    this.message =
        'Acesso permitido apenas para contas institucionais @souunit.com.br.',
  ]);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const allowedDomain = 'souunit.com.br';
  static const googleProviderId = 'google.com';
  static const passwordProviderId = 'password';

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _isGoogleSignInInitialized = false;

  static bool isInstitutionalEmail(String? email) {
    final normalizedEmail = email?.trim().toLowerCase();
    if (normalizedEmail == null || normalizedEmail.isEmpty) {
      return false;
    }

    final atIndex = normalizedEmail.lastIndexOf('@');
    if (atIndex == -1) {
      return false;
    }

    return normalizedEmail.substring(atIndex + 1) == allowedDomain;
  }

  static bool userUsesGoogle(User? user) {
    return user?.providerData.any(
          (provider) => provider.providerId == googleProviderId,
        ) ??
        false;
  }

  static bool userUsesPassword(User? user) {
    return user?.providerData.any(
          (provider) => provider.providerId == passwordProviderId,
        ) ??
        false;
  }

  static bool canChangePassword(User? user) {
    return userUsesPassword(user) && !userUsesGoogle(user);
  }

  Future<void> initializeGoogleSignIn() async {
    if (_isGoogleSignInInitialized) {
      return;
    }

    await _googleSignIn.initialize(hostedDomain: allowedDomain);
    _isGoogleSignInInitialized = true;
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    await validateInstitutionalUserOrSignOut(credential.user);
    return credential;
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (!isInstitutionalEmail(email)) {
      throw const InstitutionalDomainAuthException();
    }

    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await validateInstitutionalUserOrSignOut(credential.user);
    return credential;
  }

  Future<UserCredential> signInWithGoogle() async {
    await initializeGoogleSignIn();

    if (!_googleSignIn.supportsAuthenticate()) {
      throw UnsupportedError(
        'Google Sign-In nao esta disponivel nesta plataforma.',
      );
    }

    await _clearGoogleProviderSession();
    final googleAccount = await _googleSignIn.authenticate();
    if (!isInstitutionalEmail(googleAccount.email)) {
      await _clearGoogleProviderSession(revokeAccess: true);
      throw const InstitutionalDomainAuthException(
        'Selecione uma conta institucional @souunit.com.br.',
      );
    }

    final googleAuth = googleAccount.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    await validateInstitutionalUserOrSignOut(userCredential.user);

    return userCredential;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _firebaseAuth.currentUser;
    final email = user?.email;

    if (user == null || email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Usuario nao autenticado.',
      );
    }

    if (!canChangePassword(user)) {
      throw FirebaseAuthException(
        code: 'operation-not-allowed',
        message: 'Esta conta nao permite alteracao de senha no app.',
      );
    }

    final currentCredential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(currentCredential);
    await user.updatePassword(newPassword);

    try {
      final refreshedUser = _firebaseAuth.currentUser;
      if (refreshedUser == null) {
        throw FirebaseAuthException(
          code: 'user-signed-out',
          message: 'Senha alterada. Entre novamente para continuar.',
        );
      }

      final newCredential = EmailAuthProvider.credential(
        email: email,
        password: newPassword,
      );

      await refreshedUser.reauthenticateWithCredential(newCredential);
      await refreshedUser.getIdToken(true);
      await refreshedUser.reload();
      await validateInstitutionalUserOrSignOut(_firebaseAuth.currentUser);
    } on Object {
      await signOut();
      throw FirebaseAuthException(
        code: 'password-changed-session-expired',
        message: 'Senha alterada. Entre novamente para continuar.',
      );
    }
  }

  Future<void> validateInstitutionalUserOrSignOut(User? user) async {
    if (isInstitutionalEmail(user?.email)) {
      return;
    }

    await signOut();
    throw const InstitutionalDomainAuthException();
  }

  Future<void> signOut() async {
    final shouldClearGoogleSession = userUsesGoogle(_firebaseAuth.currentUser);

    await _runIgnoringErrors(
      _firebaseAuth.signOut().timeout(const Duration(seconds: 5)),
    );

    if (shouldClearGoogleSession) {
      await _clearGoogleProviderSession();
    }
  }

  Future<void> _clearGoogleProviderSession({bool revokeAccess = false}) async {
    await _runIgnoringErrors(() async {
      await initializeGoogleSignIn().timeout(const Duration(seconds: 5));
      final googleCleanup = revokeAccess
          ? _googleSignIn.disconnect()
          : _googleSignIn.signOut();
      await googleCleanup.timeout(const Duration(seconds: 5));
    }());
  }

  Future<void> _runIgnoringErrors(Future<void> future) async {
    try {
      await future;
    } on Object {
      // Auth cleanup is best-effort. The app must never get stuck because a
      // provider SDK is already in a stale or partially signed-out state.
    }
  }
}
