import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/enums.dart';
import '../models/verification.dart';

/// Firestore-backed agent verification requests.
///   verifications/{agentId} → Verification.toMap()
/// Approving also flips users/{agentId}.verified (admin-only via rules).
class VerificationRepository {
  VerificationRepository([FirebaseFirestore? db])
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('verifications');

  Future<void> submit(Verification v) => _col.doc(v.agentId).set(v.toMap());

  Stream<Verification?> watchForAgent(String agentId) {
    return _col.doc(agentId).snapshots().map(
        (d) => d.exists ? Verification.fromMap(d.data()!) : null);
  }

  Stream<List<Verification>> watchPending() {
    return _col
        .where('status', isEqualTo: VerificationStatus.pending.name)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) => Verification.fromMap(d.data())).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    });
  }

  Future<void> approve(String agentId) async {
    await _col.doc(agentId).update({'status': VerificationStatus.approved.name});
    await _db.collection('users').doc(agentId).update({'verified': true});
  }

  Future<void> reject(String agentId, String note) async {
    await _col.doc(agentId).update({
      'status': VerificationStatus.rejected.name,
      'reviewNote': note,
    });
    await _db.collection('users').doc(agentId).update({'verified': false});
  }
}
