import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/gradient_screen_layout.dart';
import './content_page/content_page.dart';
import 'create_dependent_page.dart';

class AddPersonsPage extends StatefulWidget {
  final String nomeGrupo;
  final String descricaoGrupo;
  final List<DependenteData> dependentes;
  final String? grupoIdExistente;

  const AddPersonsPage({
    super.key,
    required this.nomeGrupo,
    required this.descricaoGrupo,
    required this.dependentes,
    this.grupoIdExistente,
  });

  @override
  State<AddPersonsPage> createState() => _AddPersonsPageState();
}

class _AddPersonsPageState extends State<AddPersonsPage> {
  bool _criando = true;
  String? _erroMsg;
  String _codigoResponsavel = '';
  String? _codigoDependente;
  bool _temDependenteComApp = false;

  @override
  void initState() {
    super.initState();
    _criarGrupo();
  }

  String _gerarCodigo() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    final parte1 = List.generate(
      3,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
    final parte2 = List.generate(
      3,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
    return '$parte1-$parte2';
  }

  Future<void> _criarGrupo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuário não autenticado.');

      final db = FirebaseFirestore.instance;

      if (widget.grupoIdExistente != null) {
        final grupoDoc = await db
            .collection('grupos')
            .doc(widget.grupoIdExistente)
            .get();
        final data = grupoDoc.data() ?? {};
        final codigoResponsavel =
            data['codigoResponsavel'] as String? ?? _gerarCodigo();
        final codigoDependente = data['codigoDependente'] as String?;

        if (!mounted) return;
        setState(() {
          _criando = false;
          _codigoResponsavel = codigoResponsavel;
          _codigoDependente = codigoDependente;
          _temDependenteComApp = codigoDependente != null;
        });
        return;
      }

      final codigoResponsavel = _gerarCodigo();
      final temDependenteComApp = widget.dependentes.any((d) => d.usaApp);
      final codigoDependente = temDependenteComApp ? _gerarCodigo() : null;

      final grupoRef = await db.collection('grupos').add({
        'nome': widget.nomeGrupo,
        'descricao': widget.descricaoGrupo,
        'criadoEm': FieldValue.serverTimestamp(),
        'criadorId': user.uid,
        'criado_por': user.email ?? '',
        'codigoResponsavel': codigoResponsavel,
        if (codigoDependente != null) 'codigoDependente': codigoDependente,
      });

      final nomeUsuario = (user.displayName?.trim().isNotEmpty ?? false)
          ? user.displayName!.trim()
          : (user.email ?? '').trim();

      await db.collection('usuarios').doc(user.uid).set({
        'grupoId': grupoRef.id,
        'nome': nomeUsuario,
      }, SetOptions(merge: true));

      await db
          .collection('grupos')
          .doc(grupoRef.id)
          .collection('membros')
          .doc(user.uid)
          .set({
            'uid': user.uid,
            'papel': 'responsavel',
            'nome': nomeUsuario,
            'email': user.email ?? '',
            'criado_por': user.email ?? '',
            'entradaEm': FieldValue.serverTimestamp(),
          });

      for (final dep in widget.dependentes) {
        await db
            .collection('grupos')
            .doc(grupoRef.id)
            .collection('dependentes')
            .add({
              'nome': dep.nome,
              'usaApp': dep.usaApp,
            });
      }

      if (!mounted) return;

      setState(() {
        _criando = false;
        _codigoResponsavel = codigoResponsavel;
        _codigoDependente = codigoDependente;
        _temDependenteComApp = temDependenteComApp;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _criando = false;
        _erroMsg = 'Erro ao criar grupo. Tente novamente.';
      });
    }
  }

  void _copiar(String codigo) {
    Clipboard.setData(ClipboardData(text: codigo));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código copiado!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_criando) {
      return const _LoadingGrupo();
    }

    if (_erroMsg != null) {
      return _ErroGrupo(mensagem: _erroMsg!);
    }

    return GradientScreenLayout(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFBDBDBD)),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: Color(0xFF484848),
                    ),
                  ),
                ),
                const Spacer(),
                if (widget.grupoIdExistente == null)
                  const Row(
                    children: [
                      _ProgressDot(isActive: false),
                      SizedBox(width: 6),
                      _ProgressDot(isActive: false),
                      SizedBox(width: 6),
                      _ProgressDot(isActive: false),
                      SizedBox(width: 6),
                      _ProgressDot(isActive: true),
                    ],
                  ),
                const Spacer(),
                const SizedBox(width: 36),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Adicione Responsáveis',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Compartilhe os códigos abaixo para que outros familiares ou cuidadores possam ingressar no seu grupo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF8A8A8A)),
            ),
            const SizedBox(height: 32),
            _CodigoCard(
              titulo: 'Código para responsáveis e cuidadores',
              subtitulo:
                  'Compartilhe este código com cuidadores e responsáveis.',
              codigo: _codigoResponsavel,
              icon: Image.asset(
                'assets/images/cuidadores-Photoroom.png',
                width: 60,
                height: 60,
                fit: BoxFit.contain,
              ),
              color: const Color(0xFF4A94CF),
              onCompartilhar: () => _copiar(_codigoResponsavel),
            ),
            if (_temDependenteComApp && _codigoDependente != null) ...[
              const SizedBox(height: 20),
              _CodigoCard(
                titulo: 'Código para dependente',
                subtitulo:
                    'Compartilhe este código com o dependente para que ele também possa acessar o grupo.',
                codigo: _codigoDependente!,
                icon: Image.asset(
                  'assets/images/dependente-Photoroom.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                ),
                color: const Color(0xFF66BB6A),
                onCompartilhar: () => _copiar(_codigoDependente!),
              ),
            ],
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline, size: 20, color: Color(0xFF546E7A)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Seus dados pessoais são importantes. Compartilhe estes códigos apenas com quem ajudará nos cuidados.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF546E7A)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContentPage(),
                    ),
                    (route) => false,
                  );
                },
                child: Text(
                  widget.grupoIdExistente != null
                      ? 'Voltar ao grupo'
                      : 'Finalizar grupo',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4A94CF),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _CodigoCard extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final String codigo;
  final Widget icon;
  final Color color;
  final VoidCallback onCompartilhar;

  const _CodigoCard({
    required this.titulo,
    required this.subtitulo,
    required this.codigo,
    required this.icon,
    required this.color,
    required this.onCompartilhar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
          ),
          child: Column(
            children: [
              icon,
              const SizedBox(height: 16),
              Text(
                codigo,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  subtitulo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF757575),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onCompartilhar,
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text(
                    'Compartilhar código',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoadingGrupo extends StatelessWidget {
  const _LoadingGrupo();

  @override
  Widget build(BuildContext context) {
    return GradientScreenLayout(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A94CF)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Criando seu grupo...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErroGrupo extends StatelessWidget {
  final String mensagem;

  const _ErroGrupo({required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return GradientScreenLayout(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressDot extends StatelessWidget {
  const _ProgressDot({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? const Color(0xFF484848) : const Color(0xFFD9D9D9),
      ),
    );
  }
}
