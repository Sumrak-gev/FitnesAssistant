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

  static const List<String> titles = [
    'Новичок',
    'Любитель',
    'Спортсмен',
    'Атлет',
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
    while (safeXp >= xpForLevel(level + 1)) {
      level++;
    }
    final titleIndex =
        level - 1 < titles.length ? level - 1 : titles.length - 1;
    return LevelInfo(
      level: level,
      title: titles[titleIndex],
      totalXp: safeXp,
      currentLevelXp: xpForLevel(level),
      nextLevelXp: xpForLevel(level + 1),
    );
  }
}
