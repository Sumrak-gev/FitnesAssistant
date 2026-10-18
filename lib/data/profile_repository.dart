import 'package:drift/drift.dart';
import '../core/db/app_database.dart';
import '../models/goal.dart';
import '../models/user_profile.dart';
import '../models/reminder_settings.dart';

class ProfileRepository {
  ProfileRepository(this.database);
  final AppDatabase database;

  Future<UserProfile> loadProfile() async {
    final row = await database.select(database.localProfiles).getSingleOrNull();
    if (row == null) return const UserProfile();
    return UserProfile(
      name: row.name,
      birthDate: row.birthDate,
      sex: ProfileSex.values.byName(row.sex),
      heightCm: row.heightCm,
      weightKg: row.weightKg,
      targetWeightKg: row.targetWeightKg,
      activity: ActivityLevel.values.byName(row.activity),
      goal: GoalType.values.byName(row.goal),
      programId: row.programId,
    );
  }

  Future<void> saveProfile(UserProfile profile) =>
      database.transaction(() async {
        profile.validate();
        await database
            .into(database.localProfiles)
            .insertOnConflictUpdate(
              LocalProfilesCompanion.insert(
                id: const Value(1),
                name: profile.name.trim(),
                birthDate: Value(profile.birthDate),
                sex: profile.sex.name,
                heightCm: Value(profile.heightCm),
                weightKg: Value(profile.weightKg),
                targetWeightKg: Value(profile.targetWeightKg),
                activity: profile.activity.name,
                goal: profile.goal.name,
                programId: Value(profile.programId),
                updatedAt: DateTime.now().toUtc(),
              ),
            );
        await (database.update(database.nutritionUsers)
              ..where((u) => u.localSlot.equals(1)))
            .write(const NutritionUsersCompanion(profileId: Value(1)));
      });

  Future<ReminderSettings> loadReminders() async {
    final row = await database
        .select(database.localReminders)
        .getSingleOrNull();
    if (row == null) return const ReminderSettings();
    return ReminderSettings(
      frequency: ReminderFrequency.values.byName(row.frequency),
      hour: row.hour,
      minute: row.minute,
      weekday: row.weekday,
      monthDay: row.monthDay,
    );
  }

  Future<void> saveReminders(ReminderSettings settings) async {
    settings.validate();
    await database
        .into(database.localReminders)
        .insertOnConflictUpdate(
          LocalRemindersCompanion.insert(
            id: const Value(1),
            frequency: settings.frequency.name,
            hour: settings.hour,
            minute: settings.minute,
            weekday: settings.weekday,
            monthDay: settings.monthDay,
          ),
        );
  }
}
