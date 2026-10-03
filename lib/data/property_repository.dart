import '../models/property.dart';
import 'sample_data.dart';

/// Abstract data source for property listings. Two implementations exist:
///  - [InMemoryPropertyRepository] (default) — seed data, runs with no backend.
///  - FirestorePropertyRepository — see firestore_repositories.dart.
abstract class PropertyRepository {
  Future<List<Property>> fetchAll();
  Future<Property?> fetchById(String id);
  Future<List<Property>> fetchByAgent(String agentId);
  Future<void> add(Property property);
  Future<void> update(Property property);
  Future<void> delete(String id);
}

/// In-memory repository seeded with Lagos sample listings.
class InMemoryPropertyRepository implements PropertyRepository {
  InMemoryPropertyRepository() : _items = [...seedProperties];

  final List<Property> _items;

  @override
  Future<List<Property>> fetchAll() async {
    await _latency();
    return [..._items]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Property?> fetchById(String id) async {
    await _latency();
    try {
      return _items.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Property>> fetchByAgent(String agentId) async {
    await _latency();
    return _items.where((p) => p.agentId == agentId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> add(Property property) async {
    await _latency();
    _items.add(property);
  }

  @override
  Future<void> update(Property property) async {
    await _latency();
    final i = _items.indexWhere((p) => p.id == property.id);
    if (i != -1) _items[i] = property;
  }

  @override
  Future<void> delete(String id) async {
    await _latency();
    _items.removeWhere((p) => p.id == id);
  }

  // Simulate network latency so loading states are visible in the demo.
  Future<void> _latency() =>
      Future<void>.delayed(const Duration(milliseconds: 350));
}
