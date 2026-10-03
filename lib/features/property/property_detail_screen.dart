import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/contact.dart';
import '../../core/format.dart';
import '../../core/responsive.dart';
import '../../models/app_user.dart';
import '../../models/enums.dart';
import '../../models/property.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/favorite_button.dart';
import 'gallery.dart';
import 'video_tour.dart';

class PropertyDetailScreen extends ConsumerWidget {
  const PropertyDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(propertyByIdProvider(id));

    return Scaffold(
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _NotFound(message: '$e'),
        data: (p) {
          if (p == null) return const _NotFound();
          final agentAsync = ref.watch(agentByIdProvider(p.agentId));
          return _Body(property: p, agent: agentAsync.valueOrNull);
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.property, required this.agent});
  final Property property;
  final AppUser? agent;

  @override
  Widget build(BuildContext context) {
    final p = property;
    final isWide = context.isDesktop;

    final content = CustomScrollView(
      slivers: [
        // ---- Gallery ----
        SliverToBoxAdapter(child: PropertyGallery(images: p.images, heroTag: p.id)),
        SliverToBoxAdapter(
          child: PageContainer(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _Main(p: p)),
                      const SizedBox(width: 32),
                      Expanded(
                          flex: 2,
                          child: _ContactCard(property: p, agent: agent)),
                    ],
                  )
                : _Main(p: p),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/search'),
        ),
        title: Text(p.area, style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [FavoriteButton(p.id, filledBackground: false), const SizedBox(width: 8)],
      ),
      body: content,
      // Sticky contact bar on mobile; the side card handles wide screens.
      bottomNavigationBar: isWide
          ? null
          : _StickyContactBar(property: p, agent: agent),
    );
  }
}

class _Main extends StatelessWidget {
  const _Main({required this.p});
  final Property p;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _TypePill(p.type),
            const SizedBox(width: 8),
            Text(timeAgo(p.createdAt),
                style: const TextStyle(color: AppColors.slate, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 12),
        Text(p.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.location_on_rounded,
                size: 18, color: AppColors.slate),
            const SizedBox(width: 4),
            Expanded(
                child: Text(p.address,
                    style: const TextStyle(
                        color: AppColors.slate, fontSize: 15))),
          ],
        ),
        const SizedBox(height: 16),
        Text(priceLabel(p, compact: false),
            style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.green)),
        if (p.serviceCharge != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
                '+ ${formatNaira(p.serviceCharge!)} service charge / year',
                style: const TextStyle(color: AppColors.slate, fontSize: 13)),
          ),
        const SizedBox(height: 20),
        _KeyFacts(p),
        const SizedBox(height: 24),
        const _Heading('Description'),
        Text(p.description,
            style: const TextStyle(fontSize: 15, height: 1.6, color: AppColors.ink)),
        if (p.hasVideo) ...[
          const SizedBox(height: 24),
          const _Heading('Video tour'),
          VideoTour(url: p.videos.first),
        ],
        if (p.amenities.isNotEmpty) ...[
          const SizedBox(height: 24),
          const _Heading('Amenities & features'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final a in p.amenities)
                InfoPill(a, icon: Icons.check_circle_outline_rounded),
            ],
          ),
        ],
        const SizedBox(height: 24),
        const _Heading('Location'),
        _MiniMap(p),
        const SizedBox(height: 8),
        Text(
          'Approximate location in ${p.area}. Exact address shared on inspection.',
          style: const TextStyle(color: AppColors.slate, fontSize: 12.5),
        ),
      ],
    );
  }
}

class _KeyFacts extends StatelessWidget {
  const _KeyFacts(this.p);
  final Property p;

  @override
  Widget build(BuildContext context) {
    final facts = <(IconData, String, String)>[];
    if (p.isLand) {
      if (p.sizeSqm != null) {
        facts.add((Icons.straighten_rounded, p.sizeSqm!.toStringAsFixed(0), 'sqm'));
      }
      if (p.landTitle != null) {
        facts.add((Icons.verified_outlined, p.landTitle!.label, 'Title'));
      }
    } else {
      facts.add((Icons.bed_rounded, '${p.bedrooms}', 'Bedrooms'));
      facts.add((Icons.bathtub_outlined, '${p.bathrooms}', 'Bathrooms'));
      facts.add((Icons.wc_rounded, '${p.toilets}', 'Toilets'));
      if (p.furnishing != null) {
        facts.add((Icons.chair_outlined, p.furnishing!.label, 'Furnishing'));
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.greenSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final (icon, value, label) in facts)
            Flexible(
              child: Column(
                children: [
                  Icon(icon, color: AppColors.green, size: 24),
                  const SizedBox(height: 6),
                  Text(value,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 14)),
                  Text(label,
                      style: const TextStyle(
                          color: AppColors.slate, fontSize: 11.5)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.property, required this.agent});
  final Property property;
  final AppUser? agent;

  @override
  Widget build(BuildContext context) {
    final a = agent;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Listed by',
                style: TextStyle(color: AppColors.slate, fontSize: 13)),
            const SizedBox(height: 12),
            if (a != null) _AgentRow(a) else const Text('Agent'),
            const SizedBox(height: 20),
            if (a != null) _ContactButtons(property: property, agent: a),
          ],
        ),
      ),
    );
  }
}

class _AgentRow extends StatelessWidget {
  const _AgentRow(this.a);
  final AppUser a;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.greenSoft,
          backgroundImage:
              a.photoUrl != null ? NetworkImage(a.photoUrl!) : null,
          child: a.photoUrl == null
              ? const Icon(Icons.person, color: AppColors.green)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(a.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                  if (a.verified) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.verified_rounded,
                        color: AppColors.green, size: 18),
                  ],
                ],
              ),
              if (a.agencyName != null)
                Text(a.agencyName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.slate)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactButtons extends StatelessWidget {
  const _ContactButtons({required this.property, required this.agent});
  final Property property;
  final AppUser agent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Contact.whatsapp(context, agent, property),
            icon: const Icon(Icons.chat_rounded, size: 18),
            label: const Text('Chat on WhatsApp'),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366)),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Contact.call(context, agent.phone),
                icon: const Icon(Icons.call_rounded, size: 18),
                label: const Text('Call'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Contact.email(context, agent, property),
                icon: const Icon(Icons.mail_outline_rounded, size: 18),
                label: const Text('Email'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StickyContactBar extends StatelessWidget {
  const _StickyContactBar({required this.property, required this.agent});
  final Property property;
  final AppUser? agent;

  @override
  Widget build(BuildContext context) {
    final a = agent;
    return Material(
      elevation: 12,
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(priceLabel(property, compact: false),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            color: AppColors.green)),
                    if (a != null)
                      Text(a.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.slate, fontSize: 12)),
                  ],
                ),
              ),
              if (a != null) ...[
                _RoundBtn(
                  icon: Icons.call_rounded,
                  color: AppColors.green,
                  onTap: () => Contact.call(context, a.phone),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => Contact.whatsapp(context, a, property),
                  icon: const Icon(Icons.chat_rounded, size: 18),
                  label: const Text('WhatsApp'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn(
      {required this.icon, required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

class _MiniMap extends StatelessWidget {
  const _MiniMap(this.p);
  final Property p;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 220,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: p.latLng,
            initialZoom: 13,
            interactionOptions:
                const InteractionOptions(flags: InteractiveFlag.none),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'ng.gidihomes.gidi_homes',
            ),
            MarkerLayer(markers: [
              Marker(
                point: p.latLng,
                width: 44,
                height: 44,
                child: const Icon(Icons.location_on_rounded,
                    color: AppColors.danger, size: 44),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      );
}

class _TypePill extends StatelessWidget {
  const _TypePill(this.type);
  final ListingType type;
  @override
  Widget build(BuildContext context) {
    final color = switch (type) {
      ListingType.rent => AppColors.green,
      ListingType.shortlet => const Color(0xFF2563EB),
      ListingType.land => const Color(0xFF8A5A00),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(type.label,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12.5)),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({this.message});
  final String? message;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: EmptyState(
        icon: Icons.home_outlined,
        title: 'Listing not found',
        message: message ?? 'This property may have been removed.',
        action: ElevatedButton(
            onPressed: () => context.go('/search'),
            child: const Text('Browse listings')),
      ),
    );
  }
}
