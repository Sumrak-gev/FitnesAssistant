enum GoalType { weightLoss, muscleGain, maintenance, endurance }

/// Цель пользователя — влияет на расчёт КБЖУ и подбор тренировок.
class Goal {
  final GoalType type;
  final DateTime startDate;
  final double? targetWeight;

  const Goal({
    required this.type,
    required this.startDate,
    this.targetWeight,
  });

  String get label {
    switch (type) {
      case GoalType.weightLoss:
        return 'Похудение';
      case GoalType.muscleGain:
        return 'Набор массы';
      case GoalType.maintenance:
        return 'Поддержание веса';
      case GoalType.endurance:
        return 'Выносливость';
    }
  }
}
