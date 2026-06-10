import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/auth/auth_service.dart';
import 'change_password_page.dart';
import 'edit_profile_page.dart';
import 'terms_privacy_page.dart';

const _primaryBlue = Color(0xFF4A97CF);
const _textDark = Colors.black;
const _textMuted = Color(0xFF7E7777);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isSigningOut = false;

  Future<void> _desconectar() async {
    if (_isSigningOut) {
      return;
    }

    setState(() {
      _isSigningOut = true;
    });

    await AuthService.instance.signOut();

    if (!mounted) {
      return;
    }

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  String _profileSubtitle(EditableProfileDetails profile) {
    final hasExtraDetails =
        profile.birthDate != null ||
        profile.gender != null ||
        profile.nationality != null ||
        profile.postalCode != null;

    if (hasExtraDetails && profile.email.isNotEmpty) {
      return profile.email;
    }

    return profile.email.isEmpty ? 'Complete seu perfil...' : profile.email;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario nao autenticado.')),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .snapshots(),
      builder: (context, userSnapshot) {
        final profile = EditableProfileDetails.fromUserData(
          user,
          userSnapshot.data?.data(),
        );
        final canChangePassword = AuthService.canChangePassword(user);

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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
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
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
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
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 132),
                      children: [
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: LinearProgressIndicator(
                              minHeight: 2,
                              color: _primaryBlue,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFA98BD6),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  profile.initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: _textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _profileSubtitle(profile),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: _textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProfilePage(
                                        initialProfile: profile,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: _textMuted,
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (canChangePassword) ...[
                          const SizedBox(height: 20),
                          _SimpleMenuTile(
                            label: 'Alterar Senha',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ChangePasswordPage(),
                                ),
                              );
                            },
                            showChevron: false,
                          ),
                        ],
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _MenuTile(
                                label: 'Termos e Privacidade',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TermsPrivacyPage(),
                                    ),
                                  );
                                },
                                isFirst: true,
                                isLast: false,
                              ),
                              const Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                                color: Color(0xFFE8EFF5),
                              ),
                              _MenuTile(
                                label: 'Ajuda',
                                onTap: () {},
                                isFirst: false,
                                isLast: false,
                              ),
                              const Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                                color: Color(0xFFE8EFF5),
                              ),
                              _MenuTile(
                                label: 'Notificacoes',
                                onTap: () {},
                                isFirst: false,
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _SimpleMenuTile(
                          label: _isSigningOut
                              ? 'Desconectando...'
                              : 'Desconectar',
                          onTap: _isSigningOut ? null : _desconectar,
                          showChevron: false,
                          labelColor: Colors.redAccent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SimpleMenuTile extends StatelessWidget {
  const _SimpleMenuTile({
    required this.label,
    required this.onTap,
    this.showChevron = false,
    this.labelColor = _textDark,
  });

  final String label;
  final VoidCallback? onTap;
  final bool showChevron;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
            if (showChevron)
              const Icon(Icons.chevron_right, color: _textMuted, size: 22),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.label,
    required this.onTap,
    required this.isFirst,
    required this.isLast,
  });

  final String label;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _textDark,
              ),
            ),
            const Icon(Icons.chevron_right, color: _textMuted, size: 22),
          ],
        ),
      ),
    );
  }
}
