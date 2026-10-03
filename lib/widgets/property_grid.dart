import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/responsive.dart';
import '../models/property.dart';
import 'property_card.dart';

/// Responsive grid of [PropertyCard]s. Column count adapts to width.
class PropertyGrid extends StatelessWidget {
  const PropertyGrid({
    super.key,
    required this.properties,
    this.shrinkWrap = false,
    this.physics,
    this.padding = EdgeInsets.zero,
  });

  final List<Property> properties;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final cols = context.gridColumns;
    return GridView.builder(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: properties.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        mainAxisExtent: 320,
      ),
      itemBuilder: (context, i) {
        final p = properties[i];
        return PropertyCard(
          property: p,
          onTap: () => context.push('/property/${p.id}'),
        );
      },
    );
  }
}
