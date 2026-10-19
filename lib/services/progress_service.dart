import '../models/day_log.dart';
import '../models/level.dart';
import '../models/streak.dart';
import '../models/weekly_summary.dart';
import '../utils/date_helpers.dart';
import 'level_service.dart';
import 'nutrition_service.dart';
import 'streak_service.dart';
import 'weekly_summary_service.dart';

/// Всё, что нужно вкладке «Прогресс», в одном объекте.
class ProgressSnapshot {
  /// Серия недель подряд с выполненной целью по тренировкам.
  final StreakInfo workoutWeekStreak;

  /// Серия дней подряд в пределах нормы калорий.
  final StreakInfo nutritionDayStreak;

  final LevelInfo level;
  final int totalWorkouts;

  final WeeklySummary currentWeek;
  final WeeklySummary previousWeek;
  final String currentWeekHeadline;
  final String previousWeekHeadline;

  /// Сравнение прошлой недели с позапрошлой.
  final String previousWeekComparison;

  const ProgressSnapshot({
    required this.workoutWeekStreak,
    required this.nutritionDayStreak,
    required this.level,
    required this.totalWorkouts,
    required this.currentWeek,
    required this.previousWeek,
    required this.currentWeekHeadline,
    required this.previousWeekHeadline,
    required this.previousWeekComparison,
  });
}

class ProgressService {
  ProgressService({
    NutritionService? nutrition,
    StreakService? streaks,
    LevelService? levels,
    WeeklySummaryService? weekly,
  })  : _streaks = streaks ?? StreakService(nutrition: nutrition),
        _levels = levels ?? LevelService(),
        _weekly = weekly ?? WeeklySummaryService(nutrition: nutrition);

  final StreakService _streaks;
  final LevelService _levels;
  final WeeklySummaryService _weekly;

  ProgressSnapshot build({
    required List<DayLog> logs,
    required DateTime today,
    required double dailyTarget,
    int workoutGoal = 3,
  }) {
    final day = dateOnly(today);
    final thisWeek = startOfWeek(day);
    final lastWeek = addDays(thisWeek, -7);
    final weekBeforeLast = addDays(thisWeek, -14);

    final goalWeeks = _streaks.workoutWeeks(logs, workoutGoal);
    final normDays = _streaks.nutritionDays(logs, dailyTarget);

    final workoutStreak = _streaks.calculate(
      units: goalWeeks,
      currentUnit: thisWeek,
      stepDays: 7,
    );
    final nutritionStreak = _streaks.calculate(
      units: normDays,
      currentUnit: day,
    );

    final totalWorkouts = logs.where((l) => l.workoutDone).length;
    // Опыт за неделю с выполненной целью начисляется только по её окончании.
    final completedGoalWeeks = goalWeeks.where((w) => w.isBefore(thisWeek)).length;
    final xp = _levels.calculateXp(
      workouts: totalWorkouts,
      nutritionDays: normDays.length,
      goalWeeks: completedGoalWeeks,
    );

    WeeklySummary summary(DateTime start) => _weekly.build(
          logs: logs,
          weekStart: start,
          today: day,
          dailyTarget: dailyTarget,
          workoutGoal: workoutGoal,
        );

    final current = summary(thisWeek);
    final previous = summary(lastWeek);
    final beforePrevious = summary(weekBeforeLast);

    return ProgressSnapshot(
      workoutWeekStreak: workoutStreak,
      nutritionDayStreak: nutritionStreak,
      level: _levels.levelFor(xp),
      totalWorkouts: totalWorkouts,
      currentWeek: current,
      previousWeek: previous,
      currentWeekHeadline: _weekly.headline(current),
      previousWeekHeadline: _weekly.headline(previous),
      previousWeekComparison: _weekly.compare(previous, beforePrevious),
    );
  }
}
