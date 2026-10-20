import 'package:flutter/material.dart';

class HarborSplashScreen extends StatefulWidget {
  const HarborSplashScreen({super.key});

  @override
  State<HarborSplashScreen> createState() => _HarborSplashScreenState();
}

class _HarborSplashScreenState extends State<HarborSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathing = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  late final Animation<double> _scale = Tween<double>(
    begin: .96,
    end: 1.04,
  ).animate(CurvedAnimation(parent: _breathing, curve: Curves.easeInOut));

  @override
  void dispose() {
    _breathing.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Semantics(
        label: 'Loading Harbor',
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: .10),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.onSurface.withValues(alpha: .20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: .12),
                        blurRadius: 28,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.water_drop_rounded,
                    size: 44,
                    color: colors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Harbor',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.5,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Your plan, your pace',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withValues(alpha: .62),
                ),
              ),
              const SizedBox(height: 34),
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.primary.withValues(alpha: .82),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
