import '../models/exercise.dart';
import '../models/program.dart';

class WorkoutService {
  /// Подобрать замену упражнению: та же группа мышц, без противопоказаний
  /// пользователя, отличное упражнение.
  Exercise? findReplacement({
    required Exercise current,
    required List<Exercise> pool,
    required List<String> userContraindications,
  }) {
    for (final candidate in pool) {
      if (candidate.id == current.id) continue;
      if (candidate.muscleGroup != current.muscleGroup) continue;
      final hasConflict = candidate.contraindications
          .any((c) => userContraindications.contains(c));
      if (!hasConflict) return candidate;
    }
    return null;
  }

  /// Отфильтровать программы, подходящие пользователю по здоровью.
  List<Program> filterSafePrograms(
    List<Program> programs,
    List<String> userContraindications,
  ) {
    return programs.where((p) {
      final riskyExercises = p.exercises.where(
        (e) => e.contraindications.any(userContraindications.contains),
      );
      return riskyExercises.isEmpty;
    }).toList();
  }
}
