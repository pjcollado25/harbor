import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/ledger/presentation/cubit/ledger_cubit.dart';
import 'edge_blur_overlay.dart';
import 'glass_chrome.dart';

class HarborShell extends StatefulWidget {
  const HarborShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  static const _destinations = <({String label, IconData icon, String path})>[
    (label: 'Today', icon: Icons.home_outlined, path: '/'),
    (label: 'Plan', icon: Icons.calendar_month_outlined, path: '/plan'),
    (label: 'Bills', icon: Icons.receipt_long_outlined, path: '/bills'),
    (label: 'Activity', icon: Icons.show_chart_rounded, path: '/activity'),
    (label: 'Settings', icon: Icons.settings_outlined, path: '/settings'),
  ];

  @override
  State<HarborShell> createState() => _HarborShellState();
}

class _HarborShellState extends State<HarborShell> {
  bool _notificationPromptStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybePromptForNotifications();
    });
  }

  Future<void> _maybePromptForNotifications() async {
    if (_notificationPromptStarted) return;
    _notificationPromptStarted = true;
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;

    final ledgerCubit = context.read<LedgerCubit>();
    final enabled = await ledgerCubit.checkReminderPermission();
    if (!mounted || enabled) return;

    final shouldRequest = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.notifications_active_outlined),
        title: const Text('Turn on bill reminders?'),
        content: const Text(
          'Allow Harbor to notify you before a bill is due. Your reminders stay on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (shouldRequest != true || !mounted) return;

    final granted = await ledgerCubit.requestReminderPermission();
    if (!mounted || granted) return;

    final openSettings = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.notifications_off_outlined),
        title: const Text('Notifications are turned off'),
        content: const Text(
          'You can still use Harbor. Turn on notifications in your device settings to receive bill reminders.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
    if (openSettings == true && mounted) {
      await ledgerCubit.openReminderSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationShell = widget.navigationShell;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        _AmbientBackdrop(dark: dark),
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          // Let each tab's scrollable content continue behind the floating
          // navigation surface.
          body: SafeArea(
            top: false,
            bottom: false,
            child: navigationShell,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Material(
            color: Colors.transparent,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: -14,
                      right: -14,
                      bottom: 0,
                      height: 64 + 88,
                      child: const IgnorePointer(
                        child: EdgeBlurOverlay(
                          placement: EdgeBlurPlacement.bottom,
                          blurSigma: 34,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: dark ? .14 : .045,
                            ),
                            blurRadius: 24,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: HarborGlassChrome(
                        edge: HarborGlassChromeEdge.rounded,
                        borderRadius: BorderRadius.circular(32),
                        blurSigma: 34,
                        frostScale: 0.3,
                        child: SizedBox(
                          height: 64,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final tabWidth =
                                  constraints.maxWidth /
                                  HarborShell._destinations.length;
                              return Stack(
                                children: [
                                  AnimatedPositioned(
                                    duration: const Duration(
                                      milliseconds: 280,
                                    ),
                                    curve: Curves.easeInOutCubic,
                                    top: 6,
                                    bottom: 6,
                                    left:
                                        navigationShell.currentIndex *
                                            tabWidth +
                                        6,
                                    width: tabWidth - 12,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: dark
                                            ? Colors.white.withValues(
                                                alpha: .016,
                                              )
                                            : Colors.black.withValues(
                                                alpha: .012,
                                              ),
                                        border: Border.all(
                                          color: dark
                                              ? Colors.white.withValues(
                                                  alpha: .035,
                                                )
                                              : Colors.black.withValues(
                                                  alpha: .025,
                                                ),
                                        ),
                                        borderRadius: BorderRadius.circular(22),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: .03),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      for (
                                        var index = 0;
                                        index <
                                            HarborShell._destinations.length;
                                        index++
                                      )
                                        Expanded(
                                          child: _TabButton(
                                            destination: HarborShell
                                                ._destinations[index],
                                            selected:
                                                navigationShell
                                                    .currentIndex ==
                                                index,
                                            onTap: () =>
                                                navigationShell.goBranch(
                                              index,
                                              initialLocation:
                                                  index ==
                                                  navigationShell
                                                      .currentIndex,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                      ),
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AmbientBackdrop extends StatelessWidget {
  const _AmbientBackdrop({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark
              ? const [Color(0xFF000000), Color(0xFF0A1018)]
              : const [Color(0xFFF8FAFC), Color(0xFFEEF2F6)],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.destination,
    required this.selected,
    required this.onTap,
  });
  final ({String label, IconData icon, String path}) destination;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: destination.label,
    child: Semantics(
      label: destination.label,
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Center(
            child: AnimatedScale(
              scale: selected ? 1.08 : 1,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: Icon(
                destination.icon,
                size: 24,
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: .66),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
