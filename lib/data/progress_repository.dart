import 'dart:convert';
import 'package:drift/drift.dart';
import '../core/db/app_database.dart';
import '../models/day_log.dart';
import '../models/daily_ration.dart';
import '../utils/date_helpers.dart';
import 'fitness_repository.dart';
import 'nutrition_repository.dart';

class ProgressRepository {
  ProgressRepository(this.database) : _records = FitnessRepository(database);
  final AppDatabase database;
  final FitnessRepository _records;

  Future<List<DayLog>> getLogs() async {
    final rows = await _records.rows('progress');
    final logs = <DateTime, DayLog>{};
    for (final row in rows) {
      final data = jsonDecode(row.data) as Map<String, dynamic>;
      final day = DateTime.parse(data['day'] as String);
      logs[day] = DayLog(
        date: day,
        workoutDone: data['workoutDone'] as bool,
        caloriesConsumed: (data['caloriesConsumed'] as num?)?.toDouble(),
      );
    }
    final owner = await NutritionRepository(database).userId();
    final meals = await (database.select(
      database.nutritionMeals,
    )..where((m) => m.userId.equals(owner) & m.deletedAt.isNull())).get();
    final entries = await (database.select(
      database.nutritionEntries,
    )..where((e) => e.userId.equals(owner) & e.deletedAt.isNull())).get();
    final totals = <DateTime, double>{};
    final dates = {for (final meal in meals) meal.id: DateTime.parse(meal.day)};
    for (final entry in entries) {
      final day = dates[entry.mealId];
      if (day != null) {
        totals[day] = (totals[day] ?? 0) + entry.calories * entry.grams / 100;
      }
    }
    for (final entry in totals.entries) {
      logs[entry.key] = (logs[entry.key] ?? DayLog(date: entry.key)).copyWith(
        caloriesConsumed: entry.value,
      );
    }
    return logs.values.toList();
  }

  Future<void> _save(DateTime date, {bool? workout, double? calories}) =>
      database.transaction(() async {
        final key = dateOnly(date);
        if (key.year < 1900 || key.year > 2100) {
          throw ArgumentError('Проверьте дату записи.');
        }
        final id = fitnessId('progress:${nutritionDay(key)}');
        final old = (await _records.rows(
          'progress',
        )).where((r) => r.id == id).firstOrNull;
        final data = old == null
            ? <String, dynamic>{}
            : jsonDecode(old.data) as Map<String, dynamic>;
        await _records.save('progress', id, {
          'day': nutritionDay(key),
          'workoutDone': workout ?? data['workoutDone'] ?? false,
          'caloriesConsumed': calories ?? data['caloriesConsumed'],
        });
        if (workout == true) {
          await _records.save(
            'achievement',
            fitnessId('achievement:first_workout'),
            {'key': 'first_workout', 'unlocked': true},
          );
        }
      });

  Future<void> markWorkout(DateTime date) => _save(date, workout: true);
  Future<void> logCalories(DateTime date, double calories) {
    if (!calories.isFinite || calories < 0 || calories > 100000) {
      throw ArgumentError('Проверьте калории.');
    }
    return _save(date, calories: calories);
  }
}
