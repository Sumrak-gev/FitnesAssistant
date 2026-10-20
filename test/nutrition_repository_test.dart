import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';
import 'package:fitness_assistant/core/db/app_database.dart';
import 'package:fitness_assistant/core/sync/sync_writer.dart';
import 'package:fitness_assistant/data/nutrition_repository.dart';
import 'package:fitness_assistant/data/profile_repository.dart';
import 'package:fitness_assistant/models/daily_ration.dart';
import 'package:fitness_assistant/models/product.dart';
import 'package:fitness_assistant/models/user_profile.dart';

void main() {
  late AppDatabase db;
  late NutritionRepository repo;
  late Product product;
  final monday = DateTime(2026, 12, 28);
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = NutritionRepository(db);
    product = Product(
      id: const Uuid().v4(),
      name: 'Рис',
      calories: 130,
      protein: 2.7,
      fat: .3,
      carbs: 28,
    );
  });
  tearDown(() => db.close());

  test(
    'CRUD, snapshots, date moves, soft deletion and outbox stay atomic',
    () async {
      await repo.saveProduct(product);
      await repo.saveEntry(
        productId: product.id,
        grams: 125,
        day: monday,
        kind: MealKind.lunch,
      );
      var week = await repo.days(monday, 7);
      var entry = week.first.meals.single.entries.single;
      expect(week, hasLength(7));
      expect(week.last.day, DateTime(2027, 1, 3));
      expect(week.first.totals.calories, 162.5);
      await repo.saveProduct(
        Product(
          id: product.id,
          name: 'Изменённый рис',
          calories: 300,
          protein: 10,
          fat: 1,
          carbs: 60,
        ),
      );
      expect((await repo.days(monday, 1)).single.totals.calories, 162.5);
      await repo.deleteProduct(product.id);
      expect(await repo.products(), isEmpty);
      await repo.saveEntry(
        id: entry.id,
        productId: product.id,
        grams: 200,
        day: DateTime(2027, 1, 1),
        kind: MealKind.dinner,
      );
      week = await repo.days(monday, 7);
      expect(week.first.entryCount, 0);
      expect(week[4].totals.calories, 260);
      entry = week[4].meals.single.entries.single;
      expect(entry.product.name, 'Рис');
      await repo.deleteEntry(entry.id);
      expect(
        (await repo.days(monday, 7)).map((d) => d.entryCount),
        everyElement(0),
      );
      final queue = await db.select(db.syncOutbox).get();
      expect(queue.last.operation, 'delete');
      expect(jsonDecode(queue.last.payload)['data'], isNull);
      expect(queue.map((e) => e.mutationId).toSet().length, queue.length);
      final count = queue.length;
      await expectLater(
        repo.saveEntry(
          productId: product.id,
          grams: 100,
          day: monday,
          kind: MealKind.snack,
        ),
        throwsStateError,
      );
      expect(await db.select(db.syncOutbox).get(), hasLength(count));
    },
  );

  test(
    'Delete meal cascades tombstones; recreating same slot never restores old entries',
    () async {
      await repo.saveProduct(product);
      for (var i = 0; i < 2; i++) {
        await repo.saveEntry(
          productId: product.id,
          grams: 100,
          day: monday,
          kind: MealKind.breakfast,
        );
      }
      final old = (await repo.days(monday, 1)).single.meals.single;
      await repo.deleteMeal(old.id);
      expect((await repo.days(monday, 1)).single.entryCount, 0);
      await repo.saveEntry(
        productId: product.id,
        grams: 10,
        day: monday,
        kind: MealKind.breakfast,
      );
      final current = (await repo.days(monday, 1)).single.meals.single;
      expect(current.id, old.id);
      expect(current.entries, hasLength(1));
      expect(current.totals.calories, 13);
    },
  );

  test(
    'Owner checks and composite foreign keys block cross-user data',
    () async {
      await repo.saveProduct(product);
      await repo.saveEntry(
        productId: product.id,
        grams: 100,
        day: monday,
        kind: MealKind.lunch,
      );
      final foreign = NutritionRepository(db, accountId: const Uuid().v4());
      expect(await foreign.products(), isEmpty);
      expect((await foreign.days(monday, 1)).single.entryCount, 0);
      await expectLater(foreign.deleteProduct(product.id), throwsStateError);
      await expectLater(
        foreign.saveEntry(
          productId: product.id,
          grams: 100,
          day: monday,
          kind: MealKind.lunch,
        ),
        throwsStateError,
      );
      final other = Product(
        id: const Uuid().v4(),
        name: 'Вода',
        calories: 0,
        protein: 0,
        fat: 0,
        carbs: 0,
      );
      await foreign.saveProduct(other);
      await foreign.saveEntry(
        productId: other.id,
        grams: 100,
        day: monday,
        kind: MealKind.dinner,
      );
      final foreignMeal = (await foreign.days(monday, 1)).single.meals.single;
      await expectLater(
        db
            .into(db.nutritionEntries)
            .insert(
              NutritionEntriesCompanion.insert(
                id: const Uuid().v4(),
                userId: await repo.userId(),
                mealId: foreignMeal.id,
                productId: product.id,
                grams: 100,
                productName: 'Рис',
                calories: 130,
                protein: 2.7,
                fat: .3,
                carbs: 28,
                updatedAt: DateTime.now(),
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    },
  );

  test('Invalid input never leaves partial meals or outbox records', () async {
    await repo.saveProduct(product);
    final queueCount = (await db.select(db.syncOutbox).get()).length;
    for (final grams in [0.0, -1.0, double.nan, double.infinity, 10001.0]) {
      await expectLater(
        repo.saveEntry(
          productId: product.id,
          grams: grams,
          day: monday,
          kind: MealKind.lunch,
        ),
        throwsArgumentError,
      );
    }
    await expectLater(
      repo.saveEntry(
        productId: product.id,
        grams: 100,
        day: DateTime(2200),
        kind: MealKind.lunch,
      ),
      throwsArgumentError,
    );
    expect(await db.select(db.nutritionMeals).get(), isEmpty);
    expect(await db.select(db.syncOutbox).get(), hasLength(queueCount));
    expect(
      () => const Product(
        id: 'p',
        name: ' ',
        calories: 0,
        protein: 0,
        fat: 0,
        carbs: 0,
      ).validate(),
      throwsArgumentError,
    );
  });

  test(
    'Local identity is stable and linked when a previously empty profile is saved',
    () async {
      final first = await repo.userId();
      expect(await NutritionRepository(db).userId(), first);
      await ProfileRepository(db).saveProfile(const UserProfile(name: 'Денис'));
      expect((await db.select(db.syncUsers).getSingle()).profileId, 1);
    },
  );

  test('File reopen preserves products, grams, snapshots and outbox', () async {
    await db.close();
    final dir = await Directory.systemTemp.createTemp('nutrition_persist_');
    final file = File('${dir.path}/fitness.sqlite');
    var disk = AppDatabase(NativeDatabase(file));
    try {
      var repository = NutritionRepository(disk);
      await repository.saveProduct(product);
      await repository.saveEntry(
        productId: product.id,
        grams: 12.5,
        day: monday,
        kind: MealKind.snack,
      );
      final user = await repository.userId();
      await disk.close();
      disk = AppDatabase(NativeDatabase(file));
      repository = NutritionRepository(disk);
      expect(await repository.userId(), user);
      expect((await repository.days(monday, 1)).single.totals.calories, 16.25);
      expect(await disk.select(disk.syncOutbox).get(), hasLength(3));
    } finally {
      await disk.close();
      await dir.delete(recursive: true);
    }
  });

  test(
    'Real schema v1 file migrates to v2 without losing profile or reminder',
    () async {
      await db.close();
      final dir = await Directory.systemTemp.createTemp('nutrition_migration_');
      final file = File('${dir.path}/fitness.sqlite');
      final legacy = sqlite3.open(file.path);
      legacy.execute(
        'CREATE TABLE local_profiles (id INTEGER NOT NULL PRIMARY KEY CHECK(id=1), name TEXT NOT NULL, birth_date INTEGER, sex TEXT NOT NULL, height_cm REAL, weight_kg REAL, target_weight_kg REAL, activity TEXT NOT NULL, goal TEXT NOT NULL, program_id TEXT, updated_at INTEGER NOT NULL)',
      );
      legacy.execute(
        'CREATE TABLE local_reminders (id INTEGER NOT NULL PRIMARY KEY CHECK(id=1), frequency TEXT NOT NULL, hour INTEGER NOT NULL, minute INTEGER NOT NULL, weekday INTEGER NOT NULL, month_day INTEGER NOT NULL)',
      );
      legacy.execute(
        "INSERT INTO local_profiles VALUES(1,'Денис',NULL,'male',180,80,75,'active','weightLoss','p1',1700000000)",
      );
      legacy.execute(
        "INSERT INTO local_reminders VALUES(1,'weekly',18,30,3,1)",
      );
      legacy.execute('PRAGMA user_version=1');
      legacy.close();
      final migrated = AppDatabase(NativeDatabase(file));
      try {
        expect((await ProfileRepository(migrated).loadProfile()).name, 'Денис');
        expect((await ProfileRepository(migrated).loadReminders()).hour, 18);
        await NutritionRepository(migrated).saveProduct(product);
        expect(
          await migrated.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty,
        );
        expect(
          (await migrated.customSelect('PRAGMA user_version').getSingle())
              .read<int>('user_version'),
          4,
        );
        final indexes = await migrated
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type='index' AND name='nutrition_meals_owner_day'",
            )
            .get();
        expect(indexes, hasLength(1));
      } finally {
        await migrated.close();
        await dir.delete(recursive: true);
      }
    },
  );

  test(
    'Outbox is shared: other modules enqueue, nutrition ignores them',
    () async {
      final sync = SyncWriter(db);
      final owner = await sync.userId();
      await sync.enqueue(
        owner: owner,
        entity: 'workout_session',
        id: const Uuid().v4(),
        operation: 'upsert',
        revision: 1,
        baseVersion: 0,
        data: {'title': 'Ноги'},
      );
      expect(await db.select(db.syncOutbox).get(), hasLength(1));
      expect(await NutritionRepository(db).pendingMutations(), isEmpty);
    },
  );

  test('Real schema v2 file migrates to v3 keeping the outbox queue', () async {
    await db.close();
    final dir = await Directory.systemTemp.createTemp('outbox_migration_');
    final file = File('${dir.path}/fitness.sqlite');
    final legacy = sqlite3.open(file.path);
    legacy.execute(
      'CREATE TABLE local_profiles (id INTEGER NOT NULL PRIMARY KEY CHECK(id=1), name TEXT NOT NULL, birth_date INTEGER, sex TEXT NOT NULL, height_cm REAL, weight_kg REAL, target_weight_kg REAL, activity TEXT NOT NULL, goal TEXT NOT NULL, program_id TEXT, updated_at INTEGER NOT NULL)',
    );
    legacy.execute(
      'CREATE TABLE nutrition_users (id TEXT NOT NULL PRIMARY KEY, local_slot INTEGER CHECK(local_slot=1), profile_id INTEGER REFERENCES local_profiles(id) ON DELETE SET NULL)',
    );
    legacy.execute(
      "CREATE TABLE nutrition_outbox (sequence INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, mutation_id TEXT NOT NULL UNIQUE, user_id TEXT NOT NULL REFERENCES nutrition_users(id), entity TEXT NOT NULL CHECK(entity IN ('product','meal','entry')), entity_id TEXT NOT NULL, operation TEXT NOT NULL CHECK(operation IN ('upsert','delete')), payload TEXT NOT NULL, created_at INTEGER NOT NULL)",
    );
    legacy.execute(
      'CREATE INDEX nutrition_outbox_order ON nutrition_outbox(sequence)',
    );
    legacy.execute("INSERT INTO nutrition_users VALUES('u1',1,NULL)");
    legacy.execute(
      "INSERT INTO nutrition_outbox VALUES(1,'m1','u1','product','p1','upsert','{}',1700000000)",
    );
    legacy.execute('PRAGMA user_version=2');
    legacy.close();
    final migrated = AppDatabase(NativeDatabase(file));
    try {
      expect(await migrated.select(migrated.syncOutbox).get(), hasLength(1));
      await SyncWriter(migrated).enqueue(
        owner: 'u1',
        entity: 'workout_session',
        id: const Uuid().v4(),
        operation: 'delete',
        revision: 2,
        baseVersion: 1,
      );
      expect(await migrated.select(migrated.syncOutbox).get(), hasLength(2));
      expect(
        await migrated.customSelect('PRAGMA foreign_key_check').get(),
        isEmpty,
      );
      final indexes = await migrated
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='index' AND name='nutrition_outbox_order'",
          )
          .get();
      expect(indexes, hasLength(1));
    } finally {
      await migrated.close();
      await dir.delete(recursive: true);
    }
  });
}
