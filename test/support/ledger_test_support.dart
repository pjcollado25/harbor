import 'package:harbor/core/errors/result.dart';
import 'package:harbor/features/ledger/domain/entities/ledger_entities.dart';
import 'package:harbor/features/ledger/domain/repositories/ledger_repository.dart';
import 'package:harbor/features/ledger/domain/repositories/reminder_scheduler.dart';
import 'package:harbor/features/ledger/domain/usecases/ledger_use_cases.dart';
import 'package:harbor/features/ledger/presentation/cubit/ledger_cubit.dart';

class TestLedgerRepository implements LedgerRepository {
  @override
  Future<Result<LedgerSnapshot>> load() async =>
      const Success(LedgerSnapshot());

  @override
  Future<Result<void>> saveBill(Bill bill) async => const Success(null);

  @override
  Future<Result<void>> deleteBill(String id) async => const Success(null);

  @override
  Future<Result<void>> saveIncome(IncomeEvent income) async =>
      const Success(null);

  @override
  Future<Result<void>> deleteIncome(String id) async => const Success(null);

  @override
  Future<Result<void>> savePayment(Payment payment) async =>
      const Success(null);

  @override
  Future<Result<void>> deletePayment(String id) async => const Success(null);

  @override
  Future<Result<void>> saveFunds(FundsSnapshot snapshot) async =>
      const Success(null);

  @override
  Future<Result<void>> savePreferences(UserPreferences preferences) async =>
      const Success(null);

  @override
  Future<Result<void>> saveBufferGoal(int? amount) async => const Success(null);

  @override
  Future<Result<void>> clearAll() async => const Success(null);
}

class _TestReminderScheduler implements ReminderScheduler {
  @override
  Future<Result<void>> scheduleFor(
    Bill bill, {
    required bool hideDetails,
  }) async =>
      const Success(null);

  @override
  Future<Result<void>> cancelFor(String billId) async => const Success(null);

  @override
  Future<Result<void>> requestPermission() async => const Success(null);

  @override
  Future<bool> notificationsEnabled() async => true;

  @override
  Future<void> openNotificationSettings() async {}
}

LedgerCubit createTestLedgerCubit({LedgerState? initial}) {
  final repository = TestLedgerRepository();
  final scheduler = _TestReminderScheduler();
  final cubit = LedgerCubit(
    loadLedger: LoadLedger(repository),
    saveBill: SaveBill(repository),
    deleteBill: DeleteBill(repository),
    saveIncome: SaveIncome(repository),
    deleteIncome: DeleteIncome(repository),
    recordPayment: RecordPayment(repository),
    undoPayment: UndoPayment(repository),
    saveFunds: SaveFunds(repository),
    savePreferences: SavePreferences(repository),
    saveBufferGoal: SaveBufferGoal(repository),
    scheduleReminder: ScheduleBillReminder(scheduler),
    cancelReminder: CancelBillReminder(scheduler),
    requestPermission: RequestReminderPermission(scheduler),
    checkReminderPermission: CheckReminderPermission(scheduler),
    openReminderSettings: OpenReminderSettings(scheduler),
    clearLocalData: ClearLocalData(repository),
  );
  if (initial != null) {
    cubit.emit(initial);
  }
  return cubit;
}
