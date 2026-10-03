import 'enums.dart';

/// A registered user — either a buyer/renter or an agent/landlord.
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.photoUrl,
    this.agencyName,
    this.whatsapp,
    this.verified = false,
    this.bio,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? photoUrl;
  final String? agencyName; // agents only
  final String? whatsapp; // defaults to phone if null
  final bool verified;
  final String? bio;

  bool get isAgent => role == UserRole.agent;
  String get whatsappNumber => whatsapp ?? phone;

  AppUser copyWith({
    String? name,
    String? phone,
    String? photoUrl,
    String? agencyName,
    String? whatsapp,
    bool? verified,
    String? bio,
    UserRole? role,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      agencyName: agencyName ?? this.agencyName,
      whatsapp: whatsapp ?? this.whatsapp,
      verified: verified ?? this.verified,
      bio: bio ?? this.bio,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role.name,
        'photoUrl': photoUrl,
        'agencyName': agencyName,
        'whatsapp': whatsapp,
        'verified': verified,
        'bio': bio,
      };

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
        id: m['id'] as String,
        name: m['name'] as String? ?? '',
        email: m['email'] as String? ?? '',
        phone: m['phone'] as String? ?? '',
        role: UserRole.values.firstWhere(
          (r) => r.name == m['role'],
          orElse: () => UserRole.buyer,
        ),
        photoUrl: m['photoUrl'] as String?,
        agencyName: m['agencyName'] as String?,
        whatsapp: m['whatsapp'] as String?,
        verified: m['verified'] as bool? ?? false,
        bio: m['bio'] as String?,
      );
}
