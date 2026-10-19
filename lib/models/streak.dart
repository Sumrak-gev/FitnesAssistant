/// Серия: сколько периодов (дней или недель) подряд выполнено условие.
class StreakInfo {
  /// Текущая серия.
  final int current;

  /// Лучшая серия за всё время.
  final int best;

  /// Выполнено ли условие в текущем периоде (сегодня / на этой неделе).
  /// Если нет — серия не обрывается, пока период не закончился.
  final bool currentPeriodDone;

  const StreakInfo({
    required this.current,
    required this.best,
    required this.currentPeriodDone,
  });
}
