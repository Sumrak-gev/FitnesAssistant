import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../core/db/app_database.dart';
import '../core/sync/sync_writer.dart';

String fitnessId(String key) =>
    const Uuid().v5(Namespace.url.value, 'fitness:$key');

class FitnessRepository {
  FitnessRepository(this.database);
  final AppDatabase database;

  Future<List<FitnessRecord>> rows(String entity) async {
    final owner = await SyncWriter(database).userId();
    return (database.select(database.fitnessRecords)..where(
          (r) =>
              r.userId.equals(owner) &
              r.entity.equals(entity) &
              r.deletedAt.isNull(),
        ))
        .get();
  }

  Future<void> save(String entity, String id, Map<String, dynamic> data) =>
      database.transaction(() async {
        final writer = SyncWriter(database);
        final owner = await writer.userId();
        final old =
            await (database.select(database.fitnessRecords)..where(
                  (r) =>
                      r.userId.equals(owner) &
                      r.entity.equals(entity) &
                      r.id.equals(id),
                ))
                .getSingleOrNull();
        final revision = (old?.localRevision ?? 0) + 1;
        await database
            .into(database.fitnessRecords)
            .insertOnConflictUpdate(
              FitnessRecordsCompanion.insert(
                userId: owner,
                entity: entity,
                id: id,
                data: jsonEncode(data),
                updatedAt: DateTime.now().toUtc(),
                localRevision: Value(revision),
                serverVersion: Value(old?.serverVersion ?? 0),
                deletedAt: const Value(null),
              ),
            );
        await writer.enqueue(
          owner: owner,
          entity: entity,
          id: id,
          operation: 'upsert',
          revision: revision,
          baseVersion: old?.serverVersion ?? 0,
          data: data,
        );
      });

  Future<String?> setting(String key) async => (await (database.select(
    database.appSettings,
  )..where((r) => r.key.equals(key))).getSingleOrNull())?.value;

  Future<void> setSetting(String key, String value) async {
    await database
        .into(database.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(key: key, value: value),
        );
  }

  Future<void> bindAccount(
    String serverUserId,
  ) => database.transaction(() async {
    final existing = await setting('accountId');
    if (existing != null && existing != serverUserId) {
      throw StateError(
        'На устройстве сохранены данные другого аккаунта. Войдите в прежний аккаунт.',
      );
    }
    await SyncWriter(database).userId();
    await setSetting('accountId', serverUserId);
  });
}
