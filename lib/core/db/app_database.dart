// Drift's schema DSL references its generated column inside CHECK expressions.
// ignore_for_file: recursive_getters
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'nutrition_tables.dart';
import 'sync_tables.dart';

part 'app_database.g.dart';

class LocalProfiles extends Table {
  IntColumn get id => integer().check(id.equals(1))();
  TextColumn get name => text().withLength(max: 80)();
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get sex => text()();
  RealColumn get heightCm => real().nullable()();
  RealColumn get weightKg => real().nullable()();
  RealColumn get targetWeightKg => real().nullable()();
  TextColumn get activity => text()();
  TextColumn get goal => text()();
  TextColumn get programId => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class LocalReminders extends Table {
  IntColumn get id => integer().check(id.equals(1))();
  TextColumn get frequency => text()();
  IntColumn get hour => integer().check(hour.isBetweenValues(0, 23))();
  IntColumn get minute => integer().check(minute.isBetweenValues(0, 59))();
  IntColumn get weekday => integer().check(weekday.isBetweenValues(1, 7))();
  IntColumn get monthDay => integer().check(monthDay.isBetweenValues(1, 28))();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    LocalProfiles,
    LocalReminders,
    SyncUsers,
    NutritionProducts,
    NutritionMeals,
    NutritionEntries,
    SyncOutbox,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'fitness_assistant'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) => transaction(() async {
      if (from < 2) {
        await migrator.createTable(syncUsers);
        await migrator.createTable(nutritionProducts);
        await migrator.createTable(nutritionMeals);
        await migrator.createTable(nutritionEntries);
        await migrator.createTable(syncOutbox);
        for (final index in allSchemaEntities.whereType<Index>()) {
          await migrator.createIndex(index);
        }
      }
      if (from == 2) {
        // v3: очередь стала общей для модулей — снимаем жёсткий CHECK по списку сущностей.
        await migrator.alterTable(TableMigration(syncOutbox));
      }
    }),
    beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
  );
}
