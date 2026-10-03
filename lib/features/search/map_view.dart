import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/format.dart';
import '../../models/property.dart';
import '../../theme/app_theme.dart';

/// Map of search results using free OpenStreetMap tiles (no API key).
class MapView extends StatelessWidget {
  const MapView({super.key, required this.properties});
  final List<Property> properties;

  @override
  Widget build(BuildContext context) {
    // Center on the mean of the result pins, falling back to central Lagos.
    final center = properties.isEmpty
        ? const LatLng(6.4541, 3.3947)
        : LatLng(
            properties.map((p) => p.lat).reduce((a, b) => a + b) /
                properties.length,
            properties.map((p) => p.lng).reduce((a, b) => a + b) /
                properties.length,
          );

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 11,
        interactionOptions:
            const InteractionOptions(flags: InteractiveFlag.all),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'ng.gidihomes.gidi_homes',
          maxZoom: 19,
        ),
        MarkerLayer(
          markers: [
            for (final p in properties)
              Marker(
                point: p.latLng,
                width: 92,
                height: 42,
                alignment: Alignment.topCenter,
                child: _PriceMarker(
                  label: priceLabel(p),
                  onTap: () => context.push('/property/${p.id}'),
                ),
              ),
          ],
        ),
        const Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.all(6),
            child: Text('© OpenStreetMap',
                style: TextStyle(fontSize: 10, color: AppColors.slate)),
          ),
        ),
      ],
    );
  }
}

class _PriceMarker extends StatelessWidget {
  const _PriceMarker({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Text(label,
            maxLines: 1,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12)),
      ),
    );
  }
}
