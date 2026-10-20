import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_assistant/core/db/app_database.dart';
import 'package:fitness_assistant/data/profile_repository.dart';
import 'package:fitness_assistant/main.dart';
import 'package:fitness_assistant/models/goal.dart';
import 'package:fitness_assistant/models/user_profile.dart';
import 'package:fitness_assistant/screens/profile/legal_screen.dart';
import 'package:fitness_assistant/services/profile_controller.dart';
import 'support/fake_reminders.dart';

void main() {
  late AppDatabase database;
  late ProfileController controller;
  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    controller = ProfileController(
      ProfileRepository(database),
      FakeReminders(),
    );
  });
  tearDown(() async {
    controller.dispose();
    await database.close();
  });

  testWidgets('Navigation, saved profile and shared goal on a phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await controller.repository.saveProfile(
      UserProfile(
        name: 'Денис',
        birthDate: DateTime(2000, 1, 2),
        heightCm: 180,
        weightKg: 80,
        programId: 'p1',
      ),
    );
    await tester.pumpWidget(FitnessAssistantApp(profileController: controller));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationDestination), findsNWidgets(6));
    await tester.tap(find.text('Профиль').last);
    await tester.pumpAndSettle();
    expect(find.text('Денис'), findsOneWidget);
    expect(find.text('Ноги и грудь — базовый уровень'), findsOneWidget);
    await tester.tap(find.text('Цели').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Похудение'));
    await tester.pumpAndSettle();
    expect(
      (await controller.repository.loadProfile()).goal,
      GoalType.weightLoss,
    );
    expect((await controller.repository.loadProfile()).name, 'Денис');
    await tester.tap(find.text('Профиль').last);
    await tester.pumpAndSettle();
    expect(find.text('Похудение'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(); // Flush Drift's zero-delay stream cancellation timer.
  });

  testWidgets('Invalid measurements show errors; decimals with comma persist', (
    tester,
  ) async {
    await controller.repository.saveProfile(
      UserProfile(
        name: 'Денис',
        birthDate: DateTime(2000),
        heightCm: 180,
        weightKg: 80,
      ),
    );
    await tester.pumpWidget(FitnessAssistantApp(profileController: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Профиль').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Редактировать профиль'));
    await tester.pumpAndSettle();
    final weight = find.widgetWithText(TextFormField, 'Вес, кг');
    await tester.enterText(weight, '-10');
    await tester.ensureVisible(find.text('Сохранить профиль'));
    await tester.tap(find.text('Сохранить профиль'));
    await tester.pumpAndSettle();
    expect(find.text('Введите число от 20 до 500'), findsOneWidget);
    await tester.ensureVisible(weight);
    await tester.enterText(weight, '82,5');
    await tester.ensureVisible(find.text('Сохранить профиль'));
    await tester.tap(find.text('Сохранить профиль'));
    await tester.pumpAndSettle();
    expect((await controller.repository.loadProfile()).weightKg, 82.5);
    expect(find.text('Профиль сохранён'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('Empty fields above the scroll position still prevent saving', (
    tester,
  ) async {
    await tester.pumpWidget(FitnessAssistantApp(profileController: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Профиль').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Редактировать профиль'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Сохранить профиль'));
    await tester.tap(find.text('Сохранить профиль'));
    await tester.pumpAndSettle();
    expect(find.text('Введите имя'), findsOneWidget);
    expect(find.text('Выберите дату рождения'), findsOneWidget);
    expect(find.text('Введите число от 50 до 260'), findsOneWidget);
    expect(find.text('Введите число от 20 до 500'), findsOneWidget);
    expect((await database.select(database.localProfiles).get()), isEmpty);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  for (final document in LegalDocument.values) {
    testWidgets('Legal document: ${document.title}', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: LegalScreen(document: document)),
      );
      expect(find.text(document.title), findsOneWidget);
      expect(find.byType(SelectableText), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
