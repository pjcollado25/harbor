import 'package:flutter/material.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';

/// Shared [SoftEdgeBlur] edge configs for Harbor chrome (top header + bottom nav).
///
/// See [soft_edge_blur on pub.dev](https://pub.dev/packages/soft_edge_blur).
class HarborSoftEdgeBlur {
  HarborSoftEdgeBlur._();

  static const defaultTopSigma = 68.0;
  static const defaultBottomSigma = 64.0;

  static Color _tint(BuildContext context, {required double darkAlpha, required double lightAlpha}) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return theme.canvasColor.withValues(alpha: dark ? darkAlpha : lightAlpha);
  }

  static List<ControlPoint> get _featherMask => [
    ControlPoint(
      position: 0,
      type: ControlPointType.visible,
    ),
    ControlPoint(
      position: 0.35,
      type: ControlPointType.visible,
    ),
    ControlPoint(
      position: 0.68,
      type: ControlPointType.visible,
    ),
    ControlPoint(
      position: 1,
      type: ControlPointType.transparent,
    ),
  ];

  static EdgeBlur topScrollEdge(
    BuildContext context, {
    required double height,
    double sigma = defaultTopSigma,
  }) {
    return EdgeBlur(
      type: EdgeType.topEdge,
      size: height.clamp(48.0, 260.0),
      sigma: sigma,
      tintColor: _tint(context, darkAlpha: 0.22, lightAlpha: 0.32),
      controlPoints: _featherMask,
    );
  }

  /// Blurs tab content as it scrolls under the floating nav (feather points upward).
  static EdgeBlur bottomScrollEdge(
    BuildContext context, {
    required double height,
    double sigma = defaultBottomSigma,
  }) {
    return EdgeBlur(
      type: EdgeType.bottomEdge,
      size: height.clamp(56.0, 140.0),
      sigma: sigma,
      tintColor: _tint(context, darkAlpha: 0.26, lightAlpha: 0.36),
      controlPoints: _featherMask,
    );
  }

  /// Nav dock + safe area + scroll feather above the pill.
  static double bottomEdgeHeight(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    const navHeight = 56.0;
    const outerPadding = 10.0;
    const feather = 28.0;
    return padding.bottom + outerPadding + navHeight + feather;
  }
}
