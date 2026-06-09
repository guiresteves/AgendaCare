import 'package:flutter/material.dart';

class PersonModel {
  const PersonModel({
    required this.id,
    required this.name,
    required this.role,
    required this.initials,
    required this.avatarColor,
  });

  final String id;
  final String name;
  final String role;
  final String initials;
  final Color avatarColor;

  factory PersonModel.fromMemberMap(String id, Map<String, dynamic> map) {
    final name = map['nome'] as String? ?? '';
    return PersonModel(
      id: id,
      name: name,
      role: 'Responsável',
      initials: _initials(name),
      avatarColor: const Color(0xFFE57FAA), // rosa — responsáveis
    );
  }


  factory PersonModel.fromDependentMap(String id, Map<String, dynamic> map) {
    final name = map['nome'] as String? ?? '';
    return PersonModel(
      id: id,
      name: name,
      role: 'Dependente',
      initials: _initials(name),
      avatarColor: const Color(0xFF7B9FE0), // azul — dependentes
    );
  }

  /// Gera as iniciais a partir do nome completo
  static String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (name.length >= 2) return name.substring(0, 2).toUpperCase();
    return name.toUpperCase();
  }
}