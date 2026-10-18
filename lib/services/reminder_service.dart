import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder_settings.dart';

abstract interface class ReminderScheduler {
  /// False means that the OS has not granted notification permission.
  Future<bool> apply(
    ReminderSettings settings, {
    bool requestPermission = false,
  });
}

/// Calendar arithmetic keeps wall-clock times stable across DST transitions.
tz.TZDateTime nextReminder(ReminderSettings settings, tz.TZDateTime now) {
  settings.validate();
  if (settings.frequency == ReminderFrequency.off) {
    throw ArgumentError('Отключённое напоминание не имеет даты.');
  }
  tz.TZDateTime at(int year, int month, int day) => tz.TZDateTime(
    now.location,
    year,
    month,
    day,
    settings.hour,
    settings.minute,
  );
  var next = at(now.year, now.month, now.day);
  switch (settings.frequency) {
    case ReminderFrequency.daily:
      if (!next.isAfter(now)) next = at(now.year, now.month, now.day + 1);
    case ReminderFrequency.weekly:
      next = at(
        now.year,
        now.month,
        now.day + (settings.weekday - now.weekday + 7) % 7,
      );
      if (!next.isAfter(now)) next = at(next.year, next.month, next.day + 7);
    case ReminderFrequency.monthly:
      next = at(now.year, now.month, settings.monthDay);
      if (!next.isAfter(now)) {
        next = at(now.year, now.month + 1, settings.monthDay);
      }
    case ReminderFrequency.off:
      throw StateError('Unreachable');
  }
  return next;
}

class LocalReminderService implements ReminderScheduler {
  LocalReminderService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();
  final FlutterLocalNotificationsPlugin _plugin;
  static const reminderId = 5001;
  bool _initialized = false;

  Future<void> _initialize() async {
    if (_initialized) return;
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      throw UnsupportedError('Уведомления поддерживаются на Android и iOS.');
    }
    tz_data.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_fitness'),
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
  Future<bool> apply(
    ReminderSettings settings, {
    bool requestPermission = false,
  }) async {
    settings.validate();
    await _initialize();
    // Only our reminder is cancelled; other modules own their own IDs.
    await _plugin.cancel(id: reminderId);
    if (settings.frequency == ReminderFrequency.off) return true;

    bool allowed = false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()!;
      allowed =
          (requestPermission
              ? await android.requestNotificationsPermission()
              : await android.areNotificationsEnabled()) ??
          false;
    } else {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()!;
      allowed = requestPermission
          ? await ios.requestPermissions(
                  alert: true,
                  badge: false,
                  sound: true,
                ) ??
                false
          : (await ios.checkPermissions())?.isEnabled ?? false;
    }
    if (!allowed) return false;
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
    await _plugin.zonedSchedule(
      id: reminderId,
      title: 'Время для себя',
      body: 'Загляните в дневник питания и план тренировок, когда вам удобно.',
      scheduledDate: nextReminder(settings, tz.TZDateTime.now(tz.local)),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'profile_reminders',
          'Напоминания профиля',
          channelDescription:
              'Настраиваемые напоминания о дневнике и тренировках',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: switch (settings.frequency) {
        ReminderFrequency.daily => DateTimeComponents.time,
        ReminderFrequency.weekly => DateTimeComponents.dayOfWeekAndTime,
        ReminderFrequency.monthly => DateTimeComponents.dayOfMonthAndTime,
        ReminderFrequency.off => throw StateError('Unreachable'),
      },
    );
    return true;
  }
}
