import 'package:latlong2/latlong.dart';

import 'enums.dart';

/// A property listing: rent, shortlet, or land.
class Property {
  const Property({
    required this.id,
    required this.title,
    required this.type,
    required this.price,
    required this.area,
    required this.address,
    required this.description,
    required this.images,
    required this.agentId,
    required this.lat,
    required this.lng,
    required this.createdAt,
    this.bedrooms = 0,
    this.bathrooms = 0,
    this.toilets = 0,
    this.sizeSqm,
    this.furnishing,
    this.landTitle,
    this.amenities = const [],
    this.featured = false,
    this.serviceCharge,
    this.videos = const [],
  });

  final String id;
  final String title;
  final ListingType type;

  /// Price in Naira. Rent = per year, shortlet = per night, land = total.
  final int price;

  final String area; // Lagos locality name
  final String address;
  final String description;
  final List<String> images;
  final String agentId;
  final double lat;
  final double lng;
  final DateTime createdAt;

  // Buildings (rent / shortlet)
  final int bedrooms;
  final int bathrooms;
  final int toilets;
  final Furnishing? furnishing;

  // Land
  final double? sizeSqm;
  final LandTitle? landTitle;

  final List<String> amenities;
  final bool featured;
  final int? serviceCharge; // annual, naira — common for Lagos estates
  final List<String> videos; // Cloudinary video URLs (tours)

  LatLng get latLng => LatLng(lat, lng);
  bool get isLand => type == ListingType.land;
  String? get coverImage => images.isNotEmpty ? images.first : null;
  bool get hasVideo => videos.isNotEmpty;

  Property copyWith({
    String? title,
    ListingType? type,
    int? price,
    String? area,
    String? address,
    String? description,
    List<String>? images,
    int? bedrooms,
    int? bathrooms,
    int? toilets,
    double? sizeSqm,
    Furnishing? furnishing,
    LandTitle? landTitle,
    List<String>? amenities,
    bool? featured,
    int? serviceCharge,
    double? lat,
    double? lng,
    List<String>? videos,
  }) {
    return Property(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      price: price ?? this.price,
      area: area ?? this.area,
      address: address ?? this.address,
      description: description ?? this.description,
      images: images ?? this.images,
      agentId: agentId,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      createdAt: createdAt,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      toilets: toilets ?? this.toilets,
      sizeSqm: sizeSqm ?? this.sizeSqm,
      furnishing: furnishing ?? this.furnishing,
      landTitle: landTitle ?? this.landTitle,
      amenities: amenities ?? this.amenities,
      featured: featured ?? this.featured,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      videos: videos ?? this.videos,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'type': type.name,
        'price': price,
        'area': area,
        'address': address,
        'description': description,
        'images': images,
        'agentId': agentId,
        'lat': lat,
        'lng': lng,
        'createdAt': createdAt.toIso8601String(),
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'toilets': toilets,
        'sizeSqm': sizeSqm,
        'furnishing': furnishing?.name,
        'landTitle': landTitle?.name,
        'amenities': amenities,
        'featured': featured,
        'serviceCharge': serviceCharge,
        'videos': videos,
      };

  factory Property.fromMap(Map<String, dynamic> m) => Property(
        id: m['id'] as String,
        title: m['title'] as String? ?? '',
        type: ListingType.values.firstWhere(
          (t) => t.name == m['type'],
          orElse: () => ListingType.rent,
        ),
        price: (m['price'] as num?)?.toInt() ?? 0,
        area: m['area'] as String? ?? '',
        address: m['address'] as String? ?? '',
        description: m['description'] as String? ?? '',
        images: (m['images'] as List?)?.cast<String>() ?? const [],
        agentId: m['agentId'] as String? ?? '',
        lat: (m['lat'] as num?)?.toDouble() ?? 6.5244,
        lng: (m['lng'] as num?)?.toDouble() ?? 3.3792,
        createdAt:
            DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
        bedrooms: (m['bedrooms'] as num?)?.toInt() ?? 0,
        bathrooms: (m['bathrooms'] as num?)?.toInt() ?? 0,
        toilets: (m['toilets'] as num?)?.toInt() ?? 0,
        sizeSqm: (m['sizeSqm'] as num?)?.toDouble(),
        furnishing: _enumOrNull(Furnishing.values, m['furnishing']),
        landTitle: _enumOrNull(LandTitle.values, m['landTitle']),
        amenities: (m['amenities'] as List?)?.cast<String>() ?? const [],
        featured: m['featured'] as bool? ?? false,
        serviceCharge: (m['serviceCharge'] as num?)?.toInt(),
        videos: (m['videos'] as List?)?.cast<String>() ?? const [],
      );
}

T? _enumOrNull<T extends Enum>(List<T> values, Object? name) {
  if (name == null) return null;
  for (final v in values) {
    if (v.name == name) return v;
  }
  return null;
}
