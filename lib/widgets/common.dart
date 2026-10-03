import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Section heading with optional "See all" action.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800)),
          ),
          if (action != null)
            TextButton(
              onPressed: onAction,
              child: Text(action!,
                  style: const TextStyle(
                      color: AppColors.green, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}

/// Centered empty / error placeholder.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                  color: AppColors.greenSoft, shape: BoxShape.circle),
              child: Icon(icon, size: 36, color: AppColors.green),
            ),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700)),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.slate)),
            ],
            if (action != null) ...[const SizedBox(height: 18), action!],
          ],
        ),
      ),
    );
  }
}

/// Simple pill chip used for amenities and facts.
class InfoPill extends StatelessWidget {
  const InfoPill(this.label, {super.key, this.icon, this.color});
  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: c),
            const SizedBox(width: 6),
          ],
          Text(label,
              style: TextStyle(
                  color: c, fontWeight: FontWeight.w600, fontSize: 12.5)),
        ],
      ),
    );
  }
}
