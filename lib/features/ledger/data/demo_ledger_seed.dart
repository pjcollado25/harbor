import '../../../core/utils/formatters.dart';
import '../../dashboard/domain/today_plan_builder.dart';
import '../domain/entities/ledger_entities.dart';
import 'datasources/ledger_local_data_source.dart';
import 'models/ledger_models.dart';

/// How many timeline rows to place on the anchor day (bills + income + paid).
const demoPrimaryDayItemCount = 10;

const _categories = [
  'Utilities',
  'Food',
  'Housing',
  'Transport',
  'Subscriptions',
  'Health',
  'Insurance',
  'Debt',
  'Other',
];

/// Builds a local ledger anchored to [anchorDay] (usually today).
GeneratedDemoLedger buildGeneratedDemoLedger({DateTime? anchorDay}) {
  final today = dateOnly(anchorDay ?? DateTime.now());
  final tomorrow = today.add(const Duration(days: 1));

  final bills = <Bill>[];
  // Eight open bills on the anchor day.
  for (var index = 0; index < 8; index++) {
    bills.add(
      Bill(
        id: 'demo-bill-$index',
        name: _categories[index % _categories.length],
        amount: 350 + (index + 1) * 137,
        dueDate: today,
        category: _categories[index % _categories.length],
        isEstimate: index.isEven,
      ),
    );
  }

  // One bill on the anchor day that is fully paid (still shows in the day list).
  bills.add(
    Bill(
      id: 'demo-bill-paid',
      name: 'Paid on time',
      amount: 650,
      dueDate: today,
      category: 'Utilities',
    ),
  );

  // One more bill tomorrow so the week strip has another marked day.
  bills.add(
    Bill(
      id: 'demo-bill-tomorrow',
      name: 'Next day bill',
      amount: 1200,
      dueDate: tomorrow,
      category: 'Housing',
    ),
  );

  final incomes = [
    IncomeEvent(
      id: 'demo-income-0',
      source: 'Expected deposit',
      amount: 8500 + today.day * 10,
      expectedDate: today,
    ),
  ];

  final payments = [
    Payment(
      id: 'demo-payment-0',
      billId: 'demo-bill-paid',
      amount: 650,
      date: today,
    ),
  ];

  return GeneratedDemoLedger(
    bills: bills,
    incomes: incomes,
    payments: payments,
    funds: FundsSnapshot(amount: 12000 + today.day * 100, asOf: today),
  );
}

class GeneratedDemoLedger {
  const GeneratedDemoLedger({
    required this.bills,
    required this.incomes,
    required this.payments,
    required this.funds,
  });

  final List<Bill> bills;
  final List<IncomeEvent> incomes;
  final List<Payment> payments;
  final FundsSnapshot funds;

  int itemCountOn(DateTime day) {
    final target = dateOnly(day);
    final snapshot = LedgerSnapshot(
      bills: bills,
      incomes: incomes,
      payments: payments,
    );
    return dayItemsFor(snapshot, target).length;
  }
}

Future<void> writeGeneratedDemoLedger(
  LedgerLocalDataSource source, {
  bool replace = false,
  DateTime? anchorDay,
}) async {
  if (replace) {
    await source.clearAll();
  } else if (source.readBills().isNotEmpty) {
    return;
  }

  final demo = buildGeneratedDemoLedger(anchorDay: anchorDay);

  for (final bill in demo.bills) {
    await source.putBill(BillModel.fromEntity(bill));
  }
  for (final income in demo.incomes) {
    await source.putIncome(IncomeModel.fromEntity(income));
  }
  for (final payment in demo.payments) {
    await source.putPayment(PaymentModel.fromEntity(payment));
  }

  await source.writeSettings({
    'fundsAmount': demo.funds.amount,
    'fundsDate': demo.funds.asOf,
    'darkMode': true,
    'hideReminderDetails': true,
    'currencyCode': 'PHP',
  });
}
