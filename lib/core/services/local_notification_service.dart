import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import '../../core/errors/result.dart';
import '../../features/ledger/domain/entities/ledger_entities.dart';
import '../../features/ledger/domain/repositories/reminder_scheduler.dart';

class LocalNotificationService implements ReminderScheduler {
  LocalNotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;
  bool? _permissionGranted;

  Future<void> initialize() async {
    if (_initialized) return;
    timezone_data.initializeTimeZones();
    final localZone = await FlutterTimezone.getLocalTimezone();
    timezone.setLocalLocation(timezone.getLocation(localZone.identifier));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _initialized = true;
  }

  @override
  Future<Result<void>> requestPermission() async {
    try {
      await initialize();
      if (await notificationsEnabled()) return const Success(null);
      bool granted = true;
      if (Platform.isIOS) {
        granted =
            await _plugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, badge: false, sound: true) ??
            false;
      } else if (Platform.isAndroid) {
        final result = await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
        granted = result ?? true;
      }
      _permissionGranted = granted;
      return granted
          ? const Success(null)
          : const Failed(
              AppFailure(
                'Notifications are turned off for Harbor. You can enable them in device Settings.',
              ),
            );
    } catch (error) {
      return Failed(
        AppFailure(
          'Harbor could not request notification permission.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<bool> notificationsEnabled() async {
    try {
      await initialize();
      bool? enabled;
      if (Platform.isIOS) {
        enabled =
            (await _plugin
                    .resolvePlatformSpecificImplementation<
                      IOSFlutterLocalNotificationsPlugin
                    >()
                    ?.checkPermissions())
                ?.isEnabled;
      } else if (Platform.isAndroid) {
        enabled = await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.areNotificationsEnabled();
      } else {
        return true;
      }
      _permissionGranted = enabled ?? false;
      return _permissionGranted!;
    } catch (_) {
      _permissionGranted = false;
      return false;
    }
  }

  @override
  Future<void> openNotificationSettings() async {
    await initialize();
    if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.openAppNotificationSettings();
    } else if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.openAppNotificationSettings();
    }
  }

  @override
  Future<Result<void>> scheduleFor(
    Bill bill, {
    required bool hideDetails,
  }) async {
    try {
      await initialize();
      if (!bill.isActive || bill.reminderDays <= 0) return cancelFor(bill.id);
      if (!await notificationsEnabled()) {
        return const Failed(
          AppFailure(
            'Enable reminders in Settings before scheduling a notification.',
          ),
        );
      }

      final dueAt = DateTime(
        bill.dueDate.year,
        bill.dueDate.month,
        bill.dueDate.day,
        9,
      );
      final reminderAt = dueAt.subtract(Duration(days: bill.reminderDays));
      if (!reminderAt.isAfter(DateTime.now())) return cancelFor(bill.id);
      final localDate = timezone.TZDateTime.from(reminderAt, timezone.local);
      final details = NotificationDetails(
        android: const AndroidNotificationDetails(
          'harbor_bill_reminders',
          'Bill reminders',
          channelDescription: 'Reminders you choose for upcoming bills',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      );
      await _plugin.zonedSchedule(
        id: _notificationId(bill.id),
        title: hideDetails
            ? 'A bill is coming up'
            : '${bill.name} is coming up',
        body: hideDetails
            ? 'Open Harbor to review your upcoming bill.'
            : 'Due ${bill.dueDate.month}/${bill.dueDate.day}. You entered this reminder.',
        scheduledDate: localDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: bill.id,
      );
      return const Success(null);
    } catch (error) {
      return Failed(
        AppFailure(
          'Your bill was saved, but its reminder could not be scheduled.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<void>> cancelFor(String billId) async {
    try {
      await initialize();
      await _plugin.cancel(id: _notificationId(billId));
      return const Success(null);
    } catch (error) {
      return Failed(
        AppFailure('Harbor could not cancel the bill reminder.', cause: error),
      );
    }
  }

  int _notificationId(String value) {
    var hash = 0;
    for (final rune in value.runes) {
      hash = (hash * 31 + rune) & 0x7fffffff;
    }
    return hash;
  }
}
