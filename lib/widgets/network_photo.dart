import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Cached image with branded loading + error placeholders so broken URLs
/// never leave an ugly gap.
class NetworkPhoto extends StatelessWidget {
  const NetworkPhoto(this.url, {super.key, this.fit = BoxFit.cover});

  final String? url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return const _Placeholder();
    return CachedNetworkImage(
      imageUrl: url!,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 250),
      placeholder: (_, __) => const _Placeholder(shimmer: true),
      errorWidget: (_, __, ___) => const _Placeholder(),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({this.shimmer = false});
  final bool shimmer;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: shimmer ? AppColors.greenSoft : AppColors.line,
      alignment: Alignment.center,
      child: Icon(Icons.home_rounded,
          color: AppColors.slate.withValues(alpha: 0.4), size: 40),
    );
  }
}
