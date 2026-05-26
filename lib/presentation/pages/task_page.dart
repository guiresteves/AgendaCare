import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

// Modelo de dados para representar uma pessoa (cuidador ou paciente)

class _Person {
    final String name;
    final String role;
    final String avatarColor;
    final String initials;

    _Person({
        required this.name,
        required this.role,
        required this.avatarColor,
        required this.initials,
    });
}

// Dados mockados (Responsáveis e Dependentes)

final _mockResponsaveis = [
    _Person(
        name: 'Gabriel Augusto',
        role: 'Responsável',
        avatarColor: AppColors,
        initials: 'GA',
    ),
    _Person(
        name: 'Kauan Gabriel',
        role: 'Responsável',
        avatarColor: AppColors,
        initials: 'KG',
    ),
    _Person(
        name: 'Leonidas Moreira',
        role: 'Responsável',
        avatarColor: AppColors.avatarPink,
        initials: 'LM',
    ),
];

final _mockDependentes = [
    _Person(
        name: 'Iago Messias',
        role: 'Dependente',
        avatarColor: AppColors.avatarPurple,
        initials: 'IM',
    ),
    _Person(
        name: 'Gustavo Menezes',
        role: 'Dependente',
        avatarColor: AppColors.avatarGreen,
        initials: 'GM',
    ),
];

// Página de Tarefas

class AddTaskPage extends StatelessWidget {
    const AddTaskPage({super.key});

    @override
    State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
    final _formKey = GlobalKey<FormState>();
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();

    DateTime? _selectedDate;
    TimeOfDay? _selectedTime;

    final List<_Person> _selectedResponsaveis = {};
    final List<_Person> _selectedDependentes = {};

    String? _errorMessage;

    @override
    void dispose() {
        _titleController.dispose();
        _descriptionController.dispose();
        super.dispose();
    }

    // Selecionar Data e Hora

    Future<void> _selectDate() async {
        final now = DateTime.now();
        final selected = await showDatePicker(
            context: context,
            initialDate: _selectedDate ?? now,
            firstDate: now,
            lastDate: DateTime(now.year + 5),
            builder: (context, child) {
                return Theme(
                    data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                            primary: AppColors.primaryBlue,
                            onPrimary: Colors.textOnDark,
                            onSurface: AppColors.cardBackground,
                        ),
                    ),
                    child: child!,
                );
            },
        );
        if (selected != null) {
            setState(() {
                _selectedDate = selected;
            });
        }
    }

    Future<void> _selectTime() async {
        final selected = await showTimePicker(
            context: context,
            initialTime: _selectedTime ?? TimeOfDay.now(),
            builder: (context, child) {
                return Theme(
                    data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                            primary: AppColors.primaryBlue,
                            onPrimary: Colors.textOnDark,
                            onSurface: AppColors.cardBackground,
                        ),
                    ),
                    child: child!,
                );
            },
        );
        if (selected != null) {
            setState(() {
                _selectedTime = selected;
            });
        }
    }

    // Formatar Data e Hora para exibição

    String get _formattedDate {
        if (_selectedDate == null) { 
            return 'Selecionar Data';
        }
        final d = _selectedDate!;
        return '${d.day.toString().padLeft(2, '0')}/'
            '${d.month.toString().padLeft(2, '0')}/'
            '${d.year}';
    }

    String get _formattedTime {
        if (_selectedTime == null) {
            return 'Selecionar Hora';
        }
        final h = _selectedTime!.hour.toString().padLeft(2, '0');
        final m = _selectedTime!.minute.toString().padLeft(2, '0');
        return '$h:$m';
    }

    // Validar e Salvar Tarefa

    void _saveTask() {
        FocusScope.of(context).unfocus();

        final valid = _formKey.currentState!.validate();

        if (!valid) {
            setState(() {
                _errorMessage = 'Por favor, preencha os campos obrigatórios.';
            });
            return;
        }

        if (_selectedDate == null || _selectedTime == null) {
            setState(() {
                _errorMessage = 'Por favor, selecione data e hora.';
            });
            return;
        }

        if (_selectedResponsaveis.isEmpty) {
            setState(() {
                _errorMessage = 'Por favor, selecione pelo menos um responsável.';
            });
            return;
        }

        setState(() {
            _errorMessage = null;
        });

        Navigator.popUntil(context, (route) => route.isFirst);
    }


    // Build da Página

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: Container(
                decoration: const BoxDecoration(
                    gradient: AppColors.backgroundGradient,
                ),
                child: SafeArea(
                    child: Column(
                        children: [
                            _buildHeader(context),
                            Expanded(
                                child: SingleChildScrollView(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                    ),
                                    child: Form(
                                        key: _formKey,
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                                _buildTitleField(),
                                                const SizedBox(height: 12),
                                                _buildDetailsField(),
                                                const SizedBox(height: 16),
                                                Row(
                                                    children: [
                                                        Expanded(
                                                            child: _DateTimeButton(
                                                                label: _dateLabel,
                                                                isSelected: _selectedDate != null,
                                                                onTap: _pickDate,
                                                            ),
                                                        ),
                                                        const SizedBox(width: 12),
                                                        Expanded(
                                                            child: _DateTimeButton(
                                                                label: _timeLabel,
                                                                isSelected: _selectedTime != null,
                                                                onTap: _pickTime,
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                                const SizedBox(height: 20),
                                                _buildSectionCard(
                                                    title: 'Responsáveis',
                                                    people: _mockResponsaveis,
                                                    selected: _selectedResponsaveis,
                                                ),
                                                const SizedBox(height: 14),
                                                _buildSectionCard(
                                                    title: 'Dependentes',
                                                    people: _mockDependentes,
                                                    selected: _selectedDependentes,
                                                ),
                                                const SizedBox(height: 16),
                                                if (_errorMessage != null)
                                                Padding(
                                                    padding: const EdgeInsets.only(bottom: 8),
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
                                                _ConfirmButton(onTap: _confirm),
                                                const SizedBox(height: 16),
                                            ],
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

    // Widgets auxiliares para construção da interface

    Widget _buildHeader(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Stack(
                alignment: Alignment.center,
                children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: () => Navigator.pop(context),
                            child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: const Color(0xFF484848),
                                        width: 1.8,
                                    ),
                                ),
                                child: const Icon(
                                    Icons.arrow_back_rounded,
                                    size: 22,
                                    color: Color(0xFF484848),
                                ),
                            ),
                        ),
                    ),
                    const Text(
                        'Criar Tarefa',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                        ),
                    ),
                ],
            ),
        );
    }
 
    Widget _buildTitleField() {
        return TextFormField(
            controller: _titleController,
            textInputAction: TextInputAction.next,
            validator: (v) {
                if (v == null || v.trim().isEmpty) {
                    return 'Informe o nome da tarefa.';
                }
                return null;
            },
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
                hintText: 'Digite o nome da Tarefa',
                hintStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                ),
                suffixIcon: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                ),
                filled: true,
                fillColor: AppColors.cardBackground,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
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
            ),
        ),
    }
 
    Widget _buildDetailsField() {
        return TextFormField(
            controller: _detailsController,
            maxLines: 4,
            textInputAction: TextInputAction.newline,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
            decoration: InputDecoration(
                hintText: 'Adicione detalhes da Tarefa (opcional)...',
                hintStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                ),
                filled: true,
                fillColor: AppColors.cardBackground,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
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
            ),
        );
    }
 
    Widget _buildSectionCard({
        required String title,
        required List<_Person> people,
        required Set<int> selected,
    }) {
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
                        children: List.generate(people.length, (i) {
                            final person = people[i];
                            final isLast = i == people.length - 1;
                            return _PersonTile(
                                person: person,
                                isChecked: selected.contains(i),
                                showDivider: !isLast,
                                onChanged: (val) {
                                    setState(() {       
                                        if (val == true) {
                                            selected.add(i);
                                        } else {
                                            selected.remove(i);
                                        }
                                        _errorMessage = null;
                                    });
                                },
                            );
                        }),
                    ),
                ),
            ],
        );
    }

    // Wifgets reutilizáveis para itens da interface

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
            return GestureDetector(
                onTap: onTap,
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
                                    child: Center(
                                        child: Text(
                                            person.initials,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textOnDark,
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
                                                    fontWeight: FontWeight.w400,
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
    
    class _ConfirmButton extends StatelessWidget {
        const _ConfirmButton({required this.onTap});
        
        final VoidCallback onTap;
        
        @override
        Widget build(BuildContext context) {
            return GestureDetector(
                onTap: onTap,
                child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                        color: AppColors.confirmGreen,
                        borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Center(
                        child: Text(
                            'Confirmar',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textOnDark,
                            ),
                        ),
                    ),
                ),
            );
        }
    }   
}
