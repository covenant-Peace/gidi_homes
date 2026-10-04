import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/responsive.dart';
import '../../models/enums.dart';
import '../../models/lagos_areas.dart';
import '../../models/property_filter.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/property_card.dart';
import '../../widgets/property_grid.dart';
import 'hero_search.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _browse(WidgetRef ref, BuildContext context,
      {ListingType? type, String? area}) {
    ref.read(filterProvider.notifier).state =
        PropertyFilter(type: type, area: area);
    context.go('/search');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(featuredPropertiesProvider);
    final latest = ref.watch(publicPropertiesProvider);
    final isMobile = context.isMobile;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              titleSpacing: 16,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.location_city_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text('GidiHomes',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ],
              ),
            )
          : null,
      body: CustomScrollView(
        slivers: [
          // ---- Hero ----
          SliverToBoxAdapter(
            child: _Hero(
              onSearch: (f) {
                ref.read(filterProvider.notifier).state = f;
                context.go('/search');
              },
            ),
          ),

          // ---- Categories ----
          SliverToBoxAdapter(
            child: PageContainer(
              padding: EdgeInsets.fromLTRB(16, isMobile ? 20 : 36, 16, 8),
              child: _Categories(
                onTap: (t) => _browse(ref, context, type: t),
              ),
            ),
          ),

          // ---- Featured ----
          SliverToBoxAdapter(
            child: PageContainer(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
              child: SectionHeader('Featured listings',
                  action: 'See all', onAction: () => context.go('/search')),
            ),
          ),
          SliverToBoxAdapter(
            child: featured.when(
              loading: () => const _CarouselSkeleton(),
              error: (e, _) => const SizedBox.shrink(),
              data: (items) => SizedBox(
                height: 330,
                child: PageContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, i) => SizedBox(
                      width: isMobile ? 290 : 320,
                      child: PropertyCard(
                        property: items[i],
                        onTap: () => context.push('/property/${items[i].id}'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ---- Browse by area ----
          SliverToBoxAdapter(
            child: PageContainer(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader('Browse by area'),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final a in kLagosAreas.take(12))
                        ActionChip(
                          label: Text(a.name),
                          avatar: const Icon(Icons.place_outlined, size: 16),
                          onPressed: () =>
                              _browse(ref, context, area: a.name),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ---- Latest ----
          SliverToBoxAdapter(
            child: PageContainer(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
              child: SectionHeader('Latest on GidiHomes',
                  action: 'See all', onAction: () => context.go('/search')),
            ),
          ),
          SliverToBoxAdapter(
            child: PageContainer(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: latest.when(
                loading: () => const Center(
                    child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator())),
                error: (e, _) => Text('Could not load listings: $e'),
                data: (items) => PropertyGrid(
                  properties: items.take(context.isDesktop ? 8 : 6).toList(),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: _Footer()),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.onSearch});
  final ValueChanged<PropertyFilter> onSearch;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.greenDark, AppColors.green],
        ),
      ),
      child: PageContainer(
        padding: EdgeInsets.symmetric(
            horizontal: 20, vertical: isMobile ? 36 : 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Find your next home in Lagos',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 28 : 44,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Rentals, shortlets and verified land — from Lekki to Ikeja and everywhere between.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: isMobile ? 14 : 17,
              ),
            ),
            SizedBox(height: isMobile ? 24 : 36),
            HeroSearch(onSearch: onSearch),
          ],
        ),
      ),
    );
  }
}

class _Categories extends StatelessWidget {
  const _Categories({required this.onTap});
  final ValueChanged<ListingType> onTap;

  static const _data = [
    (ListingType.rent, Icons.vpn_key_rounded, 'Rent yearly', AppColors.green),
    (ListingType.shortlet, Icons.hotel_rounded, 'Short stays', Color(0xFF2563EB)),
    (ListingType.land, Icons.landscape_rounded, 'Buy land', Color(0xFF8A5A00)),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (type, icon, subtitle, color) in _data) ...[
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onTap(type),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Icon(icon, color: color, size: 28),
                    const SizedBox(height: 10),
                    Text(type.label,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppColors.slate, fontSize: 11.5)),
                  ],
                ),
              ),
            ),
          ),
          if ((type, icon, subtitle, color) != _data.last)
            const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _CarouselSkeleton extends StatelessWidget {
  const _CarouselSkeleton();
  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 330,
        child: Center(child: CircularProgressIndicator()),
      );
}

class _Footer extends StatelessWidget {
  const _Footer();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.ink,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      child: PageContainer(
        child: Column(
          children: [
            const Text('GidiHomes',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('Lagos property, made simple.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
            const SizedBox(height: 16),
            Text('© ${DateTime.now().year} GidiHomes. Demo app.',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
