import 'package:flutter/material.dart';

import '../widgets/gradient_screen_layout.dart';
import './content_page/content_page.dart';

class FamilyWelcomePage extends StatelessWidget {
  const FamilyWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScreenLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ProgressDot(isActive: false),
                  SizedBox(width: 4),
                  _ProgressDot(isActive: false),
                  SizedBox(width: 4),
                  _ProgressDot(isActive: true),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Você entrou na\nFamília!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 48),
              Center(
                child: Image.asset(
                  'assets/images/join_family.png',
                  height: 220,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Agora você pode acompanhar e participar das tarefas e cuidados.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF7E7777),
                  height: 1.4,
                ),
              ),
            ],
          ),
          Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContentPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4195CC),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Ir para o painel',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressDot extends StatelessWidget {
  const _ProgressDot({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 13 : 11,
      height: isActive ? 13 : 11,
      decoration: BoxDecoration(
        color: isActive
            ? const Color.fromARGB(255, 0, 0, 0)
            : const Color.fromARGB(255, 173, 173, 173),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
