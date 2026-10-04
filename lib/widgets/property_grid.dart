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
    const spacing = 16.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Card height tracks the actual column width so the (flexible) image
        // never pushes the fixed text block past the cell — which caused
        // overflow on full-width single-column phone layouts.
        final colWidth =
            (constraints.maxWidth - (cols - 1) * spacing) / cols;
        final extent = (colWidth * 11 / 16) + 138; // image + text block

        return GridView.builder(
          padding: padding,
          shrinkWrap: shrinkWrap,
          physics: physics,
          itemCount: properties.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            mainAxisExtent: extent,
          ),
          itemBuilder: (context, i) {
            final p = properties[i];
            return PropertyCard(
              property: p,
              onTap: () => context.push('/property/${p.id}'),
            );
          },
        );
      },
    );
  }
}
