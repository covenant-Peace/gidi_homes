import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/property.dart';
import '../../models/saved_search.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class SavedSearchesScreen extends ConsumerWidget {
  const SavedSearchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searches = ref.watch(savedSearchesProvider);
    final all = ref.watch(publicPropertiesProvider).valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Saved searches',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: searches.isEmpty
          ? EmptyState(
              icon: Icons.bookmark_border_rounded,
              title: 'No saved searches',
              message:
                  'Run a search, then tap the bookmark to save it and get alerts on new matches.',
              action: ElevatedButton(
                  onPressed: () => context.go('/search'),
                  child: const Text('Start searching')),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: searches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final s = searches[i];
                final matches = s.filter.apply(all);
                final newCount = matches
                    .where((Property p) => p.createdAt.isAfter(s.lastSeenAt))
                    .length;
                return _SavedSearchCard(
                  search: s,
                  total: matches.length,
                  newCount: newCount,
                  onOpen: () {
                    ref.read(filterProvider.notifier).state = s.filter;
                    ref.read(savedSearchesProvider.notifier).markSeen(s.id);
                    context.go('/search');
                  },
                  onDelete: () =>
                      ref.read(savedSearchesProvider.notifier).remove(s.id),
                );
              },
            ),
    );
  }
}

class _SavedSearchCard extends StatelessWidget {
  const _SavedSearchCard({
    required this.search,
    required this.total,
    required this.newCount,
    required this.onOpen,
    required this.onDelete,
  });
  final SavedSearch search;
  final int total;
  final int newCount;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.greenSoft,
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.saved_search_rounded,
                    color: AppColors.green),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(search.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(search.filter.summary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.slate, fontSize: 12.5)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('$total match${total == 1 ? '' : 'es'}',
                            style: const TextStyle(
                                fontSize: 12.5, fontWeight: FontWeight.w600)),
                        if (newCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: AppColors.gold,
                                borderRadius: BorderRadius.circular(999)),
                            child: Text('$newCount new',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.slate),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
