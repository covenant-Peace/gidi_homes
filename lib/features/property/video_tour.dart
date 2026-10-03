import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../theme/app_theme.dart';

/// Plays a listing's video tour (Cloudinary URL) with standard controls.
class VideoTour extends StatefulWidget {
  const VideoTour({super.key, required this.url});
  final String url;

  @override
  State<VideoTour> createState() => _VideoTourState();
}

class _VideoTourState extends State<VideoTour> {
  VideoPlayerController? _video;
  ChewieController? _chewie;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final v = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      await v.initialize();
      if (!mounted) return;
      setState(() {
        _video = v;
        _chewie = ChewieController(
          videoPlayerController: v,
          autoPlay: false,
          looping: false,
          aspectRatio: v.value.aspectRatio == 0 ? 16 / 9 : v.value.aspectRatio,
          materialProgressColors: ChewieProgressColors(
            playedColor: AppColors.green,
            handleColor: AppColors.green,
          ),
        );
      });
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  void dispose() {
    _chewie?.dispose();
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return _frame(const Center(
          child: Text('Video unavailable',
              style: TextStyle(color: AppColors.slate))));
    }
    if (_chewie == null) {
      return _frame(const Center(child: CircularProgressIndicator()));
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: _video!.value.aspectRatio == 0
            ? 16 / 9
            : _video!.value.aspectRatio,
        child: Chewie(controller: _chewie!),
      ),
    );
  }

  Widget _frame(Widget child) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
            height: 200, color: AppColors.line, child: child),
      );
}
