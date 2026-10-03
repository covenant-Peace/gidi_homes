import 'package:flutter/material.dart';

import '../../core/responsive.dart';
import '../../models/enums.dart';
import '../../models/lagos_areas.dart';
import '../../models/property_filter.dart';
import '../../theme/app_theme.dart';

/// The prominent hero search bar. Collects query, area and type, then emits
/// a [PropertyFilter].
class HeroSearch extends StatefulWidget {
  const HeroSearch({super.key, required this.onSearch});
  final ValueChanged<PropertyFilter> onSearch;

  @override
  State<HeroSearch> createState() => _HeroSearchState();
}

class _HeroSearchState extends State<HeroSearch> {
  final _query = TextEditingController();
  String? _area;
  ListingType? _type;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _submit() {
    widget.onSearch(PropertyFilter(
      query: _query.text.trim(),
      area: _area,
      type: _type,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    return Container(
      constraints: const BoxConstraints(maxWidth: 920),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 12)),
        ],
      ),
      child: isMobile ? _buildMobile() : _buildWide(),
    );
  }

  Widget _buildWide() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: _query,
            onSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              hintText: 'Area, estate or keyword…',
              prefixIcon: Icon(Icons.search_rounded),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
        _vline(),
        Expanded(flex: 2, child: _areaDropdown()),
        _vline(),
        Expanded(flex: 2, child: _typeDropdown()),
        const SizedBox(width: 10),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _submit,
            child: const Text('Search'),
          ),
        ),
      ],
    );
  }

  Widget _buildMobile() {
    return Column(
      children: [
        TextField(
          controller: _query,
          onSubmitted: (_) => _submit(),
          decoration: const InputDecoration(
            hintText: 'Area, estate or keyword…',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _areaDropdown(boxed: true)),
            const SizedBox(width: 10),
            Expanded(child: _typeDropdown(boxed: true)),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.search_rounded, size: 20),
            label: const Text('Search'),
          ),
        ),
      ],
    );
  }

  Widget _areaDropdown({bool boxed = false}) {
    return DropdownButtonFormField<String>(
      initialValue: _area,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: 'Any area',
        border: boxed ? null : InputBorder.none,
        enabledBorder: boxed ? null : InputBorder.none,
        focusedBorder: boxed ? null : InputBorder.none,
        prefixIcon: const Icon(Icons.place_outlined, size: 20),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('Any area')),
        for (final a in kLagosAreas)
          DropdownMenuItem(value: a.name, child: Text(a.name)),
      ],
      onChanged: (v) => setState(() => _area = v),
    );
  }

  Widget _typeDropdown({bool boxed = false}) {
    return DropdownButtonFormField<ListingType>(
      initialValue: _type,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: 'Any type',
        border: boxed ? null : InputBorder.none,
        enabledBorder: boxed ? null : InputBorder.none,
        focusedBorder: boxed ? null : InputBorder.none,
        prefixIcon: const Icon(Icons.category_outlined, size: 20),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('Any type')),
        for (final t in ListingType.values)
          DropdownMenuItem(value: t, child: Text(t.label)),
      ],
      onChanged: (v) => setState(() => _type = v),
    );
  }

  Widget _vline() => Container(
      width: 1, height: 32, color: AppColors.line, margin: const EdgeInsets.symmetric(horizontal: 4));
}
