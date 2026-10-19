import '../utils/date_helpers.dart';

/// Итоги одной недели (с понедельника по воскресенье).
class WeeklySummary {
  final DateTime weekStart;
  final bool isCurrent;

  final int workouts;
  final int workoutGoal;

  /// Тренировки по дням недели, Пн..Вс.
  final List<bool> workoutByDay;

  /// Дни, за которые вносилось питание.
  final int loggedDays;

  /// Из них дни в пределах нормы калорий.
  final int daysInNorm;

  /// Средние калории за дни с внесённым питанием; null, если данных нет.
  final double? avgCalories;

  /// Отклонение от нормы за внесённые дни, ккал (плюс — перебор).
  final double calorieBalance;

  const WeeklySummary({
    required this.weekStart,
    required this.isCurrent,
    required this.workouts,
    required this.workoutGoal,
    required this.workoutByDay,
    required this.loggedDays,
    required this.daysInNorm,
    required this.avgCalories,
    required this.calorieBalance,
  });

  DateTime get weekEnd => addDays(weekStart, 6);

  bool get goalReached => workouts >= workoutGoal;
}
