import '../core/db/app_database.dart';
import '../models/product.dart';
import 'nutrition_repository.dart';

class ProductRepository {
  ProductRepository(AppDatabase database)
    : _nutrition = NutritionRepository(database);
  final NutritionRepository _nutrition;
  Future<List<Product>> getAll() => _nutrition.products();
  Future<Product?> findById(String id) => _nutrition.product(id);
}
