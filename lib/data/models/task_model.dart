import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskModel {
  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.responsibleIds,
    required this.dependentIds,
    this.isConfirmed = false,
  });

  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay time;
  final List<String> responsibleIds;
  final List<String> dependentIds;
  final bool isConfirmed;

  // ── Converte para Map 
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      // Salva a data como Timestamp
      'date': Timestamp.fromDate(date),
      // Salva hora e minuto separados
      'timeHour': time.hour,
      'timeMinute': time.minute,
      'responsibleIds': responsibleIds,
      'dependentIds': dependentIds,
      'isConfirmed': isConfirmed,
    };
  }

  // ── Converte de Map — usado ao ler do Firestore 
  factory TaskModel.fromMap(String id, Map<String, dynamic> map) {
    // Lê a data como Timestamp e converte para DateTime
    final timestamp = map['date'] as Timestamp?;
    final date = timestamp?.toDate() ?? DateTime.now();

    return TaskModel(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      date: date,
      time: TimeOfDay(
        hour: map['timeHour'] as int? ?? 0,
        minute: map['timeMinute'] as int? ?? 0,
      ),
      responsibleIds: List<String>.from(map['responsibleIds'] ?? []),
      dependentIds: List<String>.from(map['dependentIds'] ?? []),
      isConfirmed: map['isConfirmed'] as bool? ?? false,
    );
  }

  // ── Cria uma cópia com campos alterados 
  TaskModel copyWith({
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? time,
    List<String>? responsibleIds,
    List<String>? dependentIds,
    bool? isConfirmed,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      responsibleIds: responsibleIds ?? this.responsibleIds,
      dependentIds: dependentIds ?? this.dependentIds,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }

  // ── Formatações 
  String get formattedDate {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  String get formattedTime {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}