import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../theme/app_theme.dart';

/// Heart toggle that writes through to the favourites controller.
class FavoriteButton extends ConsumerWidget {
  const FavoriteButton(this.propertyId, {super.key, this.filledBackground = true});

  final String propertyId;
  final bool filledBackground;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(favoritesProvider).contains(propertyId);
    final icon = Icon(
      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
      color: isFav ? AppColors.danger : AppColors.ink,
      size: 20,
    );

    return Material(
      color: filledBackground ? Colors.white : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => ref.read(favoritesProvider.notifier).toggle(propertyId),
        child: Padding(padding: const EdgeInsets.all(8), child: icon),
      ),
    );
  }
}
