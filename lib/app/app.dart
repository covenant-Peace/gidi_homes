import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'router.dart';

class GidiHomesApp extends StatelessWidget {
  const GidiHomesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GidiHomes — Lagos Property',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
