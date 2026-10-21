import '../models/level.dart';

/// Уровни и опыт (XP).
///
/// XP начисляется за тренировки, дни в норме КБЖУ и завершённые недели
/// с выполненной целью по тренировкам. Для уровня N нужно 100 * (N-1)^2 XP:
/// 2-й уровень — 100, 3-й — 400, 4-й — 900 и т.д.
class LevelService {
  static const int xpPerWorkout = 50;
  static const int xpPerNutritionDay = 20;
  static const int xpPerGoalWeek = 100;

  static const int maxLevel = 10;

  static const List<String> titles = [
    'Слабак',
    'Слабак',
    'Слабак',
    'Слабак',
    'Слабак',
    'Силач',
    'Стойкий',
    'Мощный',
    'Мастер',
    'Легенда',
  ];

  int calculateXp({
    required int workouts,
    required int nutritionDays,
    required int goalWeeks,
  }) {
    return workouts * xpPerWorkout +
        nutritionDays * xpPerNutritionDay +
        goalWeeks * xpPerGoalWeek;
  }

  /// Сколько XP нужно, чтобы достичь [level].
  int xpForLevel(int level) => 100 * (level - 1) * (level - 1);

  LevelInfo levelFor(int xp) {
    final safeXp = xp < 0 ? 0 : xp;
    var level = 1;
    while (level < maxLevel && safeXp >= xpForLevel(level + 1)) {
      level++;
    }
    return LevelInfo(
      level: level,
      title: titles[level - 1],
      totalXp: safeXp,
      currentLevelXp: xpForLevel(level),
      nextLevelXp: level == maxLevel
          ? xpForLevel(level)
          : xpForLevel(level + 1),
    );
  }
}
