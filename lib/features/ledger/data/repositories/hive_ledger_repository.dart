import 'dart:async';

import '../../../../core/errors/result.dart';
import '../../domain/entities/ledger_entities.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../datasources/ledger_local_data_source.dart';
import '../models/ledger_models.dart';

class HiveLedgerRepository implements LedgerRepository {
  const HiveLedgerRepository(this._source);
  final LedgerLocalDataSource _source;

  @override
  Future<Result<LedgerSnapshot>> load() => _guard(() {
    final settings = _source.readSettings();
    final fundsAmount = settings['fundsAmount'] as int?;
    final fundsDate = settings['fundsDate'] as DateTime?;
    return LedgerSnapshot(
      bills: _source
          .readBills()
          .map((item) => item.toEntity())
          .toList(growable: false),
      incomes: _source
          .readIncomes()
          .map((item) => item.toEntity())
          .toList(growable: false),
      payments: _source
          .readPayments()
          .map((item) => item.toEntity())
          .toList(growable: false),
      funds: fundsAmount == null || fundsDate == null
          ? null
          : FundsSnapshot(amount: fundsAmount, asOf: fundsDate),
      preferences: UserPreferences(
        darkMode: settings['darkMode'] as bool? ?? true,
        hideReminderDetails: settings['hideReminderDetails'] as bool? ?? true,
        currencyCode: settings['currencyCode'] as String? ?? 'PHP',
      ),
      bufferGoal: settings['bufferGoal'] as int?,
    );
  });

  @override
  Future<Result<void>> saveBill(Bill bill) =>
      _guard(() => _source.putBill(BillModel.fromEntity(bill)));
  @override
  Future<Result<void>> deleteBill(String id) =>
      _guard(() => _source.removeBill(id));
  @override
  Future<Result<void>> saveIncome(IncomeEvent income) =>
      _guard(() => _source.putIncome(IncomeModel.fromEntity(income)));
  @override
  Future<Result<void>> deleteIncome(String id) =>
      _guard(() => _source.removeIncome(id));
  @override
  Future<Result<void>> savePayment(Payment payment) =>
      _guard(() => _source.putPayment(PaymentModel.fromEntity(payment)));
  @override
  Future<Result<void>> deletePayment(String id) =>
      _guard(() => _source.removePayment(id));
  @override
  Future<Result<void>> saveFunds(FundsSnapshot snapshot) => _guard(
    () => _source.writeSettings({
      'fundsAmount': snapshot.amount,
      'fundsDate': snapshot.asOf,
    }),
  );
  @override
  Future<Result<void>> savePreferences(UserPreferences preferences) => _guard(
    () => _source.writeSettings({
      'darkMode': preferences.darkMode,
      'hideReminderDetails': preferences.hideReminderDetails,
      'currencyCode': preferences.currencyCode,
    }),
  );
  @override
  Future<Result<void>> clearAll() => _guard(_source.clearAll);

  @override
  Future<Result<void>> saveBufferGoal(int? amount) => _guard(() async {
    if (amount == null) {
      await _source.removeSetting('bufferGoal');
    } else {
      await _source.writeSettings({'bufferGoal': amount});
    }
  });

  Future<Result<T>> _guard<T>(FutureOr<T> Function() operation) async {
    try {
      return Success<T>(await operation());
    } catch (error) {
      return Failed<T>(
        AppFailure(
          'Harbor could not save your local data. Please try again.',
          cause: error,
        ),
      );
    }
  }
}
