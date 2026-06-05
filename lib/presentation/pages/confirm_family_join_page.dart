import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/gradient_screen_layout.dart';
import 'family_welcome_page.dart';

class ConfirmFamilyJoin extends StatefulWidget {
  final String grupoId;
  final Map<String, dynamic> grupoData;
  final List<Map<String, dynamic>> dependentes;
  final String papel;

  const ConfirmFamilyJoin({
    super.key,
    required this.grupoId,
    required this.grupoData,
    required this.dependentes,
    required this.papel,
  });

  @override
  State<ConfirmFamilyJoin> createState() => _ConfirmFamilyJoinState();
}

class _ConfirmFamilyJoinState extends State<ConfirmFamilyJoin> {
  bool _isLoading = false;
  String? _errorMessage;
  String _adminName = '';

  @override
  void initState() {
    super.initState();
    _carregarAdmin();
  }

  Future<void> _carregarAdmin() async {
    try {
      final db = FirebaseFirestore.instance;
      final criadorId = widget.grupoData['criadorId'] as String? ?? '';
      if (criadorId.isEmpty) return;

      final membrosSnap = await db
          .collection('grupos')
          .doc(widget.grupoId)
          .collection('membros')
          .doc(criadorId)
          .get();

      if (!mounted) return;
      if (membrosSnap.exists) {
        setState(() {
          _adminName = membrosSnap.data()?['nome'] ?? '';
        });
      }
    } catch (_) {}
  }

  Future<void> _confirmarEntrada() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuário não autenticado.');

      final db = FirebaseFirestore.instance;

      final nomeUsuario = (user.displayName?.trim().isNotEmpty ?? false)
          ? user.displayName!.trim()
          : (user.email ?? '').trim();

      await db
          .collection('grupos')
          .doc(widget.grupoId)
          .collection('membros')
          .doc(user.uid)
          .set({
            'uid': user.uid,
            'papel': widget.papel,
            'nome': nomeUsuario,
            'email': user.email ?? '',
            'criado_por': user.email ?? '',
            'entradaEm': FieldValue.serverTimestamp(),
          });

      await db.collection('usuarios').doc(user.uid).set({
        'grupoId': widget.grupoId,
        'papel': widget.papel,
        'nome': nomeUsuario,
      }, SetOptions(merge: true));

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FamilyWelcomePage()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _errorMessage = 'Erro ao entrar no grupo. Tente novamente.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _iniciais(String nome) {
    final partes = nome.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nome.substring(0, nome.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final nomeGrupo = widget.grupoData['nome'] as String? ?? '';
    final descricao = widget.grupoData['descricao'] as String? ?? '';
    final letraGrupo = nomeGrupo.isNotEmpty ? nomeGrupo[0].toUpperCase() : 'G';

    return GradientScreenLayout(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom -
                48,
          ),
          child: IntrinsicHeight(
            child: Column(
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
                          _ProgressDot(isActive: true),
                          SizedBox(width: 4),
                          _ProgressDot(isActive: false),
                        ],
                      ),
                    ),
                    const SizedBox(width: 34),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Confirmar entrada',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Você está prestes a entrar na família',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF7E7777),
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.06),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF9B59B6),
                            ),
                            child: Center(
                              child: Text(
                                letraGrupo,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nomeGrupo,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Você está prestes a entrar nesta família.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF7E7777),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      const SizedBox(height: 16),
                      if (_adminName.isNotEmpty) ...[
                        Row(
                          children: [
                            _buildAvatar(
                              _iniciais(_adminName),
                              const Color(0xFF4195CC),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _adminName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                const Text(
                                  'Administrador',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF7E7777),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (descricao.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            descricao,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF7E7777),
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (widget.dependentes.isNotEmpty) ...[
                        Text(
                          'Dependentes (${widget.dependentes.length})',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...widget.dependentes.map((d) {
                          final nome = d['nome'] as String? ?? '';
                          return _DependenteItem(
                            iniciais: _iniciais(nome),
                            nome: nome,
                            papel: 'Dependente',
                          );
                        }),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tudo certo? Deseja continuar?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
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
                const Spacer(),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _confirmarEntrada,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(
                      0xFF4CAF50,
                    ).withValues(alpha: 0.7),
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Confirmar entrada',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE57373),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String iniciais, Color cor) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(shape: BoxShape.circle, color: cor),
      child: Center(
        child: Text(
          iniciais,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
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

class _DependenteItem extends StatelessWidget {
  const _DependenteItem({
    required this.iniciais,
    required this.nome,
    required this.papel,
  });

  final String iniciais;
  final String nome;
  final String papel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 245, 148, 148),
            ),
            child: Center(
              child: Text(
                iniciais,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  papel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7E7777),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black26),
        ],
      ),
    );
  }
}
