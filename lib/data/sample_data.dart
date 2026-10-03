import '../models/app_user.dart';
import '../models/enums.dart';
import '../models/lagos_areas.dart';
import '../models/property.dart';
import 'property_images.dart';

/// Curated, themed demo images that always load (see property_images.dart).
/// Swap these for Firebase Storage URLs once real photos are uploaded.
List<String> _imgs(String id, ListingType type, {int count = 4}) =>
    imagesFor(type, seedFromId(id), count: count);

double _lat(String area) => (findArea(area)?.center.latitude ?? 6.5244);
double _lng(String area) => (findArea(area)?.center.longitude ?? 3.3792);

DateTime _ago(int days) => DateTime.now().subtract(Duration(days: days));

/// Seed agents / landlords.
final List<AppUser> seedAgents = [
  const AppUser(
    id: 'agent_chinwe',
    name: 'Chinwe Okonkwo',
    email: 'chinwe@primelekki.ng',
    phone: '+2348031234567',
    whatsapp: '+2348031234567',
    role: UserRole.agent,
    agencyName: 'Prime Lekki Realty',
    verified: true,
    bio:
        'Island-focused agency with 8+ years letting and selling in Lekki, Ikoyi and VI. RICS-trained team.',
    photoUrl: 'https://i.pravatar.cc/200?img=47',
  ),
  const AppUser(
    id: 'agent_tunde',
    name: 'Tunde Bakare',
    email: 'tunde@bakareco.ng',
    phone: '+2348097654321',
    whatsapp: '+2348097654321',
    role: UserRole.agent,
    agencyName: 'Bakare & Co Properties',
    verified: true,
    bio: 'Trusted land and estate specialist across the Lekki–Epe corridor.',
    photoUrl: 'https://i.pravatar.cc/200?img=12',
  ),
  const AppUser(
    id: 'agent_amaka',
    name: 'Amaka Eze',
    email: 'amaka@islandhomes.ng',
    phone: '+2348065551212',
    whatsapp: '+2348065551212',
    role: UserRole.agent,
    agencyName: 'Island Homes NG',
    verified: false,
    bio: 'Shortlets and serviced apartments for business and leisure stays.',
    photoUrl: 'https://i.pravatar.cc/200?img=32',
  ),
  const AppUser(
    id: 'agent_ibrahim',
    name: 'Ibrahim Yusuf',
    email: 'ibrahim@mainlandshelter.ng',
    phone: '+2348023339988',
    whatsapp: '+2348023339988',
    role: UserRole.agent,
    agencyName: 'Mainland Shelter',
    verified: true,
    bio: 'Affordable homes across Yaba, Surulere, Gbagada and Ikeja.',
    photoUrl: 'https://i.pravatar.cc/200?img=68',
  ),
];

/// A demo buyer account (used for the "sign in as demo" shortcut).
const demoBuyer = AppUser(
  id: 'user_demo',
  name: 'Demo User',
  email: 'demo@gidihomes.ng',
  phone: '+2348000000000',
  role: UserRole.buyer,
);

Property _p({
  required String id,
  required String title,
  required ListingType type,
  required int price,
  required String area,
  required String address,
  required String agentId,
  required String description,
  int beds = 0,
  int baths = 0,
  int toilets = 0,
  double? sqm,
  Furnishing? furnishing,
  LandTitle? title2,
  List<String> amenities = const [],
  bool featured = false,
  int? serviceCharge,
  required int ageDays,
}) {
  return Property(
    id: id,
    title: title,
    type: type,
    price: price,
    area: area,
    address: address,
    description: description,
    images: _imgs(id, type),
    agentId: agentId,
    lat: _lat(area),
    lng: _lng(area),
    createdAt: _ago(ageDays),
    bedrooms: beds,
    bathrooms: baths,
    toilets: toilets,
    sizeSqm: sqm,
    furnishing: furnishing,
    landTitle: title2,
    amenities: amenities,
    featured: featured,
    serviceCharge: serviceCharge,
  );
}

final List<Property> seedProperties = [
  // ---------------- RENT (yearly) ----------------
  _p(
    id: 'r1',
    title: '3 Bedroom Apartment with BQ',
    type: ListingType.rent,
    price: 4500000,
    area: 'Lekki Phase 1',
    address: 'Off Admiralty Way, Lekki Phase 1',
    agentId: 'agent_chinwe',
    beds: 3,
    baths: 3,
    toilets: 4,
    furnishing: Furnishing.serviced,
    featured: true,
    serviceCharge: 800000,
    amenities: ['24/7 Power', 'Swimming Pool', 'Gym', 'CCTV', 'Parking (3)', 'Elevator'],
    ageDays: 2,
    description:
        'Spacious serviced 3-bedroom apartment in a secure estate off Admiralty Way. '
        'All rooms en-suite, fitted kitchen, generous living area and a boys\' quarters. '
        'Constant power via estate generator and an inverter backup. Walking distance to Circle Mall.',
  ),
  _p(
    id: 'r2',
    title: '2 Bedroom Flat',
    type: ListingType.rent,
    price: 1800000,
    area: 'Yaba',
    address: 'Alagomeji, Yaba',
    agentId: 'agent_ibrahim',
    beds: 2,
    baths: 2,
    toilets: 3,
    furnishing: Furnishing.unfurnished,
    amenities: ['Borehole', 'Prepaid Meter', 'Parking (2)', 'Gated'],
    ageDays: 6,
    description:
        'Neat 2-bedroom flat in a quiet compound at Alagomeji. Close to the University of Lagos, '
        'Yaba tech cluster and the rail station. Prepaid meter and reliable water supply.',
  ),
  _p(
    id: 'r3',
    title: '4 Bedroom Terrace Duplex',
    type: ListingType.rent,
    price: 7000000,
    area: 'Ikate',
    address: 'Ikate Elegushi, Lekki',
    agentId: 'agent_chinwe',
    beds: 4,
    baths: 4,
    toilets: 5,
    furnishing: Furnishing.semiFurnished,
    featured: true,
    serviceCharge: 1200000,
    amenities: ['24/7 Power', 'Swimming Pool', 'Gym', 'CCTV', 'Parking (4)', 'Playground'],
    ageDays: 1,
    description:
        'Contemporary 4-bedroom terrace in a gated Ikate development. Fully fitted kitchen, '
        'family lounge, en-suite rooms and a rooftop terrace. Shared pool and gym on site.',
  ),
  _p(
    id: 'r4',
    title: 'Mini Flat (1 Bedroom)',
    type: ListingType.rent,
    price: 900000,
    area: 'Surulere',
    address: 'Adeniran Ogunsanya, Surulere',
    agentId: 'agent_ibrahim',
    beds: 1,
    baths: 1,
    toilets: 1,
    furnishing: Furnishing.unfurnished,
    amenities: ['Prepaid Meter', 'Borehole', 'Gated'],
    ageDays: 10,
    description:
        'Affordable mini flat just off Adeniran Ogunsanya, minutes from Shoprite and the '
        'business district. Tiled throughout, with a private kitchen and bathroom.',
  ),
  _p(
    id: 'r5',
    title: '5 Bedroom Detached Duplex',
    type: ListingType.rent,
    price: 25000000,
    area: 'Ikoyi',
    address: 'Bourdillon Road, Ikoyi',
    agentId: 'agent_chinwe',
    beds: 5,
    baths: 6,
    toilets: 6,
    furnishing: Furnishing.furnished,
    featured: true,
    serviceCharge: 3000000,
    amenities: ['24/7 Power', 'Swimming Pool', 'Gym', 'Cinema', 'CCTV', 'Parking (6)', 'BQ'],
    ageDays: 4,
    description:
        'Luxury fully-furnished 5-bedroom detached house on Bourdillon. Private pool, cinema room, '
        'elevator, staff quarters and ample parking. Premium Ikoyi address with top security.',
  ),
  _p(
    id: 'r6',
    title: '2 Bedroom Apartment',
    type: ListingType.rent,
    price: 3200000,
    area: 'Ikeja GRA',
    address: 'Oduduwa Crescent, Ikeja GRA',
    agentId: 'agent_ibrahim',
    beds: 2,
    baths: 2,
    toilets: 3,
    furnishing: Furnishing.semiFurnished,
    amenities: ['24/7 Power', 'CCTV', 'Parking (2)', 'Gated'],
    ageDays: 8,
    description:
        'Well-finished 2-bedroom in the serene Ikeja GRA. Quiet, leafy street close to the airport, '
        'Sheraton and Alausa secretariat. Estate security and treated water.',
  ),
  _p(
    id: 'r7',
    title: 'Self-Contain (Studio)',
    type: ListingType.rent,
    price: 650000,
    area: 'Gbagada',
    address: 'Medina Estate, Gbagada',
    agentId: 'agent_ibrahim',
    beds: 1,
    baths: 1,
    toilets: 1,
    furnishing: Furnishing.unfurnished,
    amenities: ['Prepaid Meter', 'Borehole'],
    ageDays: 14,
    description:
        'Budget-friendly self-contained studio in Medina Estate. Good for a young professional; '
        'quick access to the Third Mainland Bridge and Oworonshoki.',
  ),
  _p(
    id: 'r8',
    title: '3 Bedroom Flat',
    type: ListingType.rent,
    price: 3500000,
    area: 'Magodo',
    address: 'Magodo Phase 2, Shangisha',
    agentId: 'agent_ibrahim',
    beds: 3,
    baths: 3,
    toilets: 4,
    furnishing: Furnishing.unfurnished,
    serviceCharge: 400000,
    amenities: ['24/7 Power', 'CCTV', 'Parking (3)', 'Gated', 'Borehole'],
    ageDays: 5,
    description:
        'Roomy 3-bedroom flat in the secure Magodo Phase 2 (Shangisha). Spacious rooms, fitted kitchen '
        'and a balcony. Estate has controlled access and good internal roads.',
  ),

  // ---------------- SHORTLET (per night) ----------------
  _p(
    id: 's1',
    title: 'Luxury 2 Bedroom Serviced Apartment',
    type: ListingType.shortlet,
    price: 120000,
    area: 'Victoria Island',
    address: 'Eko Atlantic view, Victoria Island',
    agentId: 'agent_amaka',
    beds: 2,
    baths: 2,
    toilets: 2,
    furnishing: Furnishing.serviced,
    featured: true,
    amenities: ['24/7 Power', 'Wi-Fi', 'Air Conditioning', 'Pool', 'Netflix', 'Daily Cleaning'],
    ageDays: 3,
    description:
        'Immaculate 2-bedroom serviced apartment on VI with Eko Atlantic views. Smart TV with Netflix, '
        'fast Wi-Fi, daily housekeeping and 24/7 power. Minimum 2-night stay. Airport pickup available.',
  ),
  _p(
    id: 's2',
    title: '1 Bedroom Serviced Apartment',
    type: ListingType.shortlet,
    price: 75000,
    area: 'Lekki Phase 1',
    address: 'Admiralty Way, Lekki Phase 1',
    agentId: 'agent_amaka',
    beds: 1,
    baths: 1,
    toilets: 1,
    furnishing: Furnishing.serviced,
    featured: true,
    amenities: ['24/7 Power', 'Wi-Fi', 'Air Conditioning', 'Kitchen', 'Gym', 'Self check-in'],
    ageDays: 2,
    description:
        'Chic 1-bedroom shortlet in the heart of Lekki Phase 1. Self check-in via smart lock, '
        'fully equipped kitchen, workspace and gym access. Walk to restaurants and Circle Mall.',
  ),
  _p(
    id: 's3',
    title: '3 Bedroom Shortlet with Pool',
    type: ListingType.shortlet,
    price: 180000,
    area: 'Oniru',
    address: 'Oniru Estate, Victoria Island',
    agentId: 'agent_amaka',
    beds: 3,
    baths: 3,
    toilets: 4,
    furnishing: Furnishing.serviced,
    amenities: ['24/7 Power', 'Wi-Fi', 'Private Pool', 'Chef on request', 'Parking (3)', 'Air Conditioning'],
    ageDays: 7,
    description:
        'Elegant 3-bedroom in Oniru, ideal for families and small groups. Private plunge pool, '
        'chef available on request and secure parking. Close to Landmark Beach and VI nightlife.',
  ),
  _p(
    id: 's4',
    title: 'Cosy Studio Shortlet',
    type: ListingType.shortlet,
    price: 45000,
    area: 'Chevron / Lekki',
    address: 'Chevron Drive, Lekki',
    agentId: 'agent_amaka',
    beds: 1,
    baths: 1,
    toilets: 1,
    furnishing: Furnishing.serviced,
    amenities: ['24/7 Power', 'Wi-Fi', 'Air Conditioning', 'Kitchenette', 'Netflix'],
    ageDays: 12,
    description:
        'Affordable, tidy studio off Chevron Drive. Great value base for a short Lagos trip with '
        'power, Wi-Fi and a kitchenette. Easy access to the Lekki-Epe Expressway.',
  ),

  // ---------------- LAND ----------------
  _p(
    id: 'l1',
    title: '600 sqm Residential Land',
    type: ListingType.land,
    price: 25000000,
    area: 'Ibeju-Lekki',
    address: 'Near Dangote Refinery, Ibeju-Lekki',
    agentId: 'agent_tunde',
    sqm: 600,
    title2: LandTitle.certificateOfOccupancy,
    featured: true,
    amenities: ['Dry land', 'Gated estate', 'Good road network', 'Fenced'],
    ageDays: 3,
    description:
        'Prime 600 sqm plot in a fast-appreciating Ibeju-Lekki estate, minutes from the Dangote '
        'Refinery and the Lekki Free Trade Zone. Global C of O. Instant allocation after payment.',
  ),
  _p(
    id: 'l2',
    title: '2 Plots of Land (1,200 sqm)',
    type: ListingType.land,
    price: 45000000,
    area: 'Sangotedo',
    address: 'Monastery Road, Sangotedo',
    agentId: 'agent_tunde',
    sqm: 1200,
    title2: LandTitle.governorsConsent,
    amenities: ['Dry land', 'Gated estate', 'Fenced', 'Perimeter fencing'],
    ageDays: 9,
    description:
        'Two full plots (1,200 sqm) in a developed Sangotedo estate off Monastery Road. '
        'Governor\'s Consent in place. Suitable for a detached home or a small terrace development.',
  ),
  _p(
    id: 'l3',
    title: '300 sqm Land',
    type: ListingType.land,
    price: 18000000,
    area: 'Ajah',
    address: 'Off Addo Road, Ajah',
    agentId: 'agent_tunde',
    sqm: 300,
    title2: LandTitle.gazette,
    amenities: ['Dry land', 'Accessible road'],
    ageDays: 15,
    description:
        'Half plot (300 sqm) in a built-up Ajah neighbourhood off Addo Road. Gazette title, '
        'verifiable survey. Good for a compact residential build.',
  ),
  _p(
    id: 'l4',
    title: '1,000 sqm Waterfront Land',
    type: ListingType.land,
    price: 850000000,
    area: 'Banana Island',
    address: 'Banana Island, Ikoyi',
    agentId: 'agent_tunde',
    sqm: 1000,
    title2: LandTitle.certificateOfOccupancy,
    featured: true,
    amenities: ['Waterfront', 'Fully serviced estate', 'Underground utilities', 'C of O'],
    ageDays: 20,
    description:
        'Rare 1,000 sqm waterfront plot on Banana Island — Nigeria\'s most exclusive address. '
        'Fully serviced estate with underground utilities and world-class security. Global C of O.',
  ),
  _p(
    id: 'l5',
    title: '500 sqm Land in Estate',
    type: ListingType.land,
    price: 70000000,
    area: 'Magodo',
    address: 'Magodo GRA Phase 1',
    agentId: 'agent_tunde',
    sqm: 500,
    title2: LandTitle.surveyPlan,
    amenities: ['Dry land', 'Tarred road', 'Gated estate', 'Drainage'],
    ageDays: 11,
    description:
        'Well-located 500 sqm plot in the serene Magodo GRA Phase 1. Tarred roads, good drainage and '
        'controlled estate access. Registered survey; title documents available on inspection.',
  ),
];
