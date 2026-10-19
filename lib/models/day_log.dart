/// Запись об одном дне: была ли тренировка и сколько калорий съедено.
class DayLog {
  /// Только дата (без времени).
  final DateTime date;
  final bool workoutDone;

  /// null — питание за день не вносилось.
  final double? caloriesConsumed;

  const DayLog({
    required this.date,
    this.workoutDone = false,
    this.caloriesConsumed,
  });

  DayLog copyWith({bool? workoutDone, double? caloriesConsumed}) => DayLog(
        date: date,
        workoutDone: workoutDone ?? this.workoutDone,
        caloriesConsumed: caloriesConsumed ?? this.caloriesConsumed,
      );
}
