import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../models/enums.dart';
import '../../models/property.dart';
import '../../models/verification.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/network_photo.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(isAdminProvider)) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.canPop() ? context.pop() : context.go('/'),
          ),
        ),
        body: const EmptyState(
          icon: Icons.admin_panel_settings_outlined,
          title: 'Admins only',
          message: 'This area is for moderators.',
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.canPop() ? context.pop() : context.go('/'),
          ),
          title: const Text('Moderation',
              style: TextStyle(fontWeight: FontWeight.w800)),
          bottom: const TabBar(
            labelColor: AppColors.green,
            indicatorColor: AppColors.green,
            unselectedLabelColor: AppColors.slate,
            tabs: [
              Tab(text: 'Listings'),
              Tab(text: 'Agent verifications'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_PendingListings(), _PendingVerifications()],
        ),
      ),
    );
  }
}

class _PendingListings extends ConsumerWidget {
  const _PendingListings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingPropertiesProvider);
    return pending.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          EmptyState(icon: Icons.error_outline, title: 'Error', message: '$e'),
      data: (items) {
        if (items.isEmpty) {
          return const EmptyState(
            icon: Icons.inbox_outlined,
            title: 'Nothing to review',
            message: 'New listings awaiting approval will appear here.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final p = items[i];
            return _ListingReviewCard(
              property: p,
              onApprove: () => _setStatus(ref, p, ListingStatus.approved),
              onReject: () => _setStatus(ref, p, ListingStatus.rejected),
            );
          },
        );
      },
    );
  }

  Future<void> _setStatus(
      WidgetRef ref, Property p, ListingStatus status) async {
    await ref.read(propertyRepoProvider).update(p.copyWith(status: status));
    ref.read(listingsRevisionProvider.notifier).state++;
  }
}

class _ListingReviewCard extends StatelessWidget {
  const _ListingReviewCard(
      {required this.property, required this.onApprove, required this.onReject});
  final Property property;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final p = property;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            InkWell(
              onTap: () => context.push('/property/${p.id}'),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                          width: 84,
                          height: 66,
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
                                  fontWeight: FontWeight.w700)),
                          Text('${p.type.label} · ${p.area}',
                              style: const TextStyle(
                                  color: AppColors.slate, fontSize: 12.5)),
                          Text(priceLabel(p),
                              style: const TextStyle(
                                  color: AppColors.green,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close_rounded,
                        size: 18, color: AppColors.danger),
                    label: const Text('Reject',
                        style: TextStyle(color: AppColors.danger)),
                  ),
                ),
                Container(width: 1, height: 36, color: AppColors.line),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_rounded,
                        size: 18, color: AppColors.green),
                    label: const Text('Approve',
                        style: TextStyle(color: AppColors.green)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingVerifications extends ConsumerWidget {
  const _PendingVerifications();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingVerificationsProvider);
    return pending.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          EmptyState(icon: Icons.error_outline, title: 'Error', message: '$e'),
      data: (items) {
        if (items.isEmpty) {
          return const EmptyState(
            icon: Icons.verified_user_outlined,
            title: 'No pending verifications',
            message: 'Agent verification requests will appear here.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (_, i) =>
              _VerificationReviewCard(verification: items[i]),
        );
      },
    );
  }
}

class _VerificationReviewCard extends ConsumerWidget {
  const _VerificationReviewCard({required this.verification});
  final Verification verification;

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject verification'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Reason (optional)'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (note != null) {
      await ref
          .read(verificationRepoProvider)
          .reject(verification.agentId, note);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = verification;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.greenSoft,
                    child: Icon(Icons.person, color: AppColors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(v.agentName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 15)),
                        Text('${v.type.label}: ${v.idNumber}',
                            style: const TextStyle(
                                color: AppColors.slate, fontSize: 13)),
                        if (v.businessName != null)
                          Text(v.businessName!,
                              style: const TextStyle(
                                  color: AppColors.slate, fontSize: 12.5)),
                      ],
                    ),
                  ),
                ],
              ),
              if (v.documentUrl != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: NetworkPhoto(v.documentUrl)),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _reject(context, ref),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger)),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => ref
                          .read(verificationRepoProvider)
                          .approve(v.agentId),
                      icon: const Icon(Icons.verified_rounded, size: 18),
                      label: const Text('Verify'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
