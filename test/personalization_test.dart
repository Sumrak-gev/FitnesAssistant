import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fitness_assistant/core/db/app_database.dart';
import 'package:fitness_assistant/data/fitness_repository.dart';
import 'package:fitness_assistant/data/profile_repository.dart';
import 'package:fitness_assistant/models/exercise.dart';
import 'package:fitness_assistant/models/goal.dart';
import 'package:fitness_assistant/models/program.dart';
import 'package:fitness_assistant/screens/goals/goals_screen.dart';
import 'package:fitness_assistant/screens/workouts/program_builder_sheet.dart';
import 'package:fitness_assistant/services/profile_controller.dart';
import 'package:fitness_assistant/services/theme_controller.dart';
import 'package:fitness_assistant/widgets/passport_reward.dart';
import 'support/fake_reminders.dart';

void main() {
  testWidgets(
    'first goal choice persists and theme survives a controller reload',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final profile = ProfileController(ProfileRepository(db), FakeReminders());
      await profile.load();
      var saved = false;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppDatabase>.value(value: db),
            ChangeNotifierProvider<ProfileController>.value(value: profile),
          ],
          child: MaterialApp(
            home: GoalsScreen(onboarding: true, onSaved: () => saved = true),
          ),
        ),
      );
      await tester.tap(find.text('Похудение'));
      await tester.pumpAndSettle();
      expect(saved, isTrue);
      expect(
        (await ProfileRepository(db).loadProfile()).goal,
        GoalType.weightLoss,
      );
      expect(await FitnessRepository(db).setting('goalSelected'), '1');

      final theme = ThemeController(FitnessRepository(db));
      await theme.select(ThemeMode.dark);
      await theme.selectPalette(AppPalette.mint);
      final reloaded = ThemeController(FitnessRepository(db));
      await reloaded.load();
      expect(reloaded.mode, ThemeMode.dark);
      expect(reloaded.palette, AppPalette.mint);
      await tester.pumpWidget(const SizedBox());
      theme.dispose();
      reloaded.dispose();
      profile.dispose();
      await db.close();
    },
  );

  testWidgets('personal plan contains only chosen exercises', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Program? created;
    const exercises = [
      Exercise(
        id: 'squat',
        name: 'Приседания',
        muscleGroup: 'ноги',
        equipment: 'без инвентаря',
      ),
      Exercise(
        id: 'press',
        name: 'Жим',
        muscleGroup: 'грудь',
        equipment: 'гантели',
      ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async =>
                  created = await showModalBottomSheet<Program>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) =>
                        const ProgramBuilderSheet(exercises: exercises),
                  ),
              child: const Text('Открыть'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Открыть'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Название плана').first,
      'Мой день ног',
    );
    await tester.tap(find.text('Приседания'));
    await tester.tap(find.text('Сохранить план'));
    await tester.pumpAndSettle();
    expect(created?.title, 'Мой день ног');
    expect(created?.exercises.map((e) => e.id), ['squat']);
  });

  testWidgets('passport link unlocks at level six', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var opens = 0;
    Widget reward(int level) => MaterialApp(
      home: Scaffold(
        body: PassportReward(level: level, onOpen: () => opens++),
      ),
    );

    await tester.pumpWidget(reward(5));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Получить паспорт Израиля'));
    expect(opens, 0);
    expect(find.text('Откроется на уровне 6 · Силач'), findsOneWidget);

    await tester.pumpWidget(reward(6));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Получить паспорт Израиля'));
    expect(opens, 1);
    expect(find.textContaining('Telegram-канал'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
