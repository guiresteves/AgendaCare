import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../widgets/gradient_screen_layout.dart';
import 'join_family_page.dart';
import 'create_family_page.dart';


const _buttonColor = Color(0xFF4195CC);
const _mutedTextColor = Color(0xFF7E7777);

class FamilySetupPage extends StatelessWidget {
  const FamilySetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScreenLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF484848),
                    width: 1.4,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: Color(0xFF484848),
                ),
              ),
            ),
          ),
          const SizedBox(height: 38),
          const Text(
            'Bem vindo ao\nAgendaCare',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Conta criada com sucesso. Como deseja continuar?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _mutedTextColor,
            ),
          ),
          const SizedBox(height: 34),
          _FamilyOptionCard(
            iconPath: 'assets/icons/frame_criargrupo.svg',
            title: 'Criar uma nova familia',
            description: 'Seja o primeiro a organizar sua familia',
          ),
          const SizedBox(height: 14),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateFamilyPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonColor,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Criar grupo',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 42),
          _FamilyOptionCard(
            iconPath: 'assets/icons/frame_entrargrupo.svg',
            title: 'Entrar em uma familia',
            description: 'Participe de uma familia ja existente',
          ),
          const SizedBox(height: 14),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JoinFamilyPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonColor,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Entrar em grupo',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _FamilyOptionCard extends StatelessWidget {
  const _FamilyOptionCard({
    required this.iconPath,
    required this.title,
    required this.description,
  });

  final String iconPath;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          SvgPicture.asset(iconPath, width: 98, height: 105),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: _mutedTextColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
