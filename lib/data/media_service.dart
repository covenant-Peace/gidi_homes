import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../config/app_config.dart';

/// Picks images/videos and uploads them to Cloudinary via an *unsigned* preset
/// (no API secret in the client, no credit card required). Returns secure URLs
/// which are stored on the listing in Firestore.
class MediaService {
  final ImagePicker _picker = ImagePicker();

  bool get configured => AppConfig.cloudinaryConfigured;

  Future<List<XFile>> pickImages() => _picker.pickMultiImage(imageQuality: 85);

  Future<XFile?> pickVideo() =>
      _picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(minutes: 3));

  /// Uploads a single file. [isVideo] selects the Cloudinary resource type.
  Future<String> upload(XFile file, {required bool isVideo}) async {
    if (!configured) {
      throw StateError(
          'Cloudinary is not configured. Set cloudinaryCloudName & cloudinaryUploadPreset in app_config.dart.');
    }
    final resource = isVideo ? 'video' : 'image';
    final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/${AppConfig.cloudinaryCloudName}/$resource/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = AppConfig.cloudinaryUploadPreset;

    // readAsBytes works on web and native (XFile.path is not usable on web).
    final bytes = await file.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes('file', bytes,
        filename: file.name.isEmpty ? 'upload' : file.name));

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode >= 400) {
      throw Exception('Cloudinary upload failed (${streamed.statusCode}): $body');
    }
    final json = jsonDecode(body) as Map<String, dynamic>;
    return json['secure_url'] as String;
  }

  /// Uploads several images; returns their URLs in order.
  Future<List<String>> uploadImages(List<XFile> files) async {
    final urls = <String>[];
    for (final f in files) {
      urls.add(await upload(f, isVideo: false));
    }
    return urls;
  }
}
