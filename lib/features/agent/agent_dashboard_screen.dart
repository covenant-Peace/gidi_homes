import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/responsive.dart';
import '../../models/enums.dart';
import '../../models/property.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/network_photo.dart';

class AgentDashboardScreen extends ConsumerWidget {
  const AgentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;

    if (user == null) {
      return _Gate(
        title: 'Sign in required',
        message: 'Sign in as an agent to manage your listings.',
        actionLabel: 'Sign in',
        onAction: () => context.push('/auth'),
      );
    }
    if (!user.isAgent) {
      return _Gate(
        title: 'Agent access',
        message:
            'Your account is a buyer account. Post a listing to start selling or letting.',
        actionLabel: 'Post a listing',
        onAction: () => context.push('/agent/post'),
      );
    }

    final listings = ref.watch(agentListingsProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('My listings',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/agent/post'),
        backgroundColor: AppColors.green,
        icon: const Icon(Icons.add),
        label: const Text('New listing'),
      ),
      body: listings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            EmptyState(icon: Icons.error_outline, title: 'Error', message: '$e'),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.home_work_outlined,
              title: 'No listings yet',
              message: 'Post your first property to reach thousands of renters and buyers.',
              action: ElevatedButton.icon(
                onPressed: () => context.push('/agent/post'),
                icon: const Icon(Icons.add),
                label: const Text('Post a listing'),
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            child: PageContainer(
              maxWidth: 820,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _StatsRow(items: items),
                  const SizedBox(height: 16),
                  for (final p in items)
                    _ListingRow(
                      property: p,
                      onEdit: () => context.push('/agent/post?id=${p.id}'),
                      onDelete: () => _confirmDelete(context, ref, p),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Property p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete listing?'),
        content: Text('"${p.title}" will be permanently removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(propertyRepoProvider).delete(p.id);
      ref.read(listingsRevisionProvider.notifier).state++;
    }
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.items});
  final List<Property> items;

  @override
  Widget build(BuildContext context) {
    final featured = items.where((p) => p.featured).length;
    return Row(
      children: [
        _Stat(label: 'Total', value: '${items.length}', icon: Icons.home_rounded),
        const SizedBox(width: 12),
        _Stat(
            label: 'Featured',
            value: '$featured',
            icon: Icons.star_rounded,
            color: AppColors.gold),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(
      {required this.label,
      required this.value,
      required this.icon,
      this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.green;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: c),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w900)),
                Text(label,
                    style: const TextStyle(
                        color: AppColors.slate, fontSize: 12.5)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingRow extends StatelessWidget {
  const _ListingRow({
    required this.property,
    required this.onEdit,
    required this.onDelete,
  });
  final Property property;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final p = property;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/property/${p.id}'),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                      width: 92,
                      height: 72,
                      child: NetworkPhoto(p.coverImage)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14.5)),
                      const SizedBox(height: 2),
                      Text('${p.type.label} · ${p.area}',
                          style: const TextStyle(
                              color: AppColors.slate, fontSize: 12.5)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(priceLabel(p),
                              style: const TextStyle(
                                  color: AppColors.green,
                                  fontWeight: FontWeight.w800)),
                          if (p.status != ListingStatus.approved) ...[
                            const SizedBox(width: 8),
                            _StatusPill(p.status),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill(this.status);
  final ListingStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status == ListingStatus.rejected
        ? AppColors.danger
        : AppColors.gold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999)),
      child: Text(status.label,
          style: TextStyle(
              color: color, fontSize: 10.5, fontWeight: FontWeight.w700)),
    );
  }
}

class _Gate extends StatelessWidget {
  const _Gate({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: EmptyState(
        icon: Icons.lock_outline_rounded,
        title: title,
        message: message,
        action: ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
      ),
    );
  }
}
