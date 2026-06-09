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

    final googleAccount = await _googleSignIn.authenticate();
    final googleAuth = googleAccount.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    await validateInstitutionalUserOrSignOut(userCredential.user);

    return userCredential;
  }

  Future<void> validateInstitutionalUserOrSignOut(User? user) async {
    if (isInstitutionalEmail(user?.email)) {
      return;
    }

    await signOut();
    throw const InstitutionalDomainAuthException();
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();

    try {
      await initializeGoogleSignIn();
      await _googleSignIn.signOut();
    } on Object {
      // Firebase sign-out is the security boundary; Google sign-out is a local
      // provider cleanup that can fail when native configuration is incomplete.
    }
  }
}
