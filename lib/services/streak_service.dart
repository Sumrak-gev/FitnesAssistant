import '../models/day_log.dart';
import '../models/streak.dart';
import '../utils/date_helpers.dart';
import 'nutrition_service.dart';

/// Расчёт серий. Серия — это подряд идущие периоды (дни или недели),
/// в которых выполнено условие.
class StreakService {
  StreakService({NutritionService? nutrition})
      : _nutrition = nutrition ?? NutritionService();

  final NutritionService _nutrition;

  /// [units] — начала периодов, в которых условие выполнено (только даты).
  /// [currentUnit] — начало текущего периода. [stepDays] — длина периода: 1 день или 7 дней.
  /// Если текущий период ещё не засчитан, серия не обрывается: считается до предыдущего.
  StreakInfo calculate({
    required Set<DateTime> units,
    required DateTime currentUnit,
    int stepDays = 1,
  }) {
    final doneNow = units.contains(currentUnit);

    var cursor = doneNow ? currentUnit : addDays(currentUnit, -stepDays);
    var current = 0;
    while (units.contains(cursor)) {
      current++;
      cursor = addDays(cursor, -stepDays);
    }

    final sorted = units.toList()..sort();
    var best = 0;
    var run = 0;
    DateTime? prev;
    for (final u in sorted) {
      run = (prev != null && addDays(prev, stepDays) == u) ? run + 1 : 1;
      if (run > best) best = run;
      prev = u;
    }

    return StreakInfo(current: current, best: best, currentPeriodDone: doneNow);
  }

  /// Недели (по понедельникам), в которых тренировок не меньше [workoutGoal].
  Set<DateTime> workoutWeeks(List<DayLog> logs, int workoutGoal) {
    final counts = <DateTime, int>{};
    for (final log in logs) {
      if (!log.workoutDone) continue;
      final week = startOfWeek(log.date);
      counts[week] = (counts[week] ?? 0) + 1;
    }
    return {
      for (final e in counts.entries)
        if (e.value >= workoutGoal) e.key,
    };
  }

  /// Дни, в которые питание внесено и уложилось в норму калорий.
  Set<DateTime> nutritionDays(
    List<DayLog> logs,
    double dailyTarget, {
    double tolerance = 0.1,
  }) {
    return {
      for (final log in logs)
        if (log.caloriesConsumed != null &&
            _nutrition.isWithinNorm(log.caloriesConsumed!, dailyTarget,
                tolerance: tolerance))
          dateOnly(log.date),
    };
  }
}
