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
    this.createdById,      // ← novo
    this.createdByName,    // ← novo
    this.confirmedById,    // ← novo
    this.confirmedByName,  // ← novo
    this.confirmedAt,
  });

  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay time;
  final List<String> responsibleIds;
  final List<String> dependentIds;
  final bool isConfirmed;

  // Auditoria
  final String? createdById;
  final String? createdByName;
  final String? confirmedById;
  final String? confirmedByName;
  final DateTime? confirmedAt;

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

      // Auditoria
      if (createdById != null) 'createdById': createdById,
      if (createdByName != null) 'createdByName': createdByName,
      if (confirmedById != null) 'confirmedById': confirmedById,
      if (confirmedByName != null) 'confirmedByName': confirmedByName,
      if (confirmedAt != null) 'confirmedAt': Timestamp.fromDate(confirmedAt!),
    };
  }

  // ── Converte de Map — usado ao ler do Firestore 
  factory TaskModel.fromMap(String id, Map<String, dynamic> map) {
    final timestamp = map['date'] as Timestamp?;
    final confirmedAtTs = map['confirmedAt'] as Timestamp?;

    return TaskModel(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      date: timestamp?.toDate() ?? DateTime.now(),
      time: TimeOfDay(
        hour: map['timeHour'] as int? ?? 0,
        minute: map['timeMinute'] as int? ?? 0,
      ),
      responsibleIds: List<String>.from(map['responsibleIds'] ?? []),
      dependentIds: List<String>.from(map['dependentIds'] ?? []),
      isConfirmed: map['isConfirmed'] as bool? ?? false,
      // Auditoria
      createdById: map['createdById'] as String?,
      createdByName: map['createdByName'] as String?,
      confirmedById: map['confirmedById'] as String?,
      confirmedByName: map['confirmedByName'] as String?,
      confirmedAt: confirmedAtTs?.toDate(),
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
    String? createdById,
    String? createdByName,
    String? confirmedById,
    String? confirmedByName,
    DateTime? confirmedAt,
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
      createdById: createdById ?? this.createdById,
      createdByName: createdByName ?? this.createdByName,
      confirmedById: confirmedById ?? this.confirmedById,
      confirmedByName: confirmedByName ?? this.confirmedByName,
      confirmedAt: confirmedAt ?? this.confirmedAt,
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