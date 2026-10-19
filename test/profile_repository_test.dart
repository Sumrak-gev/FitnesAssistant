import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_assistant/core/db/app_database.dart';
import 'package:fitness_assistant/data/profile_repository.dart';
import 'package:fitness_assistant/models/goal.dart';
import 'package:fitness_assistant/models/user_profile.dart';
import 'package:fitness_assistant/models/reminder_settings.dart';

void main() {
  test(
    'Profile and settings survive closing and reopening the SQLite file',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'fitness_profile_test_',
      );
      final file = File('${directory.path}/profile.sqlite');
      var database = AppDatabase(NativeDatabase(file));
      try {
        var repository = ProfileRepository(database);
        expect((await repository.loadProfile()).name, isEmpty);
        expect(
          (await repository.loadReminders()).frequency,
          ReminderFrequency.off,
        );
        await repository.saveProfile(
          UserProfile(
            name: '  Денис  ',
            birthDate: DateTime(2000, 2, 29),
            sex: ProfileSex.male,
            heightCm: 180.5,
            weightKg: 82.5,
            targetWeightKg: 78,
            activity: ActivityLevel.active,
            goal: GoalType.weightLoss,
            programId: 'p1',
          ),
        );
        await repository.saveReminders(
          const ReminderSettings(
            frequency: ReminderFrequency.monthly,
            hour: 8,
            minute: 35,
            monthDay: 28,
          ),
        );
        await database.close();
        database = AppDatabase(NativeDatabase(file));
        repository = ProfileRepository(database);
        final profile = await repository.loadProfile();
        expect(profile.name, 'Денис');
        expect(profile.birthDate, DateTime(2000, 2, 29));
        expect(profile.heightCm, 180.5);
        expect(profile.weightKg, 82.5);
        expect(profile.targetWeightKg, 78);
        expect(profile.sex, ProfileSex.male);
        expect(profile.activity, ActivityLevel.active);
        expect(profile.goal, GoalType.weightLoss);
        expect(profile.programId, 'p1');
        final settings = await repository.loadReminders();
        expect(settings.frequency, ReminderFrequency.monthly);
        expect(settings.monthDay, 28);
        expect(settings.hour, 8);
        expect(settings.minute, 35);
        await repository.saveProfile(const UserProfile(name: 'Новое имя'));
        expect((await repository.loadProfile()).programId, isNull);
        expect((await repository.loadProfile()).targetWeightKg, isNull);
        expect(
          await database.select(database.localProfiles).get(),
          hasLength(1),
        );
      } finally {
        await database.close();
        await directory.delete(recursive: true);
      }
    },
  );

  test('Invalid inputs never overwrite the saved profile', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final repository = ProfileRepository(database);
    try {
      await repository.saveProfile(
        const UserProfile(name: 'Денис', weightKg: 80),
      );
      for (final value in [-1.0, double.nan, double.infinity, 501.0]) {
        await expectLater(
          repository.saveProfile(UserProfile(weightKg: value)),
          throwsArgumentError,
        );
      }
      await expectLater(
        repository.saveProfile(UserProfile(birthDate: DateTime(3000))),
        throwsArgumentError,
      );
      await expectLater(
        repository.saveReminders(const ReminderSettings(hour: 24)),
        throwsArgumentError,
      );
      await expectLater(
        repository.saveReminders(const ReminderSettings(monthDay: 31)),
        throwsArgumentError,
      );
      expect((await repository.loadProfile()).name, 'Денис');
      expect((await repository.loadProfile()).weightKg, 80);
    } finally {
      await database.close();
    }
  });
}
