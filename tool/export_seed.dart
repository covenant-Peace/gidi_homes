// Exports the Dart seed data (agents + listings) as JSON for the Admin-SDK
// seeding script. Run:  dart run tool/export_seed.dart > tool/seed.json
import 'dart:convert';

import 'package:gidi_homes/data/sample_data.dart';

void main() {
  final out = {
    'agents': seedAgents.map((a) => a.toMap()).toList(),
    'properties': seedProperties.map((p) => p.toMap()).toList(),
  };
  // ignore: avoid_print
  print(const JsonEncoder.withIndent('  ').convert(out));
}
