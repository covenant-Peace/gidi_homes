// Firebase-backed implementations of the app's repositories.
//
// These are NOT wired in by default — the app ships running on in-memory seed
// data so it works with zero backend setup (great for demos and review).
//
// To switch the whole app onto Firebase:
//   1. flutter pub add firebase_core firebase_auth cloud_firestore firebase_storage
//      (already in pubspec.yaml)
//   2. Install the FlutterFire CLI and run:  flutterfire configure
//      → this generates lib/firebase_options.dart
//   3. In main.dart, before runApp():
//        await Firebase.initializeApp(
//          options: DefaultFirebaseOptions.currentPlatform,
//        );
//   4. In lib/providers/providers.dart, swap the repository providers:
//        final propertyRepoProvider =
//            Provider<PropertyRepository>((ref) => FirestorePropertyRepository());
//        final agentRepoProvider =
//            Provider<AgentRepository>((ref) => FirestoreAgentRepository());
//        final authRepoProvider = Provider<AuthRepository>(
//            (ref) => FirebaseAuthRepository(ref.read(agentRepoProvider)));
//
// Firestore layout:
//   properties/{id}   → Property.toMap()
//   users/{uid}       → AppUser.toMap()
//
// Suggested security rules are in firestore.rules (see README).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import '../models/app_user.dart';
import '../models/enums.dart';
import '../models/property.dart';
import 'agent_repository.dart';
import 'auth_repository.dart';
import 'property_repository.dart';

// ---------------------------------------------------------------------------
// Properties
// ---------------------------------------------------------------------------
class FirestorePropertyRepository implements PropertyRepository {
  FirestorePropertyRepository([FirebaseFirestore? db])
      : _col = (db ?? FirebaseFirestore.instance).collection('properties');

  final CollectionReference<Map<String, dynamic>> _col;

  @override
  Future<List<Property>> fetchAll() async {
    final snap = await _col.orderBy('createdAt', descending: true).get();
    return snap.docs.map((d) => Property.fromMap(d.data())).toList();
  }

  @override
  Future<Property?> fetchById(String id) async {
    final doc = await _col.doc(id).get();
    return doc.exists ? Property.fromMap(doc.data()!) : null;
  }

  @override
  Future<List<Property>> fetchByAgent(String agentId) async {
    final snap = await _col
        .where('agentId', isEqualTo: agentId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => Property.fromMap(d.data())).toList();
  }

  @override
  Future<void> add(Property property) => _col.doc(property.id).set(property.toMap());

  @override
  Future<void> update(Property property) =>
      _col.doc(property.id).update(property.toMap());

  @override
  Future<void> delete(String id) => _col.doc(id).delete();
}

// ---------------------------------------------------------------------------
// Agents / user profiles
// ---------------------------------------------------------------------------
class FirestoreAgentRepository implements AgentRepository {
  FirestoreAgentRepository([FirebaseFirestore? db])
      : _col = (db ?? FirebaseFirestore.instance).collection('users');

  final CollectionReference<Map<String, dynamic>> _col;
  final Map<String, AppUser> _cache = {};

  @override
  Future<AppUser?> fetchById(String id) async {
    if (_cache.containsKey(id)) return _cache[id];
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    final user = AppUser.fromMap(doc.data()!);
    _cache[id] = user;
    return user;
  }

  @override
  Future<List<AppUser>> fetchAll() async {
    final snap = await _col.where('role', isEqualTo: 'agent').get();
    return snap.docs.map((d) => AppUser.fromMap(d.data())).toList();
  }

  @override
  void cache(AppUser user) => _cache[user.id] = user;
}

// ---------------------------------------------------------------------------
// Auth
// ---------------------------------------------------------------------------
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._agents, {FirebaseAuth? auth, FirebaseFirestore? db})
      : _auth = auth ?? FirebaseAuth.instance,
        _users = (db ?? FirebaseFirestore.instance).collection('users');

  final AgentRepository _agents;
  final FirebaseAuth _auth;
  final CollectionReference<Map<String, dynamic>> _users;

  @override
  Future<AppUser?> currentUser() async {
    final u = _auth.currentUser;
    if (u == null) return null;
    final doc = await _users.doc(u.uid).get();
    return doc.exists ? AppUser.fromMap(doc.data()!) : null;
  }

  @override
  Future<AppUser> signIn(
      {required String email, required String password}) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final doc = await _users.doc(cred.user!.uid).get();
      if (!doc.exists) throw AuthException('Profile not found.');
      return AppUser.fromMap(doc.data()!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign-in failed.');
    }
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
    String? agencyName,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final user = AppUser(
        id: cred.user!.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        agencyName: role == UserRole.agent ? agencyName : null,
      );
      await _users.doc(user.id).set(user.toMap());
      _agents.cache(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Registration failed.');
    }
  }

  @override
  Future<AppUser> signInDemo() async {
    final cred = await _auth.signInAnonymously();
    final user = AppUser(
      id: cred.user!.uid,
      name: 'Guest',
      email: 'guest@gidihomes.ng',
      phone: '',
      role: UserRole.buyer,
    );
    await _users.doc(user.id).set(user.toMap());
    return user;
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      final UserCredential cred;
      if (kIsWeb) {
        // Popup flow handled entirely by Firebase on web.
        cred = await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) throw AuthException('Sign-in cancelled.');
        final googleAuth = await googleUser.authentication;
        cred = await _auth.signInWithCredential(
          GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          ),
        );
      }
      final fbUser = cred.user!;
      final docRef = _users.doc(fbUser.uid);
      final doc = await docRef.get();
      if (doc.exists) return AppUser.fromMap(doc.data()!);

      // First Google sign-in → create a buyer profile.
      final user = AppUser(
        id: fbUser.uid,
        name: fbUser.displayName ?? 'User',
        email: fbUser.email ?? '',
        phone: fbUser.phoneNumber ?? '',
        role: UserRole.buyer,
        photoUrl: fbUser.photoURL,
      );
      await docRef.set(user.toMap());
      _agents.cache(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Google sign-in failed.');
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<AppUser> updateProfile(AppUser user) async {
    await _users.doc(user.id).set(user.toMap(), SetOptions(merge: true));
    _agents.cache(user);
    return user;
  }
}
