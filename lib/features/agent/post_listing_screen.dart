import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/responsive.dart';
import '../../data/property_images.dart';
import '../../models/enums.dart';
import '../../models/lagos_areas.dart';
import '../../models/property.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';

/// Create or edit a listing. [editId] non-null => edit mode.
class PostListingScreen extends ConsumerStatefulWidget {
  const PostListingScreen({super.key, this.editId});
  final String? editId;

  @override
  ConsumerState<PostListingScreen> createState() => _PostListingScreenState();
}

class _PostListingScreenState extends ConsumerState<PostListingScreen> {
  final _formKey = GlobalKey<FormState>();

  ListingType _type = ListingType.rent;
  String? _area;
  Furnishing? _furnishing;
  LandTitle? _landTitle;
  bool _featured = false;
  bool _saving = false;
  bool _loadedForEdit = false;
  final Set<String> _amenities = {};

  final _title = TextEditingController();
  final _address = TextEditingController();
  final _price = TextEditingController();
  final _beds = TextEditingController(text: '1');
  final _baths = TextEditingController(text: '1');
  final _toilets = TextEditingController(text: '1');
  final _sqm = TextEditingController();
  final _serviceCharge = TextEditingController();
  final _description = TextEditingController();

  static const _commonAmenities = [
    '24/7 Power', 'Borehole', 'CCTV', 'Gated', 'Parking', 'Swimming Pool',
    'Gym', 'Air Conditioning', 'Wi-Fi', 'Prepaid Meter', 'Elevator', 'BQ',
    'Fenced', 'Dry land', 'C of O',
  ];

  @override
  void dispose() {
    for (final c in [
      _title, _address, _price, _beds, _baths, _toilets,
      _sqm, _serviceCharge, _description,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _hydrate(Property p) {
    if (_loadedForEdit) return;
    _loadedForEdit = true;
    _type = p.type;
    _area = p.area;
    _furnishing = p.furnishing;
    _landTitle = p.landTitle;
    _featured = p.featured;
    _amenities.addAll(p.amenities);
    _title.text = p.title;
    _address.text = p.address;
    _price.text = p.price.toString();
    _beds.text = p.bedrooms.toString();
    _baths.text = p.bathrooms.toString();
    _toilets.text = p.toilets.toString();
    _sqm.text = p.sizeSqm?.toStringAsFixed(0) ?? '';
    _serviceCharge.text = p.serviceCharge?.toString() ?? '';
    _description.text = p.description;
  }

  Future<void> _save(Property? existing) async {
    if (!_formKey.currentState!.validate()) return;
    if (_area == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please choose an area.')));
      return;
    }
    final auth = ref.read(authControllerProvider.notifier);
    var user = auth.user;
    if (user == null) {
      context.push('/auth');
      return;
    }
    // A buyer posting a listing becomes discoverable as an agent contact.
    if (!user.isAgent) {
      user = user.copyWith(role: UserRole.agent);
      await auth.updateProfile(user);
    }
    ref.read(agentRepoProvider).cache(user);

    setState(() => _saving = true);
    final area = findArea(_area!);
    final id = existing?.id ??
        'u${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
    final images = existing?.images.isNotEmpty == true
        ? existing!.images
        : imagesFor(_type, seedFromId(id));

    final property = Property(
      id: id,
      title: _title.text.trim(),
      type: _type,
      price: int.tryParse(_price.text.replaceAll(',', '')) ?? 0,
      area: _area!,
      address: _address.text.trim(),
      description: _description.text.trim(),
      images: images,
      agentId: user.id,
      lat: area?.center.latitude ?? 6.5244,
      lng: area?.center.longitude ?? 3.3792,
      createdAt: existing?.createdAt ?? DateTime.now(),
      bedrooms: _type == ListingType.land ? 0 : int.tryParse(_beds.text) ?? 0,
      bathrooms: _type == ListingType.land ? 0 : int.tryParse(_baths.text) ?? 0,
      toilets: _type == ListingType.land ? 0 : int.tryParse(_toilets.text) ?? 0,
      sizeSqm: _type == ListingType.land ? double.tryParse(_sqm.text) : null,
      furnishing: _type == ListingType.land ? null : _furnishing,
      landTitle: _type == ListingType.land ? _landTitle : null,
      amenities: _amenities.toList(),
      featured: _featured,
      serviceCharge: _serviceCharge.text.trim().isEmpty
          ? null
          : int.tryParse(_serviceCharge.text.replaceAll(',', '')),
    );

    final repo = ref.read(propertyRepoProvider);
    if (existing == null) {
      await repo.add(property);
    } else {
      await repo.update(property);
    }
    ref.read(listingsRevisionProvider.notifier).state++;

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(existing == null
            ? 'Listing published!'
            : 'Listing updated!')));
    context.canPop() ? context.pop() : context.go('/agent');
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.editId != null;
    final existingAsync =
        editing ? ref.watch(propertyByIdProvider(widget.editId!)) : null;
    final existing = existingAsync?.valueOrNull;
    if (existing != null) _hydrate(existing);

    final isLand = _type == ListingType.land;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text(editing ? 'Edit listing' : 'Post a listing',
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        child: PageContainer(
          maxWidth: 720,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Label('Listing type'),
                _TypeSelector(
                  value: _type,
                  onChanged: (t) => setState(() => _type = t),
                ),
                const SizedBox(height: 18),

                const _Label('Title'),
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(
                      hintText: 'e.g. 3 Bedroom Apartment with BQ'),
                  validator: _req,
                ),
                const SizedBox(height: 16),

                const _Label('Area'),
                DropdownButtonFormField<String>(
                  initialValue: _area,
                  isExpanded: true,
                  decoration: const InputDecoration(hintText: 'Select a Lagos area'),
                  items: [
                    for (final a in kLagosAreas)
                      DropdownMenuItem(
                          value: a.name, child: Text('${a.name} · ${a.lga}')),
                  ],
                  onChanged: (v) => setState(() => _area = v),
                ),
                const SizedBox(height: 16),

                const _Label('Address / street'),
                TextFormField(
                  controller: _address,
                  decoration: const InputDecoration(
                      hintText: 'e.g. Off Admiralty Way, Lekki Phase 1'),
                  validator: _req,
                ),
                const SizedBox(height: 16),

                _Label(isLand
                    ? 'Price (₦, total)'
                    : _type == ListingType.shortlet
                        ? 'Price (₦ per night)'
                        : 'Price (₦ per year)'),
                TextFormField(
                  controller: _price,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      prefixText: '₦ ', hintText: 'e.g. 4500000'),
                  validator: (v) =>
                      (int.tryParse((v ?? '').replaceAll(',', '')) == null)
                          ? 'Enter a valid amount'
                          : null,
                ),
                const SizedBox(height: 16),

                // Building-specific
                if (!isLand) ...[
                  Row(
                    children: [
                      Expanded(child: _numField('Bedrooms', _beds)),
                      const SizedBox(width: 12),
                      Expanded(child: _numField('Bathrooms', _baths)),
                      const SizedBox(width: 12),
                      Expanded(child: _numField('Toilets', _toilets)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _Label('Furnishing'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final f in Furnishing.values)
                        ChoiceChip(
                          label: Text(f.label),
                          selected: _furnishing == f,
                          showCheckmark: false,
                          selectedColor: AppColors.green,
                          labelStyle: TextStyle(
                              color: _furnishing == f
                                  ? Colors.white
                                  : AppColors.greenDark,
                              fontWeight: FontWeight.w600),
                          onSelected: (_) => setState(() => _furnishing = f),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _Label('Service charge (₦ / year, optional)'),
                  TextFormField(
                    controller: _serviceCharge,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(prefixText: '₦ ', hintText: 'e.g. 800000'),
                  ),
                ],

                // Land-specific
                if (isLand) ...[
                  const _Label('Plot size (sqm)'),
                  TextFormField(
                    controller: _sqm,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'e.g. 600'),
                    validator: (v) =>
                        double.tryParse(v ?? '') == null ? 'Enter size' : null,
                  ),
                  const SizedBox(height: 16),
                  const _Label('Land title'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in LandTitle.values)
                        ChoiceChip(
                          label: Text(t.label),
                          selected: _landTitle == t,
                          showCheckmark: false,
                          selectedColor: AppColors.green,
                          labelStyle: TextStyle(
                              color: _landTitle == t
                                  ? Colors.white
                                  : AppColors.greenDark,
                              fontWeight: FontWeight.w600),
                          onSelected: (_) => setState(() => _landTitle = t),
                        ),
                    ],
                  ),
                ],

                const SizedBox(height: 18),
                const _Label('Amenities & features'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final a in _commonAmenities)
                      FilterChip(
                        label: Text(a),
                        selected: _amenities.contains(a),
                        showCheckmark: true,
                        selectedColor: AppColors.greenSoft,
                        onSelected: (sel) => setState(() =>
                            sel ? _amenities.add(a) : _amenities.remove(a)),
                      ),
                  ],
                ),

                const SizedBox(height: 18),
                const _Label('Description'),
                TextFormField(
                  controller: _description,
                  maxLines: 5,
                  decoration: const InputDecoration(
                      hintText:
                          'Describe the property, its condition and what makes it stand out…'),
                  validator: _req,
                ),

                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _featured,
                  activeThumbColor: AppColors.green,
                  title: const Text('Feature this listing',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text('Show it on the homepage carousel'),
                  onChanged: (v) => setState(() => _featured = v),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 4, bottom: 18),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.greenSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.image_outlined,
                          color: AppColors.green, size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Demo build: sample photos are attached automatically. '
                          'Wire Firebase Storage to upload real images.',
                          style: TextStyle(
                              color: AppColors.greenDark, fontSize: 12.5),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _saving ? null : () => _save(existing),
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.4, color: Colors.white))
                        : Text(editing ? 'Save changes' : 'Publish listing'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _numField(String label, TextEditingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
                color: AppColors.slate)),
        const SizedBox(height: 6),
        TextFormField(
          controller: c,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 14)),
        ),
      ],
    );
  }

  static String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
      );
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.value, required this.onChanged});
  final ListingType value;
  final ValueChanged<ListingType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final t in ListingType.values) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: value == t ? AppColors.green : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: value == t ? AppColors.green : AppColors.line),
                ),
                child: Text(
                  t.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: value == t ? Colors.white : AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          if (t != ListingType.values.last) const SizedBox(width: 10),
        ],
      ],
    );
  }
}
