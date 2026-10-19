import 'goal.dart';

enum ProfileSex {
  unspecified('Не указан'),
  female('Женский'),
  male('Мужской');

  const ProfileSex(this.label);
  final String label;
}

enum ActivityLevel {
  sedentary('Минимальная'),
  light('Низкая'),
  moderate('Средняя'),
  active('Высокая'),
  veryActive('Очень высокая');

  const ActivityLevel(this.label);
  final String label;
}

/// Local profile. Null measurements mean that onboarding is not complete.
class UserProfile {
  const UserProfile({
    this.name = '',
    this.birthDate,
    this.sex = ProfileSex.unspecified,
    this.heightCm,
    this.weightKg,
    this.targetWeightKg,
    this.activity = ActivityLevel.sedentary,
    this.goal = GoalType.maintenance,
    this.programId,
  });

  final String name;
  final DateTime? birthDate;
  final ProfileSex sex;
  final double? heightCm;
  final double? weightKg;
  final double? targetWeightKg;
  final ActivityLevel activity;
  final GoalType goal;
  final String? programId;

  UserProfile withGoal(GoalType value) => UserProfile(
    name: name,
    birthDate: birthDate,
    sex: sex,
    heightCm: heightCm,
    weightKg: weightKg,
    targetWeightKg: targetWeightKg,
    activity: activity,
    goal: value,
    programId: programId,
  );

  void validate({DateTime? now}) {
    if (name.trim().length > 80) {
      throw ArgumentError('Имя: не более 80 символов.');
    }
    final today = now ?? DateTime.now();
    if (birthDate != null &&
        (birthDate!.year < 1900 ||
            birthDate!.isAfter(DateTime(today.year, today.month, today.day)))) {
      throw ArgumentError('Проверьте дату рождения.');
    }
    validateMeasurement(heightCm, 50, 260, 'Рост');
    validateMeasurement(weightKg, 20, 500, 'Вес');
    validateMeasurement(targetWeightKg, 20, 500, 'Целевой вес');
  }

  static void validateMeasurement(
    double? value,
    double min,
    double max,
    String label,
  ) {
    if (value != null && (!value.isFinite || value < min || value > max)) {
      throw ArgumentError('$label: введите число от $min до $max.');
    }
  }
}
