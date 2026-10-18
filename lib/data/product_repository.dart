import '../core/db/app_database.dart';
import '../models/product.dart';
import 'nutrition_repository.dart';

/// Catalog facade sharing the same Drift database and ownership as the diary.
class ProductRepository {
  ProductRepository(AppDatabase database)
    : _nutrition = NutritionRepository(database);
  final NutritionRepository _nutrition;
  Future<List<Product>> getAll() => _nutrition.products();
  Future<Product?> findById(String id) => _nutrition.product(id);
  Future<void> save(Product product) => _nutrition.saveProduct(product);
  Future<void> delete(String id) => _nutrition.deleteProduct(id);
}
