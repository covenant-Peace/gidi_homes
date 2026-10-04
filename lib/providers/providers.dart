import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../data/agent_repository.dart';
import '../data/auth_repository.dart';
import '../data/chat_repository.dart';
import '../data/favorites_repository.dart';
import '../data/firestore_repositories.dart';
import '../data/inspection_repository.dart';
import '../data/property_repository.dart';
import '../data/saved_search_repository.dart';
import '../data/verification_repository.dart';
import '../models/app_user.dart';
import '../models/chat.dart';
import '../models/enums.dart';
import '../models/inspection.dart';
import '../models/property.dart';
import '../models/property_filter.dart';
import '../models/saved_search.dart';
import '../models/verification.dart';

// --------------------------------------------------------------------------
// Repositories
// --------------------------------------------------------------------------
// Backend is now Firebase (Auth + Firestore). To fall back to the offline
// in-memory seed data, swap these three for the In-Memory implementations.
final agentRepoProvider =
    Provider<AgentRepository>((ref) => FirestoreAgentRepository());

final propertyRepoProvider =
    Provider<PropertyRepository>((ref) => FirestorePropertyRepository());

final authRepoProvider = Provider<AuthRepository>(
    (ref) => FirebaseAuthRepository(ref.read(agentRepoProvider)));

final favoritesRepoProvider =
    Provider<FavoritesRepository>((ref) => FavoritesRepository());

// --------------------------------------------------------------------------
// Properties
// --------------------------------------------------------------------------
final allPropertiesProvider = FutureProvider<List<Property>>((ref) async {
  // Re-fetch whenever a mutation bumps this counter (new/edited/deleted listing).
  ref.watch(listingsRevisionProvider);
  return ref.read(propertyRepoProvider).fetchAll();
});

/// Bumped after create/update/delete to invalidate dependent providers.
final listingsRevisionProvider = StateProvider<int>((ref) => 0);

/// Only approved listings — what the public browse/search/home should show.
final publicPropertiesProvider = FutureProvider<List<Property>>((ref) async {
  final all = await ref.watch(allPropertiesProvider.future);
  return all.where((p) => p.isPublic).toList();
});

final featuredPropertiesProvider = FutureProvider<List<Property>>((ref) async {
  final all = await ref.watch(publicPropertiesProvider.future);
  final featured = all.where((p) => p.featured).toList();
  return featured.isEmpty ? all.take(5).toList() : featured;
});

final propertyByIdProvider =
    FutureProvider.family<Property?, String>((ref, id) async {
  ref.watch(listingsRevisionProvider);
  return ref.read(propertyRepoProvider).fetchById(id);
});

final agentByIdProvider =
    FutureProvider.family<AppUser?, String>((ref, id) async {
  return ref.read(agentRepoProvider).fetchById(id);
});

final agentListingsProvider =
    FutureProvider.family<List<Property>, String>((ref, agentId) async {
  ref.watch(listingsRevisionProvider);
  return ref.read(propertyRepoProvider).fetchByAgent(agentId);
});

// --------------------------------------------------------------------------
// Search / filter
// --------------------------------------------------------------------------
final filterProvider =
    StateProvider<PropertyFilter>((ref) => const PropertyFilter());

final searchResultsProvider = FutureProvider<List<Property>>((ref) async {
  final all = await ref.watch(publicPropertiesProvider.future);
  final filter = ref.watch(filterProvider);
  return filter.apply(all);
});

// --------------------------------------------------------------------------
// Auth
// --------------------------------------------------------------------------
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AppUser?>>((ref) {
  return AuthController(ref.read(authRepoProvider));
});

class AuthController extends StateNotifier<AsyncValue<AppUser?>> {
  AuthController(this._repo) : super(const AsyncValue.loading()) {
    _init();
  }

  final AuthRepository _repo;

  Future<void> _init() async {
    state = AsyncValue.data(await _repo.currentUser());
  }

  AppUser? get user => state.valueOrNull;
  bool get isSignedIn => user != null;

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(
          await _repo.signIn(email: email, password: password));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required role,
    String? agencyName,
  }) async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _repo.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
        agencyName: agencyName,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInDemo() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _repo.signInDemo());
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _repo.signInWithGoogle());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> updateProfile(AppUser user) async {
    state = AsyncValue.data(await _repo.updateProfile(user));
  }
}

// --------------------------------------------------------------------------
// Favourites
// --------------------------------------------------------------------------
final favoritesProvider =
    StateNotifierProvider<FavoritesController, Set<String>>((ref) {
  return FavoritesController(ref.read(favoritesRepoProvider));
});

class FavoritesController extends StateNotifier<Set<String>> {
  FavoritesController(this._repo) : super({}) {
    _load();
  }

  final FavoritesRepository _repo;

  Future<void> _load() async => state = await _repo.load();

  bool contains(String id) => state.contains(id);

  Future<void> toggle(String id) async {
    final next = {...state};
    if (!next.add(id)) next.remove(id);
    state = next;
    await _repo.save(next);
  }
}

/// Resolves saved ids into full [Property] objects.
final savedPropertiesProvider = FutureProvider<List<Property>>((ref) async {
  final ids = ref.watch(favoritesProvider);
  final all = await ref.watch(allPropertiesProvider.future);
  return all.where((p) => ids.contains(p.id)).toList();
});

// --------------------------------------------------------------------------
// Chat
// --------------------------------------------------------------------------
final chatRepoProvider = Provider<ChatRepository>((ref) => ChatRepository());

/// Current user's conversations (live).
final myChatsProvider = StreamProvider<List<Chat>>((ref) {
  final uid = ref.watch(authControllerProvider).valueOrNull?.id;
  if (uid == null) return Stream.value(const []);
  return ref.read(chatRepoProvider).watchChats(uid);
});

/// Messages in a chat (live).
final chatMessagesProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, chatId) {
  return ref.read(chatRepoProvider).watchMessages(chatId);
});

// --------------------------------------------------------------------------
// Inspections
// --------------------------------------------------------------------------
final inspectionRepoProvider =
    Provider<InspectionRepository>((ref) => InspectionRepository());

final myInspectionsProvider = StreamProvider<List<Inspection>>((ref) {
  final user = ref.watch(authControllerProvider).valueOrNull;
  if (user == null) return Stream.value(const []);
  final repo = ref.read(inspectionRepoProvider);
  return user.isAgent ? repo.watchForAgent(user.id) : repo.watchForBuyer(user.id);
});

// --------------------------------------------------------------------------
// Saved searches (local) + in-app alerts
// --------------------------------------------------------------------------
final savedSearchRepoProvider =
    Provider<SavedSearchRepository>((ref) => SavedSearchRepository());

final savedSearchesProvider =
    StateNotifierProvider<SavedSearchesController, List<SavedSearch>>((ref) {
  return SavedSearchesController(ref.read(savedSearchRepoProvider));
});

class SavedSearchesController extends StateNotifier<List<SavedSearch>> {
  SavedSearchesController(this._repo) : super([]) {
    _load();
  }
  final SavedSearchRepository _repo;

  Future<void> _load() async => state = await _repo.load();

  Future<void> add(PropertyFilter filter, String name) async {
    final now = DateTime.now();
    final search = SavedSearch(
      id: 's${now.microsecondsSinceEpoch}',
      name: name,
      filter: filter,
      createdAt: now,
      lastSeenAt: now,
    );
    state = [search, ...state];
    await _repo.save(state);
  }

  Future<void> remove(String id) async {
    state = state.where((s) => s.id != id).toList();
    await _repo.save(state);
  }

  Future<void> markSeen(String id) async {
    state = [
      for (final s in state)
        s.id == id ? s.copyWith(lastSeenAt: DateTime.now()) : s
    ];
    await _repo.save(state);
  }
}

/// Total count of "new since saved" listings across all saved searches (badge).
final newAlertsCountProvider = Provider<int>((ref) {
  final searches = ref.watch(savedSearchesProvider);
  final all = ref.watch(publicPropertiesProvider).valueOrNull ?? const [];
  var count = 0;
  for (final s in searches) {
    count += s.filter
        .apply(all)
        .where((p) => p.createdAt.isAfter(s.lastSeenAt))
        .length;
  }
  return count;
});

// --------------------------------------------------------------------------
// Admin / moderation / verification
// --------------------------------------------------------------------------
final isAdminProvider = Provider<bool>((ref) {
  final email = ref.watch(authControllerProvider).valueOrNull?.email;
  return AppConfig.isAdminEmail(email);
});

final pendingPropertiesProvider = FutureProvider<List<Property>>((ref) async {
  final all = await ref.watch(allPropertiesProvider.future);
  return all.where((p) => p.status == ListingStatus.pending).toList();
});

final verificationRepoProvider =
    Provider<VerificationRepository>((ref) => VerificationRepository());

/// The current agent's own verification request (if any).
final myVerificationProvider = StreamProvider<Verification?>((ref) {
  final uid = ref.watch(authControllerProvider).valueOrNull?.id;
  if (uid == null) return Stream.value(null);
  return ref.read(verificationRepoProvider).watchForAgent(uid);
});

/// Pending verification requests for admin review.
final pendingVerificationsProvider = StreamProvider<List<Verification>>((ref) {
  if (!ref.watch(isAdminProvider)) return Stream.value(const []);
  return ref.read(verificationRepoProvider).watchPending();
});
