import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const agendaBlue = Color(0xFF4195CC);
const agendaBrandBlue = Color(0xFF488ECA);
const agendaGreen = Color(0xFF34C759);
const agendaMutedText = Color(0xFF7E7777);
const agendaGradient = [Colors.white, Color(0xFFDEF6F9), Color(0xFFBDEDF3)];

class AgendaScaffold extends StatelessWidget {
  const AgendaScaffold({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 130),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
              child: ListView(
                padding: padding,
                children: [const AgendaHeader(), child],
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
