import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/seed_service.dart';
import '../../theme/app_theme.dart';

/// Dev-only screen to push the sample Lagos data into Firestore.
/// Reachable at /dev/seed. Remove in production.
class SeedScreen extends StatefulWidget {
  const SeedScreen({super.key});

  @override
  State<SeedScreen> createState() => _SeedScreenState();
}

class _SeedScreenState extends State<SeedScreen> {
  String _status = 'Ready to seed Firestore with sample Lagos data.';
  bool _busy = false;

  Future<void> _seed() async {
    setState(() {
      _busy = true;
      _status = 'Writing agents and listings…';
    });
    try {
      final count = await SeedService().run();
      setState(() => _status = '✅ Done — wrote $count documents to Firestore.');
    } catch (e) {
      setState(() => _status = '❌ Failed: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Seed Firestore (dev)'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_upload_outlined,
                  size: 56, color: AppColors.green),
              const SizedBox(height: 16),
              Text(_status, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _busy ? null : _seed,
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.2, color: Colors.white))
                    : const Icon(Icons.play_arrow_rounded),
                label: Text(_busy ? 'Seeding…' : 'Seed sample data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
