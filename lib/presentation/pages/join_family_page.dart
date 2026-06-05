import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/gradient_screen_layout.dart';
import 'confirm_family_join_page.dart';

class JoinFamilyPage extends StatefulWidget {
  const JoinFamilyPage({super.key});

  @override
  State<JoinFamilyPage> createState() => _JoinFamilyPageState();
}

class _JoinFamilyPageState extends State<JoinFamilyPage> {
  final TextEditingController _codigoController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _buscarGrupo() async {
    final codigo = _codigoController.text.trim().toUpperCase();

    if (codigo.isEmpty) {
      setState(() => _errorMessage = 'Informe o código de acesso.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuário não autenticado.');

      final db = FirebaseFirestore.instance;

      final usuarioDoc = await db.collection('usuarios').doc(user.uid).get();
      if (usuarioDoc.exists && usuarioDoc.data()?['grupoId'] != null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'Você já pertence a um grupo.';
        });
        return;
      }

      QuerySnapshot query = await db
          .collection('grupos')
          .where('codigoResponsavel', isEqualTo: codigo)
          .limit(1)
          .get();

      String papel = 'responsavel';

      if (query.docs.isEmpty) {
        query = await db
            .collection('grupos')
            .where('codigoDependente', isEqualTo: codigo)
            .limit(1)
            .get();
        papel = 'dependente';
      }

      if (query.docs.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'Código inválido. Verifique e tente novamente.';
        });
        return;
      }

      final grupoDoc = query.docs.first;
      final grupoData = grupoDoc.data() as Map<String, dynamic>;

      final dependentesSnap = await db
          .collection('grupos')
          .doc(grupoDoc.id)
          .collection('dependentes')
          .get();

      final dependentes = dependentesSnap.docs
          .map((d) => d.data())
          .toList();

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmFamilyJoin(
            grupoId: grupoDoc.id,
            grupoData: grupoData,
            dependentes: dependentes,
            papel: papel,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Erro ao buscar grupo. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                        _ProgressDot(isActive: true),
                        SizedBox(width: 4),
                        _ProgressDot(isActive: false),
                        SizedBox(width: 4),
                        _ProgressDot(isActive: false),
                      ],
                    ),
                  ),
                  const SizedBox(width: 34),
                ],
              ),
              const SizedBox(height: 38),
              const Text(
                'Entrar na Família',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Digite o código de acesso que você recebeu do administrador da família',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF7E7777),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Código de acesso',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _codigoController,
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() => _errorMessage = null);
                    }
                  },
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 5,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'X7K-9P2',
                    hintStyle: TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: Color(0xFFC7C7CC),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 14,
                    ),
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF4195CC),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFF4195CC),
                      decorationThickness: 1.2,
                    ),
                  ),
                  child: const Text('Onde encontro meu código?'),
                ),
              ),
            ],
          ),
          Column(
            children: [
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _buscarGrupo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4195CC),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFF4195CC).withValues(alpha: 0.7),
                  minimumSize: const Size.fromHeight(56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Entrar na Família',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
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