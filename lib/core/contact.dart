import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_user.dart';
import '../models/property.dart';

/// Launches tel:, WhatsApp and mailto: links for contacting an agent.
class Contact {
  static Future<void> call(BuildContext context, String phone) async {
    await _launch(context, Uri(scheme: 'tel', path: phone));
  }

  static Future<void> whatsapp(
      BuildContext context, AppUser agent, Property p) async {
    final number = agent.whatsappNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final text = Uri.encodeComponent(
        'Hi ${agent.name}, I saw your listing "${p.title}" in ${p.area} on GidiHomes. Is it still available?');
    await _launch(context, Uri.parse('https://wa.me/$number?text=$text'));
  }

  static Future<void> email(
      BuildContext context, AppUser agent, Property p) async {
    final uri = Uri(
      scheme: 'mailto',
      path: agent.email,
      queryParameters: {
        'subject': 'Enquiry: ${p.title} (${p.area}) — GidiHomes',
        'body':
            'Hi ${agent.name},\n\nI am interested in "${p.title}" in ${p.area}. '
                'Please share more details and inspection availability.\n\nThanks.',
      },
    );
    await _launch(context, uri);
  }

  static Future<void> _launch(BuildContext context, Uri uri) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) throw 'could not launch';
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not open ${uri.scheme}. Copy: ${uri.path}')),
      );
    }
  }
}
