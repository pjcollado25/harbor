import '../../../core/utils/formatters.dart';
import '../../ledger/domain/entities/ledger_entities.dart';
import 'day_plan_item.dart';

/// Monday-first week containing [anchor].
List<DateTime> weekDatesFor(DateTime anchor) {
  final start = _startOfWeek(dateOnly(anchor));
  return List.generate(7, (index) => start.add(Duration(days: index)));
}

DateTime _startOfWeek(DateTime day) =>
    day.subtract(Duration(days: day.weekday - DateTime.monday));

int billRemaining(LedgerSnapshot snapshot, Bill bill) {
  final paid = snapshot.payments
      .where((payment) => payment.billId == bill.id)
      .fold<int>(0, (sum, payment) => sum + payment.amount);
  return (bill.amount - paid).clamp(0, bill.amount);
}

List<DayPlanItem> dayItemsFor(LedgerSnapshot snapshot, DateTime day) {
  final target = dateOnly(day);
  final items = <DayPlanItem>[];

  for (final bill in snapshot.bills.where((bill) => bill.isActive)) {
    if (dateOnly(bill.dueDate) != target) continue;
    final remaining = billRemaining(snapshot, bill);
    items.add(
      DayPlanItem(
        id: 'bill:${bill.id}',
        name: bill.name,
        amount: remaining > 0 ? remaining : bill.amount,
        kind: remaining > 0 ? DayPlanItemKind.scheduled : DayPlanItemKind.paid,
      ),
    );
  }

  for (final income in snapshot.incomes) {
    if (dateOnly(income.expectedDate) == target &&
        income.status != IncomeStatus.received) {
      items.add(
        DayPlanItem(
          id: 'income:${income.id}',
          name: income.source,
          amount: income.amount,
          kind: DayPlanItemKind.income,
        ),
      );
    }
  }

  items.sort((a, b) {
    int order(DayPlanItemKind kind) => switch (kind) {
          DayPlanItemKind.scheduled => 0,
          DayPlanItemKind.income => 1,
          DayPlanItemKind.paid => 2,
        };
    final byKind = order(a.kind).compareTo(order(b.kind));
    if (byKind != 0) return byKind;
    return a.name.compareTo(b.name);
  });

  return items;
}

bool dayHasItems(LedgerSnapshot snapshot, DateTime day) =>
    dayItemsFor(snapshot, day).isNotEmpty;

/// Signed net for the summary total (income positive, bills negative).
int dayNetTotal(List<DayPlanItem> items) {
  var net = 0;
  for (final item in items) {
    switch (item.kind) {
      case DayPlanItemKind.income:
        net += item.amount;
      case DayPlanItemKind.scheduled:
      case DayPlanItemKind.paid:
        net -= item.amount;
    }
  }
  return net;
}

typedef UpcomingPlanEntry = ({DateTime date, DayPlanItem item});

UpcomingPlanEntry? nearestUpcoming(
  LedgerSnapshot snapshot,
  DateTime afterDay,
) {
  final after = dateOnly(afterDay);
  final candidates = <UpcomingPlanEntry>[];

  for (final bill in snapshot.bills.where((bill) => bill.isActive)) {
    final due = dateOnly(bill.dueDate);
    if (!due.isAfter(after)) continue;
    final remaining = billRemaining(snapshot, bill);
    if (remaining <= 0) continue;
    candidates.add((
      date: due,
      item: DayPlanItem(
        id: 'bill:${bill.id}',
        name: bill.name,
        amount: remaining,
        kind: DayPlanItemKind.scheduled,
      ),
    ));
  }

  for (final income in snapshot.incomes) {
    if (income.status == IncomeStatus.received) continue;
    final when = dateOnly(income.expectedDate);
    if (!when.isAfter(after)) continue;
    candidates.add((
      date: when,
      item: DayPlanItem(
        id: 'income:${income.id}',
        name: income.source,
        amount: income.amount,
        kind: DayPlanItemKind.income,
      ),
    ));
  }

  if (candidates.isEmpty) return null;
  candidates.sort((a, b) {
    final byDate = a.date.compareTo(b.date);
    if (byDate != 0) return byDate;
    return a.item.name.compareTo(b.item.name);
  });
  return candidates.first;
}
