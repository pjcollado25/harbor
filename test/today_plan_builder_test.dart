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
    test('subtracts bills and adds income', () {
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
      ]);
      expect(total, 500);
    });
  });
}
