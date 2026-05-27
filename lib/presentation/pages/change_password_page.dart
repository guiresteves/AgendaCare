import 'package:flutter/material.dart';

import '../widgets/gradient_screen_layout.dart';

const _buttonColor = Color(0xFF4195CC);
const _mutedTextColor = Color(0xFF7E7777);

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _alterar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _successMessage = 'Senha alterada com sucesso!';
    });
  }

  String? _validarSenhaAtual(String? value) {
    if ((value ?? '').isEmpty) return 'Informe sua senha atual.';
    return null;
  }

  String? _validarNovaSenha(String? value) {
    if ((value ?? '').isEmpty) return 'Informe a nova senha.';
    if ((value ?? '').length < 6) return 'A senha precisa ter pelo menos 6 caracteres.';
    return null;
  }

  String? _validarConfirmacao(String? value) {
    if ((value ?? '').isEmpty) return 'Confirme a nova senha.';
    if (value != _newPasswordController.text) return 'As senhas não coincidem.';
    return null;
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xFF9E9E9E),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: _buttonColor, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
      ),
    );
  }

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
            'Alterar Senha',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 60),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  validator: _validarSenhaAtual,
                  decoration: _inputDecoration(hintText: 'Senha atual'),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  validator: _validarNovaSenha,
                  decoration: _inputDecoration(hintText: 'Nova Senha'),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: _validarConfirmacao,
                  onFieldSubmitted: (_) => _alterar(),
                  decoration: _inputDecoration(hintText: 'Confirmar nova senha'),
                ),
              ],
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 18),
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
          if (_successMessage != null) ...[
            const SizedBox(height: 18),
            Text(
              _successMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4CAF50),
              ),
            ),
          ],
          const SizedBox(height: 60),
          ElevatedButton(
            onPressed: _isLoading ? null : _alterar,
            style: ElevatedButton.styleFrom(
              backgroundColor: _buttonColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _buttonColor.withValues(alpha: 0.7),
              minimumSize: const Size.fromHeight(52),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : const Text(
              'Alterar',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}