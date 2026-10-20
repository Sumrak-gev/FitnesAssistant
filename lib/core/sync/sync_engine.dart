import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../api/api_client.dart';
import '../db/app_database.dart';
import '../../data/fitness_repository.dart';
import 'sync_writer.dart';
import 'database_lease.dart';

class SyncEngine extends ChangeNotifier {
  SyncEngine(this.database, this.api, {this.onDataChanged}) {
    api.addListener(schedule);
    _subscription = database
        .select(database.syncOutbox)
        .watch()
        .listen((_) => schedule());
    schedule();
  }
  final AppDatabase database;
  final ApiClient api;
  final Future<void> Function()? onDataChanged;
  late final StreamSubscription<List<SyncOutboxData>> _subscription;
  Timer? _timer;
  Future<void>? _inFlight;
  bool _running = false, _disposed = false;
  bool _dataChanged = false;
  bool _hasPending = false;
  int _failures = 0;
  int generation = 0;
  String status = 'Ожидание входа';
  Map<String, dynamic>? conflict;
  FitnessRepository get _records => FitnessRepository(database);

  void schedule() {
    if (_disposed || _running || api.session == null || conflict != null) {
      return;
    }
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 700), synchronize);
  }

  Future<void> synchronize() => _inFlight ??= _synchronize().whenComplete(() {
    _inFlight = null;
  });

  Future<void> _synchronize() async {
    if (_disposed || _running || api.session == null || conflict != null) {
      return;
    }
    _running = true;
    _dataChanged = false;
    _hasPending = false;
    _timer?.cancel();
    status = 'Синхронизация…';
    notifyListeners();
    final lease = DatabaseLease(database, 'sync');
    var acquired = false;
    try {
      acquired = await lease.acquire();
      if (!acquired) {
        status = 'Синхронизация выполняется в фоне';
        return;
      }
      if (await _records.setting('accountId') != api.session!.userId) {
        throw StateError('Локальные данные принадлежат другому аккаунту.');
      }
      final owner = await SyncWriter(database).userId();
      await _pull(owner, lease);
      // Send in transaction order, including product/meal dependencies and every local revision.
      for (var count = 0; count < 300 && api.session != null; count++) {
        if (!await lease.acquire()) throw StateError('Sync lease expired');
        final row =
            await (database.select(database.syncOutbox)
                  ..where((o) => o.userId.equals(owner))
                  ..orderBy([(o) => OrderingTerm.asc(o.sequence)])
                  ..limit(1))
                .getSingleOrNull();
        if (row == null) break;
        try {
          final result =
              await api.request('POST', '/sync/push', {
                    'changes': [
                      {
                        ...jsonDecode(row.payload) as Map<String, dynamic>,
                        'mutationId': row.mutationId,
                        'entity': row.entity,
                        'operation': row.operation,
                      },
                    ],
                  })
                  as Map<String, dynamic>;
          final version =
              ((result['applied'] as List).single as Map)['version'] as int;
          await database.transaction(() async {
            await (database.delete(
              database.syncOutbox,
            )..where((o) => o.sequence.equals(row.sequence))).go();
            await _setVersion(owner, row.entity, row.entityId, version);
            await _rebase(owner, row.entity, row.entityId, version);
          });
        } on ApiException catch (error) {
          if (error.status == 409 && error.detail['code'] == 'meal_alias') {
            await _aliasMeal(
              owner,
              row.entityId,
              error.detail['canonicalId'] as String,
              error.detail['currentVersion'] as int,
            );
            continue;
          }
          if (error.status == 409) {
            conflict = {
              ...error.detail,
              'entity': row.entity,
              'entityId': row.entityId,
            };
            await _pull(owner, lease);
            final remote = await _records.setting(
              'remote:${row.entity}:${row.entityId}',
            );
            conflict!['canKeepLocal'] =
                error.detail['code'] == 'version_conflict' &&
                remote != null &&
                (jsonDecode(remote) as Map)['deletedAt'] == null;
          }
          rethrow;
        }
      }
      await _pull(owner, lease);
      _failures = 0;
      _hasPending =
          await (database.select(database.syncOutbox)
                ..where((o) => o.userId.equals(owner))
                ..limit(1))
              .getSingleOrNull() !=
          null;
      status = _hasPending
          ? 'Продолжается отправка очереди…'
          : 'Синхронизировано';
      if (_dataChanged) {
        generation++;
        await onDataChanged?.call();
      }
    } catch (error) {
      _failures++;
      status = conflict != null
          ? 'Конфликт: выберите версию данных'
          : api.session == null
          ? 'Войдите снова'
          : 'Нет связи. Данные сохранены локально';
    } finally {
      if (acquired) await lease.release();
      _running = false;
      if (!_disposed) {
        notifyListeners();
        if (api.session != null && conflict == null) {
          _timer = Timer(
            Duration(
              seconds: _hasPending
                  ? 1
                  : _failures == 0
                  ? 30
                  : min(300, 5 * (1 << min(_failures, 6))),
            ),
            synchronize,
          );
        }
      }
    }
  }

  Future<void> _rebase(
    String owner,
    String entity,
    String id,
    int version,
  ) async {
    final rows =
        await (database.select(database.syncOutbox)..where(
              (o) =>
                  o.userId.equals(owner) &
                  o.entity.equals(entity) &
                  o.entityId.equals(id),
            ))
            .get();
    for (final row in rows) {
      final payload = jsonDecode(row.payload) as Map<String, dynamic>;
      payload['baseVersion'] = version;
      await (database.update(database.syncOutbox)
            ..where((o) => o.sequence.equals(row.sequence)))
          .write(SyncOutboxCompanion(payload: Value(jsonEncode(payload))));
    }
  }

  Future<void> _setVersion(
    String owner,
    String entity,
    String id,
    int version,
  ) async {
    final TableInfo<Table, dynamic> table = switch (entity) {
      'product' => database.nutritionProducts,
      'meal' => database.nutritionMeals,
      'entry' => database.nutritionEntries,
      _ => database.fitnessRecords,
    };
    // Table names come exclusively from Drift's registered tables, values are parameters.
    await database.customUpdate(
      'UPDATE ${table.actualTableName} SET server_version = ? WHERE user_id = ? AND id = ?'
      '${entity == 'product' || entity == 'meal' || entity == 'entry' ? '' : ' AND entity = ?'}',
      variables: [
        Variable(version),
        Variable(owner),
        Variable(id),
        if (!['product', 'meal', 'entry'].contains(entity)) Variable(entity),
      ],
      updates: {table},
    );
  }

  Future<void> _pull(String owner, DatabaseLease lease) async {
    var cursor = await _records.setting('cursor') ?? '0';
    var more = true;
    while (more && api.session != null) {
      if (!await lease.acquire()) throw StateError('Sync lease expired');
      Map<String, dynamic> result;
      try {
        result =
            await api.request(
                  'GET',
                  '/sync/pull?since=${Uri.encodeQueryComponent(cursor)}&limit=100',
                )
                as Map<String, dynamic>;
      } on ApiException catch (error) {
        if (error.status != 410 || cursor == '0') rethrow;
        cursor = '0';
        continue;
      }
      await database.transaction(() async {
        for (final value in result['changes'] as List) {
          final change = value as Map<String, dynamic>;
          await _records.setSetting(
            'remote:${change['entity']}:${change['id']}',
            jsonEncode(change),
          );
          await _apply(owner, change);
        }
        cursor = result['nextCursor'] as String;
        await _records.setSetting('cursor', cursor);
      });
      more = result['hasMore'] as bool;
    }
  }

  Future<void> _aliasMeal(
    String owner,
    String oldId,
    String canonicalId,
    int version,
  ) => database.transaction(() async {
    if (oldId == canonicalId) return;
    final old =
        await (database.select(database.nutritionMeals)
              ..where((m) => m.userId.equals(owner) & m.id.equals(oldId)))
            .getSingleOrNull();
    if (old == null) return;
    // SQLite checks all composite references at commit, after both ends are remapped.
    await database.customStatement('PRAGMA defer_foreign_keys = ON');
    await (database.update(
      database.nutritionMeals,
    )..where((m) => m.id.equals(oldId))).write(
      NutritionMealsCompanion(
        id: Value(canonicalId),
        serverVersion: Value(version),
      ),
    );
    await (database.update(database.nutritionEntries)
          ..where((e) => e.userId.equals(owner) & e.mealId.equals(oldId)))
        .write(NutritionEntriesCompanion(mealId: Value(canonicalId)));
    final pending = await (database.select(
      database.syncOutbox,
    )..where((o) => o.userId.equals(owner))).get();
    for (final row in pending) {
      final payload = jsonDecode(row.payload) as Map<String, dynamic>;
      var changed = false;
      final isMeal = row.entity == 'meal' && row.entityId == oldId;
      if (isMeal) {
        payload['id'] = canonicalId;
        payload['baseVersion'] = version;
        changed = true;
      }
      if (row.entity == 'entry' &&
          (payload['data'] as Map?)?['mealId'] == oldId) {
        (payload['data'] as Map)['mealId'] = canonicalId;
        changed = true;
      }
      if (changed) {
        await (database.update(
          database.syncOutbox,
        )..where((o) => o.sequence.equals(row.sequence))).write(
          SyncOutboxCompanion(
            entityId: isMeal ? Value(canonicalId) : const Value.absent(),
            mutationId: Value(const Uuid().v4()),
            payload: Value(jsonEncode(payload)),
          ),
        );
      }
    }
  });

  Future<void> _apply(
    String owner,
    Map<String, dynamic> change, {
    bool force = false,
  }) async {
    final entity = change['entity'] as String, id = change['id'] as String;
    final version = change['version'] as int;
    final data = change['data'] as Map<String, dynamic>?;
    if (entity == 'meal' && data != null) {
      final slot =
          await (database.select(database.nutritionMeals)..where(
                (m) =>
                    m.userId.equals(owner) &
                    m.day.equals(data['day'] as String) &
                    m.kind.equals(data['kind'] as String),
              ))
              .getSingleOrNull();
      if (slot != null && slot.id != id) {
        await _aliasMeal(owner, slot.id, id, version);
      }
    }
    final pending =
        await (database.select(database.syncOutbox)
              ..where(
                (o) =>
                    o.userId.equals(owner) &
                    o.entity.equals(entity) &
                    o.entityId.equals(id),
              )
              ..limit(1))
            .getSingleOrNull();
    if (pending != null && !force) return;
    final updated = DateTime.parse(change['updatedAt'] as String).toUtc();
    final deleted = change['deletedAt'] == null
        ? null
        : DateTime.parse(change['deletedAt'] as String).toUtc();
    final current = switch (entity) {
      'product' => await (database.select(
        database.nutritionProducts,
      )..where((r) => r.id.equals(id))).getSingleOrNull(),
      'meal' => await (database.select(
        database.nutritionMeals,
      )..where((r) => r.id.equals(id))).getSingleOrNull(),
      'entry' => await (database.select(
        database.nutritionEntries,
      )..where((r) => r.id.equals(id))).getSingleOrNull(),
      _ =>
        await (database.select(database.fitnessRecords)..where(
              (r) =>
                  r.userId.equals(owner) &
                  r.entity.equals(entity) &
                  r.id.equals(id),
            ))
            .getSingleOrNull(),
    };
    final currentVersion = switch (current) {
      NutritionProduct r => r.serverVersion,
      NutritionMeal r => r.serverVersion,
      NutritionEntry r => r.serverVersion,
      FitnessRecord r => r.serverVersion,
      _ => 0,
    };
    if (!force && currentVersion >= version) return;
    if (data == null && current == null) return;
    _dataChanged = true;
    if (entity == 'product') {
      final old = current as NutritionProduct?;
      await database
          .into(database.nutritionProducts)
          .insertOnConflictUpdate(
            NutritionProductsCompanion.insert(
              id: id,
              userId: owner,
              name: data?['name'] as String? ?? old!.name,
              calories:
                  (data?['calories'] as num?)?.toDouble() ?? old!.calories,
              protein: (data?['protein'] as num?)?.toDouble() ?? old!.protein,
              fat: (data?['fat'] as num?)?.toDouble() ?? old!.fat,
              carbs: (data?['carbs'] as num?)?.toDouble() ?? old!.carbs,
              updatedAt: updated,
              deletedAt: Value(deleted),
              serverVersion: Value(version),
              localRevision: Value(old?.localRevision ?? 1),
            ),
          );
    } else if (entity == 'meal') {
      final old = current as NutritionMeal?;
      await database
          .into(database.nutritionMeals)
          .insertOnConflictUpdate(
            NutritionMealsCompanion.insert(
              id: id,
              userId: owner,
              day: data?['day'] as String? ?? old!.day,
              kind: data?['kind'] as String? ?? old!.kind,
              updatedAt: updated,
              deletedAt: Value(deleted),
              serverVersion: Value(version),
              localRevision: Value(old?.localRevision ?? 1),
            ),
          );
    } else if (entity == 'entry') {
      final old = current as NutritionEntry?;
      final snapshot = data?['snapshot'] as Map<String, dynamic>?;
      await database
          .into(database.nutritionEntries)
          .insertOnConflictUpdate(
            NutritionEntriesCompanion.insert(
              id: id,
              userId: owner,
              mealId: data?['mealId'] as String? ?? old!.mealId,
              productId: data?['productId'] as String? ?? old!.productId,
              grams: (data?['grams'] as num?)?.toDouble() ?? old!.grams,
              productName: snapshot?['name'] as String? ?? old!.productName,
              calories:
                  (snapshot?['calories'] as num?)?.toDouble() ?? old!.calories,
              protein:
                  (snapshot?['protein'] as num?)?.toDouble() ?? old!.protein,
              fat: (snapshot?['fat'] as num?)?.toDouble() ?? old!.fat,
              carbs: (snapshot?['carbs'] as num?)?.toDouble() ?? old!.carbs,
              updatedAt: updated,
              deletedAt: Value(deleted),
              serverVersion: Value(version),
              localRevision: Value(old?.localRevision ?? 1),
            ),
          );
    } else {
      final old = current as FitnessRecord?;
      await database
          .into(database.fitnessRecords)
          .insertOnConflictUpdate(
            FitnessRecordsCompanion.insert(
              userId: owner,
              entity: entity,
              id: id,
              data: jsonEncode(data),
              updatedAt: updated,
              deletedAt: Value(deleted),
              serverVersion: Value(version),
              localRevision: Value(old?.localRevision ?? 1),
            ),
          );
      if (entity == 'profile' && data != null) {
        await database
            .into(database.localProfiles)
            .insertOnConflictUpdate(
              LocalProfilesCompanion.insert(
                id: const Value(1),
                name: data['name'] as String,
                sex: data['sex'] as String,
                birthDate: Value(
                  data['birthDate'] == null
                      ? null
                      : DateTime.parse(data['birthDate'] as String),
                ),
                heightCm: Value((data['heightCm'] as num?)?.toDouble()),
                weightKg: Value((data['weightKg'] as num?)?.toDouble()),
                targetWeightKg: Value(
                  (data['targetWeightKg'] as num?)?.toDouble(),
                ),
                activity: data['activity'] as String,
                goal: data['goal'] as String,
                programId: Value(data['programId'] as String?),
                updatedAt: updated,
              ),
            );
        await (database.update(database.syncUsers)
              ..where((u) => u.id.equals(owner)))
            .write(const SyncUsersCompanion(profileId: Value(1)));
      }
      if (entity == 'profile' && deleted != null) {
        await (database.delete(
          database.localProfiles,
        )..where((p) => p.id.equals(1))).go();
      }
      if (entity == 'goal' && data != null) {
        await (database.update(
          database.localProfiles,
        )..where((p) => p.id.equals(1))).write(
          LocalProfilesCompanion(
            goal: Value(data['goal'] as String),
            targetWeightKg: Value((data['targetWeightKg'] as num?)?.toDouble()),
          ),
        );
      }
    }
  }

  Future<void> resolveConflict({required bool keepLocal}) async {
    final value = conflict;
    if (value == null) return;
    final entity = value['entity'] as String, id = value['entityId'] as String;
    final owner = await SyncWriter(database).userId();
    final raw = await _records.setting('remote:$entity:$id');
    if (keepLocal && value['canKeepLocal'] != true) return;
    final remote = raw == null
        ? <String, dynamic>{
            'entity': entity,
            'id': id,
            'version': 0,
            'data': null,
            'updatedAt': DateTime.now().toUtc().toIso8601String(),
            'deletedAt': DateTime.now().toUtc().toIso8601String(),
          }
        : jsonDecode(raw) as Map<String, dynamic>;
    await database.transaction(() async {
      if (keepLocal) {
        await _setVersion(owner, entity, id, remote['version'] as int);
        await _rebase(owner, entity, id, remote['version'] as int);
      } else {
        await (database.delete(database.syncOutbox)..where(
              (o) =>
                  o.userId.equals(owner) &
                  o.entity.equals(entity) &
                  o.entityId.equals(id),
            ))
            .go();
        await _apply(owner, remote, force: true);
      }
    });
    conflict = null;
    generation++;
    await onDataChanged?.call();
    schedule();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    api.removeListener(schedule);
    _subscription.cancel();
    _timer?.cancel();
    super.dispose();
  }
}
