import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../core/api/nutrition_contract.dart';
import '../core/db/app_database.dart';
import '../core/sync/sync_writer.dart';
import '../models/daily_ration.dart';
import '../models/product.dart';

class NutritionRepository {
  NutritionRepository(this.database, {String? accountId})
    : _sync = SyncWriter(database, accountId: accountId);
  final AppDatabase database;
  final SyncWriter _sync;
  static const _uuid = Uuid();

  /// One head mutation per entity. Sending/acknowledging requires the sync layer.
  Future<List<NutritionMutation>> pendingMutations({int limit = 100}) async {
    if (limit < 1 || limit > 100) throw ArgumentError('Размер пакета: 1–100.');
    final owner = await userId();
    final rows =
        await (database.select(database.syncOutbox)
              ..where(
                (o) =>
                    o.userId.equals(owner) & o.entity.isIn(nutritionEntities),
              )
              ..orderBy([(o) => OrderingTerm.asc(o.sequence)])
              ..limit(limit))
            .get();
    final seen = <String>{};
    return rows
        .where((row) => seen.add('${row.entity}:${row.entityId}'))
        .map(
          (row) => NutritionMutation.fromJson({
            ...jsonDecode(row.payload) as Map<String, dynamic>,
            'mutationId': row.mutationId,
            'entity': row.entity,
            'operation': row.operation,
          }),
        )
        .toList();
  }

  Future<String> userId() => _sync.userId();

  Future<void> _enqueue(
    String owner,
    String entity,
    String id,
    String operation,
    int revision,
    int baseVersion,
    Map<String, dynamic> data,
  ) => _sync.enqueue(
    owner: owner,
    entity: entity,
    id: id,
    operation: operation,
    revision: revision,
    baseVersion: baseVersion,
    data: data,
  );

  Product _product(NutritionProduct row) => Product(
    id: row.id,
    name: row.name,
    calories: row.calories,
    protein: row.protein,
    fat: row.fat,
    carbs: row.carbs,
  );

  Future<List<Product>> products({String query = ''}) async {
    final owner = await userId();
    final rows =
        await (database.select(database.nutritionProducts)
              ..where((p) => p.userId.equals(owner) & p.deletedAt.isNull())
              ..orderBy([(p) => OrderingTerm.asc(p.name)]))
            .get();
    final search = query.trim().toLowerCase();
    return rows
        .where((p) => p.name.toLowerCase().contains(search))
        .map(_product)
        .toList();
  }

  Future<Product?> product(String id) async {
    final owner = await userId();
    final row =
        await (database.select(database.nutritionProducts)..where(
              (p) =>
                  p.id.equals(id) &
                  p.userId.equals(owner) &
                  p.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    return row == null ? null : _product(row);
  }

  Future<void> saveProduct(Product product) => database.transaction(() async {
    product.validate();
    final owner = await userId();
    final old = await (database.select(
      database.nutritionProducts,
    )..where((p) => p.id.equals(product.id))).getSingleOrNull();
    if (old != null && (old.userId != owner || old.deletedAt != null)) {
      throw StateError('Продукт недоступен.');
    }
    final revision = (old?.localRevision ?? 0) + 1;
    await database
        .into(database.nutritionProducts)
        .insertOnConflictUpdate(
          NutritionProductsCompanion.insert(
            id: product.id,
            userId: owner,
            name: product.name.trim(),
            calories: product.calories,
            protein: product.protein,
            fat: product.fat,
            carbs: product.carbs,
            localRevision: Value(revision),
            serverVersion: Value(old?.serverVersion ?? 0),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    await _enqueue(
      owner,
      'product',
      product.id,
      'upsert',
      revision,
      old?.serverVersion ?? 0,
      {...(product.toMap()..remove('id')), 'name': product.name.trim()},
    );
  });

  Future<void> deleteProduct(String id) => database.transaction(() async {
    final owner = await userId();
    final row =
        await (database.select(database.nutritionProducts)..where(
              (p) =>
                  p.id.equals(id) &
                  p.userId.equals(owner) &
                  p.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (row == null) throw StateError('Продукт недоступен.');
    final now = DateTime.now().toUtc();
    await (database.update(
      database.nutritionProducts,
    )..where((p) => p.id.equals(id))).write(
      NutritionProductsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        localRevision: Value(row.localRevision + 1),
      ),
    );
    await _enqueue(
      owner,
      'product',
      id,
      'delete',
      row.localRevision + 1,
      row.serverVersion,
      {},
    );
  });

  Future<void> seedIfEmpty() => database.transaction(() async {
    final owner = await userId();
    if ((await (database.select(
      database.nutritionProducts,
    )..where((p) => p.userId.equals(owner))).get()).isNotEmpty) {
      return;
    }
    for (final p in [
      Product(
        id: _uuid.v4(),
        name: 'Куриная грудка',
        calories: 165,
        protein: 31,
        fat: 3.6,
        carbs: 0,
      ),
      Product(
        id: _uuid.v4(),
        name: 'Рис отварной',
        calories: 130,
        protein: 2.7,
        fat: 0.3,
        carbs: 28,
      ),
      Product(
        id: _uuid.v4(),
        name: 'Творог 5%',
        calories: 121,
        protein: 17,
        fat: 5,
        carbs: 3,
      ),
    ]) {
      await saveProduct(p);
    }
  });

  void _validateDay(DateTime day) {
    if (day.year < 1900 || day.year > 2100) {
      throw ArgumentError('Дата должна быть в пределах 1900–2100 годов.');
    }
  }

  Future<NutritionMeal> _meal(String owner, DateTime day, MealKind kind) async {
    _validateDay(day);
    var row =
        await (database.select(database.nutritionMeals)..where(
              (m) =>
                  m.userId.equals(owner) &
                  m.day.equals(nutritionDay(day)) &
                  m.kind.equals(kind.name),
            ))
            .getSingleOrNull();
    if (row == null) {
      final id = _uuid.v4();
      await database
          .into(database.nutritionMeals)
          .insert(
            NutritionMealsCompanion.insert(
              id: id,
              userId: owner,
              day: nutritionDay(day),
              kind: kind.name,
              updatedAt: DateTime.now().toUtc(),
            ),
          );
      row = await (database.select(
        database.nutritionMeals,
      )..where((m) => m.id.equals(id))).getSingle();
      await _enqueue(owner, 'meal', id, 'upsert', 1, 0, {
        'day': row.day,
        'kind': row.kind,
      });
    } else if (row.deletedAt != null) {
      await (database.update(
        database.nutritionMeals,
      )..where((m) => m.id.equals(row!.id))).write(
        NutritionMealsCompanion(
          deletedAt: const Value(null),
          updatedAt: Value(DateTime.now().toUtc()),
          localRevision: Value(row.localRevision + 1),
        ),
      );
      row = await (database.select(
        database.nutritionMeals,
      )..where((m) => m.id.equals(row!.id))).getSingle();
      await _enqueue(
        owner,
        'meal',
        row.id,
        'upsert',
        row.localRevision,
        row.serverVersion,
        {'day': row.day, 'kind': row.kind},
      );
    }
    return row;
  }

  Future<void> saveEntry({
    String? id,
    required String productId,
    required double grams,
    required DateTime day,
    required MealKind kind,
  }) => database.transaction(() async {
    RationEntry.validateGrams(grams);
    final owner = await userId();
    final old = id == null
        ? null
        : await (database.select(
            database.nutritionEntries,
          )..where((e) => e.id.equals(id))).getSingleOrNull();
    if (id != null &&
        (old == null || old.userId != owner || old.deletedAt != null)) {
      throw StateError('Запись недоступна.');
    }
    // Keep snapshot when changing grams/date/kind, even if the catalog item was deleted.
    final snapshot = old != null && old.productId == productId
        ? Product(
            id: productId,
            name: old.productName,
            calories: old.calories,
            protein: old.protein,
            fat: old.fat,
            carbs: old.carbs,
          )
        : await product(productId);
    if (snapshot == null) throw StateError('Выберите доступный продукт.');
    final meal = await _meal(owner, day, kind);
    final entryId = id ?? _uuid.v4();
    final revision = (old?.localRevision ?? 0) + 1;
    await database
        .into(database.nutritionEntries)
        .insertOnConflictUpdate(
          NutritionEntriesCompanion.insert(
            id: entryId,
            userId: owner,
            mealId: meal.id,
            productId: productId,
            grams: grams,
            productName: snapshot.name,
            calories: snapshot.calories,
            protein: snapshot.protein,
            fat: snapshot.fat,
            carbs: snapshot.carbs,
            updatedAt: DateTime.now().toUtc(),
            localRevision: Value(revision),
            serverVersion: Value(old?.serverVersion ?? 0),
          ),
        );
    await _enqueue(
      owner,
      'entry',
      entryId,
      'upsert',
      revision,
      old?.serverVersion ?? 0,
      {
        'mealId': meal.id,
        'productId': productId,
        'grams': grams,
        'snapshot': snapshot.toMap(),
      },
    );
  });

  Future<void> deleteEntry(String id) => database.transaction(() async {
    final owner = await userId();
    final row =
        await (database.select(database.nutritionEntries)..where(
              (e) =>
                  e.id.equals(id) &
                  e.userId.equals(owner) &
                  e.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (row == null) throw StateError('Запись недоступна.');
    final now = DateTime.now().toUtc();
    await (database.update(
      database.nutritionEntries,
    )..where((e) => e.id.equals(id))).write(
      NutritionEntriesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        localRevision: Value(row.localRevision + 1),
      ),
    );
    await _enqueue(
      owner,
      'entry',
      id,
      'delete',
      row.localRevision + 1,
      row.serverVersion,
      {},
    );
  });

  Future<void> deleteMeal(String id) => database.transaction(() async {
    final owner = await userId();
    final row =
        await (database.select(database.nutritionMeals)..where(
              (m) =>
                  m.id.equals(id) &
                  m.userId.equals(owner) &
                  m.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (row == null) throw StateError('Приём пищи недоступен.');
    final entries =
        await (database.select(database.nutritionEntries)..where(
              (e) =>
                  e.mealId.equals(id) &
                  e.userId.equals(owner) &
                  e.deletedAt.isNull(),
            ))
            .get();
    for (final entry in entries) {
      await deleteEntry(entry.id);
    }
    final now = DateTime.now().toUtc();
    await (database.update(
      database.nutritionMeals,
    )..where((m) => m.id.equals(id))).write(
      NutritionMealsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        localRevision: Value(row.localRevision + 1),
      ),
    );
    await _enqueue(
      owner,
      'meal',
      id,
      'delete',
      row.localRevision + 1,
      row.serverVersion,
      {},
    );
  });

  Future<List<DailyRation>> days(DateTime start, int count) async {
    if (count < 1 || count > 366) throw ArgumentError('Допустимо 1–366 дней.');
    _validateDay(start);
    final end = DateTime(start.year, start.month, start.day + count);
    final owner = await userId();
    // Two bounded queries avoid one query per meal or per entry.
    final meals =
        await (database.select(database.nutritionMeals)..where(
              (m) =>
                  m.userId.equals(owner) &
                  m.deletedAt.isNull() &
                  m.day.isBiggerOrEqualValue(nutritionDay(start)) &
                  m.day.isSmallerThanValue(nutritionDay(end)),
            ))
            .get();
    final ids = meals.map((m) => m.id).toList();
    final entries = ids.isEmpty
        ? <NutritionEntry>[]
        : await (database.select(database.nutritionEntries)
                ..where(
                  (e) =>
                      e.userId.equals(owner) &
                      e.mealId.isIn(ids) &
                      e.deletedAt.isNull(),
                )
                ..orderBy([
                  (e) => OrderingTerm.asc(e.updatedAt),
                  (e) => OrderingTerm.asc(e.id),
                ]))
              .get();
    return List.generate(count, (i) {
      final day = DateTime(start.year, start.month, start.day + i);
      final dayMeals = meals.where((m) => m.day == nutritionDay(day)).toList()
        ..sort(
          (a, b) => MealKind.values
              .byName(a.kind)
              .index
              .compareTo(MealKind.values.byName(b.kind).index),
        );
      return DailyRation(
        day: day,
        meals: dayMeals
            .map(
              (m) => Meal(
                id: m.id,
                day: day,
                kind: MealKind.values.byName(m.kind),
                entries: entries
                    .where((e) => e.mealId == m.id)
                    .map(
                      (e) => RationEntry(
                        id: e.id,
                        mealId: m.id,
                        grams: e.grams,
                        product: Product(
                          id: e.productId,
                          name: e.productName,
                          calories: e.calories,
                          protein: e.protein,
                          fat: e.fat,
                          carbs: e.carbs,
                        ),
                      ),
                    )
                    .toList(),
              ),
            )
            .toList(),
      );
    });
  }
}
