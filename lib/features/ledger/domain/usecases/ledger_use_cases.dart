import '../../../../core/errors/result.dart';
import '../entities/ledger_entities.dart';
import '../repositories/ledger_repository.dart';
import '../repositories/reminder_scheduler.dart';

class LoadLedger {
  const LoadLedger(this._repository);
  final LedgerRepository _repository;
  Future<Result<LedgerSnapshot>> call() => _repository.load();
}

class SaveBill {
  const SaveBill(this._repository);
  final LedgerRepository _repository;
  Future<Result<void>> call(Bill bill) async {
    if (bill.name.trim().isEmpty)
      return const Failed<void>(AppFailure('Enter a bill name.'));
    if (bill.amount <= 0)
      return const Failed<void>(
        AppFailure('Enter an amount greater than zero.'),
      );
    if (bill.reminderDays < 0)
      return const Failed<void>(
        AppFailure('Reminder timing cannot be negative.'),
      );
    return _repository.saveBill(bill.copyWith(name: bill.name.trim()));
  }
}

class DeleteBill {
  const DeleteBill(this._repository);
  final LedgerRepository _repository;
  Future<Result<void>> call(String id) => _repository.deleteBill(id);
}

class SaveIncome {
  const SaveIncome(this._repository);
  final LedgerRepository _repository;
  Future<Result<void>> call(IncomeEvent income) async {
    if (income.source.trim().isEmpty)
      return const Failed<void>(AppFailure('Enter an income source.'));
    if (income.amount <= 0)
      return const Failed<void>(
        AppFailure('Enter an amount greater than zero.'),
      );
    return _repository.saveIncome(income);
  }
}

class DeleteIncome {
  const DeleteIncome(this._repository);
  final LedgerRepository _repository;
  Future<Result<void>> call(String id) => _repository.deleteIncome(id);
}

class RecordPayment {
  const RecordPayment(this._repository);
  final LedgerRepository _repository;
  Future<Result<void>> call(Payment payment) async {
    if (payment.amount <= 0)
      return const Failed<void>(
        AppFailure('Enter an amount greater than zero.'),
      );
    final loaded = await _repository.load();
    if (loaded case Failed<LedgerSnapshot>(:final failure))
      return Failed(failure);
    final snapshot = (loaded as Success<LedgerSnapshot>).value;
    final matches = snapshot.bills.where((item) => item.id == payment.billId);
    final bill = matches.isEmpty ? null : matches.first;
    if (bill == null)
      return const Failed(AppFailure('This bill could not be found.'));
    final paid = snapshot.payments
        .where((item) => item.billId == bill.id)
        .fold<int>(0, (sum, item) => sum + item.amount);
    if (payment.amount > bill.amount - paid)
      return const Failed(
        AppFailure('Payment exceeds the remaining bill amount.'),
      );
    return _repository.savePayment(payment);
  }
}

class UndoPayment {
  const UndoPayment(this._repository);
  final LedgerRepository _repository;
  Future<Result<void>> call(String paymentId) =>
      _repository.deletePayment(paymentId);
}

class SaveFunds {
  const SaveFunds(this._repository);
  final LedgerRepository _repository;
  Future<Result<void>> call(FundsSnapshot snapshot) async {
    if (snapshot.amount < 0)
      return const Failed<void>(
        AppFailure('Starting funds cannot be negative.'),
      );
    return _repository.saveFunds(snapshot);
  }
}

class SavePreferences {
  const SavePreferences(this._repository);
  final LedgerRepository _repository;
  Future<Result<void>> call(UserPreferences preferences) =>
      _repository.savePreferences(preferences);
}

class SaveBufferGoal {
  const SaveBufferGoal(this._repository);
  final LedgerRepository _repository;
  Future<Result<void>> call(int? amount) async {
    if (amount != null && amount <= 0)
      return const Failed<void>(AppFailure('Enter a goal greater than zero.'));
    return _repository.saveBufferGoal(amount);
  }
}

class ScheduleBillReminder {
  const ScheduleBillReminder(this._scheduler);
  final ReminderScheduler _scheduler;
  Future<Result<void>> call(Bill bill, {required bool hideDetails}) =>
      _scheduler.scheduleFor(bill, hideDetails: hideDetails);
}

class CancelBillReminder {
  const CancelBillReminder(this._scheduler);
  final ReminderScheduler _scheduler;
  Future<Result<void>> call(String billId) => _scheduler.cancelFor(billId);
}

class RequestReminderPermission {
  const RequestReminderPermission(this._scheduler);
  final ReminderScheduler _scheduler;
  Future<Result<void>> call() => _scheduler.requestPermission();
}

class CheckReminderPermission {
  const CheckReminderPermission(this._scheduler);
  final ReminderScheduler _scheduler;
  Future<bool> call() => _scheduler.notificationsEnabled();
}

class OpenReminderSettings {
  const OpenReminderSettings(this._scheduler);
  final ReminderScheduler _scheduler;
  Future<void> call() => _scheduler.openNotificationSettings();
}

class ClearLocalData {
  const ClearLocalData(this._repository);
  final LedgerRepository _repository;
  Future<Result<void>> call() => _repository.clearAll();
}
