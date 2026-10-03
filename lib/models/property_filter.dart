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
