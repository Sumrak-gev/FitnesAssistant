import 'dart:io';
import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_assistant/core/db/app_database.dart';
import 'package:fitness_assistant/data/fitness_repository.dart';
import 'package:fitness_assistant/data/progress_repository.dart';
import 'package:fitness_assistant/data/workout_repository.dart';
import 'package:fitness_assistant/services/achievement_service.dart';
import 'package:fitness_assistant/services/progress_service.dart';

void main() {
  test(
    'Programs, real progress, achievements and outbox survive a file reopen',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'fitness_records_test_',
      );
      final file = File('${directory.path}/fitness.sqlite');
      var db = AppDatabase(NativeDatabase(file));
      try {
        final workouts = WorkoutRepository(db);
        final program = (await workouts.getPrograms()).first;
        final replacement = (await workouts.getAllExercises()).firstWhere(
          (e) => e.id == 'e2',
        );
        await workouts.saveProgram(program.replaceExercise('e1', replacement));
        final progress = ProgressRepository(db);
        for (var i = 0; i < 7; i++) {
          final day = DateTime(2026, 10, 12 + i);
          await progress.logCalories(day, 2000);
          if (i == 0 || i == 2 || i == 4) await progress.markWorkout(day);
        }
        final snapshot = ProgressService().build(
          logs: await progress.getLogs(),
          today: DateTime(2026, 10, 18),
          dailyTarget: 2000,
        );
        await AchievementService().awardProgress(db, snapshot);
        await workouts.completeProgram(
          program.replaceExercise('e1', replacement),
          DateTime(2026, 10, 18),
        );
        await db.close();
        db = AppDatabase(NativeDatabase(file));
        final persisted = (await WorkoutRepository(db).getPrograms()).single;
        expect(persisted.exercises.first.id, 'e2');
        expect(
          (await ProgressRepository(db).getLogs()).where((l) => l.workoutDone),
          hasLength(4),
        );
        final achievements = await FitnessRepository(db).rows('achievement');
        expect(achievements, hasLength(4));
        expect(
          achievements.every(
            (r) => (jsonDecode(r.data) as Map)['unlocked'] == true,
          ),
          isTrue,
        );
        final queue = await db.select(db.syncOutbox).get();
        expect(
          queue.map((r) => r.entity).toSet(),
          containsAll(['workout', 'progress', 'achievement']),
        );
        expect(
          await db.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty,
        );
      } finally {
        await db.close();
        await directory.delete(recursive: true);
      }
    },
  );
}
