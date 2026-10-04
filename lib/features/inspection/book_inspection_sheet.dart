import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/inspection.dart';
import '../../models/property.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';

/// Bottom sheet for a buyer to request a property inspection at a date/time.
class BookInspectionSheet extends ConsumerStatefulWidget {
  const BookInspectionSheet({super.key, required this.property});
  final Property property;

  static Future<void> show(BuildContext context, Property property) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BookInspectionSheet(property: property),
    );
  }

  @override
  ConsumerState<BookInspectionSheet> createState() =>
      _BookInspectionSheetState();
}

class _BookInspectionSheetState extends ConsumerState<BookInspectionSheet> {
  DateTime? _date;
  TimeOfDay? _time;
  final _note = TextEditingController();
  final _phone = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _phone.text = ref.read(authControllerProvider).valueOrNull?.phone ?? '';
  }

  @override
  void dispose() {
    _note.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 11, minute: 0));
    if (t != null) setState(() => _time = t);
  }

  Future<void> _submit() async {
    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null) {
      context.push('/auth');
      return;
    }
    if (_date == null || _time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please pick a date and time.')));
      return;
    }
    setState(() => _submitting = true);
    final when = DateTime(_date!.year, _date!.month, _date!.day, _time!.hour,
        _time!.minute);
    final inspection = Inspection(
      id: 'insp${DateTime.now().microsecondsSinceEpoch}',
      propertyId: widget.property.id,
      propertyTitle: widget.property.title,
      buyerId: user.id,
      buyerName: user.name,
      buyerPhone: _phone.text.trim(),
      agentId: widget.property.agentId,
      when: when,
      createdAt: DateTime.now(),
      note: _note.text.trim(),
    );
    try {
      await ref.read(inspectionRepoProvider).create(inspection);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Inspection requested — the agent will confirm.')));
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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.line,
                        borderRadius: BorderRadius.circular(4))),
              ),
              const SizedBox(height: 16),
              const Text('Book an inspection',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(widget.property.title,
                  style:
                      const TextStyle(color: AppColors.slate, fontSize: 13)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _PickField(
                      icon: Icons.calendar_today_rounded,
                      label: _date == null
                          ? 'Pick date'
                          : DateFormat('EEE, d MMM').format(_date!),
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PickField(
                      icon: Icons.access_time_rounded,
                      label: _time == null ? 'Pick time' : _time!.format(context),
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    labelText: 'Your phone',
                    prefixIcon: Icon(Icons.phone_outlined)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _note,
                maxLines: 2,
                decoration: const InputDecoration(
                    labelText: 'Note to agent (optional)',
                    hintText: 'e.g. I can come anytime that afternoon'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.4, color: Colors.white))
                      : const Text('Request inspection'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickField extends StatelessWidget {
  const _PickField(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.green),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
