import 'package:cloud_firestore/cloud_firestore.dart';

import 'sample_data.dart';

/// One-time helper to populate Firestore with the sample Lagos agents + listings
/// so the live app isn't empty. Run once from the /dev/seed screen while the
/// Firestore rules still allow writes, then deploy the locked-down rules.
class SeedService {
  SeedService([FirebaseFirestore? db])
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<int> run() async {
    final batch = _db.batch();

    for (final agent in seedAgents) {
      batch.set(_db.collection('users').doc(agent.id), agent.toMap());
    }
    for (final p in seedProperties) {
      batch.set(_db.collection('properties').doc(p.id), p.toMap());
    }

    await batch.commit();
    return seedAgents.length + seedProperties.length;
  }
}
