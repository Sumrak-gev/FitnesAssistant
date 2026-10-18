class NutritionValues {
  const NutritionValues({
    this.calories = 0,
    this.protein = 0,
    this.fat = 0,
    this.carbs = 0,
  });
  final double calories, protein, fat, carbs;
  NutritionValues operator +(NutritionValues other) => NutritionValues(
    calories: calories + other.calories,
    protein: protein + other.protein,
    fat: fat + other.fat,
    carbs: carbs + other.carbs,
  );
  NutritionValues scaled(double factor) => NutritionValues(
    calories: calories * factor,
    protein: protein * factor,
    fat: fat * factor,
    carbs: carbs * factor,
  );

  void validatePer100g() {
    for (final value in [calories, protein, fat, carbs]) {
      if (!value.isFinite || value < 0) {
        throw ArgumentError('КБЖУ: нужны конечные неотрицательные числа.');
      }
    }
    if (calories > 900 || protein + fat + carbs > 100.1) {
      throw ArgumentError(
        'На 100 г: не более 900 ккал и 100 г БЖУ суммарно (допуск округления 0,1 г).',
      );
    }
  }

  Map<String, dynamic> toMap() => {
    'calories': calories,
    'protein': protein,
    'fat': fat,
    'carbs': carbs,
  };
  factory NutritionValues.fromMap(Map<String, dynamic> map) => NutritionValues(
    calories: (map['calories'] as num).toDouble(),
    protein: (map['protein'] as num).toDouble(),
    fat: (map['fat'] as num).toDouble(),
    carbs: (map['carbs'] as num).toDouble(),
  );
}
