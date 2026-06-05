import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/agenda_scaffold.dart';
import 'share_family_code_page.dart';
import 'create_dependent_page.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  String? _grupoId;
  String? _criadorId;
  bool _carregando = true;
  String? _erro;
  String _currentUid = '';

  @override
  void initState() {
    super.initState();
    _carregarGrupoId();
  }

  Future<void> _carregarGrupoId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _carregando = false;
          _erro = 'Usuário não autenticado.';
        });
        return;
      }

      _currentUid = user.uid;

      final usuarioDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      final grupoId = usuarioDoc.data()?['grupoId'] as String?;

      if (!mounted) return;

      if (grupoId == null) {
        setState(() {
          _carregando = false;
        });
        return;
      }

      final grupoDoc = await FirebaseFirestore.instance
          .collection('grupos')
          .doc(grupoId)
          .get();

      if (!mounted) return;

      setState(() {
        _grupoId = grupoId;
        _criadorId = grupoDoc.data()?['criadorId'] as String?;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
        _erro = 'Erro ao carregar grupo.';
      });
    }
  }

  String _iniciais(String nome) {
    final trimmed = nome.trim();
    if (trimmed.isEmpty) return '?';
    final partes = trimmed.split(' ');
    if (partes.length >= 2 && partes[1].isNotEmpty) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1).toUpperCase();
  }

  Future<String> _resolverNome(Map<String, dynamic> dados) async {
    final nome = (dados['nome'] as String? ?? '').trim();
    if (nome.isNotEmpty) return nome;

    final uid = dados['uid'] as String?;
    if (uid == null) return '';

    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();
      return (doc.data()?['nome'] as String? ?? '').trim();
    } catch (_) {
      return '';
    }
  }

  Future<void> _removerMembro(String uid) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remover membro'),
        content: const Text(
            'Tem certeza que deseja remover este membro do grupo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmar != true || _grupoId == null) return;

    try {
      final db = FirebaseFirestore.instance;
      await db
          .collection('grupos')
          .doc(_grupoId)
          .collection('membros')
          .doc(uid)
          .delete();

      await db.collection('usuarios').doc(uid).set(
        {'grupoId': FieldValue.delete()},
        SetOptions(merge: true),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao remover membro.')),
      );
    }
  }

  void _irParaCodigos() {
    if (_grupoId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPersonsPage(
          nomeGrupo: '',
          descricaoGrupo: '',
          dependentes: const [],
          grupoIdExistente: _grupoId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const AgendaScaffold(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4195CC)),
          ),
        ),
      );
    }

    if (_erro != null || _grupoId == null) {
      return AgendaScaffold(
        child: Center(
          child: Text(
            _erro ?? 'Você não pertence a nenhum grupo.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Color(0xFF7E7777)),
          ),
        ),
      );
    }

    final isCriador = _currentUid == _criadorId;

    return AgendaScaffold(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Grupo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 5),
            const Text(
              'Veja e organize quem cuida, e quem é cuidado no seu grupo\nfamiliar',
              style: TextStyle(
                color: agendaMutedText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 32),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('grupos')
                  .doc(_grupoId)
                  .collection('membros')
                  .snapshots(),
              builder: (context, membrosSnap) {
                final docs = membrosSnap.data?.docs ?? [];
                final responsaveisDocs = docs
                    .where((d) =>
                        (d.data() as Map<String, dynamic>)['papel'] ==
                        'responsavel')
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(
                      title: 'Responsáveis',
                      onAdd: isCriador ? _irParaCodigos : null,
                    ),
                    const SizedBox(height: 13),
                    if (responsaveisDocs.isEmpty)
                      const _EmptyState(mensagem: 'Nenhum responsável ainda.'),
                    if (responsaveisDocs.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x24000000),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: responsaveisDocs.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            indent: 18,
                            endIndent: 18,
                            color: Color(0xFFE6E6E6),
                          ),
                          itemBuilder: (_, i) {
                            final data = responsaveisDocs[i].data()
                                as Map<String, dynamic>;
                            final uid = data['uid'] as String? ?? '';
                            final nome = (data['nome'] as String? ?? '').trim();
                            final nomeExibir =
                                nome.isNotEmpty ? nome : 'Responsável';
                            final podRemover =
                                isCriador && uid != _currentUid;

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 5),
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundColor: const Color(0xFFF6CDFF),
                                child: Text(
                                  _iniciais(nomeExibir),
                                  style: const TextStyle(
                                    color: Color(0xFF9E1C8B),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              title: Text(
                                nomeExibir,
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w700),
                              ),
                              subtitle: const Text(
                                'Responsável',
                                style: TextStyle(
                                    color: agendaMutedText, fontSize: 13),
                              ),
                              trailing: podRemover
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () => _removerMembro(uid),
                                    )
                                  : null,
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('grupos')
                  .doc(_grupoId)
                  .collection('dependentes')
                  .snapshots(),
              builder: (context, dependentesSnap) {
                final docs = dependentesSnap.data?.docs ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(
                      title: 'Dependentes',
                      onAdd: isCriador ? _irParaCodigos : null,
                    ),
                    const SizedBox(height: 13),
                    if (docs.isEmpty)
                      const _EmptyState(mensagem: 'Nenhum dependente ainda.'),
                    if (docs.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x24000000),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            indent: 18,
                            endIndent: 18,
                            color: Color(0xFFE6E6E6),
                          ),
                          itemBuilder: (_, i) {
                            final data =
                                docs[i].data() as Map<String, dynamic>;
                            final nome = (data['nome'] as String? ?? '').trim();
                            final nomeExibir =
                                nome.isNotEmpty ? nome : 'Dependente';

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 5),
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundColor: const Color(0xFF94C4F5),
                                child: Text(
                                  _iniciais(nomeExibir),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              title: Text(
                                nomeExibir,
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w700),
                              ),
                              subtitle: const Text(
                                'Dependente',
                                style: TextStyle(
                                    color: agendaMutedText, fontSize: 13),
                              ),
                              trailing: null,
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String mensagem;

  const _EmptyState({required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        mensagem,
        style: const TextStyle(fontSize: 14, color: agendaMutedText),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    required this.onAdd,
  });

  final String title;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF3C3C43),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        if (onAdd != null)
          SizedBox(
            height: 30,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: agendaBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onPressed: onAdd,
              child: const Text(
                'Adicionar',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
  }
}