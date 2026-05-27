import 'package:flutter/material.dart';

import '../widgets/gradient_screen_layout.dart';
import 'family_welcome_page.dart';

const _familyName = 'Familia Carvalho';
const _familyDescription =
    'Grupo com intuito de cuidar da rotina do avô Nilton, seus remedios e medicos';
const _adminName = 'Gabriel Ramos';

const _dependentes = [
  {'iniciais': 'IM', 'nome': 'Iago Messias', 'papel': 'Dependente'},
  {'iniciais': 'GM', 'nome': 'Gustavo Menezes', 'papel': 'Dependente'},
];

class ConfirmFamilyJoin extends StatelessWidget {
  const ConfirmFamilyJoin({super.key});

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
                          child: const Center(
                            child: Text(
                              'C',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _familyName,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
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
                    Row(
                      children: [
                        _buildAvatar('GR', const Color(0xFF4195CC)),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _adminName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            Text(
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        _familyDescription,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7E7777),
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Dependentes (${_dependentes.length})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._dependentes.map(
                      (d) => _DependenteItem(
                        iniciais: d['iniciais']!,
                        nome: d['nome']!,
                        papel: d['papel']!,
                      ),
                    ),
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
            ],
          ),
          Column(
            children: [
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FamilyWelcomePage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Confirmar entrada',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
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
        ],
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