import 'exercise.dart';

/// Тренировочная программа — набор упражнений, привязанный к цели.
class Program {
  final String id;
  final String title;
  final String targetGoal; // напр. "похудение", "масса", "выносливость"
  final List<Exercise> exercises;

  const Program({
    required this.id,
    required this.title,
    required this.targetGoal,
    required this.exercises,
  });

  /// Заменить упражнение в программе на другое (той же группы мышц).
  Program replaceExercise(String oldExerciseId, Exercise newExercise) {
    final updated = exercises
        .map((e) => e.id == oldExerciseId ? newExercise : e)
        .toList();
    return Program(
      id: id,
      title: title,
      targetGoal: targetGoal,
      exercises: updated,
    );
  }
}
