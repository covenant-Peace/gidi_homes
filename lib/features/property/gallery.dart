import 'package:flutter/material.dart';

import '../../widgets/network_photo.dart';

/// Swipeable image gallery with page indicator and a full-screen viewer.
class PropertyGallery extends StatefulWidget {
  const PropertyGallery({super.key, required this.images, required this.heroTag});
  final List<String> images;
  final String heroTag;

  @override
  State<PropertyGallery> createState() => _PropertyGalleryState();
}

class _PropertyGalleryState extends State<PropertyGallery> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openFull() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _FullScreenGallery(
          images: widget.images, initialIndex: _index),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images.isEmpty ? [''] : widget.images;
    final height = MediaQuery.sizeOf(context).width < 640 ? 280.0 : 420.0;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _index = i),
            itemCount: images.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: _openFull,
              child: NetworkPhoto(images[i]),
            ),
          ),
          // counter
          Positioned(
            right: 14,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  const Icon(Icons.photo_library_rounded,
                      color: Colors.white, size: 15),
                  const SizedBox(width: 6),
                  Text('${_index + 1} / ${images.length}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5)),
                ],
              ),
            ),
          ),
          // dots
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < images.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _index ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == _index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FullScreenGallery extends StatelessWidget {
  const _FullScreenGallery({required this.images, required this.initialIndex});
  final List<String> images;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: images.length,
        itemBuilder: (_, i) => InteractiveViewer(
          maxScale: 4,
          child: Center(child: NetworkPhoto(images[i], fit: BoxFit.contain)),
        ),
      ),
    );
  }
}
