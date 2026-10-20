import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../routing/app_router.dart';
import '../services/local_notification_service.dart';
import '../../features/ledger/data/datasources/ledger_local_data_source.dart';
import '../../features/ledger/data/models/ledger_models.dart';
import '../../features/ledger/data/repositories/hive_ledger_repository.dart';
import '../../features/ledger/domain/repositories/ledger_repository.dart';
import '../../features/ledger/domain/repositories/reminder_scheduler.dart';
import '../../features/ledger/domain/usecases/ledger_use_cases.dart';
import '../../features/ledger/presentation/cubit/ledger_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  Hive.registerAdapter(BillModelAdapter());
  Hive.registerAdapter(IncomeModelAdapter());
  Hive.registerAdapter(PaymentModelAdapter());
  final bills = await Hive.openBox<BillModel>('harbor_bills_v1');
  final incomes = await Hive.openBox<IncomeModel>('harbor_income_v1');
  final payments = await Hive.openBox<PaymentModel>('harbor_payments_v1');
  final settings = await Hive.openBox<dynamic>('harbor_settings_v1');
  getIt.registerSingleton<Box<BillModel>>(bills);
  getIt.registerSingleton<Box<IncomeModel>>(incomes);
  getIt.registerSingleton<Box<PaymentModel>>(payments);
  getIt.registerSingleton<Box<dynamic>>(settings);
  getIt.registerLazySingleton<LedgerLocalDataSource>(
    () => HiveLedgerLocalDataSource(
      bills: getIt(),
      incomes: getIt(),
      payments: getIt(),
      settings: getIt(),
    ),
  );
  getIt.registerLazySingleton<LedgerRepository>(
    () => HiveLedgerRepository(getIt()),
  );
  getIt.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    FlutterLocalNotificationsPlugin.new,
  );
  getIt.registerLazySingleton<LocalNotificationService>(
    () => LocalNotificationService(getIt()),
  );
  getIt.registerLazySingleton<ReminderScheduler>(
    () => getIt<LocalNotificationService>(),
  );

  getIt.registerLazySingleton(() => LoadLedger(getIt()));
  getIt.registerLazySingleton(() => SaveBill(getIt()));
  getIt.registerLazySingleton(() => DeleteBill(getIt()));
  getIt.registerLazySingleton(() => SaveIncome(getIt()));
  getIt.registerLazySingleton(() => DeleteIncome(getIt()));
  getIt.registerLazySingleton(() => RecordPayment(getIt()));
  getIt.registerLazySingleton(() => UndoPayment(getIt()));
  getIt.registerLazySingleton(() => SaveFunds(getIt()));
  getIt.registerLazySingleton(() => SavePreferences(getIt()));
  getIt.registerLazySingleton(() => SaveBufferGoal(getIt()));
  getIt.registerLazySingleton(() => ScheduleBillReminder(getIt()));
  getIt.registerLazySingleton(() => CancelBillReminder(getIt()));
  getIt.registerLazySingleton(() => RequestReminderPermission(getIt()));
  getIt.registerLazySingleton(() => CheckReminderPermission(getIt()));
  getIt.registerLazySingleton(() => OpenReminderSettings(getIt()));
  getIt.registerLazySingleton(() => ClearLocalData(getIt()));
  getIt.registerFactory(
    () => LedgerCubit(
      loadLedger: getIt(),
      saveBill: getIt(),
      deleteBill: getIt(),
      saveIncome: getIt(),
      deleteIncome: getIt(),
      recordPayment: getIt(),
      undoPayment: getIt(),
      saveFunds: getIt(),
      savePreferences: getIt(),
      saveBufferGoal: getIt(),
      scheduleReminder: getIt(),
      cancelReminder: getIt(),
      requestPermission: getIt(),
      checkReminderPermission: getIt(),
      openReminderSettings: getIt(),
      clearLocalData: getIt(),
    ),
  );
  getIt.registerSingleton<GoRouter>(createAppRouter());
}
