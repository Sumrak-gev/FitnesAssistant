import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fitness_assistant/models/reminder_settings.dart';
import 'package:fitness_assistant/services/reminder_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  const timezone = MethodChannel('flutter_timezone');
  final calls = <MethodCall>[];
  var allowed = true;
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  setUp(() {
    calls.clear();
    allowed = true;
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method == 'checkPermissions') return {'isEnabled': allowed};
      if (call.method == 'requestNotificationsPermission' ||
          call.method == 'areNotificationsEnabled' ||
          call.method == 'requestPermissions') {
        return allowed;
      }
      return true;
    });
    messenger.setMockMethodCallHandler(timezone, (_) async => 'Europe/Moscow');
  });
  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    messenger.setMockMethodCallHandler(timezone, null);
    debugDefaultTargetPlatformOverride = null;
  });

  test(
    'Every frequency schedules one repeating Android reminder, off cancels only its ID',
    () async {
      final service = LocalReminderService();
      final expected = {
        ReminderFrequency.daily: DateTimeComponents.time,
        ReminderFrequency.weekly: DateTimeComponents.dayOfWeekAndTime,
        ReminderFrequency.monthly: DateTimeComponents.dayOfMonthAndTime,
      };
      for (final entry in expected.entries) {
        expect(
          await service.apply(
            ReminderSettings(frequency: entry.key),
            requestPermission: true,
          ),
          true,
        );
        final arguments = calls.last.arguments as Map;
        expect(calls.last.method, 'zonedSchedule');
        expect(arguments['id'], LocalReminderService.reminderId);
        expect(arguments['matchDateTimeComponents'], entry.value.index);
        expect(arguments['timeZoneName'], 'Europe/Moscow');
      }
      calls.clear();
      await service.apply(const ReminderSettings());
      expect(calls.map((c) => c.method), ['cancel']);
      expect(
        (calls.single.arguments as Map)['id'],
        LocalReminderService.reminderId,
      );
    },
  );

  test(
    'Denied Android permission cancels old reminder without scheduling a new one',
    () async {
      allowed = false;
      expect(
        await LocalReminderService().apply(
          const ReminderSettings(frequency: ReminderFrequency.daily),
          requestPermission: true,
        ),
        false,
      );
      expect(calls.map((c) => c.method), [
        'initialize',
        'cancel',
        'requestNotificationsPermission',
      ]);
    },
  );

  test(
    'iOS initialization never prompts; resume checks permission and schedules monthly',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      IOSFlutterLocalNotificationsPlugin.registerWith();
      await LocalReminderService().apply(
        const ReminderSettings(frequency: ReminderFrequency.monthly),
      );
      final initial = calls.first.arguments as Map;
      expect(initial['requestAlertPermission'], false);
      expect(initial['requestSoundPermission'], false);
      expect(calls.map((c) => c.method), [
        'initialize',
        'cancel',
        'checkPermissions',
        'zonedSchedule',
      ]);
      expect(
        (calls.last.arguments as Map)['matchDateTimeComponents'],
        DateTimeComponents.dayOfMonthAndTime.index,
      );
    },
  );
}
