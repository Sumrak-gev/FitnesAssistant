// ignore_for_file: recursive_getters
import 'package:drift/drift.dart';
import 'sync_tables.dart';

@TableIndex.sql(
  'CREATE INDEX nutrition_products_owner_name ON nutrition_products(user_id, deleted_at, name)',
)
class NutritionProducts extends Table with SyncMetadata {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  RealColumn get calories => real().check(calories.isBetweenValues(0, 900))();
  RealColumn get protein => real().check(protein.isBetweenValues(0, 100.1))();
  RealColumn get fat => real().check(fat.isBetweenValues(0, 100.1))();
  RealColumn get carbs => real().check(carbs.isBetweenValues(0, 100.1))();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Set<Column>> get uniqueKeys => [
    {id, userId},
  ];
  @override
  List<String> get customConstraints => [
    'CHECK (protein + fat + carbs <= 100.1)',
    "CHECK (length(trim(name)) > 0)",
  ];
}

@TableIndex.sql(
  'CREATE INDEX nutrition_meals_owner_day ON nutrition_meals(user_id, day, deleted_at)',
)
class NutritionMeals extends Table with SyncMetadata {
  TextColumn get id => text()();
  TextColumn get day => text().withLength(min: 10, max: 10)();
  TextColumn get kind =>
      text().check(kind.isIn(['breakfast', 'lunch', 'dinner', 'snack']))();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Set<Column>> get uniqueKeys => [
    {id, userId},
    {userId, day, kind},
  ];
}

@TableIndex.sql(
  'CREATE INDEX nutrition_entries_meal ON nutrition_entries(user_id, meal_id, deleted_at)',
)
@TableIndex.sql(
  'CREATE INDEX nutrition_entries_product ON nutrition_entries(user_id, product_id)',
)
class NutritionEntries extends Table with SyncMetadata {
  TextColumn get id => text()();
  TextColumn get mealId => text()();
  TextColumn get productId => text()();
  RealColumn get grams => real().check(
    grams.isBiggerThanValue(0) & grams.isSmallerOrEqualValue(10000),
  )();
  TextColumn get productName => text().withLength(min: 1, max: 120)();
  RealColumn get calories => real().check(calories.isBetweenValues(0, 900))();
  RealColumn get protein => real().check(protein.isBetweenValues(0, 100.1))();
  RealColumn get fat => real().check(fat.isBetweenValues(0, 100.1))();
  RealColumn get carbs => real().check(carbs.isBetweenValues(0, 100.1))();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (meal_id, user_id) REFERENCES nutrition_meals(id, user_id)',
    'FOREIGN KEY (product_id, user_id) REFERENCES nutrition_products(id, user_id)',
    'CHECK (protein + fat + carbs <= 100.1)',
  ];
}
