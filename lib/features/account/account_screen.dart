import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/responsive.dart';
import '../../models/app_user.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Text('Account',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: user == null
          ? _SignedOut()
          : _SignedIn(user: user),
    );
  }
}

class _SignedOut extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.account_circle_outlined,
      title: 'Sign in to GidiHomes',
      message:
          'Save homes across devices, contact agents, and list your own properties.',
      action: Column(
        children: [
          SizedBox(
            width: 220,
            child: ElevatedButton(
              onPressed: () => context.push('/auth'),
              child: const Text('Sign in / Register'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignedIn extends ConsumerWidget {
  const _SignedIn({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedCount = ref.watch(favoritesProvider).length;

    return SingleChildScrollView(
      child: PageContainer(
        padding: const EdgeInsets.all(16),
        maxWidth: 720,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.greenSoft,
                      backgroundImage: user.photoUrl != null
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: user.photoUrl == null
                          ? Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.green))
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(user.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w800)),
                              ),
                              if (user.verified) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.verified_rounded,
                                    color: AppColors.green, size: 18),
                              ],
                            ],
                          ),
                          Text(user.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(color: AppColors.slate)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: AppColors.greenSoft,
                                borderRadius: BorderRadius.circular(999)),
                            child: Text(user.role.label,
                                style: const TextStyle(
                                    color: AppColors.greenDark,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11.5)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (user.isAgent) ...[
              const _SectionLabel('For agents'),
              _Tile(
                icon: Icons.dashboard_customize_outlined,
                title: 'Agent dashboard',
                subtitle: 'Manage your listings',
                onTap: () => context.push('/agent'),
              ),
              _Tile(
                icon: Icons.add_home_work_outlined,
                title: 'Post a new listing',
                subtitle: 'Rent, shortlet or land',
                onTap: () => context.push('/agent/post'),
              ),
              const SizedBox(height: 20),
            ],

            const _SectionLabel('Activity'),
            _Tile(
              icon: Icons.favorite_border_rounded,
              title: 'Saved properties',
              subtitle:
                  '$savedCount saved home${savedCount == 1 ? '' : 's'}',
              onTap: () => context.go('/saved'),
            ),
            if (!user.isAgent)
              _Tile(
                icon: Icons.add_home_work_outlined,
                title: 'List a property',
                subtitle: 'Become an agent / landlord',
                onTap: () => context.push('/agent/post'),
              ),
            const SizedBox(height: 20),

            const _SectionLabel('Settings'),
            _Tile(
              icon: Icons.logout_rounded,
              title: 'Sign out',
              color: AppColors.danger,
              onTap: () async {
                await ref.read(authControllerProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.slate,
                fontWeight: FontWeight.w700,
                fontSize: 13)),
      );
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.ink;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: (color ?? AppColors.green).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color ?? AppColors.green, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: c)),
                      if (subtitle != null)
                        Text(subtitle!,
                            style: const TextStyle(
                                color: AppColors.slate, fontSize: 12.5)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.slate),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
