import 'enums.dart';
import 'property.dart';

/// Immutable search/filter criteria used by the search screen.
class PropertyFilter {
  const PropertyFilter({
    this.query = '',
    this.type,
    this.area,
    this.minPrice,
    this.maxPrice,
    this.minBeds,
    this.furnishing,
    this.landTitle,
    this.sort = SortOption.newest,
  });

  final String query;
  final ListingType? type;
  final String? area;
  final int? minPrice;
  final int? maxPrice;
  final int? minBeds;
  final Furnishing? furnishing;
  final LandTitle? landTitle;
  final SortOption sort;

  bool get isEmpty =>
      query.isEmpty &&
      type == null &&
      area == null &&
      minPrice == null &&
      maxPrice == null &&
      minBeds == null &&
      furnishing == null &&
      landTitle == null;

  int get activeCount => [
        type != null,
        area != null,
        minPrice != null,
        maxPrice != null,
        minBeds != null,
        furnishing != null,
        landTitle != null,
      ].where((e) => e).length;

  PropertyFilter copyWith({
    String? query,
    Object? type = _sentinel,
    Object? area = _sentinel,
    Object? minPrice = _sentinel,
    Object? maxPrice = _sentinel,
    Object? minBeds = _sentinel,
    Object? furnishing = _sentinel,
    Object? landTitle = _sentinel,
    SortOption? sort,
  }) {
    return PropertyFilter(
      query: query ?? this.query,
      type: type == _sentinel ? this.type : type as ListingType?,
      area: area == _sentinel ? this.area : area as String?,
      minPrice: minPrice == _sentinel ? this.minPrice : minPrice as int?,
      maxPrice: maxPrice == _sentinel ? this.maxPrice : maxPrice as int?,
      minBeds: minBeds == _sentinel ? this.minBeds : minBeds as int?,
      furnishing:
          furnishing == _sentinel ? this.furnishing : furnishing as Furnishing?,
      landTitle:
          landTitle == _sentinel ? this.landTitle : landTitle as LandTitle?,
      sort: sort ?? this.sort,
    );
  }

  /// Short human-readable summary, e.g. "Rent · Lekki Phase 1 · 2+ beds".
  String get summary {
    final parts = <String>[];
    if (type != null) parts.add(type!.label);
    if (area != null) parts.add(area!);
    if (minBeds != null) parts.add('$minBeds+ beds');
    if (minPrice != null || maxPrice != null) {
      parts.add('₦${minPrice ?? 0}–${maxPrice ?? '∞'}');
    }
    if (furnishing != null) parts.add(furnishing!.label);
    if (landTitle != null) parts.add(landTitle!.label);
    if (query.isNotEmpty) parts.add('"$query"');
    return parts.isEmpty ? 'All listings' : parts.join(' · ');
  }

  Map<String, dynamic> toMap() => {
        'query': query,
        'type': type?.name,
        'area': area,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'minBeds': minBeds,
        'furnishing': furnishing?.name,
        'landTitle': landTitle?.name,
        'sort': sort.name,
      };

  factory PropertyFilter.fromMap(Map<String, dynamic> m) => PropertyFilter(
        query: m['query'] as String? ?? '',
        type: _byName(ListingType.values, m['type']),
        area: m['area'] as String?,
        minPrice: (m['minPrice'] as num?)?.toInt(),
        maxPrice: (m['maxPrice'] as num?)?.toInt(),
        minBeds: (m['minBeds'] as num?)?.toInt(),
        furnishing: _byName(Furnishing.values, m['furnishing']),
        landTitle: _byName(LandTitle.values, m['landTitle']),
        sort: _byName(SortOption.values, m['sort']) ?? SortOption.newest,
      );

  /// Apply this filter to a list and return the matching, sorted result.
  List<Property> apply(List<Property> source) {
    final q = query.trim().toLowerCase();
    var out = source.where((p) {
      if (type != null && p.type != type) return false;
      if (area != null && p.area != area) return false;
      if (minPrice != null && p.price < minPrice!) return false;
      if (maxPrice != null && p.price > maxPrice!) return false;
      if (minBeds != null && p.bedrooms < minBeds!) return false;
      if (furnishing != null && p.furnishing != furnishing) return false;
      if (landTitle != null && p.landTitle != landTitle) return false;
      if (q.isNotEmpty) {
        final hay = '${p.title} ${p.area} ${p.address} ${p.description}'
            .toLowerCase();
        if (!hay.contains(q)) return false;
      }
      return true;
    }).toList();

    switch (sort) {
      case SortOption.newest:
        out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case SortOption.priceLow:
        out.sort((a, b) => a.price.compareTo(b.price));
      case SortOption.priceHigh:
        out.sort((a, b) => b.price.compareTo(a.price));
    }
    return out;
  }
}

const _sentinel = Object();

T? _byName<T extends Enum>(List<T> values, Object? name) {
  if (name == null) return null;
  for (final v in values) {
    if (v.name == name) return v;
  }
  return null;
}
