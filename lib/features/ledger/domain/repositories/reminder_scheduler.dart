import '../../../../core/errors/result.dart';
import '../entities/ledger_entities.dart';

abstract interface class ReminderScheduler {
  Future<Result<void>> scheduleFor(Bill bill, {required bool hideDetails});
  Future<Result<void>> cancelFor(String billId);
  Future<Result<void>> requestPermission();
  Future<bool> notificationsEnabled();
  Future<void> openNotificationSettings();
}
