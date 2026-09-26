import '../models/achievement.dart';

class AchievementService {
  /// Заглушка стартового набора достижений — источник данных подключить позже.
  List<Achievement> defaultAchievements() => const [
        Achievement(
          id: 'first_week',
          title: 'Первая неделя',
          description: 'Неделя без пропусков тренировок',
        ),
        Achievement(
          id: 'kbju_streak_7',
          title: 'В графике',
          description: '7 дней подряд в пределах КБЖУ',
        ),
        Achievement(
          id: 'program_complete',
          title: 'Программа пройдена',
          description: 'Завершена первая тренировочная программа целиком',
        ),
      ];
}
