import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  // NOTE: Firebase is wired behind the repository layer but disabled by default
  // so the app runs on seed data with no backend config. See lib/data/
  // firestore_repositories.dart and README.md to switch it on.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: GidiHomesApp()));
}
