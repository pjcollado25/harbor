import 'dart:ui';

import 'package:flutter/material.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 24,
    this.tint,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = dark
        ? Colors.white.withValues(alpha: .055)
        : Colors.black.withValues(alpha: .04);
    final fillColor =
        tint ??
        (dark
            ? Colors.white.withValues(alpha: .025)
            : Colors.black.withValues(alpha: .025));
    final shape = BorderRadius.circular(radius);
    return Container(
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: [
          BoxShadow(
            color: dark
                ? Colors.black.withValues(alpha: .16)
                : Colors.black.withValues(alpha: .05),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: shape,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(color: fillColor, borderRadius: shape),
            foregroundDecoration: BoxDecoration(
              borderRadius: shape,
              border: Border.all(color: borderColor, width: .65),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: radius,
                  right: radius,
                  height: 2,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: dark ? .025 : .09),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: padding,
                  child: Material(color: Colors.transparent, child: child),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
