import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/inspection.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class InspectionsScreen extends ConsumerWidget {
  const InspectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final isAgent = user?.isAgent ?? false;
    final inspections = ref.watch(myInspectionsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text(isAgent ? 'Inspection requests' : 'My inspections',
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: user == null
          ? EmptyState(
              icon: Icons.lock_outline_rounded,
              title: 'Sign in to view inspections',
              action: ElevatedButton(
                  onPressed: () => context.push('/auth'),
                  child: const Text('Sign in')),
            )
          : inspections.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState(
                  icon: Icons.error_outline, title: 'Error', message: '$e'),
              data: (list) {
                if (list.isEmpty) {
                  return EmptyState(
                    icon: Icons.event_available_outlined,
                    title: isAgent
                        ? 'No inspection requests yet'
                        : 'No inspections booked',
                    message: isAgent
                        ? 'Requests from buyers will appear here.'
                        : 'Request an inspection from any listing.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _InspectionCard(
                    inspection: list[i],
                    isAgent: isAgent,
                    onStatus: (s) => ref
                        .read(inspectionRepoProvider)
                        .updateStatus(list[i].id, s),
                  ),
                );
              },
            ),
    );
  }
}

class _InspectionCard extends StatelessWidget {
  const _InspectionCard({
    required this.inspection,
    required this.isAgent,
    required this.onStatus,
  });
  final Inspection inspection;
  final bool isAgent;
  final ValueChanged<InspectionStatus> onStatus;

  Color get _statusColor => switch (inspection.status) {
        InspectionStatus.pending => AppColors.gold,
        InspectionStatus.confirmed => AppColors.green,
        InspectionStatus.declined => AppColors.danger,
        InspectionStatus.cancelled => AppColors.slate,
      };

  @override
  Widget build(BuildContext context) {
    final i = inspection;
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
                  Expanded(
                    child: InkWell(
                      onTap: () => context.push('/property/${i.propertyId}'),
                      child: Text(i.propertyTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999)),
                    child: Text(i.status.label,
                        style: TextStyle(
                            color: _statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _row(Icons.event_rounded,
                  DateFormat('EEE, d MMM yyyy · h:mm a').format(i.when)),
              if (isAgent) ...[
                const SizedBox(height: 6),
                _row(Icons.person_outline, i.buyerName),
                const SizedBox(height: 6),
                _row(Icons.phone_outlined, i.buyerPhone),
              ],
              if (i.note.isNotEmpty) ...[
                const SizedBox(height: 6),
                _row(Icons.sticky_note_2_outlined, i.note),
              ],
              const SizedBox(height: 14),
              if (isAgent && i.status == InspectionStatus.pending)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => onStatus(InspectionStatus.confirmed),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Confirm'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => onStatus(InspectionStatus.declined),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            side: const BorderSide(color: AppColors.danger)),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text('Decline'),
                      ),
                    ),
                  ],
                ),
              if (isAgent && i.buyerPhone.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton.icon(
                    onPressed: () => launchUrl(
                        Uri(scheme: 'tel', path: i.buyerPhone)),
                    icon: const Icon(Icons.call_rounded, size: 18),
                    label: const Text('Call buyer'),
                  ),
                ),
              if (!isAgent && i.status == InspectionStatus.pending)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => onStatus(InspectionStatus.cancelled),
                    child: const Text('Cancel request',
                        style: TextStyle(color: AppColors.danger)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.slate),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 13, color: AppColors.ink))),
        ],
      );
}
