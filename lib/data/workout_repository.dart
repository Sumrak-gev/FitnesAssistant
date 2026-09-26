import '../models/exercise.dart';
import '../models/program.dart';

/// TODO: заменить in-memory реализацию на SQLite (sqflite).
class WorkoutRepository {
  final List<Exercise> _exercises = const [
    Exercise(id: 'e1', name: 'Приседания со штангой', muscleGroup: 'ноги', equipment: 'штанга', contraindications: ['травма колена']),
    Exercise(id: 'e2', name: 'Жим ногами в тренажёре', muscleGroup: 'ноги', equipment: 'тренажёр'),
    Exercise(id: 'e3', name: 'Жим лёжа', muscleGroup: 'грудь', equipment: 'штанга', contraindications: ['травма плеча']),
    Exercise(id: 'e4', name: 'Отжимания', muscleGroup: 'грудь', equipment: 'без инвентаря'),
  ];

  Future<List<Exercise>> getAllExercises() async => _exercises;

  Future<List<Program>> getPrograms() async => [
        Program(
          id: 'p1',
          title: 'Ноги и грудь — базовый уровень',
          targetGoal: 'набор массы',
          exercises: [_exercises[0], _exercises[2]],
        ),
      ];
}
