import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../widgets/gradient_screen_layout.dart';
import 'create_dependent_page.dart';
import 'share_family_code_page.dart';

class AddDependentsPage extends StatefulWidget {
  final String nomeGrupo;
  final String descricaoGrupo;

  const AddDependentsPage({
    super.key,
    required this.nomeGrupo,
    required this.descricaoGrupo,
  });

  @override
  State<AddDependentsPage> createState() => _AddDependentsPageState();
}

class _AddDependentsPageState extends State<AddDependentsPage> {
  final List<DependenteData> _dependentes = [];

  String _iniciais(String nome) {
    final partes = nome.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nome.substring(0, nome.length >= 2 ? 2 : 1).toUpperCase();
  }

  Future<void> _abrirFormDependente() async {
    final resultado = await Navigator.push<DependenteData>(
      context,
      MaterialPageRoute(builder: (context) => const NewDependentPage()),
    );

    if (resultado != null) {
      setState(() => _dependentes.add(resultado));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScreenLayout(
      child: IntrinsicHeight(
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
                    border: Border.all(color: Colors.black54),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Spacer(),
                const Row(
                  children: [
                    _ProgressDot(isActive: false),
                    SizedBox(width: 6),
                    _ProgressDot(isActive: true),
                    SizedBox(width: 6),
                    _ProgressDot(isActive: false),
                    SizedBox(width: 6),
                    _ProgressDot(isActive: false),
                  ],
                ),
                const Spacer(),
                const SizedBox(width: 36),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Adicione Dependente',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Adicione os familiares que serão cuidados',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Color(0xFF8A8A8A)),
            ),
            const SizedBox(height: 28),
            ..._dependentes.asMap().entries.map((entry) {
              final i = entry.key;
              final d = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F3F3),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.12),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFE8C2EB),
                            ),
                            child: Center(
                              child: Text(
                                _iniciais(d.nome),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF9A2CA0),
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
                                  d.nome,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Dependente',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF8A8A8A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() => _dependentes.removeAt(i));
                            },
                            icon: SvgPicture.asset(
                              'assets/icons/Trash_Full.svg',
                              width: 22,
                              height: 22,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1, color: Color(0xFFE3E3E3)),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Vai usar o aplicativo?',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: d.usaApp
                                  ? const Color(0xFF34C759).withValues(
                                      alpha: 0.15)
                                  : const Color(0xFF9E9E9E).withValues(
                                      alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              d.usaApp ? 'Sim' : 'Não',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: d.usaApp
                                    ? const Color(0xFF34C759)
                                    : const Color(0xFF9E9E9E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const Spacer(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _abrirFormDependente,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF7F3F3),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Adicionar Dependente',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPersonsPage(
                        nomeGrupo: widget.nomeGrupo,
                        descricaoGrupo: widget.descricaoGrupo,
                        dependentes: _dependentes,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A94CF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Próximo passo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
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
        color: isActive ? Colors.black : const Color(0xFFBDBDBD),
      ),
    );
  }
}