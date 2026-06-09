import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/auth/auth_service.dart';
import 'data/providers/task_provider.dart';
import 'firebase_options.dart';
import 'presentation/pages/content_page/content_page.dart';
import 'presentation/pages/family_setup_page.dart';
import 'presentation/pages/welcome_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // TaskProvider fica vivo enquanto o app estiver aberto
      create: (_) => TaskProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;

        if (user == null) {
          return const WelcomePage();
        }

        final email = user.email ?? '';
        if (!AuthService.isInstitutionalEmail(email)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AuthService.instance.signOut();
          });

          return const Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Acesso permitido apenas para contas @souunit.com.br.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final grupoId = userSnapshot.data?.data()?['grupoId'] as String?;
            if (grupoId == null || grupoId.isEmpty) {
              return const FamilySetupPage();
            }

            return const ContentPage();
          },
        );
      },
    );
  }
}
