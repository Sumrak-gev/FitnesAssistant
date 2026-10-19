import '../models/goal.dart';
import '../models/user_profile.dart';
import '../models/nutrition_values.dart';
import '../models/daily_ration.dart';

enum NutritionMode { strict, tolerant }

class DailyNorm extends NutritionValues {
  const DailyNorm({
    required super.calories,
    required super.protein,
    required super.fat,
    required super.carbs,
  });
}

class NutritionService {
  int ageOn(DateTime birthDate, DateTime date) =>
      date.year -
      birthDate.year -
      ((date.month < birthDate.month ||
              (date.month == birthDate.month && date.day < birthDate.day))
          ? 1
          : 0);

  DailyNorm normForProfile(UserProfile profile, {DateTime? onDate}) {
    profile.validate();
    if (profile.birthDate == null ||
        profile.heightCm == null ||
        profile.weightKg == null ||
        profile.sex == ProfileSex.unspecified) {
      throw ArgumentError(
        'Для расчёта заполните дату рождения, пол, рост и вес в профиле.',
      );
    }
    return calculateNorm(
      weightKg: profile.weightKg!,
      heightCm: profile.heightCm!,
      age: ageOn(profile.birthDate!, onDate ?? DateTime.now()),
      isMale: profile.sex == ProfileSex.male,
      activity: profile.activity,
      goal: profile.goal,
    );
  }

  /// Mifflin–St Jeor estimate, activity and goal are independent multipliers.
  /// Macro energy shares are application defaults, not a clinical prescription.
  DailyNorm calculateNorm({
    required double weightKg,
    required double heightCm,
    required int age,
    required bool isMale,
    required GoalType goal,
    ActivityLevel activity = ActivityLevel.sedentary,
  }) {
    if (!weightKg.isFinite ||
        !heightCm.isFinite ||
        weightKg < 30 ||
        weightKg > 300 ||
        heightCm < 100 ||
        heightCm > 250 ||
        age < 18 ||
        age > 100) {
      throw ArgumentError(
        'Расчёт доступен для взрослых 18–100 лет, роста 100–250 см и веса 30–300 кг.',
      );
    }
    final bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + (isMale ? 5 : -161);
    final activityFactor = switch (activity) {
      ActivityLevel.sedentary => 1.2,
      ActivityLevel.light => 1.375,
      ActivityLevel.moderate => 1.55,
      ActivityLevel.active => 1.725,
      ActivityLevel.veryActive => 1.9,
    };
    final goalFactor = switch (goal) {
      GoalType.weightLoss => 0.85,
      GoalType.muscleGain => 1.10,
      GoalType.maintenance || GoalType.endurance => 1.0,
    };
    final calories = bmr * activityFactor * goalFactor;
    if (calories < 1000) {
      throw ArgumentError(
        'Расчёт даёт менее 1000 ккал. Нужна индивидуальная оценка специалиста.',
      );
    }
    final (proteinShare, fatShare) = switch (goal) {
      GoalType.weightLoss => (0.30, 0.30),
      GoalType.muscleGain => (0.30, 0.25),
      GoalType.maintenance => (0.25, 0.30),
      GoalType.endurance => (0.20, 0.25),
    };
    return DailyNorm(
      calories: calories,
      protein: calories * proteinShare / 4,
      fat: calories * fatShare / 9,
      carbs: calories * (1 - proteinShare - fatShare) / 4,
    );
  }

  /// Calendar week Monday–Sunday, all seven days including days with no records.
  DateTime weekStart(DateTime day) =>
      DateTime(day.year, day.month, day.day - day.weekday + 1);
  NutritionValues weekTotals(List<DailyRation> days) =>
      days.fold(const NutritionValues(), (sum, day) => sum + day.totals);
  double weeklyBalance(List<double> consumed, double target) {
    if (!target.isFinite ||
        target <= 0 ||
        consumed.any((v) => !v.isFinite || v < 0)) {
      throw ArgumentError('Некорректные значения недельного баланса.');
    }
    return consumed.fold<double>(0, (sum, value) => sum + value) -
        target * consumed.length;
  }

  /// Проверяет, попадает ли дневное потребление в допустимый диапазон нормы.
  bool isWithinNorm(double consumed, double dailyTarget, {double tolerance = 0.1}) {
    if (!consumed.isFinite || consumed < 0 || !dailyTarget.isFinite || dailyTarget <= 0) {
      return false;
    }
    return (consumed - dailyTarget).abs() <= dailyTarget * tolerance;
  }
}
