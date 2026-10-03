import '../models/enums.dart';

/// Curated Unsplash photo IDs (validated to resolve) used so demo listings
/// look like real estate. In production these are replaced by Firebase Storage
/// URLs of the agent's own uploads.
const _buildingPhotos = [
  '1560448204-e02f11c3d0e2',
  '1512917774080-9991f1c4c750',
  '1570129477492-45c003edd2be',
  '1568605114967-8130f3a36994',
  '1580587771525-78b9dba3b914',
  '1600596542815-ffad4c1539a9',
  '1600607687939-ce8a6c25118c',
  '1600566753086-00f18fb6b3ea',
  '1600585154340-be6161a56a0c',
  '1512915922686-57c11dde9b6b',
  '1572120360610-d971b9d7767c',
  '1449844908441-8829872d2607',
  '1523217582562-09d0def993a6',
  '1564013799919-ab600027ffc6',
  '1518780664697-55e3ad937233',
  '1613490493576-7fde63acd811',
  '1576941089067-2de3c901e126',
  '1564501049412-61c2a3083791',
  '1605146769289-440113cc3d00',
  '1591474200742-8e512e6f98f8',
];

const _landPhotos = [
  '1500382017468-9049fed747ef',
  '1416879595882-3373a0480b5b',
  '1434725039720-aaad6dd32dfe',
  '1501785888041-af3ef285b470',
  '1542401886-65d6c61db217',
  '1512699355324-f07e3106dae5',
];

String _url(String id) => 'https://images.unsplash.com/photo-$id?w=900&q=80&auto=format&fit=crop';

/// Deterministic set of [count] themed photo URLs for a listing, chosen from the
/// pool matching its [type], offset by a stable [seed].
List<String> imagesFor(ListingType type, int seed, {int count = 4}) {
  final pool = type == ListingType.land ? _landPhotos : _buildingPhotos;
  return List.generate(count, (i) {
    final idx = (seed * 3 + i * 5) % pool.length;
    return _url(pool[idx]);
  });
}

/// Stable integer seed from a listing id string.
int seedFromId(String id) {
  var h = 0;
  for (final c in id.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return h;
}
