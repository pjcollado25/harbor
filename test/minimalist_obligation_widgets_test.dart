import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harbor/features/dashboard/presentation/widgets/available_buffer_card.dart';
import 'package:harbor/shared/widgets/obligation_row.dart';

void main() {
  testWidgets('available buffer displays the entered balance and summary', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AvailableBufferCard(
            amount: 13200,
            currencyCode: 'PHP',
            subtitle:
                '8 bills remaining · Entered funds cover bills through Friday',
          ),
        ),
      ),
    );

    expect(find.text('Available Buffer'), findsOneWidget);
    expect(find.text('₱13,200'), findsOneWidget);
    expect(
      find.text('8 bills remaining · Entered funds cover bills through Friday'),
      findsOneWidget,
    );
  });

  testWidgets('obligation row fits a narrow screen without overflow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ObligationRow(
              name: 'Monthly utilities bill',
              detail: 'Due tomorrow',
              amount: 148700,
              currencyCode: 'PHP',
              category: 'Utilities',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Monthly utilities bill'), findsOneWidget);
    expect(find.textContaining('₱148,700'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
