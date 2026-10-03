import 'package:flutter/widgets.dart';

/// Breakpoints shared across the app so the same codebase reads as a polished
/// website on wide screens and a mobile app on phones.
class Breakpoints {
  static const double mobile = 640;
  static const double tablet = 1024;
  static const double maxContent = 1200; // centered page width on desktop
}

extension ResponsiveContext on BuildContext {
  double get width => MediaQuery.sizeOf(this).width;
  bool get isMobile => width < Breakpoints.mobile;
  bool get isTablet =>
      width >= Breakpoints.mobile && width < Breakpoints.tablet;
  bool get isDesktop => width >= Breakpoints.tablet;

  /// Columns for a responsive property grid.
  int get gridColumns {
    final w = width;
    if (w >= 1400) return 4;
    if (w >= Breakpoints.tablet) return 3;
    if (w >= Breakpoints.mobile) return 2;
    return 1;
  }
}

/// Centers content and caps its width on large screens.
class PageContainer extends StatelessWidget {
  const PageContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.maxWidth = Breakpoints.maxContent,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
