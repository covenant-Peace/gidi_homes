import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../models/enums.dart';
import '../../models/lagos_areas.dart';
import '../../models/property_filter.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';

/// Full-screen-ish bottom sheet exposing every filter dimension.
class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const FilterSheet(),
    );
  }

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late PropertyFilter _draft;

  @override
  void initState() {
    super.initState();
    _draft = ref.read(filterProvider);
  }

  @override
  Widget build(BuildContext context) {
    final isLand = _draft.type == ListingType.land;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 12),
            Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(4))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
              child: Row(
                children: [
                  const Text('Filters',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  TextButton(
                    onPressed: () =>
                        setState(() => _draft = const PropertyFilter()),
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  _label('Listing type'),
                  Wrap(
                    spacing: 8,
                    children: [
                      _choice('Any', _draft.type == null,
                          () => setState(() => _draft = _draft.copyWith(type: null))),
                      for (final t in ListingType.values)
                        _choice(t.label, _draft.type == t,
                            () => setState(() => _draft = _draft.copyWith(type: t))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _label('Area'),
                  DropdownButtonFormField<String>(
                    initialValue: _draft.area,
                    isExpanded: true,
                    decoration: const InputDecoration(hintText: 'Any area'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Any area')),
                      for (final a in kLagosAreas)
                        DropdownMenuItem(
                            value: a.name, child: Text('${a.name} · ${a.lga}')),
                    ],
                    onChanged: (v) =>
                        setState(() => _draft = _draft.copyWith(area: v)),
                  ),
                  const SizedBox(height: 20),
                  _label('Price range (₦)'),
                  Row(
                    children: [
                      Expanded(
                        child: _numberField(
                          hint: 'Min',
                          value: _draft.minPrice,
                          onChanged: (v) => _draft =
                              _draft.copyWith(minPrice: v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _numberField(
                          hint: 'Max',
                          value: _draft.maxPrice,
                          onChanged: (v) => _draft =
                              _draft.copyWith(maxPrice: v),
                        ),
                      ),
                    ],
                  ),
                  if (!isLand) ...[
                    const SizedBox(height: 20),
                    _label('Bedrooms (min)'),
                    Wrap(
                      spacing: 8,
                      children: [
                        _choice('Any', _draft.minBeds == null,
                            () => setState(() => _draft = _draft.copyWith(minBeds: null))),
                        for (final n in [1, 2, 3, 4, 5])
                          _choice('$n+', _draft.minBeds == n,
                              () => setState(() => _draft = _draft.copyWith(minBeds: n))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _label('Furnishing'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _choice('Any', _draft.furnishing == null,
                            () => setState(() => _draft = _draft.copyWith(furnishing: null))),
                        for (final f in Furnishing.values)
                          _choice(f.label, _draft.furnishing == f,
                              () => setState(() => _draft = _draft.copyWith(furnishing: f))),
                      ],
                    ),
                  ],
                  if (isLand) ...[
                    const SizedBox(height: 20),
                    _label('Land title'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _choice('Any', _draft.landTitle == null,
                            () => setState(() => _draft = _draft.copyWith(landTitle: null))),
                        for (final t in LandTitle.values)
                          _choice(t.label, _draft.landTitle == t,
                              () => setState(() => _draft = _draft.copyWith(landTitle: t))),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(filterProvider.notifier).state = _draft;
                      Navigator.of(context).pop();
                    },
                    child: const Text('Apply filters'),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(s,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      );

  Widget _choice(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: AppColors.green,
      labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.greenDark,
          fontWeight: FontWeight.w600),
    );
  }

  Widget _numberField({
    required String hint,
    required int? value,
    required ValueChanged<int?> onChanged,
  }) {
    return TextFormField(
      initialValue: value?.toString(),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hint,
        helperText: value != null ? formatNairaCompact(value) : null,
      ),
      onChanged: (v) => onChanged(int.tryParse(v.replaceAll(',', ''))),
    );
  }
}
