/// Уровень пользователя, рассчитанный из очков опыта (XP).
class LevelInfo {
  final int level;
  final String title;
  final int totalXp;

  /// XP, с которого начался текущий уровень.
  final int currentLevelXp;

  /// XP, при котором откроется следующий уровень.
  final int nextLevelXp;

  const LevelInfo({
    required this.level,
    required this.title,
    required this.totalXp,
    required this.currentLevelXp,
    required this.nextLevelXp,
  });

  int get xpIntoLevel => totalXp - currentLevelXp;
  int get xpToNext => nextLevelXp - totalXp;

  /// Доля заполнения шкалы уровня, от 0.0 до 1.0.
  double get progress =>
      (xpIntoLevel / (nextLevelXp - currentLevelXp)).clamp(0.0, 1.0).toDouble();
}
