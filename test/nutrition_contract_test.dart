import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_assistant/core/api/nutrition_contract.dart';
import 'package:fitness_assistant/core/db/app_database.dart';
import 'package:fitness_assistant/data/nutrition_repository.dart';
import 'package:fitness_assistant/models/product.dart';
import 'package:fitness_assistant/models/daily_ration.dart';

void main() {
  test(
    'Drift outbox serializes to the shared push envelope, one head per entity',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = NutritionRepository(db);
      try {
        const product = Product(
          id: '11111111-1111-4111-8111-111111111111',
          name: 'Рис отварной',
          calories: 130,
          protein: 2.7,
          fat: .3,
          carbs: 28,
        );
        await repo.saveProduct(product);
        await repo.saveEntry(
          productId: product.id,
          grams: 125,
          day: DateTime(2026, 10, 18),
          kind: MealKind.lunch,
        );
        await repo.saveProduct(
          const Product(
            id: '11111111-1111-4111-8111-111111111111',
            name: 'Новое имя',
            calories: 130,
            protein: 2.7,
            fat: .3,
            carbs: 28,
          ),
        );
        final pending = await repo.pendingMutations();
        expect(pending.map((c) => c.entity), ['product', 'meal', 'entry']);
        expect(pending.first.data!['name'], 'Рис отварной');
        expect(pending.first.data!.containsKey('id'), false);
        final payload = NutritionPushRequest(pending).toJson();
        expect(jsonDecode(jsonEncode(payload)), payload);
        final destination = Platform.environment['NUTRITION_CONTRACT_FIXTURE'];
        if (destination != null) {
          await File(destination).writeAsString(
            '${const JsonEncoder.withIndent('  ').convert(payload)}\n',
          );
        }
        await expectLater(
          repo.pendingMutations(limit: 101),
          throwsArgumentError,
        );
        expect(
          () => NutritionPushRequest([pending.first, pending.first]),
          throwsArgumentError,
        );
        expect(() => NutritionPushRequest([]), throwsArgumentError);
        final bad = {...pending.first.toJson(), 'operation': 'delete'};
        expect(() => NutritionMutation.fromJson(bad), throwsArgumentError);
      } finally {
        await db.close();
      }
    },
  );
}
