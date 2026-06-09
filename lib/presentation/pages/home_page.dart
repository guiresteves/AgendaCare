import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/person_model.dart';
import '../../data/models/task_model.dart';
import '../../data/providers/task_provider.dart';
import '../widgets/agenda_scaffold.dart';

const agendaBlue = AppColors.primaryBlue;
const agendaBrandBlue = AppColors.primaryBlue;
const agendaMutedText = AppColors.textMuted;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Guarda as listas de pessoas em memória para o card usar
  List<PersonModel> _responsaveis = [];
  List<PersonModel> _dependentes = [];

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TaskProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFDEF6F9), Color(0xFFBDEDF3)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              const AgendaHeader(),

              // ── Conteúdo rolável ──────────────────────────────────────────
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const Text(
                            'Bom dia!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Center(
                            child: Text(
                              '06 de abril',
                              style: TextStyle(
                                color: agendaBrandBlue,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const WeekSelector(),
                          const SizedBox(height: 28),
                          const Text(
                            'Tarefas de hoje',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Ver, organizar e acompanhar os cuidados para hoje.',
                            style: TextStyle(
                              color: agendaMutedText,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ]),
                      ),
                    ),

                    // ── Carrega pessoas + tarefas em paralelo ─────────────
                    StreamBuilder<List<PersonModel>>(
                      stream: provider.responsaveisStream(),
                      builder: (context, respSnap) {
                        if (respSnap.hasData) {
                          _responsaveis = respSnap.data!;
                        }
                        return StreamBuilder<List<PersonModel>>(
                          stream: provider.dependentesStream(),
                          builder: (context, depSnap) {
                            if (depSnap.hasData) {
                              _dependentes = depSnap.data!;
                            }
                            return StreamBuilder<List<TaskModel>>(
                              stream: provider.tasksStream(),
                              builder: (context, taskSnap) {
                                // Carregando
                                if (taskSnap.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SliverFillRemaining(
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: agendaBlue,
                                      ),
                                    ),
                                  );
                                }

                                // Erro
                                if (taskSnap.hasError) {
                                  return SliverFillRemaining(
                                    child: Center(
                                      child: Text(
                                        'Erro ao carregar tarefas.',
                                        style: TextStyle(
                                            color: agendaMutedText),
                                      ),
                                    ),
                                  );
                                }

                                final tasks = taskSnap.data ?? [];

                                // Vazio
                                if (tasks.isEmpty) {
                                  return const SliverFillRemaining(
                                    child: _EmptyTasksMessage(),
                                  );
                                }

                                // Lista
                                return SliverPadding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 0, 16, 130),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 16),
                                          child: TaskCard(
                                            task: tasks[index],
                                            responsaveis: _responsaveis,
                                            dependentes: _dependentes,
                                          ),
                                        );
                                      },
                                      childCount: tasks.length,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyTasksMessage extends StatelessWidget {
  const _EmptyTasksMessage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: AppColors.primaryBlue.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            const Text(
              'Nenhuma tarefa para hoje!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: agendaMutedText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Toque no + para adicionar uma nova tarefa.',
              style: TextStyle(fontSize: 13, color: agendaMutedText),
            ),
          ],
        ),
      ),
    );
  }
}

// ── WeekSelector ──────────────────────────────────────────────────────────────

class WeekSelector extends StatelessWidget {
  const WeekSelector({super.key});

  @override
  Widget build(BuildContext context) {
    const days = [
      _WeekDay('D', '05'),
      _WeekDay('S', '06', selected: true),
      _WeekDay('T', '07'),
      _WeekDay('Q', '08'),
      _WeekDay('Q', '09'),
      _WeekDay('S', '06'),
      _WeekDay('S', '10'),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) => _DayItem(day: day)).toList(),
    );
  }
}

class _DayItem extends StatelessWidget {
  const _DayItem({required this.day});
  final _WeekDay day;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(day.label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 5),
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: day.selected ? agendaBlue : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Text(
            day.number,
            style: TextStyle(
              color: day.selected ? Colors.white : Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _WeekDay {
  const _WeekDay(this.label, this.number, {this.selected = false});
  final String label;
  final String number;
  final bool selected;
}

// ── TaskCard ──────────────────────────────────────────────────────────────────

class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.responsaveis,
    required this.dependentes,
  });

  final TaskModel task;
  final List<PersonModel> responsaveis;
  final List<PersonModel> dependentes;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _isExpanded = false;
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() => _isExpanded = !_isExpanded);
    _isExpanded ? _controller.forward() : _controller.reverse();
  }

  Future<void> _confirmTask() async {
    setState(() => _isConfirming = true);
    await context
        .read<TaskProvider>()
        .toggleConfirmTask(widget.task.id, widget.task.isConfirmed);
    if (mounted) setState(() => _isConfirming = false);
  }

  void _openEditSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<TaskProvider>(),
        child: _EditTaskSheet(
          task: widget.task,
          responsaveis: widget.responsaveis,
          dependentes: widget.dependentes,
        ),
      ),
    );
  }

  void _openDeleteSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _DeleteConfirmSheet(
        taskTitle: widget.task.title,
        onConfirm: () async {
          await context.read<TaskProvider>().deleteTask(widget.task.id);
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isConfirmed = task.isConfirmed;

    final now = DateTime.now();
    final taskDateTime = DateTime(
      task.date.year,
      task.date.month,
      task.date.day,
      task.time.hour,
      task.time.minute,
    );
    final isLate = taskDateTime.isBefore(now);

    final statusText = isConfirmed
        ? 'Confirmado'
        : isLate
            ? 'Atrasado'
            : 'Pendente';

    final statusColor = isConfirmed
        ? const Color(0xFF71C26B)
        : isLate
            ? Colors.red
            : const Color(0xFF8E8E93);

    final timeColor = isConfirmed
        ? const Color(0xFF71C26B)
        : isLate
            ? Colors.red
            : agendaBlue;

    // Resolve pessoas pelos IDs salvos na tarefa
    final responsaveisMap = {for (final p in widget.responsaveis) p.id: p};
    final dependentesMap = {for (final p in widget.dependentes) p.id: p};

    final taskResponsaveis = task.responsibleIds
        .map((id) => responsaveisMap[id])
        .whereType<PersonModel>()
        .toList();

    final taskDependentes = task.dependentIds
        .map((id) => dependentesMap[id])
        .whereType<PersonModel>()
        .toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Linha principal ────────────────────────────────────────────────
          Row(
            children: [
              Icon(
                isConfirmed ? Icons.check_circle : Icons.access_time,
                color:
                    isConfirmed ? const Color(0xFF71C26B) : agendaBlue,
                size: 29,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                task.formattedTime,
                style: TextStyle(
                    color: timeColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
              ),
              GestureDetector(
                onTap: _toggleExpand,
                child: AnimatedRotation(
                  turns: _isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.chevron_right,
                      color: Color(0xFF7E7777)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE6E6E6)),
          const SizedBox(height: 10),

          // ── Avatares ───────────────────────────────────────────────────────
          Row(
            children: [
              _PeopleColumn(
                title: 'Responsáveis:',
                people: taskResponsaveis,
              ),
              _PeopleColumn(
                title: 'Dependentes:',
                people: taskDependentes,
                dependent: true,
              ),
            ],
          ),

          // ── Expansível ─────────────────────────────────────────────────────
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Divider(color: Color(0xFFE6E6E6)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 16, color: agendaMutedText),
                    const SizedBox(width: 6),
                    Text(task.formattedDate,
                        style: const TextStyle(
                            fontSize: 14, color: agendaMutedText)),
                    const SizedBox(width: 20),
                    const Icon(Icons.access_time,
                        size: 16, color: agendaMutedText),
                    const SizedBox(width: 6),
                    Text(task.formattedTime,
                        style: const TextStyle(
                            fontSize: 14, color: agendaMutedText)),
                  ],
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.notes_outlined,
                          size: 16, color: agendaMutedText),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(task.description,
                            style: const TextStyle(
                                fontSize: 14, color: agendaMutedText)),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(color: Color(0xFFE6E6E6)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openEditSheet,
                        icon:
                            const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Editar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: agendaBlue,
                          side: const BorderSide(color: agendaBlue),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openDeleteSheet,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Excluir'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side:
                              const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),

          const SizedBox(height: 14),
          const Divider(color: Color(0xFFE6E6E6)),
          const SizedBox(height: 10),

          // ── Botão confirmar ────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF71C26B),
                disabledBackgroundColor: const Color(0xFF71C26B),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26)),
              ),
              onPressed: _isConfirming ? null : _confirmTask,
              child: _isConfirming
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      isConfirmed ? 'Confirmado ✓' : 'Confirmar',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Sheet Editar ───────────────────────────────────────────────────────

class _EditTaskSheet extends StatefulWidget {
  const _EditTaskSheet({
    required this.task,
    required this.responsaveis,
    required this.dependentes,
  });

  final TaskModel task;
  final List<PersonModel> responsaveis;
  final List<PersonModel> dependentes;

  @override
  State<_EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends State<_EditTaskSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late Set<String> _selectedResponsaveis;
  late Set<String> _selectedDependentes;
  String? _errorMessage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _selectedDate = widget.task.date;
    _selectedTime = widget.task.time;
    _selectedResponsaveis = Set.from(widget.task.responsibleIds);
    _selectedDependentes = Set.from(widget.task.dependentIds);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
            colorScheme:
                const ColorScheme.light(primary: agendaBlue)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
            colorScheme:
                const ColorScheme.light(primary: agendaBlue)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Informe o nome da tarefa.');
      return;
    }
    if (_selectedResponsaveis.isEmpty) {
      setState(
          () => _errorMessage = 'Selecione pelo menos um responsável.');
      return;
    }
    setState(() => _isSaving = true);

    final updated = widget.task.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      date: _selectedDate,
      time: _selectedTime,
      responsibleIds: _selectedResponsaveis.toList(),
      dependentIds: _selectedDependentes.toList(),
    );

    await context.read<TaskProvider>().updateTask(updated);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarefa atualizada com sucesso.')),
      );
    }
  }

  String get _formattedDate {
    final d = _selectedDate.day.toString().padLeft(2, '0');
    final m = _selectedDate.month.toString().padLeft(2, '0');
    return '$d/$m/${_selectedDate.year}';
  }

  String get _formattedTime {
    final h = _selectedTime.hour.toString().padLeft(2, '0');
    final m = _selectedTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Editar Tarefa',
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: _inputDecoration(hintText: 'Nome da tarefa'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration:
                  _inputDecoration(hintText: 'Detalhes (opcional)'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _SheetDateTimeButton(
                        label: _formattedDate, onTap: _pickDate)),
                const SizedBox(width: 12),
                Expanded(
                    child: _SheetDateTimeButton(
                        label: _formattedTime, onTap: _pickTime)),
              ],
            ),
            const SizedBox(height: 20),

            // Responsáveis vindos do Firestore
            _SheetPeopleSection(
              title: 'Responsáveis',
              people: widget.responsaveis,
              selectedIds: _selectedResponsaveis,
              onChanged: (id, selected) => setState(() {
                selected
                    ? _selectedResponsaveis.add(id)
                    : _selectedResponsaveis.remove(id);
                _errorMessage = null;
              }),
            ),
            const SizedBox(height: 14),

            // Dependentes vindos do Firestore
            _SheetPeopleSection(
              title: 'Dependentes',
              people: widget.dependentes,
              selectedIds: _selectedDependentes,
              onChanged: (id, selected) => setState(() {
                selected
                    ? _selectedDependentes.add(id)
                    : _selectedDependentes.remove(id);
              }),
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
                      color: AppColors.error),
                ),
              ),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: agendaBlue,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Salvar alterações',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle:
          const TextStyle(color: AppColors.textMuted, fontSize: 15),
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: agendaBlue, width: 1.4)),
    );
  }
}

// ── Bottom Sheet Excluir ──────────────────────────────────────────────────────

class _DeleteConfirmSheet extends StatelessWidget {
  const _DeleteConfirmSheet(
      {required this.taskTitle, required this.onConfirm});

  final String taskTitle;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_outline,
                color: Colors.redAccent, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('Excluir tarefa?',
              style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            'Tem certeza que deseja excluir\n"$taskTitle"?\nEssa ação não pode ser desfeita.',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14, color: agendaMutedText, height: 1.4),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: agendaMutedText,
                    side: const BorderSide(color: Color(0xFFDDDDDD)),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                  ),
                  child: const Text('Cancelar',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onConfirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                  ),
                  child: const Text('Excluir',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _PeopleColumn extends StatelessWidget {
  const _PeopleColumn({
    required this.title,
    required this.people,
    this.dependent = false,
  });

  final String title;
  final List<PersonModel> people;
  final bool dependent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(color: agendaMutedText, fontSize: 12)),
          const SizedBox(height: 7),
          SizedBox(
            height: 38,
            child: Stack(
              children: [
                for (int i = 0; i < people.length; i++)
                  Positioned(
                    left: i * 25.0,
                    child: CircleAvatar(
                      radius: 19,
                      backgroundColor: people[i].avatarColor,
                      child: Text(
                        people[i].initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetDateTimeButton extends StatelessWidget {
  const _SheetDateTimeButton(
      {required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: agendaBlue)),
        ),
      ),
    );
  }
}

class _SheetPeopleSection extends StatelessWidget {
  const _SheetPeopleSection({
    required this.title,
    required this.people,
    required this.selectedIds,
    required this.onChanged,
  });

  final String title;
  final List<PersonModel> people;
  final Set<String> selectedIds;
  final void Function(String id, bool selected) onChanged;

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: people.map((person) {
              final isLast = person == people.last;
              final isSelected = selectedIds.contains(person.id);
              return Column(
                children: [
                  InkWell(
                    onTap: () => onChanged(person.id, !isSelected),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: person.avatarColor,
                            child: Text(person.initials,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(person.name,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)),
                          ),
                          Checkbox(
                            value: isSelected,
                            onChanged: (val) =>
                                onChanged(person.id, val ?? false),
                            activeColor: agendaBlue,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    const Divider(height: 1, indent: 50, endIndent: 14),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}