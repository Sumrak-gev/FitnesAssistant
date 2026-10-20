import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../core/api/api_client.dart';
import '../core/db/app_database.dart';
import '../models/product.dart';
import 'fitness_repository.dart';
import 'nutrition_repository.dart';

class CatalogRepository {
  CatalogRepository(this.database, this.api);
  final AppDatabase database;
  final ApiClient api;

  Future<int> importProducts(String query) async {
    final rows =
        await api.request(
              'GET',
              '/products?q=${Uri.encodeQueryComponent(query)}&limit=100',
            )
            as List;
    final nutrition = NutritionRepository(database);
    final namespace =
        await FitnessRepository(database).setting('accountId') ??
        await nutrition.userId();
    await database.transaction(() async {
      for (final item in rows) {
        final data = item as Map<String, dynamic>;
        final id = const Uuid().v5(namespace, 'catalog-product:${data['id']}');
        final existing = await (database.select(
          database.nutritionProducts,
        )..where((p) => p.id.equals(id))).getSingleOrNull();
        if (existing != null) continue;
        await nutrition.saveProduct(Product.fromMap({...data, 'id': id}));
        await FitnessRepository(database).setSetting(
          'source:product:$id',
          jsonEncode({
            'sourceUrl': data['sourceUrl'],
            'license': data['license'],
          }),
        );
      }
    });
    return rows.length;
  }

  Future<int> importExercises() async {
    var offset = 0;
    while (offset < 10000) {
      final rows =
          await api.request('GET', '/exercises?offset=$offset&limit=200')
              as List;
      await database.transaction(() async {
        for (final item in rows) {
          final data = item as Map<String, dynamic>;
          await database
              .into(database.exerciseCatalog)
              .insertOnConflictUpdate(
                ExerciseCatalogCompanion.insert(
                  id: data['id'] as String,
                  data: jsonEncode(data),
                ),
              );
        }
      });
      offset += rows.length;
      if (rows.length < 200) break;
    }
    return offset;
  }
}
