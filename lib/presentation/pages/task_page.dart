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
]

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
}
