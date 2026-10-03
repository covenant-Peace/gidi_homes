import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../models/enums.dart';
import 'agent_repository.dart';
import 'sample_data.dart';

/// Authentication abstraction. Default implementation is a local mock that
/// persists the signed-in user to SharedPreferences. Swap for
/// FirebaseAuthRepository (see firestore_repositories.dart) when wiring Firebase.
abstract class AuthRepository {
  Future<AppUser?> currentUser();
  Future<AppUser> signIn({required String email, required String password});
  Future<AppUser> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
    String? agencyName,
  });
  Future<AppUser> signInDemo();
  Future<void> signOut();
  Future<AppUser> updateProfile(AppUser user);
}

const _prefsKey = 'gidi_current_user';

class InMemoryAuthRepository implements AuthRepository {
  InMemoryAuthRepository(this._agents);

  final AgentRepository _agents;

  // Local account store (email -> (user, password)). Seeded with agents so you
  // can log in as any seed agent with password "password".
  final Map<String, (AppUser, String)> _accounts = {
    for (final a in seedAgents) a.email.toLowerCase(): (a, 'password'),
    demoBuyer.email.toLowerCase(): (demoBuyer, 'password'),
  };

  @override
  Future<AppUser?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return null;
    try {
      return AppUser.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AppUser> signIn(
      {required String email, required String password}) async {
    await _latency();
    final entry = _accounts[email.toLowerCase().trim()];
    if (entry == null) {
      throw AuthException('No account found for that email.');
    }
    if (entry.$2 != password) {
      throw AuthException('Incorrect password. (Hint: demo password is "password")');
    }
    await _persist(entry.$1);
    return entry.$1;
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
    await _latency();
    final key = email.toLowerCase().trim();
    if (_accounts.containsKey(key)) {
      throw AuthException('An account with that email already exists.');
    }
    final user = AppUser(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      role: role,
      agencyName: role == UserRole.agent ? agencyName?.trim() : null,
    );
    _accounts[key] = (user, password);
    if (user.isAgent) _agents.cache(user);
    await _persist(user);
    return user;
  }

  @override
  Future<AppUser> signInDemo() async {
    await _latency();
    await _persist(demoBuyer);
    return demoBuyer;
  }

  @override
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  @override
  Future<AppUser> updateProfile(AppUser user) async {
    await _latency();
    final key = user.email.toLowerCase();
    final pwd = _accounts[key]?.$2 ?? 'password';
    _accounts[key] = (user, pwd);
    if (user.isAgent) _agents.cache(user);
    await _persist(user);
    return user;
  }

  Future<void> _persist(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(user.toMap()));
  }

  Future<void> _latency() =>
      Future<void>.delayed(const Duration(milliseconds: 500));
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}
