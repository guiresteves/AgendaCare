import 'package:flutter/material.dart';

/// Modelo simples de pessoa para uso nos mocks.
/// Quando integrar Firebase, substitua por um modelo vindo do Firestore.
class MockPerson {
  const MockPerson({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarColor,
    required this.initials,
  });

  final String id;
  final String name;
  final String role;
  final Color avatarColor;
  final String initials;
}

// ── Dados mockados ────────────────────────────────────────────────────────────

const mockResponsaveis = [
  MockPerson(
    id: 'ga',
    name: 'Gabriel Augusto',
    role: 'Responsável',
    avatarColor: Color(0xFFE57FAA),
    initials: 'GA',
  ),
  MockPerson(
    id: 'kg',
    name: 'Kauan Gabriel',
    role: 'Responsável',
    avatarColor: Color(0xFF7B9FE0),
    initials: 'KG',
  ),
  MockPerson(
    id: 'lm',
    name: 'Leonidas Moreira',
    role: 'Responsável',
    avatarColor: Color(0xFF6DC4A8),
    initials: 'LM',
  ),
];

const mockDependentes = [
  MockPerson(
    id: 'im',
    name: 'Iago Messias',
    role: 'Dependente',
    avatarColor: Color(0xFF7B9FE0),
    initials: 'IM',
  ),
  MockPerson(
    id: 'gm',
    name: 'Gustavo Menezes',
    role: 'Dependente',
    avatarColor: Color(0xFF6DC4A8),
    initials: 'GM',
  ),
];

/// Map para busca rápida por ID — usado no home para resolver iniciais
final mockPeopleById = {
  'ga': mockResponsaveis[0],
  'kg': mockResponsaveis[1],
  'lm': mockResponsaveis[2],
  'im': mockDependentes[0],
  'gm': mockDependentes[1],
};