import 'nutrition_values.dart';
import 'product.dart';

String nutritionDay(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
DateTime dayOnly(DateTime date) => DateTime(date.year, date.month, date.day);

enum MealKind {
  breakfast('Завтрак'),
  lunch('Обед'),
  dinner('Ужин'),
  snack('Перекус');

  const MealKind(this.label);
  final String label;
}

class RationEntry {
  const RationEntry({
    required this.id,
    required this.mealId,
    required this.product,
    required this.grams,
  });
  final String id, mealId;

  /// Snapshot: catalog edits/deletions must not change historical consumption.
  final Product product;
  final double grams;
  NutritionValues get totals => product.values.scaled(grams / 100);
  static void validateGrams(double grams) {
    if (!grams.isFinite || grams <= 0 || grams > 10000) {
      throw ArgumentError('Масса порции: больше 0 и не более 10 000 г.');
    }
  }
}

class Meal {
  Meal({
    required this.id,
    required this.day,
    required this.kind,
    required List<RationEntry> entries,
  }) : entries = List.unmodifiable(entries);
  final String id;
  final DateTime day;
  final MealKind kind;
  final List<RationEntry> entries;
  NutritionValues get totals =>
      entries.fold(const NutritionValues(), (sum, entry) => sum + entry.totals);
}

class DailyRation {
  DailyRation({required this.day, required List<Meal> meals})
    : meals = List.unmodifiable(meals);
  final DateTime day;
  final List<Meal> meals;
  NutritionValues get totals =>
      meals.fold(const NutritionValues(), (sum, meal) => sum + meal.totals);
  int get entryCount => meals.fold(0, (sum, meal) => sum + meal.entries.length);
}
