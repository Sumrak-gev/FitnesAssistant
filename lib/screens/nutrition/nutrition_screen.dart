import 'package:flutter/material.dart';
import '../../services/nutrition_service.dart';
import '../../models/goal.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = NutritionService();
    // Пример расчёта — реальные данные пользователя подключить позже.
    final norm = service.calculateNorm(
      weightKg: 75,
      heightCm: 178,
      age: 22,
      isMale: true,
      goal: GoalType.maintenance,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('КБЖУ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Дневная норма (пример):', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Text('Калории: ${norm.calories.toStringAsFixed(0)} ккал'),
            Text('Белки: ${norm.protein.toStringAsFixed(0)} г'),
            Text('Жиры: ${norm.fat.toStringAsFixed(0)} г'),
            Text('Углеводы: ${norm.carbs.toStringAsFixed(0)} г'),
            const SizedBox(height: 24),
            const Text(
              'TODO: дневник питания, выбор продуктов, толерантный режим (недельный баланс).',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
