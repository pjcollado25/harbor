import '../../../core/utils/formatters.dart';
import '../../ledger/domain/entities/ledger_entities.dart';

/// The amount and status word shown for a bill.
///
/// A settled bill shows what was paid. An open bill shows what is still owed.
/// [label] is the same word on the list and the detail screen.
class BillMoneyStatus {
  const BillMoneyStatus({
    required this.paid,
    required this.remaining,
    required this.displayAmount,
    required this.label,
  });

  final int paid;
  final int remaining;
  final int displayAmount;
  final String label;

  bool get isPaid => label == 'Paid';
}

BillMoneyStatus billMoneyStatus(Bill bill, int paid, DateTime today) {
  final remaining = (bill.amount - paid).clamp(0, bill.amount);
  if (remaining == 0) {
    return BillMoneyStatus(
      paid: paid,
      remaining: 0,
      displayAmount: paid,
      label: 'Paid',
    );
  }
  final overdue = dateOnly(bill.dueDate).isBefore(dateOnly(today));
  return BillMoneyStatus(
    paid: paid,
    remaining: remaining,
    displayAmount: remaining,
    label: overdue ? 'Overdue' : 'Upcoming',
  );
}
