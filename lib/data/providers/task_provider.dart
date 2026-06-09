import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../models/person_model.dart';

class TaskProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<String?> _getGrupoId() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final userDoc = await _db.collection('usuarios').doc(user.uid).get();
    return userDoc.data()?['grupoId'] as String?;
  }

  Future<CollectionReference?> _tasksRef() async {
    final grupoId = await _getGrupoId();
    if (grupoId == null || grupoId.isEmpty) return null;
    return _db.collection('grupos').doc(grupoId).collection('tarefas');
  }

  Stream<List<TaskModel>> tasksStream() async* {
    final grupoId = await _getGrupoId();
    if (grupoId == null || grupoId.isEmpty) {
      yield [];
      return;
    }
    yield* _db
        .collection('grupos')
        .doc(grupoId)
        .collection('tarefas')
        .orderBy('date')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => TaskModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<PersonModel>> responsaveisStream() async* {
    final grupoId = await _getGrupoId();
    if (grupoId == null || grupoId.isEmpty) {
      yield [];
      return;
    }
    yield* _db
        .collection('grupos')
        .doc(grupoId)
        .collection('membros')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => PersonModel.fromMemberMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<PersonModel>> dependentesStream() async* {
    final grupoId = await _getGrupoId();
    if (grupoId == null || grupoId.isEmpty) {
      yield [];
      return;
    }
    yield* _db
        .collection('grupos')
        .doc(grupoId)
        .collection('dependentes')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => PersonModel.fromDependentMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> addTask(TaskModel task) async {
    try {
      final ref = await _tasksRef();
      if (ref == null) return;

      final user = _auth.currentUser;
      String? creatorName;

      if (user != null) {
        final userDoc = await _db.collection('usuarios').doc(user.uid).get();
        creatorName = userDoc.data()?['nome'] as String?;
      }

      final taskWithCreator = task.copyWith(
        createdById: user?.uid,
        createdByName: creatorName,
      );

      await ref.add(taskWithCreator.toMap());
    } catch (e) {
      debugPrint('Erro ao adicionar tarefa: $e');
    }
  }

  Future<void> updateTask(TaskModel updated) async {
    try {
      final ref = await _tasksRef();
      if (ref == null) return;
      await ref.doc(updated.id).update(updated.toMap());
    } catch (e) {
      debugPrint('Erro ao atualizar tarefa: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      final ref = await _tasksRef();
      if (ref == null) return;
      await ref.doc(id).delete();
    } catch (e) {
      debugPrint('Erro ao excluir tarefa: $e');
    }
  }

  Future<void> toggleConfirmTask(String id, bool currentValue) async {
    try {
      final ref = await _tasksRef();
      if (ref == null) return;

      final user = _auth.currentUser;
      if (user == null) return;

      // Busca a tarefa para validar responsável
      final doc = await ref.doc(id).get();
      final task = TaskModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      if (!task.responsibleIds.contains(user.uid)) {
        debugPrint('Usuário não é responsável por esta tarefa.');
        return;
      }

      if (currentValue) {
        // Desmarcando — limpa os dados de confirmação
        await ref.doc(id).update({
          'isConfirmed': false,
          'confirmedById': FieldValue.delete(),
          'confirmedByName': FieldValue.delete(),
          'confirmedAt': FieldValue.delete(),
        });
      } else {
        // Confirmando — grava auditoria
        final userDoc = await _db.collection('usuarios').doc(user.uid).get();
        final confirmerName = userDoc.data()?['nome'] as String?;

        await ref.doc(id).update({
          'isConfirmed': true,
          'confirmedById': user.uid,
          'confirmedByName': confirmerName,
          'confirmedAt': Timestamp.fromDate(DateTime.now()),
        });
      }
    } catch (e) {
      debugPrint('Erro ao confirmar tarefa: $e');
    }
  }
}