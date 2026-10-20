import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/ledger/presentation/cubit/ledger_cubit.dart';
import 'shared/widgets/harbor_splash_screen.dart';

class HarborApp extends StatelessWidget {
  const HarborApp({super.key, required this.router, required this.ledgerCubit});
  final GoRouter router;
  final LedgerCubit ledgerCubit;

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: ledgerCubit,
    child: BlocBuilder<LedgerCubit, LedgerState>(
      builder: (context, state) => MaterialApp.router(
        title: 'Harbor',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: state.snapshot.preferences.darkMode
            ? ThemeMode.dark
            : ThemeMode.light,
        routerConfig: router,
        builder: (context, child) => _StartupSplashGate(
          isLoading: state.isLoading,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    ),
  );
}

class _StartupSplashGate extends StatefulWidget {
  const _StartupSplashGate({required this.isLoading, required this.child});

  final bool isLoading;
  final Widget child;

  @override
  State<_StartupSplashGate> createState() => _StartupSplashGateState();
}

class _StartupSplashGateState extends State<_StartupSplashGate> {
  Timer? _minimumDurationTimer;
  bool _minimumDurationElapsed = false;

  @override
  void initState() {
    super.initState();
    _minimumDurationTimer = Timer(const Duration(milliseconds: 850), () {
      if (!mounted) return;
      setState(() => _minimumDurationElapsed = true);
    });
  }

  @override
  void dispose() {
    _minimumDurationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showSplash = widget.isLoading || !_minimumDurationElapsed;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: showSplash
          ? const HarborSplashScreen(key: ValueKey('harbor-splash'))
          : KeyedSubtree(
              key: const ValueKey('harbor-app'),
              child: widget.child,
            ),
    );
  }
}
