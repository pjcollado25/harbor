import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harbor/core/theme/app_theme.dart';
import 'package:harbor/features/ledger/domain/entities/ledger_entities.dart';
import 'package:harbor/features/ledger/presentation/cubit/ledger_cubit.dart';
import 'package:harbor/features/settings/presentation/pages/settings_page.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'support/ledger_test_support.dart';

Widget _buildSettingsApp({
  required LedgerCubit cubit,
  Future<PackageInfo>? packageInfoFuture,
}) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: BlocProvider<LedgerCubit>.value(
      value: cubit,
      child: Scaffold(
        body: SettingsPage(packageInfoFuture: packageInfoFuture),
      ),
    ),
  );
}

void main() {
  group('SettingsPage.formatVersion', () {
    test('formats version and build number', () {
      final info = PackageInfo(
        appName: 'Drop27Payment',
        packageName: 'com.harbor.app',
        version: '1.2.3',
        buildNumber: '42',
        buildSignature: '',
      );
      expect(SettingsPage.formatVersion(info), 'Version 1.2.3 (Build 42)');
    });

    test('formats version without build number', () {
      final info = PackageInfo(
        appName: 'Drop27Payment',
        packageName: 'com.harbor.app',
        version: '1.2.3',
        buildNumber: '',
        buildSignature: '',
      );
      expect(SettingsPage.formatVersion(info), 'Version 1.2.3');
    });

    test('formats build number without version', () {
      final info = PackageInfo(
        appName: 'Drop27Payment',
        packageName: 'com.harbor.app',
        version: '',
        buildNumber: '42',
        buildSignature: '',
      );
      expect(SettingsPage.formatVersion(info), 'Build 42');
    });

    test('returns empty string when both version and build are empty', () {
      final info = PackageInfo(
        appName: 'Drop27Payment',
        packageName: 'com.harbor.app',
        version: '',
        buildNumber: '',
        buildSignature: '',
      );
      expect(SettingsPage.formatVersion(info), '');
    });
  });

  group('SettingsPage version build display', () {
    testWidgets('displays version and build in settings footer', (
      tester,
    ) async {
      final cubit = createTestLedgerCubit(
        initial: const LedgerState(
          isLoading: false,
          snapshot: LedgerSnapshot(),
        ),
      );

      final fakePackageInfo = PackageInfo(
        appName: 'Drop27Payment',
        packageName: 'com.harbor.app',
        version: '0.0.1',
        buildNumber: '2',
        buildSignature: '',
      );

      await tester.pumpWidget(
        _buildSettingsApp(
          cubit: cubit,
          packageInfoFuture: Future.value(fakePackageInfo),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Version 0.0.1 (Build 2)'),
        200,
      );
      await tester.pumpAndSettle();

      expect(find.text('Version 0.0.1 (Build 2)'), findsOneWidget);
      expect(
        find.text('Drop27Payment · Your bills stay on this device'),
        findsOneWidget,
      );

      final versionWidget = tester.widget<Text>(
        find.text('Version 0.0.1 (Build 2)'),
      );
      expect(versionWidget.style?.fontSize, 12);
      expect(versionWidget.style?.color?.a, closeTo(0.54, 0.02));
    });

    testWidgets('displays version and build from platform package info', (
      tester,
    ) async {
      PackageInfo.setMockInitialValues(
        appName: 'Drop27Payment',
        packageName: 'com.harbor.app',
        version: '0.0.1',
        buildNumber: '2',
        buildSignature: '',
      );

      final cubit = createTestLedgerCubit(
        initial: const LedgerState(
          isLoading: false,
          snapshot: LedgerSnapshot(),
        ),
      );

      await tester.pumpWidget(_buildSettingsApp(cubit: cubit));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Version 0.0.1 (Build 2)'),
        200,
      );
      await tester.pumpAndSettle();

      expect(find.text('Version 0.0.1 (Build 2)'), findsOneWidget);
    });

    testWidgets('renders fallback when platform info is not available', (
      tester,
    ) async {
      final cubit = createTestLedgerCubit(
        initial: const LedgerState(
          isLoading: false,
          snapshot: LedgerSnapshot(),
        ),
      );

      await tester.pumpWidget(
        _buildSettingsApp(
          cubit: cubit,
          packageInfoFuture: Future.value(
            PackageInfo(
              appName: 'Drop27Payment',
              packageName: 'com.harbor.app',
              version: '',
              buildNumber: '',
              buildSignature: '',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Drop27Payment · Your bills stay on this device'),
        200,
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Drop27Payment · Your bills stay on this device'),
        findsOneWidget,
      );
      expect(find.text('Version 0.0.1 (Build 2)'), findsNothing);
    });
  });
}
