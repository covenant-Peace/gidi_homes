import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/media_service.dart';
import '../../models/enums.dart';
import '../../models/verification.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final _media = MediaService();
  VerificationType _type = VerificationType.nin;
  final _idNumber = TextEditingController();
  final _business = TextEditingController();
  XFile? _doc;
  bool _submitting = false;
  bool _resubmit = false;

  @override
  void dispose() {
    _idNumber.dispose();
    _business.dispose();
    super.dispose();
  }

  Future<void> _pickDoc() async {
    final picked = await _media.pickImages();
    if (picked.isNotEmpty) setState(() => _doc = picked.first);
  }

  Future<void> _submit() async {
    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null) {
      context.push('/auth');
      return;
    }
    if (_idNumber.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter your ID number.')));
      return;
    }
    setState(() => _submitting = true);
    try {
      String? docUrl;
      if (_doc != null && _media.configured) {
        docUrl = await _media.upload(_doc!, isVideo: false);
      }
      final v = Verification(
        agentId: user.id,
        agentName: user.name,
        type: _type,
        idNumber: _idNumber.text.trim(),
        businessName: _business.text.trim().isEmpty
            ? user.agencyName
            : _business.text.trim(),
        documentUrl: docUrl,
        createdAt: DateTime.now(),
      );
      await ref.read(verificationRepoProvider).submit(v);
      if (mounted) {
        setState(() {
          _submitting = false;
          _resubmit = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Submitted for review. We\'ll verify you shortly.')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final existing = ref.watch(myVerificationProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Get verified',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: existing != null && !_resubmit
              ? _StatusView(
                  v: existing,
                  onResubmit: () => setState(() => _resubmit = true),
                )
              : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppColors.greenSoft,
              borderRadius: BorderRadius.circular(14)),
          child: const Row(
            children: [
              Icon(Icons.verified_user_outlined, color: AppColors.green),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Verified agents earn a badge and buyers\' trust. Submit your '
                  'NIN or CAC and we\'ll review it.',
                  style: TextStyle(color: AppColors.greenDark, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('ID type',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final t in VerificationType.values) ...[
              Expanded(
                child: ChoiceChip(
                  label: Text(t == VerificationType.nin
                      ? 'NIN (individual)'
                      : 'CAC (company)'),
                  selected: _type == t,
                  showCheckmark: false,
                  selectedColor: AppColors.green,
                  labelStyle: TextStyle(
                      color: _type == t ? Colors.white : AppColors.greenDark,
                      fontWeight: FontWeight.w600),
                  onSelected: (_) => setState(() => _type = t),
                ),
              ),
              if (t != VerificationType.values.last) const SizedBox(width: 10),
            ],
          ],
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _idNumber,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: _type == VerificationType.nin
                ? 'NIN (11 digits)'
                : 'CAC / RC number',
            prefixIcon: const Icon(Icons.badge_outlined),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _business,
          decoration: const InputDecoration(
            labelText: 'Business / agency name (optional)',
            prefixIcon: Icon(Icons.business_outlined),
          ),
        ),
        const SizedBox(height: 18),
        const Text('Supporting document (optional)',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _media.configured ? _pickDoc : null,
          icon: const Icon(Icons.upload_file_outlined, size: 18),
          label: Text(_doc == null ? 'Upload ID / CAC certificate' : 'Change file'),
        ),
        if (_doc != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.green, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(_doc!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.slate, fontSize: 12.5)),
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.4, color: Colors.white))
                : const Text('Submit for review'),
          ),
        ),
      ],
    );
  }
}

class _StatusView extends StatelessWidget {
  const _StatusView({required this.v, required this.onResubmit});
  final Verification v;
  final VoidCallback onResubmit;

  @override
  Widget build(BuildContext context) {
    final (color, icon, title) = switch (v.status) {
      VerificationStatus.pending => (
          AppColors.gold,
          Icons.hourglass_top_rounded,
          'Under review'
        ),
      VerificationStatus.approved => (
          AppColors.green,
          Icons.verified_rounded,
          'You\'re verified'
        ),
      VerificationStatus.rejected => (
          AppColors.danger,
          Icons.cancel_outlined,
          'Not approved'
        ),
    };

    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 48),
        ),
        const SizedBox(height: 16),
        Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(
          switch (v.status) {
            VerificationStatus.pending =>
              'Your ${v.type.label} is being reviewed. This usually takes a short while.',
            VerificationStatus.approved =>
              'Your badge now shows on your listings. Thank you!',
            VerificationStatus.rejected =>
              v.reviewNote?.isNotEmpty == true
                  ? 'Reason: ${v.reviewNote}'
                  : 'Please check your details and resubmit.',
          },
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.slate),
        ),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            title: Text('${v.type.label}: ${v.idNumber}'),
            subtitle: v.businessName != null ? Text(v.businessName!) : null,
            trailing: Text(v.status.label,
                style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          ),
        ),
        if (v.status == VerificationStatus.rejected) ...[
          const SizedBox(height: 16),
          OutlinedButton(
              onPressed: onResubmit, child: const Text('Resubmit')),
        ],
      ],
    );
  }
}
