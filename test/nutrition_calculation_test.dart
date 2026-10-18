import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_assistant/models/goal.dart';
import 'package:fitness_assistant/models/user_profile.dart';
import 'package:fitness_assistant/models/nutrition_values.dart';
import 'package:fitness_assistant/models/daily_ration.dart';
import 'package:fitness_assistant/models/product.dart';
import 'package:fitness_assistant/services/nutrition_service.dart';

void main() {
  final service = NutritionService();
  test('Known Mifflin example and energy consistency', () {
    final norm = service.calculateNorm(
      weightKg: 80,
      heightCm: 180,
      age: 30,
      isMale: true,
      goal: GoalType.maintenance,
    );
    expect(norm.calories, closeTo(1780 * 1.2, 1e-8));
    expect(
      norm.protein * 4 + norm.fat * 9 + norm.carbs * 4,
      closeTo(norm.calories, 1e-8),
    );
    final female = service.calculateNorm(
      weightKg: 60,
      heightCm: 165,
      age: 25,
      isMale: false,
      activity: ActivityLevel.moderate,
      goal: GoalType.maintenance,
    );
    expect(female.calories, closeTo((600 + 1031.25 - 125 - 161) * 1.55, 1e-8));
  });
  for (final goal in GoalType.values) {
    for (final activity in ActivityLevel.values) {
      test('Nonnegative consistent macros: ${goal.name}/${activity.name}', () {
        final norm = service.calculateNorm(
          weightKg: 75,
          heightCm: 178,
          age: 25,
          isMale: true,
          activity: activity,
          goal: goal,
        );
        expect(norm.calories, greaterThan(0));
        expect(norm.protein, greaterThan(0));
        expect(norm.fat, greaterThan(0));
        expect(norm.carbs, greaterThan(0));
        expect(
          norm.protein * 4 + norm.fat * 9 + norm.carbs * 4,
          closeTo(norm.calories, 1e-8),
        );
      });
    }
  }
  test(
    'Goal changes independent of activity; no invented profile defaults',
    () {
      double calories(GoalType goal) => service
          .calculateNorm(
            weightKg: 80,
            heightCm: 180,
            age: 30,
            isMale: true,
            goal: goal,
            activity: ActivityLevel.light,
          )
          .calories;
      expect(
        calories(GoalType.weightLoss),
        closeTo(calories(GoalType.maintenance) * .85, 1e-8),
      );
      expect(
        calories(GoalType.muscleGain),
        closeTo(calories(GoalType.maintenance) * 1.1, 1e-8),
      );
      expect(
        () => service.normForProfile(const UserProfile()),
        throwsArgumentError,
      );
    },
  );
  test('Birthday, leap birthday and week crossing year', () {
    expect(service.ageOn(DateTime(2000, 10, 18), DateTime(2026, 10, 17)), 25);
    expect(service.ageOn(DateTime(2000, 10, 18), DateTime(2026, 10, 18)), 26);
    expect(service.ageOn(DateTime(2000, 2, 29), DateTime(2025, 2, 28)), 24);
    expect(service.ageOn(DateTime(2000, 2, 29), DateTime(2025, 3, 1)), 25);
    expect(service.weekStart(DateTime(2027, 1, 3)), DateTime(2026, 12, 28));
  });
  test('Invalid body values, age and low-energy result fail explicitly', () {
    for (final weight in [double.nan, double.infinity, -1.0, 301.0]) {
      expect(
        () => service.calculateNorm(
          weightKg: weight,
          heightCm: 180,
          age: 30,
          isMale: true,
          goal: GoalType.maintenance,
        ),
        throwsArgumentError,
      );
    }
    for (final age in [17, 101]) {
      expect(
        () => service.calculateNorm(
          weightKg: 80,
          heightCm: 180,
          age: age,
          isMale: true,
          goal: GoalType.maintenance,
        ),
        throwsArgumentError,
      );
    }
    expect(
      () => service.calculateNorm(
        weightKg: 30,
        heightCm: 100,
        age: 100,
        isMale: false,
        goal: GoalType.weightLoss,
      ),
      throwsArgumentError,
    );
  });
  test(
    'Portions are calculated without premature rounding and zero foods are valid',
    () {
      const p = Product(
        id: 'p',
        name: 'Рис',
        calories: 130,
        protein: 2.7,
        fat: .3,
        carbs: 28,
      );
      const entry = RationEntry(id: 'e', mealId: 'm', product: p, grams: 12.5);
      expect(entry.totals.calories, 16.25);
      expect(entry.totals.protein, closeTo(.3375, 1e-12));
      const NutritionValues().validatePer100g();
      expect(
        () => const NutritionValues(calories: 901).validatePer100g(),
        throwsArgumentError,
      );
      expect(
        () => const NutritionValues(protein: 50, fat: 60).validatePer100g(),
        throwsArgumentError,
      );
      for (final grams in [0.0, -1.0, double.nan, double.infinity, 10001.0]) {
        expect(() => RationEntry.validateGrams(grams), throwsArgumentError);
      }
    },
  );
  test('Weekly balance includes zero days and rejects invalid values', () {
    expect(service.weeklyBalance([2000, 2100, 0, 0, 0, 0, 0], 2000), -9900);
    expect(service.weeklyBalance([], 2000), 0);
    expect(
      () => service.weeklyBalance([double.nan], 2000),
      throwsArgumentError,
    );
    expect(() => service.weeklyBalance([2000], 0), throwsArgumentError);
  });
}
