import 'package:flutter/material.dart';

/// Responsive design utility and layout helpers for Balloon Kingdom.
/// Ensures consistent scaling and prevention of overflow across all devices:
/// - Compact Mobile (< 380px width)
/// - Standard Mobile (380px - 600px width)
/// - Tablets & Foldables (600px - 1024px width)
/// - Desktop & Web (> 1024px width)
class Responsive {
  static const double compactBreakpoint = 380.0;
  static const double tabletBreakpoint = 600.0;
  static const double desktopBreakpoint = 1024.0;

  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;
  static double height(BuildContext context) => MediaQuery.sizeOf(context).height;

  static bool isCompact(BuildContext context) => width(context) < compactBreakpoint;
  static bool isTablet(BuildContext context) =>
      width(context) >= tabletBreakpoint && width(context) < desktopBreakpoint;
  static bool isDesktop(BuildContext context) => width(context) >= desktopBreakpoint;
  static bool isWideScreen(BuildContext context) => width(context) >= tabletBreakpoint;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  /// Dynamic grid column count based on screen width
  static int crossAxisCount(
    BuildContext context, {
    int compact = 2,
    int? mobile,
    int? tablet,
    int? desktop,
    int medium = 3,
    int large = 4,
  }) {
    final w = width(context);
    if (w >= desktopBreakpoint) return desktop ?? large;
    if (w >= tabletBreakpoint) return tablet ?? medium;
    return mobile ?? compact;
  }
}

/// A responsive wrapper widget that centers content and constrains max width on tablets & web
/// preventing distorted or ultra-stretched UI on large screens.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 640.0,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: padding,
        child: child,
      ),
    );
  }
}
