import '../models/day_log.dart';
import '../utils/date_helpers.dart';

/// TODO: заменить in-memory реализацию на SQLite (sqflite).
class ProgressRepository {
  ProgressRepository._(this._logs);

  /// Пустая история.
  factory ProgressRepository.empty() => ProgressRepository._({});

  /// Демонстрационная история за 8 недель: тренировки по пн/ср/пт,
  /// одна «просевшая» неделя 3 недели назад и разброс по калориям.
  /// Сегодняшний день пустой — тренировку можно отметить на экране.
  factory ProgressRepository.demo({
    required double dailyTarget,
    DateTime? today,
  }) {
    final end = dateOnly(today ?? DateTime.now());
    final thisWeek = startOfWeek(end);
    const offsets = [-80, 120, 40, 350, -60, 90, 10, -150, 260, 30];
    final logs = <DateTime, DayLog>{};

    for (var i = 1; i <= 56; i++) {
      final date = addDays(end, -i);
      final weeksBack =
          (thisWeek.difference(startOfWeek(date)).inHours / (24 * 7)).round();
      final trainingDay = date.weekday == DateTime.monday ||
          date.weekday == DateTime.wednesday ||
          date.weekday == DateTime.friday;
      final skipped = weeksBack == 3 && date.weekday == DateTime.friday;
      final calories = i % 11 == 6
          ? null
          : (dailyTarget + offsets[i % offsets.length]).roundToDouble();
      logs[date] = DayLog(
        date: date,
        workoutDone: trainingDay && !skipped,
        caloriesConsumed: calories,
      );
    }
    return ProgressRepository._(logs);
  }

  final Map<DateTime, DayLog> _logs;

  Future<List<DayLog>> getLogs() async => _logs.values.toList();

  Future<void> markWorkout(DateTime date) async {
    final key = dateOnly(date);
    final existing = _logs[key] ?? DayLog(date: key);
    _logs[key] = existing.copyWith(workoutDone: true);
  }

  Future<void> logCalories(DateTime date, double calories) async {
    final key = dateOnly(date);
    final existing = _logs[key] ?? DayLog(date: key);
    _logs[key] = existing.copyWith(caloriesConsumed: calories);
  }
}
