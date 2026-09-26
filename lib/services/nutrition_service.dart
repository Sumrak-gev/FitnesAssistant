import '../models/goal.dart';

/// Режим расчёта КБЖУ:
/// - strict: точный дневной лимит.
/// - tolerant: скользящий недельный баланс вместо жёсткого дневного контроля.
enum NutritionMode { strict, tolerant }

class DailyNorm {
  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  const DailyNorm({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });
}

class NutritionService {
  /// Базовый расчёт нормы КБЖУ (упрощённая формула Миффлина — Сан Жеора).
  DailyNorm calculateNorm({
    required double weightKg,
    required double heightCm,
    required int age,
    required bool isMale,
    required GoalType goal,
  }) {
    double bmr = isMale
        ? 10 * weightKg + 6.25 * heightCm - 5 * age + 5
        : 10 * weightKg + 6.25 * heightCm - 5 * age - 161;

    double calories = switch (goal) {
      GoalType.weightLoss => bmr * 1.2 * 0.8,   // дефицит ~20%
      GoalType.muscleGain => bmr * 1.4 * 1.15,  // профицит ~15%
      GoalType.maintenance => bmr * 1.3,
      GoalType.endurance => bmr * 1.5,
    };

    // Упрощённое распределение БЖУ.
    final protein = weightKg * 1.8;
    final fat = weightKg * 1.0;
    final carbs = (calories - (protein * 4 + fat * 9)) / 4;

    return DailyNorm(calories: calories, protein: protein, fat: fat, carbs: carbs);
  }

  /// Толерантная проверка: считает средний баланс за N дней вместо
  /// сравнения с лимитом каждый день. Возвращает разницу (ккал) от нормы.
  double weeklyBalance(List<double> dailyCaloriesConsumed, double dailyTarget) {
    if (dailyCaloriesConsumed.isEmpty) return 0;
    final totalTarget = dailyTarget * dailyCaloriesConsumed.length;
    final totalConsumed =
        dailyCaloriesConsumed.fold<double>(0, (sum, v) => sum + v);
    return totalConsumed - totalTarget;
  }
}
