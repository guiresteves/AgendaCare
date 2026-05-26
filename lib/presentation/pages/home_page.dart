import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../widgets/agenda_scaffold.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Set<String> _confirmedTasks = {};
  final Set<String> _loadingTasks = {};

  Future<void> _confirmTask(AgendaTask task) async {
    setState(() => _loadingTasks.add(task.title));
    await Future.delayed(const Duration(milliseconds: 550));
    setState(() {
      _loadingTasks.remove(task.title);
      _confirmedTasks.add(task.title);
    });
  }

  @override
  Widget build(BuildContext context) {
    const tasks = [
      AgendaTask(
        title: 'Dar banho em Gustavo',
        status: 'Atrasado',
        time: '09:30',
        statusColor: Colors.red,
        timeColor: Colors.red,
        responsibleInitials: ['KA', 'LM'],
        dependentInitials: 'GU',
        icon: TaskIcon.warning,
      ),
      AgendaTask(
        title: 'Levar Iago ao Hospital',
        status: 'Faltam 5 horas e 12 minutos',
        time: '15:30',
        statusColor: Color(0xFF8E8E93),
        timeColor: agendaBlue,
        responsibleInitials: ['KA', 'LM'],
        dependentInitials: 'IM',
        icon: TaskIcon.clock,
      ),
    ];

    return AgendaScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bom dia!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ver, organizar e acompanhar os cuidados para\nhoje.',
            style: TextStyle(
              color: agendaMutedText,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 16),
          for (final task in tasks) ...[
            TaskCard(
              task: task,
              isLoading: _loadingTasks.contains(task.title),
              isConfirmed: _confirmedTasks.contains(task.title),
              onConfirm: () => _confirmTask(task),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class WeekSelector extends StatelessWidget {
  const WeekSelector({super.key});

  @override
  Widget build(BuildContext context) {
    const days = [
      WeekDay('D', '05'),
      WeekDay('S', '06', selected: true),
      WeekDay('T', '07'),
      WeekDay('Q', '08'),
      WeekDay('Q', '09'),
      WeekDay('S', '06'),
      WeekDay('S', '10'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) => DayItem(day: day)).toList(),
    );
  }
}

class DayItem extends StatelessWidget {
  const DayItem({super.key, required this.day});

  final WeekDay day;

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

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.isLoading,
    required this.isConfirmed,
    required this.onConfirm,
  });

  final AgendaTask task;
  final bool isLoading;
  final bool isConfirmed;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final statusText = isConfirmed ? 'Confirmado' : task.status;
    final statusColor = isConfirmed
        ? const Color(0xFF71C26B)
        : task.statusColor;
    final timeColor = isConfirmed ? const Color(0xFF71C26B) : task.timeColor;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _TaskLeadingIcon(icon: task.icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
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
                task.time,
                style: TextStyle(
                  color: timeColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF7E7777)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE6E6E6)),
          const SizedBox(height: 10),
          Row(
            children: [
              _PeopleColumn(
                title: 'Responsáveis:',
                initials: task.responsibleInitials,
              ),
              _PeopleColumn(
                title: 'Dependente:',
                initials: [task.dependentInitials],
                dependent: true,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFE6E6E6)),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF71C26B),
                disabledBackgroundColor: const Color(0xFF71C26B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              onPressed: isLoading || isConfirmed ? null : onConfirm,
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isConfirmed ? 'Confirmado' : 'Confirmar',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskLeadingIcon extends StatelessWidget {
  const _TaskLeadingIcon({required this.icon});

  final TaskIcon icon;

  @override
  Widget build(BuildContext context) {
    if (icon == TaskIcon.warning) {
      return SvgPicture.asset(
        'assets/icons/triangle_warning.svg',
        width: 28,
        height: 28,
        colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
      );
    }

    return const Icon(Icons.access_time, color: agendaBlue, size: 29);
  }
}

class _PeopleColumn extends StatelessWidget {
  const _PeopleColumn({
    required this.title,
    required this.initials,
    this.dependent = false,
  });

  final String title;
  final List<String> initials;
  final bool dependent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: agendaMutedText, fontSize: 12),
          ),
          const SizedBox(height: 7),
          SizedBox(
            height: 38,
            child: Stack(
              children: [
                for (int i = 0; i < initials.length; i++)
                  Positioned(
                    left: i * 25,
                    child: InitialsAvatar(
                      initials: initials[i],
                      backgroundColor: dependent || initials[i] == 'LM'
                          ? const Color(0xFF94C4F5)
                          : const Color(0xFFF6CDFF),
                      textColor: dependent || initials[i] == 'LM'
                          ? Colors.white
                          : const Color(0xFF9E1C8B),
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

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.initials,
    required this.backgroundColor,
    required this.textColor,
  });

  final String initials;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 19,
      backgroundColor: backgroundColor,
      child: Text(
        initials,
        style: TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class AgendaTask {
  const AgendaTask({
    required this.title,
    required this.status,
    required this.time,
    required this.statusColor,
    required this.timeColor,
    required this.responsibleInitials,
    required this.dependentInitials,
    required this.icon,
  });

  final String title;
  final String status;
  final String time;
  final Color statusColor;
  final Color timeColor;
  final List<String> responsibleInitials;
  final String dependentInitials;
  final TaskIcon icon;
}

class WeekDay {
  const WeekDay(this.label, this.number, {this.selected = false});

  final String label;
  final String number;
  final bool selected;
}

enum TaskIcon { warning, clock }
