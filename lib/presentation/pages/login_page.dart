import 'package:flutter/material.dart';

const _placeholderButtonColor = Color(0xFF4195CC);
const _placeholderMutedTextColor = Color(0xFF7E7777);

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [              
              const SizedBox(height: 20),
              const Text(
                'Login',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Em DEV.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: _placeholderMutedTextColor,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _placeholderButtonColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
