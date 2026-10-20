import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:fitness_assistant/core/api/api_client.dart';
import 'package:fitness_assistant/core/db/app_database.dart';
import 'package:fitness_assistant/core/sync/sync_engine.dart';
import 'package:fitness_assistant/data/fitness_repository.dart';
import 'package:fitness_assistant/data/nutrition_repository.dart';
import 'package:fitness_assistant/data/profile_repository.dart';
import 'package:fitness_assistant/data/progress_repository.dart';
import 'package:fitness_assistant/data/workout_repository.dart';
import 'package:fitness_assistant/models/daily_ration.dart';
import 'package:fitness_assistant/models/product.dart';
import 'package:fitness_assistant/models/user_profile.dart';
import 'support/memory_token_store.dart';

class DropResponseClient extends http.BaseClient {
  final _inner = http.Client();
  bool dropNextPush = false;
  Future<void> Function()? afterNextPush;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _inner.send(request);
    if (request.url.path == '/sync/push' && afterNextPush != null) {
      final callback = afterNextPush!;
      afterNextPush = null;
      await callback();
    }
    if (request.url.path == '/sync/push' && dropNextPush) {
      dropNextPush = false;
      await response.stream.drain<void>();
      throw http.ClientException(
        'Simulated connection loss after server commit',
      );
    }
    return response;
  }

  @override
  void close() => _inner.close();
}

void main() {
  final url = Platform.environment['TEST_API_URL'];
  test(
    'Drift offline -> real API -> second device; lost ack, conflicts and meal merge',
    () async {
      final a = AppDatabase(NativeDatabase.memory()),
          b = AppDatabase(NativeDatabase.memory());
      final transport = DropResponseClient();
      final apiA = ApiClient(
        baseUrl: url,
        store: MemoryTokenStore(),
        client: transport,
      );
      final apiB = ApiClient(baseUrl: url, store: MemoryTokenStore());
      SyncEngine? engineA, engineB;
      try {
        final nutritionA = NutritionRepository(a),
            nutritionB = NutritionRepository(b);
        final product = Product(
          id: const Uuid().v4(),
          name: 'Рис',
          calories: 130,
          protein: 2.7,
          fat: .3,
          carbs: 28,
        );
        // Written before authentication and before any request can reach the server.
        await ProfileRepository(a).saveProfile(
          UserProfile(
            name: 'Офлайн',
            sex: ProfileSex.male,
            birthDate: DateTime(2000, 1, 1),
            heightCm: 180,
            weightKg: 80,
          ),
        );
        await nutritionA.saveProduct(product);
        final day = DateTime(2026, 10, 20);
        await nutritionA.saveEntry(
          productId: product.id,
          grams: 125,
          day: day,
          kind: MealKind.lunch,
        );
        await ProgressRepository(a).markWorkout(day);
        final workouts = WorkoutRepository(a);
        await workouts.saveProgram((await workouts.getPrograms()).first);
        expect(await a.select(a.syncOutbox).get(), isNotEmpty);

        final email = '${const Uuid().v4()}@example.com';
        final sessionA = await apiA.authenticate(
          email: email,
          password: 'integration-password-42',
          register: true,
        );
        await FitnessRepository(a).bindAccount(sessionA.userId);
        await apiA.accept(sessionA);
        engineA = SyncEngine(a, apiA);
        await engineA.synchronize();
        expect(engineA.status, 'Синхронизировано');
        expect(await a.select(a.syncOutbox).get(), isEmpty);

        final sessionB = await apiB.authenticate(
          email: email,
          password: 'integration-password-42',
          register: false,
        );
        await FitnessRepository(b).bindAccount(sessionB.userId);
        await apiB.accept(sessionB);
        engineB = SyncEngine(b, apiB);
        await engineB.synchronize();
        expect(engineB.status, 'Синхронизировано');
        expect((await nutritionB.days(day, 1)).single.totals.calories, 162.5);
        expect((await ProfileRepository(b).loadProfile()).name, 'Офлайн');
        expect(
          (await ProgressRepository(b).getLogs()).single.workoutDone,
          isTrue,
        );
        expect(await FitnessRepository(b).rows('achievement'), hasLength(1));
        expect(await workouts.getPrograms(), isNotEmpty);

        // A user can edit the same product while its preceding revision is in flight.
        await nutritionA.saveProduct(
          Product(
            id: product.id,
            name: 'Первая правка',
            calories: 130,
            protein: 2.7,
            fat: .3,
            carbs: 28,
          ),
        );
        transport.afterNextPush = () => nutritionA.saveProduct(
          Product(
            id: product.id,
            name: 'Правка во время отправки',
            calories: 130,
            protein: 2.7,
            fat: .3,
            carbs: 28,
          ),
        );
        await engineA.synchronize();
        expect(engineA.status, 'Синхронизировано');
        expect(await a.select(a.syncOutbox).get(), isEmpty);
        await engineB.synchronize();
        expect(
          (await nutritionB.product(product.id))!.name,
          'Правка во время отправки',
        );

        // A retry after a committed response is lost must not create another version.
        await nutritionA.saveProduct(
          Product(
            id: product.id,
            name: 'Потерянный ответ',
            calories: 130,
            protein: 2.7,
            fat: .3,
            carbs: 28,
          ),
        );
        transport.dropNextPush = true;
        await engineA.synchronize();
        expect(await a.select(a.syncOutbox).get(), hasLength(1));
        await engineA.synchronize();
        expect(engineA.status, 'Синхронизировано');
        expect(await a.select(a.syncOutbox).get(), isEmpty);
        final row = await (a.select(
          a.nutritionProducts,
        )..where((p) => p.id.equals(product.id))).getSingle();
        expect(row.serverVersion, 4);

        // Both devices add to the same previously unseen meal while offline.
        final nextDay = day.add(const Duration(days: 1));
        await nutritionA.saveEntry(
          productId: product.id,
          grams: 100,
          day: nextDay,
          kind: MealKind.dinner,
        );
        await nutritionB.saveEntry(
          productId: product.id,
          grams: 200,
          day: nextDay,
          kind: MealKind.dinner,
        );
        await engineA.synchronize();
        await engineB.synchronize();
        expect(engineB.status, 'Синхронизировано');
        await engineA.synchronize();
        expect((await nutritionA.days(nextDay, 1)).single.totals.calories, 390);
        expect((await nutritionB.days(nextDay, 1)).single.meals, hasLength(1));

        await nutritionA.saveProduct(
          Product(
            id: product.id,
            name: 'Локальная версия',
            calories: 130,
            protein: 2.7,
            fat: .3,
            carbs: 28,
          ),
        );
        await nutritionB.saveProduct(
          Product(
            id: product.id,
            name: 'Серверная версия',
            calories: 130,
            protein: 2.7,
            fat: .3,
            carbs: 28,
          ),
        );
        await engineB.synchronize();
        await engineA.synchronize();
        expect(engineA.conflict, isNotNull);
        await engineA.resolveConflict(keepLocal: true);
        await engineA.synchronize();
        expect(engineA.status, 'Синхронизировано');
        await engineB.synchronize();
        expect(
          (await nutritionB.product(product.id))!.name,
          'Локальная версия',
        );
        await expectLater(
          FitnessRepository(a).bindAccount(const Uuid().v4()),
          throwsStateError,
        );
        expect(await a.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
        expect(await b.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
      } finally {
        engineA?.dispose();
        engineB?.dispose();
        apiA.dispose();
        apiB.dispose();
        await a.close();
        await b.close();
      }
    },
    skip: url == null
        ? 'Set TEST_API_URL to isolated real API (fitness_test)'
        : false,
  );
}
