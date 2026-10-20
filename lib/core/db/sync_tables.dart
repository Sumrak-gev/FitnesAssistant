// ignore_for_file: recursive_getters
import 'package:drift/drift.dart';
import 'app_database.dart';

/// Владелец данных. Имя таблицы в SQLite сохранено, чтобы не делать миграцию.
@TableIndex.sql(
  'CREATE UNIQUE INDEX nutrition_local_user ON nutrition_users(local_slot) WHERE local_slot IS NOT NULL',
)
class SyncUsers extends Table {
  @override
  String get tableName => 'nutrition_users';

  TextColumn get id => text()();
  IntColumn get localSlot => integer().nullable().check(localSlot.equals(1))();
  IntColumn get profileId => integer().nullable().references(
    LocalProfiles,
    #id,
    onDelete: KeyAction.setNull,
  )();
  @override
  Set<Column> get primaryKey => {id};
}

/// Общие поля синхронизируемой сущности: владелец, время, мягкое удаление, версии.
mixin SyncMetadata on Table {
  TextColumn get userId => text().references(SyncUsers, #id)();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get localRevision => integer()
      .withDefault(const Constant(1))
      .check(localRevision.isBiggerThanValue(0))();
  IntColumn get serverVersion => integer()
      .withDefault(const Constant(0))
      .check(serverVersion.isBiggerOrEqualValue(0))();
}

@TableIndex.sql(
  'CREATE INDEX nutrition_outbox_order ON nutrition_outbox(sequence)',
)
class SyncOutbox extends Table {
  @override
  String get tableName => 'nutrition_outbox';

  IntColumn get sequence => integer().autoIncrement()();
  TextColumn get mutationId => text().unique()();
  TextColumn get userId => text().references(SyncUsers, #id)();

  /// Имя сущности модуля, например product; допустимые значения задаёт модуль.
  TextColumn get entity => text().withLength(min: 1, max: 64)();
  TextColumn get entityId => text()();
  TextColumn get operation =>
      text().check(operation.isIn(['upsert', 'delete']))();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();
}
