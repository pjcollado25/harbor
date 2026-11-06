import 'package:flutter_test/flutter_test.dart';
import 'package:harbor/core/utils/formatters.dart';
import 'package:harbor/features/dashboard/domain/today_plan_builder.dart';
import 'package:harbor/features/ledger/data/datasources/ledger_local_data_source.dart';
import 'package:harbor/features/ledger/data/demo_ledger_seed.dart';
import 'package:harbor/features/ledger/data/models/ledger_models.dart';
import 'package:harbor/features/ledger/domain/entities/ledger_entities.dart';

class _MemoryLedgerSource implements LedgerLocalDataSource {
  final Map<String, BillModel> bills = {};
  final Map<String, IncomeModel> incomes = {};
  final Map<String, PaymentModel> payments = {};
  final Map<String, dynamic> settings = {};

  @override
  Future<void> clearAll() async {
    bills.clear();
    incomes.clear();
    payments.clear();
    settings.clear();
  }

  @override
  List<BillModel> readBills() => bills.values.toList(growable: false);

  @override
  List<IncomeModel> readIncomes() => incomes.values.toList(growable: false);

  @override
  List<PaymentModel> readPayments() => payments.values.toList(growable: false);

  @override
  Future<void> putBill(BillModel bill) async => bills[bill.id] = bill;

  @override
  Future<void> putIncome(IncomeModel income) async => incomes[income.id] = income;

  @override
  Future<void> putPayment(PaymentModel payment) async =>
      payments[payment.id] = payment;

  @override
  Future<void> removeBill(String id) async => bills.remove(id);

  @override
  Future<void> removeIncome(String id) async => incomes.remove(id);

  @override
  Future<void> removePayment(String id) async => payments.remove(id);

  @override
  Map<String, dynamic> readSettings() => Map<String, dynamic>.from(settings);

  @override
  Future<void> writeSettings(Map<String, dynamic> values) async =>
      settings.addAll(values);

  @override
  Future<void> removeSetting(String key) async => settings.remove(key);
}

void main() {
  test('generated demo has 10 items on the anchor day', () {
    final demo = buildGeneratedDemoLedger(anchorDay: DateTime(2026, 10, 29));
    expect(demo.itemCountOn(DateTime(2026, 10, 29)), demoPrimaryDayItemCount);
  });

  test('writeGeneratedDemoLedger yields 10 today timeline rows', () async {
    final source = _MemoryLedgerSource();
    final anchor = DateTime(2026, 10, 29);
    await writeGeneratedDemoLedger(source, anchorDay: anchor);

    final snapshot = LedgerSnapshot(
      bills: source.readBills().map((b) => b.toEntity()).toList(),
      incomes: source.readIncomes().map((i) => i.toEntity()).toList(),
      payments: source.readPayments().map((p) => p.toEntity()).toList(),
    );
    expect(dayItemsFor(snapshot, dateOnly(anchor)).length, 10);
  });
}
