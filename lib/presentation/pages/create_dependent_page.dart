import 'package:flutter/material.dart';

import '../widgets/gradient_screen_layout.dart';

class DependenteData {
  final String nome;
  final bool usaApp;

  const DependenteData({
    required this.nome,
    required this.usaApp,
  });
}

class NewDependentPage extends StatefulWidget {
  const NewDependentPage({super.key});

  @override
  State<NewDependentPage> createState() => _NewDependentPageState();
}

class _NewDependentPageState extends State<NewDependentPage> {
  final TextEditingController _nomeController = TextEditingController();
  bool _usaApp = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  void _adicionar() {
    final nome = _nomeController.text.trim();

    if (nome.isEmpty) {
      setState(() => _errorMessage = 'Informe o nome do dependente.');
      return;
    }

    Navigator.pop(
      context,
      DependenteData(nome: nome, usaApp: _usaApp),
    );
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
                  width: 34,
                  height: 34,
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
              ],
            ),
            const SizedBox(height: 26),
            const Text(
              'Novo Dependente',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Adicione quem vai ser cuidado',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Color(0xFF8C8C8C)),
            ),
            const SizedBox(height: 34),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _nomeController,
                style: const TextStyle(fontSize: 16, color: Colors.black),
                onChanged: (_) {
                  if (_errorMessage != null) {
                    setState(() => _errorMessage = null);
                  }
                },
                decoration: const InputDecoration(
                  hintText: 'Nome do Dependente',
                  hintStyle: TextStyle(fontSize: 16, color: Colors.black87),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.15),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Vai usar o aplicativo',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  SizedBox(
                    width: 52,
                    height: 30,
                    child: Switch(
                      value: _usaApp,
                      onChanged: (val) {
                        setState(() {
                          _usaApp = val;
                          _errorMessage = null;
                        });
                      },
                      activeTrackColor: const Color(0xFF45C85A),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey,
                    ),
                  ),
                ],
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
            const SizedBox(height: 18),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'Um dependente com login pode acessar o aplicativo para ver as próprias tarefas. Ele não pode criar novas tarefas, modificar tarefas existentes ou alterar configurações da família.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Color(0xFF546E7A),
                ),
              ),
            ),
            const Spacer(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _adicionar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4894D0),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: const Text(
                  'Adicionar Dependente',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}