import 'dart:ui';

import 'package:flutter/material.dart';

enum EdgeBlurPlacement { top, bottom }

/// Blur-only scroll edge (no tint). Mask is tuned for a long, seam-free falloff.
class EdgeBlurOverlay extends StatelessWidget {
  const EdgeBlurOverlay({
    super.key,
    required this.placement,
    this.blurSigma = 36,
  });

  final EdgeBlurPlacement placement;
  final double blurSigma;

  static const _stops = [0.0, 0.2, 0.45, 0.68, 0.88, 1.0];
  static const _mask = [
    Color(0xFF000000),
    Color(0xE0000000),
    Color(0xA8000000),
    Color(0x60000000),
    Color(0x22000000),
    Color(0x00000000),
  ];

  @override
  Widget build(BuildContext context) {
    final begin = placement == EdgeBlurPlacement.top
        ? Alignment.topCenter
        : Alignment.bottomCenter;
    final end = placement == EdgeBlurPlacement.top
        ? Alignment.bottomCenter
        : Alignment.topCenter;

    return ClipRect(
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: begin,
          end: end,
          stops: _stops,
          colors: _mask,
        ).createShader(bounds),
        blendMode: BlendMode.dstIn,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurSigma,
            sigmaY: blurSigma,
            tileMode: TileMode.clamp,
          ),
          child: const ColoredBox(color: Color(0x01FFFFFF)),
        ),
      ),
    );
  }
}
