import 'package:flutter_test/flutter_test.dart';
import 'package:harbor/core/utils/formatters.dart';
import 'package:harbor/features/dashboard/domain/day_plan_item.dart';
import 'package:harbor/features/dashboard/domain/today_plan_builder.dart';
import 'package:harbor/features/ledger/domain/entities/ledger_entities.dart';

void main() {
  group('dayItemsFor', () {
    test('maps due bills and expected income on the same day', () {
      final day = DateTime(2026, 3, 4);
      final snapshot = LedgerSnapshot(
        bills: [
          Bill(
            id: 'rent',
            name: 'Rent',
            amount: 1850,
            dueDate: day,
          ),
        ],
        incomes: [
          IncomeEvent(
            id: 'pay',
            source: 'Paycheck',
            amount: 2400,
            expectedDate: day,
          ),
        ],
      );

      final items = dayItemsFor(snapshot, day);
      expect(items, hasLength(2));
      expect(items.any((item) => item.kind == DayPlanItemKind.scheduled), isTrue);
      expect(items.any((item) => item.kind == DayPlanItemKind.income), isTrue);
    });

    test('marks fully paid bills as paid on due date', () {
      final day = DateTime(2026, 3, 4);
      final snapshot = LedgerSnapshot(
        bills: [
          Bill(id: 'net', name: 'Internet', amount: 65, dueDate: day),
        ],
        payments: [
          Payment(id: 'p1', billId: 'net', amount: 65, date: day),
        ],
      );

      final items = dayItemsFor(snapshot, day);
      expect(items.single.kind, DayPlanItemKind.paid);
    });
  });

  group('nearestUpcoming', () {
    test('returns the earliest future commitment after the selected day', () {
      final selected = dateOnly(DateTime(2026, 3, 2));
      final snapshot = LedgerSnapshot(
        bills: [
          Bill(
            id: 'b1',
            name: 'Electric',
            amount: 94,
            dueDate: DateTime(2026, 3, 5),
          ),
          Bill(
            id: 'b2',
            name: 'Rent',
            amount: 1850,
            dueDate: DateTime(2026, 3, 4),
          ),
        ],
      );

      final upcoming = nearestUpcoming(snapshot, selected);
      expect(upcoming?.item.name, 'Rent');
      expect(upcoming?.date, dateOnly(DateTime(2026, 3, 4)));
    });
  });

  group('dayNetTotal', () {
    test('subtracts open bills and adds income', () {
      final total = dayNetTotal(const [
        DayPlanItem(
          id: '1',
          name: 'Rent',
          amount: 1000,
          kind: DayPlanItemKind.scheduled,
        ),
        DayPlanItem(
          id: '2',
          name: 'Pay',
          amount: 1500,
          kind: DayPlanItemKind.income,
        ),
        DayPlanItem(
          id: '3',
          name: 'Already paid',
          amount: 400,
          kind: DayPlanItemKind.paid,
        ),
      ]);
      expect(total, 500);
    });
  });

  group('daySummary', () {
    test('says what is left after income', () {
      final summary = daySummary(const [
        DayPlanItem(
          id: '1',
          name: 'Rent',
          amount: 1000,
          kind: DayPlanItemKind.scheduled,
        ),
        DayPlanItem(
          id: '2',
          name: 'Pay',
          amount: 1198,
          kind: DayPlanItemKind.income,
        ),
        DayPlanItem(
          id: '3',
          name: 'Already paid',
          amount: 400,
          kind: DayPlanItemKind.paid,
        ),
      ], 'PHP');

      expect(summary.lead, '1 bill still to pay');
      expect(summary.detail, '₱198 left after income');
    });

    test('shows a minus when income does not cover open bills', () {
      final summary = daySummary(const [
        DayPlanItem(
          id: '1',
          name: 'Rent',
          amount: 1000,
          kind: DayPlanItemKind.scheduled,
        ),
        DayPlanItem(
          id: '2',
          name: 'Food',
          amount: 200,
          kind: DayPlanItemKind.scheduled,
        ),
      ], 'PHP');

      expect(summary.lead, '2 bills still to pay');
      expect(summary.detail, '−₱1,200 short');
    });

    test('names an empty day and a day that is only income', () {
      expect(daySummary(const [], 'PHP').lead, 'Nothing scheduled');
      expect(daySummary(const [], 'PHP').detail, isNull);

      final incomeOnly = daySummary(const [
        DayPlanItem(
          id: '1',
          name: 'Pay',
          amount: 8580,
          kind: DayPlanItemKind.income,
        ),
      ], 'PHP');
      expect(incomeOnly.lead, 'No bills still to pay');
      expect(incomeOnly.detail, '₱8,580 coming in');
    });
  });
}
