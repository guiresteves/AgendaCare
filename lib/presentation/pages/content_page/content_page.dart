import 'package:agendacare/presentation/pages/group_page.dart';
import 'package:agendacare/presentation/pages/history_page.dart';
import 'package:agendacare/presentation/pages/home_page.dart';
import 'package:agendacare/presentation/pages/profile_page.dart';
import 'package:agendacare/presentation/pages/task_page.dart';
import 'package:flutter/material.dart';

import '../../widgets/agenda_scaffold.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({super.key});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  static const _taskIndex = 2;

  final List<Widget> _pages = const [
    HomePage(),
    GroupPage(),
    AddTaskPage(),
    HistoryPage(),
    ProfilePage(),
  ];

  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    if (_currentIndex == index) {
      return;
    }

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _handlePageChanged(int index) {
    if (_currentIndex == index) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: _handlePageChanged,
        children: _pages,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 86,
        height: 86,
        child: FloatingActionButton(
          backgroundColor: agendaBlue,
          elevation: _currentIndex == _taskIndex ? 6 : 2,
          shape: const CircleBorder(),
          onPressed: () => _goToPage(_taskIndex),
          child: const Icon(Icons.add, color: Colors.white, size: 34),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomBarItem(
                icon: Icons.home_filled,
                label: 'Home',
                isActive: _currentIndex == 0,
                onTap: () => _goToPage(0),
              ),
              _BottomBarItem(
                icon: Icons.people_alt_outlined,
                label: 'Grupo',
                isActive: _currentIndex == 1,
                onTap: () => _goToPage(1),
              ),
              const SizedBox(width: 44),
              _BottomBarItem(
                icon: Icons.calendar_today_outlined,
                label: 'Histórico',
                isActive: _currentIndex == 3,
                onTap: () => _goToPage(3),
              ),
              _BottomBarItem(
                icon: Icons.person_outline,
                label: 'Perfil',
                isActive: _currentIndex == 4,
                onTap: () => _goToPage(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  const _BottomBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.black : const Color(0xFF8A9BB0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 66,
        height: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
