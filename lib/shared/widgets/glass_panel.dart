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
    final shape = BorderRadius.circular(radius);
    if (dark) {
      return ClipRRect(
        borderRadius: shape,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tint ?? Theme.of(context).colorScheme.surface,
            borderRadius: shape,
          ),
          child: Padding(
            padding: padding,
            child: Material(color: Colors.transparent, child: child),
          ),
        ),
      );
    }

    final fillColor = tint ?? Colors.white.withValues(alpha: .82);
    return ClipRRect(
      borderRadius: shape,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: shape,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(color: fillColor, borderRadius: shape),
            foregroundDecoration: BoxDecoration(
              borderRadius: shape,
              border: Border.all(
                color: Colors.black.withValues(alpha: .14),
                width: .65,
              ),
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
                            Colors.black.withValues(alpha: .05),
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
