import '../models/app_user.dart';
import 'sample_data.dart';

/// Lookup for agent/landlord profiles referenced by listings.
abstract class AgentRepository {
  Future<AppUser?> fetchById(String id);
  Future<List<AppUser>> fetchAll();
  void cache(AppUser user);
}

class InMemoryAgentRepository implements AgentRepository {
  final Map<String, AppUser> _byId = {
    for (final a in seedAgents) a.id: a,
  };

  @override
  Future<AppUser?> fetchById(String id) async => _byId[id];

  @override
  Future<List<AppUser>> fetchAll() async => _byId.values.toList();

  @override
  void cache(AppUser user) => _byId[user.id] = user;
}
