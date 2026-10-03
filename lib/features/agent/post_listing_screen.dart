import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/responsive.dart';
import '../../data/media_service.dart';
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

  // Media
  final MediaService _media = MediaService();
  final List<XFile> _pickedImages = [];
  XFile? _pickedVideo;
  List<String> _existingImages = [];
  List<String> _existingVideos = [];
  String _uploadStatus = '';

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
    _existingImages = [...p.images];
    _existingVideos = [...p.videos];
  }

  Future<void> _addImages() async {
    final picked = await _media.pickImages();
    if (picked.isNotEmpty) setState(() => _pickedImages.addAll(picked));
  }

  Future<void> _addVideo() async {
    final picked = await _media.pickVideo();
    if (picked != null) setState(() => _pickedVideo = picked);
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

    // --- Upload media to Cloudinary ---
    List<String> images = [..._existingImages];
    List<String> videos = [..._existingVideos];
    try {
      if (_pickedImages.isNotEmpty) {
        if (!_media.configured) throw StateError('Media upload not configured.');
        setState(() => _uploadStatus = 'Uploading ${_pickedImages.length} photo(s)…');
        images.addAll(await _media.uploadImages(_pickedImages));
      }
      if (_pickedVideo != null) {
        if (!_media.configured) throw StateError('Media upload not configured.');
        setState(() => _uploadStatus = 'Uploading video…');
        videos.add(await _media.upload(_pickedVideo!, isVideo: true));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _uploadStatus = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e')));
      }
      return;
    }

    // Fall back to themed placeholder photos only if nothing was provided.
    if (images.isEmpty) images = imagesFor(_type, seedFromId(id));
    setState(() => _uploadStatus = 'Saving listing…');

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
      videos: videos,
    );

    final repo = ref.read(propertyRepoProvider);
    if (existing == null) {
      await repo.add(property);
    } else {
      await repo.update(property);
    }
    ref.read(listingsRevisionProvider.notifier).state++;

    if (!mounted) return;
    setState(() {
      _saving = false;
      _uploadStatus = '';
    });
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

                const SizedBox(height: 18),
                _buildMediaSection(),

                if (_saving && _uploadStatus.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                        const SizedBox(width: 10),
                        Text(_uploadStatus,
                            style: const TextStyle(
                                color: AppColors.slate, fontSize: 13)),
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

  Widget _buildMediaSection() {
    final hasVideo = _pickedVideo != null || _existingVideos.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Label('Photos'),
        if (!_media.configured)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Color(0xFF8A5A00), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Media upload isn\'t configured yet — sample photos will be '
                      'attached automatically. (Set Cloudinary keys in app_config.dart.)',
                      style: TextStyle(color: Color(0xFF8A5A00), fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        SizedBox(
          height: 96,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _AddTile(
                icon: Icons.add_photo_alternate_outlined,
                label: 'Add photos',
                onTap: _media.configured ? _addImages : null,
              ),
              for (int i = 0; i < _existingImages.length; i++)
                _Thumb(
                  child: Image.network(_existingImages[i], fit: BoxFit.cover),
                  onRemove: () =>
                      setState(() => _existingImages.removeAt(i)),
                ),
              for (int i = 0; i < _pickedImages.length; i++)
                _Thumb(
                  child: _XFileImage(_pickedImages[i]),
                  onRemove: () => setState(() => _pickedImages.removeAt(i)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const _Label('Video tour (optional)'),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _media.configured ? _addVideo : null,
              icon: const Icon(Icons.videocam_outlined, size: 18),
              label: Text(hasVideo ? 'Replace video' : 'Add video'),
            ),
            const SizedBox(width: 12),
            if (hasVideo)
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.green, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _pickedVideo?.name ?? 'Current video attached',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.slate, fontSize: 12.5),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () => setState(() {
                        _pickedVideo = null;
                        _existingVideos = [];
                      }),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
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

class _AddTile extends StatelessWidget {
  const _AddTile(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 96,
          decoration: BoxDecoration(
            color: AppColors.greenSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: enabled ? AppColors.green : AppColors.line,
                style: BorderStyle.solid),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: enabled ? AppColors.green : AppColors.slate, size: 24),
              const SizedBox(height: 4),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: enabled ? AppColors.greenDark : AppColors.slate,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.child, required this.onRemove});
  final Widget child;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(width: 96, height: 96, child: child),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                    color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cross-platform preview of a picked [XFile] (web + native) via bytes.
class _XFileImage extends StatelessWidget {
  const _XFileImage(this.file);
  final XFile file;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: file.readAsBytes(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const ColoredBox(
            color: AppColors.line,
            child: Center(
                child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))),
          );
        }
        return Image.memory(snap.data!, fit: BoxFit.cover);
      },
    );
  }
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
