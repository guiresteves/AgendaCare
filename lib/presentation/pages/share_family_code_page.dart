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

  const AddPersonsPage({
    super.key,
    required this.nomeGrupo,
    required this.descricaoGrupo,
    required this.dependentes,
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
    final parte1 =
        List.generate(3, (_) => chars[rand.nextInt(chars.length)]).join();
    final parte2 =
        List.generate(3, (_) => chars[rand.nextInt(chars.length)]).join();
    return '$parte1-$parte2';
  }

  Future<void> _criarGrupo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuário não autenticado.');

      final db = FirebaseFirestore.instance;

      final codigoResponsavel = _gerarCodigo();
      final temDependenteComApp =
          widget.dependentes.any((d) => d.usaApp);
      final codigoDependente =
          temDependenteComApp ? _gerarCodigo() : null;

      final grupoRef = await db.collection('grupos').add({
        'nome': widget.nomeGrupo,
        'descricao': widget.descricaoGrupo,
        'criadoEm': FieldValue.serverTimestamp(),
        'criadorId': user.uid,
        'codigoResponsavel': codigoResponsavel,
        if (codigoDependente != null) 'codigoDependente': codigoDependente,
      });

      await db
          .collection('usuarios')
          .doc(user.uid)
          .set({'grupoId': grupoRef.id}, SetOptions(merge: true));

      await db
          .collection('grupos')
          .doc(grupoRef.id)
          .collection('membros')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'papel': 'responsavel',
        'nome': user.displayName ?? '',
        'email': user.email ?? '',
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
          if (dep.email != null) 'email': dep.email,
          'criadoEm': FieldValue.serverTimestamp(),
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

  void _compartilhar(String codigo) {
    _copiar(codigo);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.pop(context),
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
                  const Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ProgressDot(isActive: false),
                        SizedBox(width: 4),
                        _ProgressDot(isActive: false),
                        SizedBox(width: 4),
                        _ProgressDot(isActive: false),
                        SizedBox(width: 4),
                        _ProgressDot(isActive: true),
                      ],
                    ),
                  ),
                  const SizedBox(width: 34),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Adicione Responsaveis',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Compartilhe os códigos abaixo para que outros familiares ou cuidadores possam ingressar no seu grupo.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF7E7777),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              _CodigoCard(
                titulo: 'Código para responsáveis e cuidadores',
                codigo: _codigoResponsavel,
                onCopiar: () => _copiar(_codigoResponsavel),
                onCompartilhar: () => _compartilhar(_codigoResponsavel),
              ),
              if (_temDependenteComApp && _codigoDependente != null) ...[
                const SizedBox(height: 16),
                _CodigoCard(
                  titulo: 'Código para dependentes',
                  codigo: _codigoDependente!,
                  onCopiar: () => _copiar(_codigoDependente!),
                  onCompartilhar: () => _compartilhar(_codigoDependente!),
                ),
              ],
              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Seus dados pessoais sao importantes. Compartilhe estes códigos apenas com quem ajudara nos cuidados.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF546E7A),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContentPage(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Finalizar grupo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4195CC),
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFF4195CC),
                  ),
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

class _CodigoCard extends StatelessWidget {
  final String titulo;
  final String codigo;
  final VoidCallback onCopiar;
  final VoidCallback onCompartilhar;

  const _CodigoCard({
    required this.titulo,
    required this.codigo,
    required this.onCopiar,
    required this.onCompartilhar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onCopiar,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              codigo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: onCompartilhar,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4195CC),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Compartilhar código',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4195CC)),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Criando seu grupo...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Isso vai levar só um momento',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black.withValues(alpha: 0.5),
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
            const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
            const SizedBox(height: 20),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4195CC),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
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