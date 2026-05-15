import 'package:flutter/material.dart';

import '../widgets/gradient_screen_layout.dart';
import 'login_page.dart';
import 'signup_page.dart';

const _benefitIconGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF94C4F5), Color(0xFF4195CC)],
);

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  double _logoHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 360) {
      return 180;
    }

    if (screenWidth > 480) {
      return 240;
    }

    return 220;
  }

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
              Center(
                child: Image.asset(
                  'assets/images/app_logo.png',
                  height: _logoHeight(context),
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'AgendaCare',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cuidado organizado, familia conectada',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7E7777),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 56),
              const _BenefitItem(
                icon: Icons.people_outline_rounded,
                title: 'Organize a familia',
                description:
                    'Conecte todos os cuidadores e compartilhe responsabilidades',
              ),
              const SizedBox(height: 28),
              const _BenefitItem(
                icon: Icons.calendar_month_outlined,
                title: 'Acompanhe a rotina',
                description:
                    'Veja todas as tarefas e compromissos de cuidado em um so lugar',
              ),
              const SizedBox(height: 28),
              const _BenefitItem(
                icon: Icons.favorite_outline_rounded,
                title: 'Cuide com carinho',
                description:
                    'Uma ferramenta simples para apoiar o cuidado de quem voce ama',
              ),
            ],
          ),
          Column(
            children: [
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Comecar agora',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 18),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text(
                  'Ja tenho conta',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: _benefitIconGradient,
          ),
          child: Icon(icon, color: Colors.white, size: 34),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7E7777),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
