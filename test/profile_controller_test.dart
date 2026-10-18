import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_assistant/core/db/app_database.dart';
import 'package:fitness_assistant/data/profile_repository.dart';
import 'package:fitness_assistant/models/reminder_settings.dart';
import 'package:fitness_assistant/services/profile_controller.dart';
import 'support/fake_reminders.dart';

void main() {
  late AppDatabase database;
  late ProfileController controller;
  late FakeReminders scheduler;
  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    scheduler = FakeReminders();
    controller = ProfileController(ProfileRepository(database), scheduler);
  });
  tearDown(() async {
    controller.dispose();
    await database.close();
  });

  test(
    'Startup does not ask permission; denial is visible and persisted',
    () async {
      await controller.load();
      expect(scheduler.requested, false);
      scheduler.allowed = false;
      await controller.saveReminders(
        const ReminderSettings(frequency: ReminderFrequency.weekly),
      );
      expect(scheduler.requested, true);
      expect(controller.reminderWarning, contains('запрещены'));
      expect(
        (await controller.repository.loadReminders()).frequency,
        ReminderFrequency.weekly,
      );
      scheduler.allowed = true;
      await controller.reconcileReminders();
      expect(scheduler.requested, false);
      expect(controller.reminderWarning, isNull);
    },
  );
  test(
    'Disabling applies cancellation even when permission was denied',
    () async {
      await controller.load();
      scheduler.allowed = false;
      await controller.saveReminders(const ReminderSettings());
      expect(scheduler.applied!.frequency, ReminderFrequency.off);
      expect(scheduler.requested, false);
      expect(controller.reminderWarning, isNull);
    },
  );
  test(
    'OS failure does not lose desired settings; resume retries them',
    () async {
      await controller.load();
      scheduler.fail = true;
      await controller.saveReminders(
        const ReminderSettings(frequency: ReminderFrequency.monthly),
      );
      expect(controller.reminderWarning, contains('не запланировано'));
      expect(controller.busy, false);
      scheduler.fail = false;
      await controller.reconcileReminders();
      expect(controller.reminderWarning, isNull);
      expect(scheduler.applied!.frequency, ReminderFrequency.monthly);
    },
  );
}
