import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../db/app_database.dart';

/// Общая точка записи для всех модулей, которые синхронизируются с сервером:
/// определяет владельца данных и кладёт изменения в очередь отправки (outbox).
///
/// Вызывать внутри `database.transaction`, вместе с самой записью сущности.
class SyncWriter {
  SyncWriter(this.database, {this.accountId});
  final AppDatabase database;

  /// Идентификатор аккаунта; null — локальный владелец (до входа в аккаунт).
  final String? accountId;
  static const _uuid = Uuid();

  /// Владелец данных. Создаётся при первом обращении.
  Future<String> userId() async {
    SimpleSelectStatement<$SyncUsersTable, SyncUser> owner() =>
        database.select(database.syncUsers)..where(
          (u) => accountId == null
              ? u.localSlot.equals(1)
              : u.id.equals(accountId!),
        );
    final existing = await owner().getSingleOrNull();
    if (existing != null) return existing.id;
    final profile = await database
        .select(database.localProfiles)
        .getSingleOrNull();
    await database
        .into(database.syncUsers)
        .insert(
          SyncUsersCompanion.insert(
            id: accountId ?? _uuid.v4(),
            localSlot: Value(accountId == null ? 1 : null),
            profileId: Value(accountId == null ? profile?.id : null),
          ),
          mode: InsertMode.insertOrIgnore,
        );
    return (await owner().getSingle()).id;
  }

  /// Добавляет изменение в очередь. Для `delete` данные не передаются.
  Future<void> enqueue({
    required String owner,
    required String entity,
    required String id,
    required String operation,
    required int revision,
    required int baseVersion,
    Map<String, dynamic> data = const {},
  }) async {
    await database
        .into(database.syncOutbox)
        .insert(
          SyncOutboxCompanion.insert(
            mutationId: _uuid.v4(),
            userId: owner,
            entity: entity,
            entityId: id,
            operation: operation,
            payload: jsonEncode({
              'id': id,
              'baseVersion': baseVersion,
              'clientRevision': revision,
              'data': operation == 'delete' ? null : data,
            }),
            createdAt: DateTime.now().toUtc(),
          ),
        );
  }
}
