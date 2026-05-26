import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class _Person {
  const _Person({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarColor,
    required this.initials,
  });

  final String id;
  final String name;
  final String role;
  final Color avatarColor;
  final String initials;
}

const _mockResponsaveis = [
  _Person(
    id: 'ga',
    name: 'Gabriel Augusto',
    role: 'Responsavel',
    avatarColor: AppColors.avatarPink,
    initials: 'GA',
  ),
  _Person(
    id: 'kg',
    name: 'Kauan Gabriel',
    role: 'Responsavel',
    avatarColor: AppColors.avatarBlue,
    initials: 'KG',
  ),
  _Person(
    id: 'lm',
    name: 'Leonidas Moreira',
    role: 'Responsavel',
    avatarColor: AppColors.avatarTeal,
    initials: 'LM',
  ),
];

const _mockDependentes = [
  _Person(
    id: 'im',
    name: 'Iago Messias',
    role: 'Dependente',
    avatarColor: AppColors.avatarBlue,
    initials: 'IM',
  ),
  _Person(
    id: 'gm',
    name: 'Gustavo Menezes',
    role: 'Dependente',
    avatarColor: AppColors.avatarTeal,
    initials: 'GM',
  ),
];

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final Set<String> _selectedResponsaveis = <String>{};
  final Set<String> _selectedDependentes = <String>{};

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: AppColors.textOnDark,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null) {
      return;
    }

    setState(() {
      _selectedDate = date;
      _errorMessage = null;
    });
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: AppColors.textOnDark,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null) {
      return;
    }

    setState(() {
      _selectedTime = time;
      _errorMessage = null;
    });
  }

  String get _formattedDate {
    if (_selectedDate == null) {
      return 'Selecionar data';
    }

    final date = _selectedDate!;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String get _formattedTime {
    if (_selectedTime == null) {
      return 'Selecionar hora';
    }

    final hour = _selectedTime!.hour.toString().padLeft(2, '0');
    final minute = _selectedTime!.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _toggleSelection(Set<String> selectedItems, String id, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedItems.add(id);
      } else {
        selectedItems.remove(id);
      }
      _errorMessage = null;
    });
  }

  void _saveTask() {
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      setState(() {
        _errorMessage = 'Preencha os campos obrigatorios.';
      });
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      setState(() {
        _errorMessage = 'Selecione data e hora.';
      });
      return;
    }

    if (_selectedResponsaveis.isEmpty) {
      setState(() {
        _errorMessage = 'Selecione pelo menos um responsavel.';
      });
      return;
    }

    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _selectedDate = null;
      _selectedTime = null;
      _selectedResponsaveis.clear();
      _selectedDependentes.clear();
      _errorMessage = null;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tarefa criada com sucesso.')));
  }

  InputDecoration _inputDecoration({
    required String hintText,
    int maxLines = 1,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      ),
      filled: true,
      fillColor: AppColors.cardBackground,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 18,
        vertical: maxLines == 1 ? 18 : 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.inputFocusBorder,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 132),
            children: [
              const _TaskHeader(),
              const SizedBox(height: 20),
              const Text(
                'Nova tarefa',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Organize um novo cuidado para o grupo familiar.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o nome da tarefa.';
                        }
                        return null;
                      },
                      decoration: _inputDecoration(
                        hintText: 'Digite o nome da tarefa',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      decoration: _inputDecoration(
                        hintText: 'Adicione detalhes da tarefa (opcional)',
                        maxLines: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _DateTimeButton(
                      label: _formattedDate,
                      isSelected: _selectedDate != null,
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateTimeButton(
                      label: _formattedTime,
                      isSelected: _selectedTime != null,
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _PeopleCard(
                title: 'Responsaveis',
                people: _mockResponsaveis,
                selectedIds: _selectedResponsaveis,
                onChanged: (id, isSelected) {
                  _toggleSelection(_selectedResponsaveis, id, isSelected);
                },
              ),
              const SizedBox(height: 14),
              _PeopleCard(
                title: 'Dependentes',
                people: _mockDependentes,
                selectedIds: _selectedDependentes,
                onChanged: (id, isSelected) {
                  _toggleSelection(_selectedDependentes, id, isSelected);
                },
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ),
              SizedBox(
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.confirmGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  onPressed: _saveTask,
                  child: const Text(
                    'Confirmar',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textOnDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskHeader extends StatelessWidget {
  const _TaskHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(21),
          ),
          child: const Icon(
            Icons.playlist_add_circle_outlined,
            color: AppColors.primaryBlue,
            size: 24,
          ),
        ),
        const Expanded(
          child: Text(
            'AgendaCare',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppColors.primaryBlue,
          ),
        ),
      ],
    );
  }
}

class _DateTimeButton extends StatelessWidget {
  const _DateTimeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(color: AppColors.primaryBlue, width: 1.4)
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _PeopleCard extends StatelessWidget {
  const _PeopleCard({
    required this.title,
    required this.people,
    required this.selectedIds,
    required this.onChanged,
  });

  final String title;
  final List<_Person> people;
  final Set<String> selectedIds;
  final void Function(String id, bool isSelected) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: List.generate(people.length, (index) {
              final person = people[index];
              final isLast = index == people.length - 1;

              return _PersonTile(
                person: person,
                isChecked: selectedIds.contains(person.id),
                showDivider: !isLast,
                onChanged: (value) {
                  onChanged(person.id, value ?? false);
                },
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({
    required this.person,
    required this.isChecked,
    required this.showDivider,
    required this.onChanged,
  });

  final _Person person;
  final bool isChecked;
  final bool showDivider;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: person.avatarColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  person.initials,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textOnDark,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      person.role,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isChecked,
                  onChanged: onChanged,
                  activeColor: AppColors.primaryBlue,
                  checkColor: AppColors.textOnDark,
                  side: const BorderSide(
                    color: AppColors.checkboxBorder,
                    width: 1.6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            indent: 68,
            endIndent: 14,
            color: AppColors.divider,
          ),
      ],
    );
  }
}
