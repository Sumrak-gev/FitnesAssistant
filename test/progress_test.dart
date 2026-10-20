import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_assistant/models/day_log.dart';
import 'package:fitness_assistant/services/level_service.dart';
import 'package:fitness_assistant/services/progress_service.dart';
import 'package:fitness_assistant/services/streak_service.dart';
import 'package:fitness_assistant/services/weekly_summary_service.dart';
import 'package:fitness_assistant/utils/date_helpers.dart';
import 'package:fitness_assistant/utils/ru_plural.dart';

void main() {
  // Воскресенье; неделя начинается в понедельник 12.10.2026.
  final today = DateTime(2026, 10, 18);

  group('StreakService', () {
    final service = StreakService();

    test('серия дней, включая сегодня', () {
      final info = service.calculate(
        units: {addDays(today, -2), addDays(today, -1), today},
        currentUnit: today,
      );
      expect(info.current, 3);
      expect(info.best, 3);
      expect(info.currentPeriodDone, isTrue);
    });

    test('если сегодня ещё не засчитано, серия не обрывается', () {
      final info = service.calculate(
        units: {addDays(today, -2), addDays(today, -1)},
        currentUnit: today,
      );
      expect(info.current, 2);
      expect(info.currentPeriodDone, isFalse);
    });

    test('пропуск дня обрывает серию, рекорд сохраняется', () {
      final info = service.calculate(
        units: {
          addDays(today, -5),
          addDays(today, -4),
          addDays(today, -3),
          addDays(today, -1),
          today,
        },
        currentUnit: today,
      );
      expect(info.current, 2);
      expect(info.best, 3);
    });

    test('нет данных — серия 0', () {
      final info = service.calculate(units: {}, currentUnit: today);
      expect(info.current, 0);
      expect(info.best, 0);
    });

    test('серия недель (шаг 7 дней)', () {
      final thisWeek = startOfWeek(today);
      final info = service.calculate(
        units: {
          addDays(thisWeek, -14),
          addDays(thisWeek, -7),
          addDays(thisWeek, -28),
        },
        currentUnit: thisWeek,
        stepDays: 7,
      );
      expect(info.current, 2);
      expect(info.best, 2);
      expect(info.currentPeriodDone, isFalse);
    });
  });

  group('LevelService', () {
    final service = LevelService();

    test('границы уровней', () {
      expect(service.levelFor(0).level, 1);
      expect(service.levelFor(99).level, 1);
      expect(service.levelFor(100).level, 2);
      expect(service.levelFor(399).level, 2);
      expect(service.levelFor(400).level, 3);
      expect(service.levelFor(900).level, 4);
    });

    test('прогресс внутри уровня', () {
      final info = service.levelFor(250); // уровень 2: 100..400
      expect(info.xpIntoLevel, 150);
      expect(info.xpToNext, 150);
      expect(info.progress, closeTo(0.5, 1e-9));
    });

    test('название уровня не выходит за список', () {
      expect(service.levelFor(1000000).title, LevelService.titles.last);
    });

    test('расчёт XP', () {
      expect(
        service.calculateXp(workouts: 2, nutritionDays: 3, goalWeeks: 1),
        2 * 50 + 3 * 20 + 100,
      );
    });
  });

  group('WeeklySummaryService', () {
    final service = WeeklySummaryService();

    test('итоги недели', () {
      final logs = [
        DayLog(date: DateTime(2026, 10, 12), workoutDone: true, caloriesConsumed: 2300),
        DayLog(date: DateTime(2026, 10, 14), workoutDone: true, caloriesConsumed: 2600),
        DayLog(date: DateTime(2026, 10, 16), workoutDone: true),
        // другая неделя — не должна учитываться
        DayLog(date: DateTime(2026, 10, 11), workoutDone: true, caloriesConsumed: 5000),
      ];
      final summary = service.build(
        logs: logs,
        weekStart: DateTime(2026, 10, 12),
        today: today,
        dailyTarget: 2300,
      );
      expect(summary.isCurrent, isTrue);
      expect(summary.workouts, 3);
      expect(summary.goalReached, isTrue);
      expect(summary.workoutByDay, [true, false, true, false, true, false, false]);
      expect(summary.loggedDays, 2);
      expect(summary.daysInNorm, 1);
      expect(summary.avgCalories, 2450);
      expect(summary.calorieBalance, 300);
      expect(summary.weekEnd, DateTime(2026, 10, 18));
    });

    test('неделя без данных', () {
      final summary = service.build(
        logs: const [],
        weekStart: DateTime(2026, 10, 5),
        today: today,
        dailyTarget: 2300,
      );
      expect(summary.isCurrent, isFalse);
      expect(summary.workouts, 0);
      expect(summary.avgCalories, isNull);
      expect(service.headline(summary), contains('без тренировок'));
    });
  });

  group('ProgressService', () {
    test('серия недель, XP и уровень', () {
      final logs = <DayLog>[];
      for (var w = 0; w < 3; w++) {
        final weekStart = DateTime(2026, 10, 12 - 7 * w);
        for (final offset in [0, 2, 4]) {
          logs.add(DayLog(date: addDays(weekStart, offset), workoutDone: true));
        }
      }
      final snapshot = ProgressService().build(
        logs: logs,
        today: today,
        dailyTarget: 2300,
      );
      expect(snapshot.workoutWeekStreak.current, 3);
      expect(snapshot.workoutWeekStreak.best, 3);
      expect(snapshot.nutritionDayStreak.current, 0);
      expect(snapshot.totalWorkouts, 9);
      // 9 тренировок * 50 + 2 завершённые недели * 100 = 650 XP -> 3-й уровень
      expect(snapshot.level.totalXp, 650);
      expect(snapshot.level.level, 3);
    });
  });

  group('pluralRu', () {
    test('склонение', () {
      expect(pluralRu(1, 'день', 'дня', 'дней'), 'день');
      expect(pluralRu(2, 'день', 'дня', 'дней'), 'дня');
      expect(pluralRu(5, 'день', 'дня', 'дней'), 'дней');
      expect(pluralRu(11, 'день', 'дня', 'дней'), 'дней');
      expect(pluralRu(21, 'день', 'дня', 'дней'), 'день');
      expect(pluralRu(0, 'день', 'дня', 'дней'), 'дней');
    });
  });
}
