import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

const _screenBackground = Color(0xFFF2F2F7);
const _cardBackground = Colors.white;
const _dividerColor = Color(0xFFE2E2E8);
const _mutedTextColor = Color(0xFF9A9AA3);
const _saveButtonColor = Color(0xFF71C26B);
const _avatarBackground = Color(0xFFF2C1F3);
const _avatarTextColor = Color(0xFF9F1D8B);

class EditableProfileDetails {
  const EditableProfileDetails({
    required this.name,
    required this.email,
    this.birthDate,
    this.gender,
    this.nationality,
    this.postalCode,
  });

  final String name;
  final String email;
  final String? birthDate;
  final String? gender;
  final String? nationality;
  final String? postalCode;

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'AC';
    }

    if (parts.length == 1) {
      final single = parts.first.toUpperCase();
      return single.length >= 2 ? single.substring(0, 2) : single;
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  EditableProfileDetails copyWith({
    String? name,
    String? email,
    String? birthDate,
    String? gender,
    String? nationality,
    String? postalCode,
  }) {
    return EditableProfileDetails(
      name: name ?? this.name,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      nationality: nationality ?? this.nationality,
      postalCode: postalCode ?? this.postalCode,
    );
  }

  factory EditableProfileDetails.fromUser(User? user) {
    return EditableProfileDetails.fromUserData(user, null);
  }

  factory EditableProfileDetails.fromUserData(
    User? user,
    Map<String, dynamic>? data,
  ) {
    final email = user?.email?.trim();
    final storedEmail = (data?['email'] as String?)?.trim();
    final resolvedEmail = (storedEmail != null && storedEmail.isNotEmpty)
        ? storedEmail
        : (email != null && email.isNotEmpty)
        ? email
        : '';
    final displayName = user?.displayName?.trim();
    final storedName = (data?['nome'] as String?)?.trim();
    final resolvedName = (storedName != null && storedName.isNotEmpty)
        ? storedName
        : (displayName != null && displayName.isNotEmpty)
        ? displayName
        : _fallbackNameFromEmail(resolvedEmail);

    return EditableProfileDetails(
      name: resolvedName,
      email: resolvedEmail,
      birthDate: data?['dataNascimento'] as String?,
      gender: data?['genero'] as String?,
      nationality: data?['nacionalidade'] as String?,
      postalCode: data?['cep'] as String?,
    );
  }
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.initialProfile});

  final EditableProfileDetails initialProfile;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameController;

  late String? _birthDate;
  late String? _gender;
  late String? _nationality;
  late String? _postalCode;

  bool _isSaving = false;
  String? _nameError;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialProfile.name);
    _birthDate = widget.initialProfile.birthDate;
    _gender = widget.initialProfile.gender;
    _nationality = widget.initialProfile.nationality;
    _postalCode = widget.initialProfile.postalCode;
    _nameController.addListener(_handleNameChanged);
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_handleNameChanged)
      ..dispose();
    super.dispose();
  }

  EditableProfileDetails get _draftProfile {
    return widget.initialProfile.copyWith(
      name: _nameController.text.trim(),
      birthDate: _birthDate,
      gender: _gender,
      nationality: _nationality,
      postalCode: _postalCode,
    );
  }

  void _handleNameChanged() {
    if (!mounted) {
      return;
    }

    setState(() {
      if (_nameError != null && _nameController.text.trim().isNotEmpty) {
        _nameError = null;
      }
    });
  }

  Future<void> _pickBirthDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Data de nascimento',
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    setState(() {
      _birthDate = _formatDate(pickedDate);
    });
  }

  Future<void> _selectGender() async {
    final selectedGender = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        const options = ['Masculino', 'Feminino', 'Outro'];

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD7D7DD),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Genero',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              for (final option in options)
                ListTile(
                  title: Text(
                    option,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: option == _gender
                      ? const Icon(Icons.check_rounded, color: _saveButtonColor)
                      : null,
                  onTap: () => Navigator.pop(context, option),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (selectedGender == null || !mounted) {
      return;
    }

    setState(() {
      _gender = selectedGender;
    });
  }

  Future<void> _editNationality() async {
    final result = await _promptTextValue(
      title: 'Nacionalidade',
      initialValue: _nationality,
      hintText: 'Ex.: Brasileira',
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _nationality = result;
    });
  }

  Future<void> _editPostalCode() async {
    final result = await _promptTextValue(
      title: 'CEP',
      initialValue: _postalCode,
      hintText: '00000-000',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9-]'))],
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _postalCode = result;
    });
  }

  Future<String?> _promptTextValue({
    required String title,
    required String? initialValue,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) async {
    final controller = TextEditingController(text: initialValue ?? '');

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          content: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _saveButtonColor),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _saveButtonColor),
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return result;
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();

    final trimmedName = _nameController.text.trim();
    if (trimmedName.isEmpty) {
      setState(() {
        _nameError = 'Informe seu nome.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    final updatedProfile = _draftProfile;
    final user = FirebaseAuth.instance.currentUser;

    try {
      if (user == null) {
        throw FirebaseAuthException(
          code: 'not-authenticated',
          message: 'Usuario nao autenticado.',
        );
      }

      if (trimmedName != (user.displayName ?? '').trim()) {
        try {
          await user.updateDisplayName(trimmedName);
        } on FirebaseAuthException {
          // Firestore remains the app profile source even if Auth sync fails.
        }
      }

      final db = FirebaseFirestore.instance;
      final userRef = db.collection('usuarios').doc(user.uid);
      final currentProfile = await userRef.get();
      final grupoId = currentProfile.data()?['grupoId'] as String?;

      await userRef.set({
        'nome': trimmedName,
        'email': user.email ?? updatedProfile.email,
        'dataNascimento': updatedProfile.birthDate,
        'genero': updatedProfile.gender,
        'nacionalidade': updatedProfile.nationality,
        'cep': updatedProfile.postalCode,
        'atualizadoEm': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (grupoId != null && grupoId.isNotEmpty) {
        await db
            .collection('grupos')
            .doc(grupoId)
            .collection('membros')
            .doc(user.uid)
            .set({
              'nome': trimmedName,
              'email': user.email ?? updatedProfile.email,
            }, SetOptions(merge: true));
      }

      if (!mounted) {
        return;
      }

      Navigator.pop(context, updatedProfile);
    } on FirebaseException catch (error) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveError = error.message ?? 'Nao foi possivel salvar o perfil.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveError = 'Nao foi possivel salvar o perfil.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _draftProfile;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: _screenBackground,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(14, 8, 14, bottomInset + 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => Navigator.maybePop(context),
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
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Editar Perfil',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, thickness: 1, color: _dividerColor),
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: _avatarBackground,
                    child: Text(
                      profile.initials,
                      style: const TextStyle(
                        color: _avatarTextColor,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile.name.isEmpty ? 'Seu nome' : profile.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _ProfileCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nameController,
                                textInputAction: TextInputAction.next,
                                cursorColor: Colors.black,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Seu nome',
                                  hintStyle: TextStyle(
                                    color: _mutedTextColor,
                                    fontSize: 17,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            AnimatedOpacity(
                              opacity: _nameController.text.trim().isEmpty
                                  ? 0
                                  : 1,
                              duration: const Duration(milliseconds: 180),
                              child: IgnorePointer(
                                ignoring: _nameController.text.trim().isEmpty,
                                child: IconButton(
                                  onPressed: () => _nameController.clear(),
                                  icon: const Icon(
                                    Icons.cancel_rounded,
                                    color: Color(0xFFC6C6CC),
                                    size: 22,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 24,
                                    minHeight: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: _dividerColor,
                        ),
                        const SizedBox(height: 14),
                        _LabeledActionRow(
                          label: 'Data de Nascimento',
                          value: _birthDate ?? '00/00/0000',
                          onTap: _pickBirthDate,
                        ),
                      ],
                    ),
                  ),
                  if (_nameError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _nameError!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (_saveError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _saveError!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  _SingleLineActionCard(text: profile.email),
                  const SizedBox(height: 14),
                  _SingleLineActionCard(
                    text: _gender ?? 'Genero',
                    onTap: _selectGender,
                  ),
                  const SizedBox(height: 14),
                  _ProfileCard(
                    child: Column(
                      children: [
                        _LabeledActionRow(
                          label: 'Nacionalidade',
                          value: _nationality ?? 'Selecionar',
                          valueColor: _nationality == null
                              ? _mutedTextColor
                              : Colors.black,
                          onTap: _editNationality,
                        ),
                        const SizedBox(height: 14),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: _dividerColor,
                        ),
                        const SizedBox(height: 14),
                        _LabeledActionRow(
                          label: 'CEP',
                          value: _postalCode ?? '0000-000',
                          valueColor: _postalCode == null
                              ? _mutedTextColor
                              : Colors.black,
                          onTap: _editPostalCode,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 34),
                  SizedBox(
                    height: 50,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _saveButtonColor,
                        disabledBackgroundColor: _saveButtonColor.withValues(
                          alpha: 0.7,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      onPressed: _isSaving ? null : _saveProfile,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Salvar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(26),
      ),
      child: child,
    );
  }
}

class _SingleLineActionCard extends StatelessWidget {
  const _SingleLineActionCard({required this.text, this.onTap});

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Ink(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: _cardBackground,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                const _ChevronIcon(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LabeledActionRow extends StatelessWidget {
  const _LabeledActionRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.valueColor = _mutedTextColor,
  });

  final String label;
  final String value;
  final Color valueColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: valueColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const _ChevronIcon(),
          ],
        ),
      ),
    );
  }
}

class _ChevronIcon extends StatelessWidget {
  const _ChevronIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/chevron_right_md.svg',
      width: 22,
      height: 22,
      colorFilter: const ColorFilter.mode(Color(0xFFC8C8CE), BlendMode.srcIn),
    );
  }
}

String _fallbackNameFromEmail(String email) {
  if (email.trim().isEmpty) {
    return 'Usuario AgendaCare';
  }

  final localPart = email.split('@').first;
  final words = localPart
      .replaceAll(RegExp(r'[._-]+'), ' ')
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map(_capitalizeWord)
      .toList();

  if (words.isEmpty) {
    return 'Usuario AgendaCare';
  }

  return words.join(' ');
}

String _capitalizeWord(String value) {
  if (value.isEmpty) {
    return value;
  }

  return '${value[0].toUpperCase()}${value.substring(1).toLowerCase()}';
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString().padLeft(4, '0');
  return '$day/$month/$year';
}
