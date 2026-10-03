import 'package:latlong2/latlong.dart';

/// A Lagos neighbourhood / locality used for browsing and filtering.
class LagosArea {
  const LagosArea(this.name, this.lga, this.center);

  final String name;
  final String lga; // Local Government Area / axis
  final LatLng center;

  @override
  String toString() => name;
}

/// Curated set of popular Lagos property localities, grouped loosely by axis.
/// Coordinates are approximate neighbourhood centroids (good enough for map pins).
const List<LagosArea> kLagosAreas = [
  // --- Lekki / Ajah axis (Eti-Osa) ---
  LagosArea('Lekki Phase 1', 'Eti-Osa', LatLng(6.4431, 3.4725)),
  LagosArea('Lekki Phase 2', 'Eti-Osa', LatLng(6.4499, 3.5420)),
  LagosArea('Ikate', 'Eti-Osa', LatLng(6.4390, 3.4950)),
  LagosArea('Chevron / Lekki', 'Eti-Osa', LatLng(6.4445, 3.5330)),
  LagosArea('Ajah', 'Eti-Osa', LatLng(6.4698, 3.5852)),
  LagosArea('Sangotedo', 'Eti-Osa', LatLng(6.4680, 3.6250)),
  LagosArea('Ibeju-Lekki', 'Ibeju-Lekki', LatLng(6.4310, 3.7050)),

  // --- Highbrow island (Lagos Island / Eti-Osa) ---
  LagosArea('Ikoyi', 'Eti-Osa', LatLng(6.4525, 3.4350)),
  LagosArea('Victoria Island', 'Eti-Osa', LatLng(6.4281, 3.4219)),
  LagosArea('Banana Island', 'Eti-Osa', LatLng(6.4620, 3.4480)),
  LagosArea('Oniru', 'Eti-Osa', LatLng(6.4310, 3.4560)),

  // --- Mainland ---
  LagosArea('Ikeja GRA', 'Ikeja', LatLng(6.5790, 3.3560)),
  LagosArea('Ikeja', 'Ikeja', LatLng(6.6018, 3.3515)),
  LagosArea('Magodo', 'Kosofe', LatLng(6.6190, 3.3760)),
  LagosArea('Gbagada', 'Kosofe', LatLng(6.5560, 3.3870)),
  LagosArea('Yaba', 'Lagos Mainland', LatLng(6.5095, 3.3710)),
  LagosArea('Surulere', 'Surulere', LatLng(6.5010, 3.3580)),
  LagosArea('Maryland', 'Ikeja', LatLng(6.5710, 3.3690)),
  LagosArea('Ogudu', 'Kosofe', LatLng(6.5660, 3.3900)),
  LagosArea('Ketu', 'Kosofe', LatLng(6.5890, 3.3850)),
  LagosArea('Ojodu Berger', 'Ikeja', LatLng(6.6380, 3.3660)),
];

/// Case-insensitive lookup by area name.
LagosArea? findArea(String name) {
  final lower = name.toLowerCase().trim();
  for (final a in kLagosAreas) {
    if (a.name.toLowerCase() == lower) return a;
  }
  return null;
}
