import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/responsive.dart';
import '../../models/enums.dart';
import '../../models/property_filter.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/property_grid.dart';
import 'filter_sheet.dart';
import 'map_view.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _query = TextEditingController();
  bool _mapView = false;

  @override
  void initState() {
    super.initState();
    _query.text = ref.read(filterProvider).query;
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _patch(PropertyFilter Function(PropertyFilter) f) {
    final n = ref.read(filterProvider.notifier);
    n.state = f(n.state);
  }

  Future<void> _saveSearch() async {
    final filter = ref.read(filterProvider);
    final controller = TextEditingController(text: filter.summary);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save search'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                "We'll tell you when new listings match it.",
                style: TextStyle(color: AppColors.slate, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await ref.read(savedSearchesProvider.notifier).add(filter, name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Search saved.'),
          action: SnackBarAction(
              label: 'View', onPressed: () => context.push('/saved-searches')),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(filterProvider);
    final results = ref.watch(searchResultsProvider);

    // Keep the text field in sync when filters are set from elsewhere (e.g. home).
    if (_query.text != filter.query) _query.text = filter.query;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Text('Search',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Save this search',
            onPressed: _saveSearch,
            icon: const Icon(Icons.bookmark_add_outlined),
          ),
          IconButton(
            tooltip: _mapView ? 'List view' : 'Map view',
            onPressed: () => setState(() => _mapView = !_mapView),
            icon: Icon(_mapView ? Icons.view_list_rounded : Icons.map_outlined),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // ---- Search + filter controls ----
          Material(
            color: AppColors.surface,
            elevation: 0.5,
            child: PageContainer(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _query,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (v) =>
                              _patch((f) => f.copyWith(query: v.trim())),
                          decoration: InputDecoration(
                            hintText: 'Search area, estate, keyword…',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _query.text.isEmpty
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.close_rounded),
                                    onPressed: () {
                                      _query.clear();
                                      _patch((f) => f.copyWith(query: ''));
                                    },
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _FilterButton(
                        count: filter.activeCount,
                        onTap: () => FilterSheet.show(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Quick type toggles + active chips
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _quickType(null, 'All', filter),
                        for (final t in ListingType.values)
                          _quickType(t, t.label, filter),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---- Results ----
          Expanded(
            child: results.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Something went wrong',
                message: '$e',
              ),
              data: (items) {
                if (items.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No properties match',
                    message: 'Try widening your filters or a different area.',
                    action: OutlinedButton(
                      onPressed: () => ref.read(filterProvider.notifier).state =
                          const PropertyFilter(),
                      child: const Text('Clear all filters'),
                    ),
                  );
                }
                if (_mapView) return MapView(properties: items);
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: PageContainer(
                        padding:
                            const EdgeInsets.fromLTRB(16, 14, 16, 4),
                        child: Row(
                          children: [
                            Text('${items.length} result${items.length == 1 ? '' : 's'}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            const Spacer(),
                            _SortMenu(
                              value: filter.sort,
                              onChanged: (s) =>
                                  _patch((f) => f.copyWith(sort: s)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: PageContainer(
                        padding:
                            const EdgeInsets.fromLTRB(16, 8, 16, 32),
                        child: PropertyGrid(
                          properties: items,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickType(ListingType? type, String label, PropertyFilter filter) {
    final selected = filter.type == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        selectedColor: AppColors.green,
        labelStyle: TextStyle(
            color: selected ? Colors.white : AppColors.greenDark,
            fontWeight: FontWeight.w600),
        onSelected: (_) => _patch((f) => f.copyWith(type: type)),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: count > 0 ? AppColors.green : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: count > 0 ? AppColors.green : AppColors.line),
        ),
        child: Row(
          children: [
            Icon(Icons.tune_rounded,
                size: 20,
                color: count > 0 ? Colors.white : AppColors.ink),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Text('$count',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800)),
            ],
          ],
        ),
      ),
    );
  }
}

class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.value, required this.onChanged});
  final SortOption value;
  final ValueChanged<SortOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortOption>(
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (_) => [
        for (final o in SortOption.values)
          PopupMenuItem(value: o, child: Text(o.label)),
      ],
      child: Row(
        children: [
          const Icon(Icons.swap_vert_rounded, size: 18, color: AppColors.slate),
          const SizedBox(width: 4),
          Text(value.label,
              style: const TextStyle(
                  color: AppColors.slate, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
