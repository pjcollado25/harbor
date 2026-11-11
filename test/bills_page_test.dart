import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harbor/features/bills/presentation/pages/bills_page.dart';
import 'package:harbor/features/ledger/domain/entities/ledger_entities.dart';
import 'package:harbor/features/ledger/presentation/cubit/ledger_cubit.dart';

import 'support/ledger_test_support.dart';

void main() {
  testWidgets('bills use a builder-backed list with clean obligation rows', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final cubit = createTestLedgerCubit(
      initial: LedgerState(
        isLoading: false,
        snapshot: LedgerSnapshot(
          bills: [
            Bill(
              id: 'utilities',
              name: 'Utilities',
              amount: 487,
              dueDate: DateTime.now().add(const Duration(days: 3)),
              category: 'Utilities',
            ),
          ],
        ),
      ),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: cubit, child: const BillsPage()),
      ),
    );

    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Utilities'), findsOneWidget);
    expect(find.textContaining('Due '), findsOneWidget);
    expect(find.text('₱487'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
