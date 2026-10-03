import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/responsive.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/property_grid.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedPropertiesProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Text('Saved properties',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: saved.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            EmptyState(icon: Icons.error_outline, title: 'Error', message: '$e'),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'No saved properties yet',
              message:
                  'Tap the heart on any listing to keep it here for later.',
              action: ElevatedButton(
                onPressed: () => context.go('/search'),
                child: const Text('Browse listings'),
              ),
            );
          }
          return SingleChildScrollView(
            child: PageContainer(
              padding: const EdgeInsets.all(16),
              child: PropertyGrid(
                properties: items,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
            ),
          );
        },
      ),
    );
  }
}
