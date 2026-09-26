/// Продукт питания: базовые значения КБЖУ на 100 г.
class Product {
  final String id;
  final String name;
  final double calories; // ккал / 100 г
  final double protein;  // г / 100 г
  final double fat;      // г / 100 г
  final double carbs;    // г / 100 г

  const Product({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'] as String,
        name: map['name'] as String,
        calories: (map['calories'] as num).toDouble(),
        protein: (map['protein'] as num).toDouble(),
        fat: (map['fat'] as num).toDouble(),
        carbs: (map['carbs'] as num).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'calories': calories,
        'protein': protein,
        'fat': fat,
        'carbs': carbs,
      };
}
