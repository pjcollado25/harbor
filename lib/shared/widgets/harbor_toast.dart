import 'dart:async';

import 'package:flutter/material.dart';

/// Shows Harbor feedback in a taller floating bubble below the status bar.
void showHarborToast(
  BuildContext context,
  String message, {
  bool isError = false,
  SnackBarAction? action,
}) {
  final colors = Theme.of(context).colorScheme;
  final overlay = Overlay.of(context, rootOverlay: true);
  _activeToastTimers.remove(overlay)?.cancel();
  _activeToastEntries.remove(overlay)?.remove();

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) {
      final media = MediaQuery.of(context);
      return Positioned(
        top: media.padding.top + 12,
        left: 20,
        right: 20,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, -10 * (1 - value)),
                  child: child,
                ),
              ),
              child: Material(
                color: colors.surface.withValues(alpha: .94),
                elevation: 8,
                shadowColor: Colors.black.withValues(alpha: .22),
                shape: StadiumBorder(
                  side: BorderSide(
                    color: colors.outline.withValues(alpha: .55),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 68),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isError
                              ? Icons.error_outline_rounded
                              : Icons.check_circle_outline_rounded,
                          size: 22,
                          color: isError ? colors.error : colors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: colors.onSurface),
                          ),
                        ),
                        if (action != null) ...[
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: action.onPressed,
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  action.textColor ?? colors.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              minimumSize: const Size(48, 40),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(action.label),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  _activeToastEntries[overlay] = entry;
  overlay.insert(entry);
  _activeToastTimers[overlay] = Timer(const Duration(seconds: 3), () {
    if (identical(_activeToastEntries[overlay], entry)) {
      _activeToastEntries.remove(overlay);
      _activeToastTimers.remove(overlay);
      entry.remove();
    }
  });
}

final Map<OverlayState, OverlayEntry> _activeToastEntries = {};
final Map<OverlayState, Timer> _activeToastTimers = {};
