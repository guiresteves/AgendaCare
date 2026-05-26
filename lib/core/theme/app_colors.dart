import 'package:flutter/material.dart';

class AppColors {

    AppColors._();

    // Cores Principais

    static const primaryBlue = Color(0xFF4195CC);
    static const confirmGreen = Color(0xFF5DBB72);

    // Textos

    static const textPrimary = Colors.black;
    static const textMuted = Color(0xFF7E7777);
    static const textOnDark = Colors.white;

    // Cores dos Avatares

    static const avatarPink = Color(0xFFE57FAA);
    static const avatarBlue = Color(0xFF7B9FE0);
    static const avatarTeal = Color(0xFF6DC4A8);

    // Cards e Contêineres

    static const cardBackground = Colors.white;
    static const divider = Color(0xFFF0F0F0);
    static const checkboxBorder = Color(0xFFBBBBBB);

    // Cores de Fundo

    static const gradientStart = Colors.white;
    static const gradientEnd = Color(0xFFBDEDF3);
    
    static const backgroundGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gradientStart, gradientEnd],
    );

    // Erros e Alertas

    static const error = Colors.redAccent;
    static const inputFocusBorder = primaryBlue;
}