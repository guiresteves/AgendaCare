import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../widgets/gradient_screen_layout.dart';

const _buttonColor = Color(0xFF4195CC);
const _mutedTextColor = Color(0xFF7E7777);

class TermsPrivacyPage extends StatelessWidget {
  const TermsPrivacyPage({super.key});

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
              onTap: () => Navigator.pop(context),
              child: SizedBox(
                width: 34,
                height: 34,
                child: SvgPicture.asset(
                  'assets/icons/Back.svg',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Termos e Privacidade',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Informacoes gerais sobre o uso do AgendaCare e o cuidado com seus dados.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _mutedTextColor,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 32),
          const _TermsSection(
            title: 'Termos de uso',
            paragraphs: [
              'O AgendaCare ajuda familias e cuidadores a organizar tarefas, compromissos e informacoes relacionadas ao cuidado.',
              'Ao usar o aplicativo, voce concorda em informar dados verdadeiros, manter suas credenciais seguras e utilizar os recursos de forma responsavel.',
              'As informacoes cadastradas devem ser compartilhadas apenas com pessoas autorizadas do seu grupo familiar ou de cuidado.',
            ],
          ),
          const SizedBox(height: 18),
          const _TermsSection(
            title: 'Privacidade',
            paragraphs: [
              'Coletamos apenas os dados necessarios para identificar sua conta, organizar seu perfil e conectar voce ao seu grupo.',
              'Seu email, nome e dados de perfil podem ser armazenados para melhorar a experiencia dentro do aplicativo.',
              'Nao vendemos seus dados pessoais. O acesso as informacoes do grupo depende das permissoes e vinculos criados no proprio aplicativo.',
            ],
          ),
          const SizedBox(height: 18),
          const _TermsSection(
            title: 'Seguranca e responsabilidades',
            paragraphs: [
              'O aplicativo usa autenticacao para proteger o acesso, mas voce tambem deve manter sua senha e seu dispositivo protegidos.',
              'O AgendaCare nao substitui orientacao medica, acompanhamento profissional ou servicos de emergencia.',
              'Estes termos podem ser atualizados futuramente para refletir melhorias no aplicativo ou novas necessidades legais.',
            ],
          ),
          const SizedBox(height: 32),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _buttonColor,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Entendi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  const _TermsSection({required this.title, required this.paragraphs});

  final String title;
  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          for (final paragraph in paragraphs) ...[
            Text(
              paragraph,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _mutedTextColor,
                height: 1.4,
              ),
            ),
            if (paragraph != paragraphs.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
