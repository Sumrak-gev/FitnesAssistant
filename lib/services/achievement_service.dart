import '../models/achievement.dart';
import '../core/db/app_database.dart';
import '../data/fitness_repository.dart';
import 'progress_service.dart';

class AchievementService {
  Future<void> awardProgress(AppDatabase database, ProgressSnapshot snapshot) =>
      database.transaction(() async {
        final repository = FitnessRepository(database);
        final existing = (await repository.rows(
          'achievement',
        )).map((r) => r.id).toSet();
        final keys = [
          if (snapshot.totalWorkouts > 0) 'first_workout',
          if (snapshot.workoutWeekStreak.best > 0) 'first_week',
          if (snapshot.nutritionDayStreak.best >= 7) 'kbju_streak_7',
        ];
        for (final key in keys) {
          final id = fitnessId('achievement:$key');
          if (!existing.contains(id)) {
            await repository.save('achievement', id, {
              'key': key,
              'unlocked': true,
            });
          }
        }
      });

  /// Определения достижений; состояние открытия хранится в Drift.
  List<Achievement> defaultAchievements() => const [
    Achievement(
      id: 'first_workout',
      title: 'Первый шаг',
      description: 'Отмечена первая тренировка',
    ),
    Achievement(
      id: 'first_week',
      title: 'Первая неделя',
      description: 'Три тренировки в течение одной недели',
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
