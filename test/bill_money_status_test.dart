import 'package:flutter_test/flutter_test.dart';
import 'package:harbor/features/bills/domain/bill_money_status.dart';
import 'package:harbor/features/ledger/domain/entities/ledger_entities.dart';

void main() {
  final today = DateTime(2026, 11, 8);
  Bill bill({required int amount, required DateTime due}) => Bill(
    id: 'bill',
    name: 'Rent',
    amount: amount,
    dueDate: due,
  );

  test('a future bill is upcoming and shows what is still owed', () {
    final status = billMoneyStatus(
      bill(amount: 1446, due: DateTime(2026, 11, 15)),
      0,
      today,
    );

    expect(status.label, 'Upcoming');
    expect(status.displayAmount, 1446);
  });

  test('a settled bill shows Paid and the amount that was paid', () {
    final status = billMoneyStatus(
      bill(amount: 1446, due: today),
      1446,
      today,
    );

    expect(status.label, 'Paid');
    expect(status.displayAmount, 1446);
    expect(status.remaining, 0);
  });

  test('a past unpaid bill is overdue', () {
    final status = billMoneyStatus(
      bill(amount: 500, due: DateTime(2026, 11, 1)),
      100,
      today,
    );

    expect(status.label, 'Overdue');
    expect(status.displayAmount, 400);
  });
}
