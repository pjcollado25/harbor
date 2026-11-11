import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';

import 'harbor_sticky_header_surface.dart';

/// Tab root layout with a collapsing, feathered header.
class HarborStickyScrollView extends StatefulWidget {
  const HarborStickyScrollView({
    super.key,
    required this.title,
    this.children,
    this.slivers,
    this.subtitle,
    this.leading,
    this.trailing,
    this.horizontalPadding = 20,
    this.bottomPadding = 120,
    this.keepSubtitleWhenCollapsed = false,
    this.titleFontWeight = FontWeight.w700,
    this.expandedTitleSize = 21,
    this.collapsedTitleSize = 17,
  }) : assert(slivers == null || children == null);

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget>? children;
  final List<Widget>? slivers;
  final double horizontalPadding;
  final double bottomPadding;
  final bool keepSubtitleWhenCollapsed;
  final FontWeight titleFontWeight;
  final double expandedTitleSize;
  final double collapsedTitleSize;

  static const double collapsedHeight = 44;
  static const double collapsedHeightWithSubtitle = 38;
  static const double headerFeatherExtent = 32;
  static const double headerEdgeBleed = 28;

  @override
  State<HarborStickyScrollView> createState() => _HarborStickyScrollViewState();
}

class _HarborStickyScrollViewState extends State<HarborStickyScrollView> {
  double _scrollOffset = 0;

  double get _featherExtent =>
      widget.keepSubtitleWhenCollapsed && widget.subtitle != null
      ? HarborStickyScrollView.headerFeatherExtent
      : HarborStickyScrollView.headerEdgeBleed;

  double get _collapsedBodyHeight {
    final base = widget.keepSubtitleWhenCollapsed && widget.subtitle != null
        ? HarborStickyScrollView.collapsedHeightWithSubtitle
        : HarborStickyScrollView.collapsedHeight;
    return base + _featherExtent;
  }

  double get _expandedBodyHeight {
    var height = 48.0 + _featherExtent;
    if (widget.subtitle != null) height += 18;
    if (widget.leading != null) height += 22;
    return height;
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final maxHeader = _expandedBodyHeight + topInset;
    final minHeader = _collapsedBodyHeight + topInset;
    final collapseRange = (maxHeader - minHeader).clamp(0.0, double.infinity);
    final collapseT = collapseRange > 0
        ? (_scrollOffset / collapseRange).clamp(0.0, 1.0)
        : 0.0;
    final progress = Curves.easeInOutCubic.transform(collapseT);
    final headerHeight = collapseRange > 0
        ? (maxHeader - _scrollOffset.clamp(0.0, collapseRange))
        : minHeader;
    final bottomPadding = math.max(
      widget.bottomPadding,
      MediaQuery.paddingOf(context).bottom + 10 + 56 + 36,
    );
    final scrollView = CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: maxHeader)),
        if (widget.slivers == null)
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              widget.horizontalPadding,
              4,
              widget.horizontalPadding,
              bottomPadding,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate(widget.children ?? const []),
            ),
          )
        else ...[
          ...widget.slivers!,
          SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
        ],
      ],
    );
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis != Axis.vertical) return false;
        final next = notification.metrics.pixels;
        if ((next - _scrollOffset).abs() < 0.5) return false;
        setState(() => _scrollOffset = next);
        return false;
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SoftEdgeBlur(
            edges: [
              HarborSoftEdgeBlur.topScrollEdge(
                context,
                height: headerHeight,
                sigma: HarborSoftEdgeBlur.defaultTopSigma,
              ),
            ],
            child: scrollView,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(
                      context,
                    ).scaffoldBackgroundColor.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.78, 1],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  widget.horizontalPadding,
                  topInset + 2,
                  widget.horizontalPadding,
                  0,
                ),
                child: _HarborCollapsingHeaderContent(
                  title: widget.title,
                  subtitle: widget.subtitle,
                  leading: widget.leading,
                  trailing: widget.trailing,
                  progress: progress,
                  keepSubtitleWhenCollapsed: widget.keepSubtitleWhenCollapsed,
                  titleFontWeight: widget.titleFontWeight,
                  expandedTitleSize: widget.expandedTitleSize,
                  collapsedTitleSize: widget.collapsedTitleSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HarborCollapsingHeaderContent extends StatelessWidget {
  const _HarborCollapsingHeaderContent({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.trailing,
    required this.progress,
    required this.keepSubtitleWhenCollapsed,
    required this.titleFontWeight,
    required this.expandedTitleSize,
    required this.collapsedTitleSize,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final double progress;
  final bool keepSubtitleWhenCollapsed;
  final FontWeight titleFontWeight;
  final double expandedTitleSize;
  final double collapsedTitleSize;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final titleSize = lerpDouble(
      expandedTitleSize,
      collapsedTitleSize,
      progress,
    )!;
    final titleSpacing = lerpDouble(-0.55, -0.25, progress)!;
    final subtitleSize = lerpDouble(14, 12, progress)!;
    final subtitleFade = keepSubtitleWhenCollapsed
        ? 1.0
        : (1 - progress).clamp(0.0, 1.0);

    return Align(
      alignment: Alignment.topLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    fontWeight: titleFontWeight,
                    letterSpacing: titleSpacing,
                    height: 1.12,
                    color: onSurface,
                  ),
                ),
                if (subtitle != null)
                  ClipRect(
                    child: Align(
                      alignment: Alignment.topLeft,
                      heightFactor: subtitleFade,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: subtitleSize,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            color: onSurface.withValues(
                              alpha: keepSubtitleWhenCollapsed ? 0.45 : .68,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}
