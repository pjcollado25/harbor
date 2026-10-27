import 'dart:ui';

import 'package:flutter/material.dart';

import 'glass_chrome.dart';

/// Tab root layout with a collapsing glass header (large at top, compact on scroll).
class HarborStickyScrollView extends StatelessWidget {
  const HarborStickyScrollView({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.leading,
    this.trailing,
    this.horizontalPadding = 20,
    this.bottomPadding = 120,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget> children;
  final double horizontalPadding;
  final double bottomPadding;

  static const double collapsedHeight = 48;
  static const double headerEdgeBleed = 32;

  double get _expandedHeight {
    var height = 50.0 + headerEdgeBleed;
    if (subtitle != null) height += 18;
    if (leading != null) height += 22;
    return height;
  }

  double get _collapsedHeight => collapsedHeight + headerEdgeBleed;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _HarborCollapsingHeaderDelegate(
            title: title,
            subtitle: subtitle,
            leading: leading,
            trailing: trailing,
            horizontalPadding: horizontalPadding,
            topInset: topInset,
            expandedHeight: _expandedHeight + topInset,
            collapsedHeight: _collapsedHeight + topInset,
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            10,
            horizontalPadding,
            bottomPadding,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate(children),
          ),
        ),
      ],
    );
  }
}

class _HarborCollapsingHeaderDelegate extends SliverPersistentHeaderDelegate {
  _HarborCollapsingHeaderDelegate({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.trailing,
    required this.horizontalPadding,
    required this.topInset,
    required this.expandedHeight,
    required this.collapsedHeight,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final double horizontalPadding;
  final double topInset;
  final double expandedHeight;
  final double collapsedHeight;

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => collapsedHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final range = maxExtent - minExtent;
    final t = range > 0 ? (shrinkOffset / range).clamp(0.0, 1.0) : 0.0;
    final progress = Curves.easeInOutCubic.transform(t);
    final alignProgress = ((progress - 0.4) / 0.6).clamp(0.0, 1.0);
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final titleSize = lerpDouble(21, 17, progress)!;
    final titleSpacing = lerpDouble(-0.55, -0.25, progress)!;

    return HarborGlassChrome(
      edge: HarborGlassChromeEdge.bar,
      softBottomFade: true,
      softFadeExtent: HarborStickyScrollView.headerEdgeBleed,
      showTopHighlight: false,
      blurSigma: 38,
      frostScale: 0.34,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        topInset + 2,
        horizontalPadding,
        8,
      ),
      child: SizedBox.expand(
        child: Align(
          alignment: Alignment.lerp(
            Alignment.topLeft,
            Alignment.centerLeft,
            alignProgress,
          )!,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (leading != null)
                      ClipRect(
                        child: Align(
                          alignment: Alignment.topLeft,
                          heightFactor: (1 - progress).clamp(0.0, 1.0),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: leading,
                          ),
                        ),
                      ),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w700,
                        letterSpacing: titleSpacing,
                        height: 1.12,
                        color: onSurface,
                      ),
                    ),
                    if (subtitle != null)
                      ClipRect(
                        child: Align(
                          alignment: Alignment.topLeft,
                          heightFactor: (1 - progress).clamp(0.0, 1.0),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Text(
                              subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: onSurface.withValues(alpha: .68),
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HarborCollapsingHeaderDelegate oldDelegate) {
    return oldDelegate.title != title ||
        oldDelegate.subtitle != subtitle ||
        oldDelegate.expandedHeight != expandedHeight ||
        oldDelegate.collapsedHeight != collapsedHeight ||
        oldDelegate.topInset != topInset ||
        oldDelegate.leading != leading ||
        oldDelegate.trailing != trailing;
  }
}
