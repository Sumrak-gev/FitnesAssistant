import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../core/db/app_database.dart';
import '../core/sync/sync_writer.dart';
import '../models/exercise.dart';
import '../models/program.dart';
import 'fitness_repository.dart';
import 'progress_repository.dart';

class WorkoutRepository {
  WorkoutRepository(this.database) : _records = FitnessRepository(database);
  final AppDatabase database;
  final FitnessRepository _records;

  Future<void> completeProgram(Program program, DateTime day) =>
      database.transaction(() async {
        await saveProgram(program);
        await ProgressRepository(database).markWorkout(day);
        final id = fitnessId('achievement:program_complete');
        if (!(await _records.rows('achievement')).any((r) => r.id == id)) {
          await _records.save('achievement', id, {
            'key': 'program_complete',
            'unlocked': true,
          });
        }
      });

  static const _starterExercises = [
    Exercise(
      id: 'e1',
      name: 'Приседания со штангой',
      muscleGroup: 'ноги',
      equipment: 'штанга',
      contraindications: ['травма колена'],
    ),
    Exercise(
      id: 'e2',
      name: 'Жим ногами в тренажёре',
      muscleGroup: 'ноги',
      equipment: 'тренажёр',
    ),
    Exercise(
      id: 'e3',
      name: 'Жим лёжа',
      muscleGroup: 'грудь',
      equipment: 'штанга',
      contraindications: ['травма плеча'],
    ),
    Exercise(
      id: 'e4',
      name: 'Отжимания',
      muscleGroup: 'грудь',
      equipment: 'без инвентаря',
    ),
  ];

  Future<void> _seed() => database.transaction(() async {
    if (await _records.setting('workoutsSeeded') == '1') return;
    for (final exercise in _starterExercises) {
      await database
          .into(database.exerciseCatalog)
          .insertOnConflictUpdate(
            ExerciseCatalogCompanion.insert(
              id: exercise.id,
              data: jsonEncode(exercise.toMap()),
            ),
          );
    }
    if ((await _records.rows('workout')).isEmpty) {
      await database
          .into(database.fitnessRecords)
          .insert(
            FitnessRecordsCompanion.insert(
              userId: await SyncWriter(database).userId(),
              entity: 'workout',
              id: fitnessId('workout:p1'),
              data: jsonEncode({
                'title': 'Ноги и грудь — базовый уровень',
                'targetGoal': 'набор массы',
                'exercises': [
                  _starterExercises[0].toMap(),
                  _starterExercises[2].toMap(),
                ],
              }),
              updatedAt: DateTime.now().toUtc(),
            ),
          );
    }
    await _records.setSetting('workoutsSeeded', '1');
  });

  Future<List<Exercise>> getAllExercises() async {
    await _seed();
    return (await database.select(database.exerciseCatalog).get())
        .map(
          (r) => Exercise.fromMap(jsonDecode(r.data) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<Program>> getPrograms() async {
    await _seed();
    return (await _records.rows('workout')).map((row) {
      final data = jsonDecode(row.data) as Map<String, dynamic>;
      return Program(
        id: row.id == fitnessId('workout:p1') ? 'p1' : row.id,
        title: data['title'] as String,
        targetGoal: data['targetGoal'] as String,
        exercises: (data['exercises'] as List)
            .map((e) => Exercise.fromMap(e as Map<String, dynamic>))
            .toList(),
      );
    }).toList();
  }

  Future<void> saveProgram(Program program) => _records.save(
    'workout',
    Uuid.isValidUUID(fromString: program.id)
        ? program.id
        : fitnessId('workout:${program.id}'),
    {
      'title': program.title,
      'targetGoal': program.targetGoal,
      'exercises': program.exercises.map((e) => e.toMap()).toList(),
    },
  );
}
