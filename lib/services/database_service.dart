// lib/services/database_service.dart
// Serviço de banco de dados com Firestore (CRUD de compromissos)

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Nome da coleção no Firestore
  static const String _collection = 'appointments';

  // ─── CREATE ────────────────────────────────────────────────────────────────
  // Adiciona um novo compromisso no Firestore
  Future<void> addAppointment(Appointment appointment) async {
    await _db.collection(_collection).add(appointment.toMap());
  }

  // ─── READ ──────────────────────────────────────────────────────────────────
  // Retorna um Stream com a lista de compromissos do usuário, ordenados por data
  // O Stream atualiza automaticamente quando os dados mudam no Firestore
  Stream<List<Appointment>> getAppointments(String userId) {
    return _db
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => Appointment.fromMap(doc.data(), doc.id))
          .toList();
      // Ordenação feita no Flutter (não precisa de índice)
      list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return list;
    });
  }

  // ─── UPDATE ────────────────────────────────────────────────────────────────
  // Atualiza um compromisso existente (usa o ID para localizar o documento)
  Future<void> updateAppointment(Appointment appointment) async {
    await _db
        .collection(_collection)
        .doc(appointment.id)
        .update(appointment.toMap());
  }

  // ─── DELETE ────────────────────────────────────────────────────────────────
  // Remove um compromisso pelo ID
  Future<void> deleteAppointment(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}
