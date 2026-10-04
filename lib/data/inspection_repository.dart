import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/inspection.dart';

/// Firestore-backed inspection requests.  inspections/{id} → Inspection.toMap()
class InspectionRepository {
  InspectionRepository([FirebaseFirestore? db])
      : _col = (db ?? FirebaseFirestore.instance).collection('inspections');

  final CollectionReference<Map<String, dynamic>> _col;

  Future<void> create(Inspection inspection) =>
      _col.doc(inspection.id).set(inspection.toMap());

  /// Requests made by a buyer.
  Stream<List<Inspection>> watchForBuyer(String buyerId) {
    return _col.where('buyerId', isEqualTo: buyerId).snapshots().map(_sorted);
  }

  /// Requests received by an agent.
  Stream<List<Inspection>> watchForAgent(String agentId) {
    return _col.where('agentId', isEqualTo: agentId).snapshots().map(_sorted);
  }

  Future<void> updateStatus(String id, InspectionStatus status) =>
      _col.doc(id).update({'status': status.name});

  List<Inspection> _sorted(QuerySnapshot<Map<String, dynamic>> snap) {
    final list = snap.docs.map((d) => Inspection.fromMap(d.data())).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }
}
