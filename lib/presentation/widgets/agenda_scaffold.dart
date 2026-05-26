import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../pages/group_page.dart';
import '../pages/history_page.dart';
import '../pages/home_page.dart';
import '../pages/profile_page.dart';

const agendaBlue = Color(0xFF4195CC);
const agendaBrandBlue = Color(0xFF488ECA);
const agendaGreen = Color(0xFF34C759);
const agendaMutedText = Color(0xFF7E7777);
const agendaInactiveNav = Color(0xFF9DB2CE);
const agendaGradient = [Colors.white, Color(0xFFDEF6F9), Color(0xFFBDEDF3)];

enum AgendaTab { home, group, history, profile }

class AgendaScaffold extends StatelessWidget {
  const AgendaScaffold({
    super.key,
    required this.activeTab,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 110),
    this.floatingActionButton,
  });

  final AgendaTab activeTab;
  final Widget child;
  final EdgeInsets padding;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: agendaGradient,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ListView(
                      padding: padding,
                      children: [const AgendaHeader(), child],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AgendaBottomBar(activeTab: activeTab),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 48,
                    child: Center(
                      child:
                          floatingActionButton ??
                          FloatingActionButton(
                            backgroundColor: agendaBlue,
                            shape: const CircleBorder(),
                            onPressed: () {},
                            child: SvgPicture.asset(
                              'assets/icons/add_plus_circle.svg',
                              width: 28,
                              height: 28,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
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

class AgendaHeader extends StatelessWidget {
  const AgendaHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: Image.asset(
              'assets/images/agenda_care_mascot.png',
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Image.asset(
                'assets/images/app_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const Expanded(child: BrandTitle()),
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              'assets/icons/bell_ring_figma.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(agendaBlue, BlendMode.srcIn),
            ),
          ),
        ],
      ),
    );
  }
}

class BrandTitle extends StatelessWidget {
  const BrandTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'Agenda',
            style: TextStyle(
              color: agendaBrandBlue,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
          TextSpan(
            text: 'Care',
            style: TextStyle(
              color: agendaGreen,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

class AgendaBottomBar extends StatelessWidget {
  const AgendaBottomBar({super.key, required this.activeTab});

  final AgendaTab activeTab;

  void _openTab(BuildContext context, AgendaTab tab) {
    if (tab == activeTab) return;

    final page = switch (tab) {
      AgendaTab.home => const HomePage(),
      AgendaTab.group => const GroupPage(),
      AgendaTab.history => const HistoryPage(),
      AgendaTab.profile => const ProfilePage(),
    };

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 76,
      color: Colors.white,
      elevation: 0,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_filled,
            label: 'Home',
            active: activeTab == AgendaTab.home,
            onTap: () => _openTab(context, AgendaTab.home),
          ),
          _NavItem(
            icon: Icons.groups_outlined,
            label: 'Grupo',
            active: activeTab == AgendaTab.group,
            onTap: () => _openTab(context, AgendaTab.group),
          ),
          const SizedBox(width: 48),
          _NavItem(
            icon: Icons.calendar_today_outlined,
            label: 'Histórico',
            active: activeTab == AgendaTab.history,
            onTap: () => _openTab(context, AgendaTab.history),
          ),
          _NavItem(
            icon: Icons.person_outline,
            label: 'Perfil',
            active: activeTab == AgendaTab.profile,
            onTap: () => _openTab(context, AgendaTab.profile),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.black : agendaInactiveNav;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 62,
        height: 58,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 23),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: label == 'Histórico' ? 10 : 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
