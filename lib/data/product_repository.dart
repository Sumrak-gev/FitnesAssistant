import '../models/product.dart';

/// TODO: заменить in-memory реализацию на SQLite (sqflite).
class ProductRepository {
  final List<Product> _products = const [
    Product(id: '1', name: 'Куриная грудка', calories: 165, protein: 31, fat: 3.6, carbs: 0),
    Product(id: '2', name: 'Рис отварной', calories: 130, protein: 2.7, fat: 0.3, carbs: 28),
    Product(id: '3', name: 'Творог 5%', calories: 121, protein: 17, fat: 5, carbs: 3),
  ];

  Future<List<Product>> getAll() async => _products;

  Future<Product?> findById(String id) async {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
