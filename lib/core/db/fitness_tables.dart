import 'package:drift/drift.dart';
import 'sync_tables.dart';

/// Typed at the repository/API boundary; one durable envelope for fitness modules.
class FitnessRecords extends Table with SyncMetadata {
  TextColumn get entity => text()();
  TextColumn get id => text()();
  TextColumn get data => text()();
  @override
  Set<Column> get primaryKey => {userId, entity, id};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}

class ExerciseCatalog extends Table {
  TextColumn get id => text()();
  TextColumn get data => text()();
  @override
  Set<Column> get primaryKey => {id};
}
