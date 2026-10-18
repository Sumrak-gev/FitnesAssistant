import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as data;
import 'package:timezone/timezone.dart' as tz;
import 'package:fitness_assistant/models/reminder_settings.dart';
import 'package:fitness_assistant/services/reminder_service.dart';

void main() {
  setUpAll(data.initializeTimeZones);
  test('Daily at exact time advances to tomorrow', () {
    final now = tz.TZDateTime(tz.UTC, 2026, 10, 17, 19);
    expect(
      nextReminder(
        const ReminderSettings(frequency: ReminderFrequency.daily),
        now,
      ),
      tz.TZDateTime(tz.UTC, 2026, 10, 18, 19),
    );
  });
  test('Weekly preserves chosen weekday across year boundary', () {
    final now = tz.TZDateTime(tz.UTC, 2026, 12, 31, 20);
    expect(
      nextReminder(
        const ReminderSettings(frequency: ReminderFrequency.weekly, weekday: 1),
        now,
      ),
      tz.TZDateTime(tz.UTC, 2027, 1, 4, 19),
    );
  });
  test('Monthly works in February and rolls December into next year', () {
    const settings = ReminderSettings(
      frequency: ReminderFrequency.monthly,
      monthDay: 28,
    );
    expect(
      nextReminder(settings, tz.TZDateTime(tz.UTC, 2028, 2, 1)),
      tz.TZDateTime(tz.UTC, 2028, 2, 28, 19),
    );
    expect(
      nextReminder(settings, tz.TZDateTime(tz.UTC, 2026, 12, 29)),
      tz.TZDateTime(tz.UTC, 2027, 1, 28, 19),
    );
  });
  test('Daily keeps wall-clock time across spring DST', () {
    final zone = tz.getLocation('Europe/Berlin');
    final now = tz.TZDateTime(zone, 2026, 3, 28, 20);
    final next = nextReminder(
      const ReminderSettings(frequency: ReminderFrequency.daily),
      now,
    );
    expect(next, tz.TZDateTime(zone, 2026, 3, 29, 19));
    expect(next.difference(now).inHours, 22);
  });
  test('Disabled reminder cannot be scheduled', () {
    expect(
      () => nextReminder(const ReminderSettings(), tz.TZDateTime.now(tz.UTC)),
      throwsArgumentError,
    );
  });
}
