import 'package:flutter/material.dart';

const _primaryBlue = Color(0xFF4A97CF);
const _textDark = Colors.black;
const _textMuted = Color(0xFF7E7777);
const _divider = Color(0xFFE8EFF5);

const _avatarPurple = Color(0xFFA98BD6);
const _avatarPink = Color(0xFFE88BB2);
const _avatarBlue = Color(0xFF6FB3E8);

class _TaskRecord {
  const _TaskRecord({
    required this.title,
    required this.completedAt,
    required this.notes,
    required this.registeredBy,
    required this.responsaveis,
    required this.dependentes,
  });

  final String title;
  final String completedAt;
  final String notes;
  final String registeredBy;
  final List<_Avatar> responsaveis;
  final List<_Avatar> dependentes;
}

class _Avatar {
  const _Avatar({required this.initials, required this.color});

  final String initials;
  final Color color;
}

const _sampleTasks = [
  _TaskRecord(
    //Marcados como Placeholder são partes que só irão ser completadas quando for fazer o backend
    title: 'TITULO TAREFA', // Placeholder
    completedAt: 'HORÁRIO DE CONCLUSÃO', // Placeholder
    notes: 'Notas', // Placeholder
    registeredBy: '00', // Placeholder
    responsaveis: [
      _Avatar(initials: '00', color: _avatarPurple), // Placeholder
      _Avatar(initials: '00', color: _avatarPink), // Placeholder
    ],
    dependentes: [
      _Avatar(initials: '00', color: _avatarBlue), // Placeholder
    ],
  ),
  _TaskRecord(
    title: 'TITULO TAREFA', // Placeholder
    completedAt: 'HORARIO DE CONCLUSAO', // Placeholder
    notes: 'HORÁRIO DE CONCLUSAO', // Placeholder
    registeredBy: '00', // Placeholder
    responsaveis: [
      _Avatar(initials: '00', color: _avatarPurple), // Placeholder
      _Avatar(initials: '00', color: _avatarPink), // Placeholder
    ],
    dependentes: [
      _Avatar(initials: '00', color: _avatarBlue), // Placeholder
    ],
  ),
];

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFD4F0F7)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _AppBar(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  children: [
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: _FilterChip(),
                    ),
                    const SizedBox(height: 16),
                    ..._sampleTasks.map((task) => _TaskCard(task: task)),
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

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.favorite_rounded,
                      color: _primaryBlue,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const Expanded(
                child: Text(
                  'AgendaCare',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _primaryBlue,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: _primaryBlue,
                ),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Hoje',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _primaryBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_outlined, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              'Últimos 7 dias',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.expand_more, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final _TaskRecord task;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF4CAF50),
                  size: 28,
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
                        'Concluído às ${task.completedAt}',
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
            const SizedBox(height: 10),
            const Divider(color: _divider, thickness: 1, height: 1),
            const SizedBox(height: 10),
            Text(
              task.notes,
              style: const TextStyle(
                fontSize: 13,
                color: _textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Responsáveis:',
                        style: TextStyle(fontSize: 12, color: _textMuted),
                      ),
                      const SizedBox(height: 6),
                      _AvatarStack(avatars: task.responsaveis),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dependentes:',
                        style: TextStyle(fontSize: 12, color: _textMuted),
                      ),
                      const SizedBox(height: 6),
                      _AvatarStack(avatars: task.dependentes),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Registrado por ${task.registeredBy}',
                style: const TextStyle(fontSize: 12, color: _textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.avatars});

  final List<_Avatar> avatars;

  static const double _size = 34;
  static const double _overlap = 12;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _size,
      width: _size + (_avatarWidth * (avatars.length - 1)),
      child: Stack(
        children: List.generate(avatars.length, (i) {
          return Positioned(
            left: i * _avatarWidth,
            child: _AvatarCircle(avatar: avatars[i]),
          );
        }),
      ),
    );
  }

  double get _avatarWidth => _size - _overlap;
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.avatar});

  final _Avatar avatar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: avatar.color,
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        avatar.initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
