import 'dart:ui';

import 'package:flutter/material.dart';

/// Frosted glass surface shared by sticky headers, panels, and chrome bars.
class HarborGlassChrome extends StatelessWidget {
  const HarborGlassChrome({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.borderRadius = BorderRadius.zero,
    this.showTopHighlight = true,
    this.edge = HarborGlassChromeEdge.bar,
    this.softBottomFade = false,
    this.softTopFade = false,
    this.softFadeExtent = 40,
    this.blurSigma = 36,
    this.frostScale = 1,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final bool showTopHighlight;
  final HarborGlassChromeEdge edge;
  final bool softBottomFade;
  final bool softTopFade;
  final double softFadeExtent;
  final double blurSigma;
  final double frostScale;

  static ImageFilter blurFilter(double sigma) => ImageFilter.blur(
    sigmaX: sigma,
    sigmaY: sigma,
    tileMode: TileMode.clamp,
  );

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final veil = dark
        ? Colors.white.withValues(alpha: 0.032 * frostScale)
        : Colors.white.withValues(alpha: 0.26 * frostScale);
    final borderColor = dark
        ? Colors.white.withValues(alpha: .03)
        : Colors.black.withValues(alpha: .025);
    final highlight = Colors.white.withValues(alpha: dark ? .08 : .22);

    final border = switch (edge) {
      HarborGlassChromeEdge.bar => softBottomFade
          ? null
          : Border(
              bottom: BorderSide(color: borderColor, width: .25),
            ),
      HarborGlassChromeEdge.rounded => null,
    };

    final content = Padding(
      padding: padding,
      child: Material(color: Colors.transparent, child: child),
    );

    final topHighlight = showTopHighlight
        ? Positioned(
            top: 0,
            left: 32,
            right: 32,
            height: 1,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      highlight,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          )
        : null;

    final usesEdgeFade = softBottomFade || softTopFade;

    if (!usesEdgeFade) {
      return ClipRRect(
        borderRadius: borderRadius,
        clipBehavior: Clip.hardEdge,
        child: BackdropFilter(
          filter: blurFilter(blurSigma),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: border,
              color: veil,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ?topHighlight,
                content,
              ],
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final fadePortion = (softFadeExtent / constraints.maxHeight)
                    .clamp(0.18, 0.42);
                final solidEnd = softBottomFade ? 1 - fadePortion : fadePortion;
                final fadeStart = softBottomFade
                    ? solidEnd - 0.02
                    : fadePortion + 0.02;

                final stops = softBottomFade
                    ? [0.0, fadeStart, solidEnd, 1.0]
                    : [0.0, fadeStart, solidEnd, 1.0];
                final maskColors = softBottomFade
                    ? const [
                        Color(0xFFFFFFFF),
                        Color(0xFFFFFFFF),
                        Color(0x66FFFFFF),
                        Color(0x00FFFFFF),
                      ]
                    : const [
                        Color(0x00FFFFFF),
                        Color(0x66FFFFFF),
                        Color(0xFFFFFFFF),
                        Color(0xFFFFFFFF),
                      ];

                return ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: stops,
                    colors: maskColors,
                  ).createShader(bounds),
                  blendMode: BlendMode.dstIn,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      BackdropFilter(
                        filter: blurFilter(blurSigma),
                        child: ColoredBox(color: veil),
                      ),
                      ?topHighlight,
                    ],
                  ),
                );
              },
            ),
          ),
          content,
        ],
      ),
    );
  }
}

enum HarborGlassChromeEdge { bar, rounded }
