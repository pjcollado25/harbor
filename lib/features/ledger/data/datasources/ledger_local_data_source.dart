import 'package:hive/hive.dart';

import '../models/ledger_models.dart';

abstract interface class LedgerLocalDataSource {
  List<BillModel> readBills();
  List<IncomeModel> readIncomes();
  List<PaymentModel> readPayments();
  Future<void> putBill(BillModel bill);
  Future<void> removeBill(String id);
  Future<void> putIncome(IncomeModel income);
  Future<void> removeIncome(String id);
  Future<void> putPayment(PaymentModel payment);
  Future<void> removePayment(String id);
  Map<String, dynamic> readSettings();
  Future<void> writeSettings(Map<String, dynamic> values);
  Future<void> removeSetting(String key);
  Future<void> clearAll();
}

class HiveLedgerLocalDataSource implements LedgerLocalDataSource {
  const HiveLedgerLocalDataSource({
    required Box<BillModel> bills,
    required Box<IncomeModel> incomes,
    required Box<PaymentModel> payments,
    required Box<dynamic> settings,
  }) : _bills = bills,
       _incomes = incomes,
       _payments = payments,
       _settings = settings;
  final Box<BillModel> _bills;
  final Box<IncomeModel> _incomes;
  final Box<PaymentModel> _payments;
  final Box<dynamic> _settings;

  @override
  List<BillModel> readBills() => _bills.values.toList(growable: false);
  @override
  List<IncomeModel> readIncomes() => _incomes.values.toList(growable: false);
  @override
  List<PaymentModel> readPayments() => _payments.values.toList(growable: false);
  @override
  Future<void> putBill(BillModel bill) => _bills.put(bill.id, bill);
  @override
  Future<void> removeBill(String id) async {
    await _bills.delete(id);
    await _payments.deleteAll(
      _payments.values
          .where((value) => value.billId == id)
          .map((value) => value.id),
    );
  }

  @override
  Future<void> putIncome(IncomeModel income) => _incomes.put(income.id, income);
  @override
  Future<void> removeIncome(String id) => _incomes.delete(id);
  @override
  Future<void> putPayment(PaymentModel payment) =>
      _payments.put(payment.id, payment);
  @override
  Future<void> removePayment(String id) => _payments.delete(id);
  @override
  Map<String, dynamic> readSettings() => Map<String, dynamic>.from(
    _settings.toMap().map((key, value) => MapEntry(key.toString(), value)),
  );
  @override
  Future<void> writeSettings(Map<String, dynamic> values) =>
      _settings.putAll(values);
  @override
  Future<void> removeSetting(String key) => _settings.delete(key);
  @override
  Future<void> clearAll() async {
    await Future.wait([
      _bills.clear(),
      _incomes.clear(),
      _payments.clear(),
      _settings.clear(),
    ]);
  }
}
