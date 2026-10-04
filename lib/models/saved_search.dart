import 'property_filter.dart';

/// A persisted search (a [PropertyFilter] + a name), used to re-run a search
/// and surface "new since you saved it" counts as in-app alerts.
class SavedSearch {
  const SavedSearch({
    required this.id,
    required this.name,
    required this.filter,
    required this.createdAt,
    required this.lastSeenAt,
  });

  final String id;
  final String name;
  final PropertyFilter filter;
  final DateTime createdAt;
  final DateTime lastSeenAt; // listings newer than this count as "new"

  SavedSearch copyWith({DateTime? lastSeenAt, String? name}) => SavedSearch(
        id: id,
        name: name ?? this.name,
        filter: filter,
        createdAt: createdAt,
        lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'filter': filter.toMap(),
        'createdAt': createdAt.toIso8601String(),
        'lastSeenAt': lastSeenAt.toIso8601String(),
      };

  factory SavedSearch.fromMap(Map<String, dynamic> m) => SavedSearch(
        id: m['id'] as String,
        name: m['name'] as String? ?? 'Saved search',
        filter: PropertyFilter.fromMap(
            (m['filter'] as Map).cast<String, dynamic>()),
        createdAt:
            DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
        lastSeenAt:
            DateTime.tryParse(m['lastSeenAt'] as String? ?? '') ?? DateTime.now(),
      );
}
