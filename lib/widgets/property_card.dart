import 'package:flutter/material.dart';

import '../core/format.dart';
import '../models/enums.dart';
import '../models/property.dart';
import '../theme/app_theme.dart';
import 'favorite_button.dart';
import 'network_photo.dart';

/// The core listing card used in grids, carousels and lists.
class PropertyCard extends StatelessWidget {
  const PropertyCard({super.key, required this.property, required this.onTap});

  final Property property;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = property;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Image + badges ----
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NetworkPhoto(p.coverImage),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Row(
                      children: [
                        _Badge(
                          label: p.type.label,
                          color: _typeColor(p.type),
                        ),
                        if (p.featured) ...[
                          const SizedBox(width: 6),
                          const _Badge(
                              label: 'Featured',
                              color: AppColors.gold,
                              icon: Icons.star_rounded),
                        ],
                      ],
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: FavoriteButton(p.id),
                  ),
                  Positioned(
                    left: 10,
                    bottom: 10,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        priceLabel(p),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ---- Text ----
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15.5),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 15, color: AppColors.slate),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          p.area,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.slate, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _Specs(p),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _typeColor(ListingType t) => switch (t) {
        ListingType.rent => AppColors.green,
        ListingType.shortlet => const Color(0xFF2563EB),
        ListingType.land => const Color(0xFF8A5A00),
      };
}

class _Specs extends StatelessWidget {
  const _Specs(this.p);
  final Property p;

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String)>[];
    if (p.isLand) {
      if (p.sizeSqm != null) {
        items.add((Icons.straighten_rounded, '${p.sizeSqm!.toStringAsFixed(0)} sqm'));
      }
      if (p.landTitle != null) {
        items.add((Icons.verified_outlined, p.landTitle!.label));
      }
    } else {
      items.add((Icons.bed_rounded, '${p.bedrooms}'));
      items.add((Icons.bathtub_outlined, '${p.bathrooms}'));
      if (p.furnishing != null) {
        items.add((Icons.chair_outlined, p.furnishing!.label));
      }
    }

    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        for (final (icon, label) in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.slate),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600)),
            ],
          ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color, this.icon});
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: Colors.white),
            const SizedBox(width: 3),
          ],
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
