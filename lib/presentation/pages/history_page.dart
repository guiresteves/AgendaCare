import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/person_model.dart';
import '../../data/models/task_model.dart';
import '../../data/providers/task_provider.dart';
import '../widgets/agenda_scaffold.dart';

const _primaryBlue = AppColors.primaryBlue;
const _textDark = AppColors.textPrimary;
const _textMuted = AppColors.textMuted;
const _divider = AppColors.divider;
const _cardBackground = AppColors.cardBackground;
const _successGreen = AppColors.confirmGreen;

enum _FilterOption {
  hoje('Hoje', 0),
  ultimos7('Últimos 7 dias', 7),
  ultimos30('Últimos 30 dias', 30);

  const _FilterOption(this.label, this.days);

  final String label;
  final int days;
}

class _HistoryEntry {
  const _HistoryEntry({
    required this.task,
    required this.completedAt,
  });

  final TaskModel task;
  final DateTime completedAt;
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Set<String> _savingCompletionIds = {};
  final Set<String> _clearingCompletionIds = {};

  _FilterOption _selectedFilter = _FilterOption.hoje;

  void _onFilterTap() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterSheet(
        selected: _selectedFilter,
        onSelected: (filter) {
          setState(() => _selectedFilter = filter);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<String?> _getGrupoId() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final userDoc = await _db.collection('usuarios').doc(user.uid).get();
    return userDoc.data()?['grupoId'] as String?;
  }

  Stream<List<_HistoryEntry>> _historyEntriesStream() async* {
    final grupoId = await _getGrupoId();

    if (grupoId == null || grupoId.isEmpty) {
      yield [];
      return;
    }

    yield* _db
        .collection('grupos')
        .doc(grupoId)
        .collection('tarefas')
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      final entries = <_HistoryEntry>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final task = TaskModel.fromMap(doc.id, data);

        if (!task.isConfirmed) {
          if (data.containsKey('historyCompletedAt')) {
            _clearHistoryCompletedAt(doc.reference);
          }
          continue;
        }

        DateTime? completedAt;

        final historyCompletedAt = data['historyCompletedAt'];
        if (historyCompletedAt is Timestamp) {
          completedAt = historyCompletedAt.toDate();
        }

        if (completedAt == null) {
          completedAt = DateTime.now();
          _saveHistoryCompletedAt(doc.reference, completedAt);
        }

        entries.add(
          _HistoryEntry(
            task: task,
            completedAt: completedAt,
          ),
        );
      }

      return entries;
    });
  }

  Future<void> _saveHistoryCompletedAt(
      DocumentReference<Map<String, dynamic>> ref,
      DateTime completedAt,
      ) async {
    if (_savingCompletionIds.contains(ref.id)) return;

    _savingCompletionIds.add(ref.id);

    try {
      await ref.update({
        'historyCompletedAt': Timestamp.fromDate(completedAt),
      });
    } catch (e) {
      debugPrint('Erro ao salvar historyCompletedAt: $e');
    } finally {
      _savingCompletionIds.remove(ref.id);
    }
  }

  Future<void> _clearHistoryCompletedAt(
      DocumentReference<Map<String, dynamic>> ref,
      ) async {
    if (_clearingCompletionIds.contains(ref.id)) return;

    _clearingCompletionIds.add(ref.id);

    try {
      await ref.update({
        'historyCompletedAt': FieldValue.delete(),
      });
    } catch (e) {
      debugPrint('Erro ao limpar historyCompletedAt: $e');
    } finally {
      _clearingCompletionIds.remove(ref.id);
    }
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isInSelectedPeriod(_HistoryEntry entry) {
    final completedDate = _dateOnly(entry.completedAt);

    final now = DateTime.now();
    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    switch (_selectedFilter) {
      case _FilterOption.hoje:
        return completedDate == today;

      case _FilterOption.ultimos7:
      case _FilterOption.ultimos30:
        final start = today.subtract(
          Duration(days: _selectedFilter.days - 1),
        );

        return !completedDate.isBefore(start) && !completedDate.isAfter(today);
    }
  }

  List<_HistoryEntry> _filterCompletedTasks(List<_HistoryEntry> entries) {
    final completed = entries.where(_isInSelectedPeriod).toList();

    completed.sort(
          (a, b) => b.completedAt.compareTo(a.completedAt),
    );

    return completed;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TaskProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: AgendaHeader(),
              ),
              Text(
                _selectedFilter == _FilterOption.hoje
                    ? 'Hoje'
                    : _selectedFilter.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: StreamBuilder<List<PersonModel>>(
                  stream: provider.responsaveisStream(),
                  builder: (context, respSnap) {
                    final responsaveis =
                        respSnap.data ?? const <PersonModel>[];

                    return StreamBuilder<List<PersonModel>>(
                      stream: provider.dependentesStream(),
                      builder: (context, depSnap) {
                        final dependentes =
                            depSnap.data ?? const <PersonModel>[];

                        return StreamBuilder<List<_HistoryEntry>>(
                          stream: _historyEntriesStream(),
                          builder: (context, taskSnap) {
                            if (taskSnap.connectionState ==
                                ConnectionState.waiting &&
                                !taskSnap.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: _primaryBlue,
                                ),
                              );
                            }

                            if (taskSnap.hasError) {
                              return const _ErrorState();
                            }

                            final entries = _filterCompletedTasks(
                              taskSnap.data ?? [],
                            );

                            return ListView(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                8,
                                16,
                                120,
                              ),
                              children: [
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: _FilterChip(
                                    label: _selectedFilter.label,
                                    onTap: _onFilterTap,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (entries.isEmpty)
                                  _EmptyState(filter: _selectedFilter)
                                else
                                  ...entries.map(
                                        (entry) => _TaskCard(
                                      entry: entry,
                                      responsaveis: responsaveis,
                                      dependentes: dependentes,
                                    ),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: _primaryBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.expand_more,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({
    required this.selected,
    required this.onSelected,
  });

  final _FilterOption selected;
  final ValueChanged<_FilterOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Filtrar por período',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 12),
          ..._FilterOption.values.map((option) {
            final isSelected = option == selected;

            return ListTile(
              onTap: () => onSelected(option),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              leading: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: _primaryBlue,
              ),
              title: Text(
                option.label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: _textDark,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _cardBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            SizedBox(height: 12),
            Text(
              'Erro ao carregar o histórico.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Verifique a conexão e tente novamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: _textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.filter,
  });

  final _FilterOption filter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 34,
        ),
        decoration: BoxDecoration(
          color: _cardBackground,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Icon(
              Icons.assignment_turned_in_outlined,
              size: 60,
              color: _primaryBlue.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 14),
            const Text(
              'Nenhuma tarefa concluída',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              filter == _FilterOption.hoje
                  ? 'Ainda não há tarefas confirmadas hoje.'
                  : 'Nenhuma tarefa confirmada em ${filter.label.toLowerCase()}.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: _textMuted.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.entry,
    required this.responsaveis,
    required this.dependentes,
  });

  final _HistoryEntry entry;
  final List<PersonModel> responsaveis;
  final List<PersonModel> dependentes;

  TaskModel get task => entry.task;

  List<PersonModel> _resolvePeople(
      List<String> ids,
      List<PersonModel> people,
      ) {
    final peopleMap = {
      for (final person in people) person.id: person,
    };

    return ids.map((id) => peopleMap[id]).whereType<PersonModel>().toList();
  }

  String _registeredBy(List<PersonModel> taskResponsaveis) {
    if (taskResponsaveis.isEmpty) {
      return 'responsável não informado';
    }

    if (taskResponsaveis.length == 1) {
      return taskResponsaveis.first.name;
    }

    return '${taskResponsaveis.first.name} e mais ${taskResponsaveis.length - 1}';
  }

  String _completedText() {
    final completedAt = entry.completedAt;

    final day = completedAt.day.toString().padLeft(2, '0');
    final month = completedAt.month.toString().padLeft(2, '0');
    final year = completedAt.year;

    final hour = completedAt.hour.toString().padLeft(2, '0');
    final minute = completedAt.minute.toString().padLeft(2, '0');

    return 'Concluído em $day/$month/$year às $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final taskResponsaveis = _resolvePeople(
      task.responsibleIds,
      responsaveis,
    );

    final taskDependentes = _resolvePeople(
      task.dependentIds,
      dependentes,
    );

    final notes = task.description.trim().isEmpty
        ? 'Sem observações.'
        : task.description.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _successGreen.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: _successGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _completedText(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: _textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(
              color: _divider,
              thickness: 1,
              height: 1,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.notes_outlined,
                  size: 16,
                  color: _textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    notes,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _textMuted,
                      fontStyle: FontStyle.italic,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _PeopleColumn(
                    title: 'Responsáveis:',
                    people: taskResponsaveis,
                    emptyText: 'Não informado',
                  ),
                ),
                Expanded(
                  child: _PeopleColumn(
                    title: 'Dependentes:',
                    people: taskDependentes,
                    emptyText: 'Nenhum',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Registrado por ${_registeredBy(taskResponsaveis)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: _textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeopleColumn extends StatelessWidget {
  const _PeopleColumn({
    required this.title,
    required this.people,
    required this.emptyText,
  });

  final String title;
  final List<PersonModel> people;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: _textMuted,
          ),
        ),
        const SizedBox(height: 6),
        if (people.isEmpty)
          Text(
            emptyText,
            style: TextStyle(
              fontSize: 12,
              color: _textMuted.withValues(alpha: 0.75),
            ),
          )
        else
          _AvatarStack(people: people),
      ],
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({
    required this.people,
  });

  final List<PersonModel> people;

  static const double _size = 34;
  static const double _overlap = 12;

  double get _avatarWidth => _size - _overlap;

  @override
  Widget build(BuildContext context) {
    final visiblePeople = people.take(4).toList();
    final extraCount = people.length - visiblePeople.length;

    return SizedBox(
      height: _size,
      width: _size +
          (_avatarWidth * (visiblePeople.length - 1)) +
          (extraCount > 0 ? _avatarWidth : 0),
      child: Stack(
        children: [
          for (int i = 0; i < visiblePeople.length; i++)
            Positioned(
              left: i * _avatarWidth,
              child: _AvatarCircle(
                person: visiblePeople[i],
              ),
            ),
          if (extraCount > 0)
            Positioned(
              left: visiblePeople.length * _avatarWidth,
              child: _ExtraAvatar(
                count: extraCount,
              ),
            ),
        ],
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.person,
  });

  final PersonModel person;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: person.name,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: person.avatarColor,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          person.initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ExtraAvatar extends StatelessWidget {
  const _ExtraAvatar({
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _textMuted.withValues(alpha: 0.8),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '+$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}