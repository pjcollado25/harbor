import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harbor/core/theme/app_theme.dart';
import 'package:harbor/features/activity/presentation/pages/activity_page.dart';
import 'package:harbor/features/dashboard/presentation/pages/today_page.dart';
import 'package:harbor/features/ledger/domain/entities/ledger_entities.dart';
import 'package:harbor/features/ledger/presentation/cubit/ledger_cubit.dart';
import 'package:harbor/features/plan/presentation/pages/plan_page.dart';
import 'package:harbor/features/settings/presentation/pages/settings_page.dart';
import 'package:harbor/shared/widgets/edge_blur_overlay.dart';
import 'package:harbor/shared/widgets/glass_panel.dart';

import 'support/ledger_test_support.dart';

Widget _themedShell({
  required ThemeData theme,
  required Widget child,
  required LedgerCubit cubit,
}) {
  return MaterialApp(
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    themeMode: theme.brightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light,
    home: BlocProvider<LedgerCubit>.value(
      value: cubit,
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  group('light and dark surfaces', () {
    for (final mode in [Brightness.light, Brightness.dark]) {
      final label = mode == Brightness.light ? 'light' : 'dark';
      final theme = mode == Brightness.light
          ? AppTheme.light()
          : AppTheme.dark();

      testWidgets('TodayPage renders in $label mode', (tester) async {
        final cubit = createTestLedgerCubit(
          initial: LedgerState(
            isLoading: false,
            snapshot: LedgerSnapshot(
              preferences: UserPreferences(darkMode: mode == Brightness.dark),
            ),
          ),
        );
        await tester.binding.setSurfaceSize(const Size(390, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          _themedShell(theme: theme, cubit: cubit, child: const TodayPage()),
        );
        await tester.pump();

        expect(find.text('Today'), findsOneWidget);
        expect(find.text('Available Buffer'), findsOneWidget);
        expect(find.text('Upcoming obligations'), findsOneWidget);
        expect(find.text('No upcoming obligations'), findsOneWidget);
      });

      testWidgets('Today keeps its header pinned while obligations scroll', (
        tester,
      ) async {
        final cubit = createTestLedgerCubit(
          initial: LedgerState(
            isLoading: false,
            snapshot: LedgerSnapshot(
              bills: List.generate(
                16,
                (index) => Bill(
                  id: 'bill-$index',
                  name: 'Bill $index',
                  amount: 100,
                  dueDate: DateTime.now().add(Duration(days: index + 1)),
                ),
              ),
              preferences: UserPreferences(darkMode: mode == Brightness.dark),
            ),
          ),
        );
        await tester.binding.setSurfaceSize(const Size(390, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          _themedShell(theme: theme, cubit: cubit, child: const TodayPage()),
        );
        await tester.pump();
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
        await tester.pumpAndSettle();

        expect(find.text('Today'), findsOneWidget);
        expect(find.text('Bill 0'), findsNothing);
      });

      testWidgets('SettingsPage footer is readable in $label mode', (
        tester,
      ) async {
        final cubit = createTestLedgerCubit(
          initial: LedgerState(
            isLoading: false,
            snapshot: LedgerSnapshot(
              preferences: UserPreferences(darkMode: mode == Brightness.dark),
            ),
          ),
        );
        await tester.pumpWidget(
          _themedShell(theme: theme, cubit: cubit, child: const SettingsPage()),
        );
        await tester.pump();
        await tester.scrollUntilVisible(
          find.text('Drop27Payment · Your bills stay on this device'),
          200,
        );
        await tester.pump();

        final footer = tester.widget<Text>(
          find.text('Drop27Payment · Your bills stay on this device'),
        );
        final onSurface = theme.colorScheme.onSurface;
        final color = footer.style?.color;
        expect(color, isNotNull);
        expect(color?.a, closeTo(0.54, 0.02));
        expect(color?.r, closeTo(onSurface.r, 0.02));
      });

      testWidgets('PlanPage uses shared surfaces in $label mode', (
        tester,
      ) async {
        final cubit = createTestLedgerCubit(
          initial: LedgerState(
            isLoading: false,
            snapshot: LedgerSnapshot(
              preferences: UserPreferences(darkMode: mode == Brightness.dark),
            ),
          ),
        );
        await tester.binding.setSurfaceSize(const Size(390, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          _themedShell(theme: theme, cubit: cubit, child: const PlanPage()),
        );
        await tester.pump();
        await tester.scrollUntilVisible(find.text('PLAN ASSUMPTIONS'), 200);
        await tester.pump();

        expect(find.text('Plan'), findsOneWidget);
        expect(find.text('Your plan is clear'), findsOneWidget);
        expect(find.text('PLAN ASSUMPTIONS'), findsOneWidget);
      });

      testWidgets(
        'ActivityPage recurs subtitle uses onSurface in $label mode',
        (tester) async {
          final cubit = createTestLedgerCubit(
            initial: const LedgerState(isLoading: false),
          );
          await tester.pumpWidget(
            _themedShell(
              theme: theme,
              cubit: cubit,
              child: const ActivityPage(),
            ),
          );
          await tester.pump();

          final subtitle = tester.widget<Text>(
            find.text('Listed recurring amounts'),
          );
          final onSurface = theme.colorScheme.onSurface;
          final color = subtitle.style?.color;
          expect(color, isNotNull);
          expect(color?.a, closeTo(0.54, 0.02));
          expect(color?.r, closeTo(onSurface.r, 0.02));
        },
      );

      testWidgets('GlassPanel and edge blur build in $label mode', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Stack(
                children: [
                  const Center(child: Text('content')),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: const EdgeBlurOverlay(
                      placement: EdgeBlurPlacement.top,
                    ),
                  ),
                  Center(child: GlassPanel(child: const Text('panel'))),
                ],
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('panel'), findsOneWidget);
      });
    }
  });

  test('dark theme uses the matte neutral palette', () {
    final theme = AppTheme.dark();

    expect(theme.scaffoldBackgroundColor, const Color(0xFF0A0A0A));
    expect(theme.colorScheme.surface, const Color(0xFF121214));
    expect(theme.colorScheme.onSurface, const Color(0xFFF2F2F7));
    expect(theme.colorScheme.primary, const Color(0xFFB8B8BD));
  });
}
