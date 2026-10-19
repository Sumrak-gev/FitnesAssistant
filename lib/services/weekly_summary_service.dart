import '../models/day_log.dart';
import '../models/weekly_summary.dart';
import '../utils/date_helpers.dart';
import '../utils/ru_plural.dart';
import 'nutrition_service.dart';

/// Недельные итоги: тренировки, питание, короткий текстовый вывод.
class WeeklySummaryService {
  WeeklySummaryService({NutritionService? nutrition, this.tolerance = 0.1})
      : _nutrition = nutrition ?? NutritionService();

  final NutritionService _nutrition;

  /// Допустимое отклонение дневных калорий от цели.
  final double tolerance;

  WeeklySummary build({
    required List<DayLog> logs,
    required DateTime weekStart,
    required DateTime today,
    required double dailyTarget,
    int workoutGoal = 3,
  }) {
    final start = dateOnly(weekStart);
    final end = addDays(start, 7); // не включая
    final weekLogs = logs.where((l) {
      final d = dateOnly(l.date);
      return !d.isBefore(start) && d.isBefore(end);
    }).toList();

    final workoutByDay = List<bool>.generate(7, (i) {
      final day = addDays(start, i);
      return weekLogs.any((l) => l.workoutDone && dateOnly(l.date) == day);
    });
    final workouts = workoutByDay.where((w) => w).length;

    final consumed = <double>[
      for (final l in weekLogs)
        if (l.caloriesConsumed != null) l.caloriesConsumed!,
    ];
    final daysInNorm = consumed
        .where((c) => _nutrition.isWithinNorm(c, dailyTarget, tolerance: tolerance))
        .length;
    final avg = consumed.isEmpty
        ? null
        : consumed.fold<double>(0, (s, v) => s + v) / consumed.length;

    return WeeklySummary(
      weekStart: start,
      isCurrent: startOfWeek(today) == start,
      workouts: workouts,
      workoutGoal: workoutGoal,
      workoutByDay: workoutByDay,
      loggedDays: consumed.length,
      daysInNorm: daysInNorm,
      avgCalories: avg,
      calorieBalance: _nutrition.weeklyBalance(consumed, dailyTarget),
    );
  }

  /// Короткий вывод по неделе.
  String headline(WeeklySummary s) {
    final missing = s.workoutGoal - s.workouts;
    if (s.isCurrent) {
      if (missing <= 0) return 'Цель недели по тренировкам выполнена — так держать!';
      final word = pluralRu(missing, 'тренировка', 'тренировки', 'тренировок');
      return 'До цели недели ещё $missing $word';
    }
    if (missing <= 0) {
      return s.daysInNorm >= 5 ? 'Отличная неделя!' : 'Цель по тренировкам выполнена';
    }
    if (s.workouts == 0) return 'Неделя без тренировок — начните заново с малого';
    return 'Цель не выполнена: ${s.workouts} из ${s.workoutGoal} тренировок';
  }

  /// Сравнение количества тренировок с предыдущей неделей.
  String compare(WeeklySummary current, WeeklySummary previous) {
    final diff = current.workouts - previous.workouts;
    if (diff == 0) return 'Тренировок столько же, сколько неделей раньше';
    final n = diff.abs();
    final word = pluralRu(n, 'тренировку', 'тренировки', 'тренировок');
    return diff > 0
        ? 'На $n $word больше, чем неделей раньше'
        : 'На $n $word меньше, чем неделей раньше';
  }
}
