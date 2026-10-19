import 'dart:io';
import 'dart:ui' as ui;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_assistant/core/db/app_database.dart';
import 'package:fitness_assistant/data/nutrition_repository.dart';
import 'package:fitness_assistant/data/profile_repository.dart';
import 'package:fitness_assistant/main.dart';
import 'package:fitness_assistant/models/user_profile.dart';
import 'package:fitness_assistant/services/profile_controller.dart';
import 'support/fake_reminders.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final fonts = Platform.environment['NUTRITION_QA_FONT_DIR'];
    if (fonts == null) return;
    final roboto = FontLoader('Roboto');
    for (final file in [
      'roboto-regular.ttf',
      'roboto-medium.ttf',
      'roboto-bold.ttf',
    ]) {
      roboto.addFont(
        File('$fonts/$file').readAsBytes().then(ByteData.sublistView),
      );
    }
    await roboto.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(
        File(
          '$fonts/materialicons-regular.otf',
        ).readAsBytes().then(ByteData.sublistView),
      );
    await icons.load();
  });
  late AppDatabase db;
  late ProfileController profile;
  late NutritionRepository repo;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = NutritionRepository(db);
    profile = ProfileController(ProfileRepository(db), FakeReminders());
  });
  tearDown(() async {
    profile.dispose();
    await db.close();
  });

  Future<void> launch(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await profile.repository.saveProfile(
      UserProfile(
        name: 'Денис',
        birthDate: DateTime(1996, 1, 1),
        sex: ProfileSex.male,
        heightCm: 180,
        weightKg: 80,
      ),
    );
    await tester.pumpWidget(
      RepaintBoundary(
        key: const Key('capture'),
        child: FitnessAssistantApp(profileController: profile),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> capture(WidgetTester tester, String name) async {
    final dir = Platform.environment['NUTRITION_SCREENSHOT_DIR'];
    if (dir == null) return;
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const Key('capture')),
    );
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await Directory(dir).create(recursive: true);
      await File('$dir/$name.png').writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  testWidgets(
    'Create/edit product, add/edit/delete diary entry; week and other modules remain usable',
    (tester) async {
      await launch(tester);
      expect(
        find.textContaining('Ориентир по текущему профилю'),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Продукты'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Новый продукт'));
      await tester.pumpAndSettle();
      for (final item in {
        'Название продукта': 'Тестовая овсянка',
        'Калории, ккал': '200',
        'Белки, г': '10',
        'Жиры, г': '4,5',
        'Углеводы, г': '30',
      }.entries) {
        await tester.enterText(
          find.widgetWithText(TextFormField, item.key),
          item.value,
        );
      }
      await tester.ensureVisible(find.text('Сохранить продукт'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Сохранить продукт'));
      await tester.pumpAndSettle();
      expect(await repo.products(query: 'овсянка'), hasLength(1));
      await tester.tap(find.text('Тестовая овсянка'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Калории, ккал'),
        '220',
      );
      await tester.ensureVisible(find.text('Сохранить продукт'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Сохранить продукт'));
      await tester.pumpAndSettle();
      expect((await repo.products(query: 'овсянка')).single.calories, 220);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FloatingActionButton, 'Добавить еду'),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(DropdownButtonFormField<String>, 'Продукт'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Тестовая овсянка').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Масса, г'),
        '125,5',
      );
      await tester.ensureVisible(find.text('Сохранить запись'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Сохранить запись'));
      await tester.pumpAndSettle();
      final today = DateTime.now();
      expect(
        (await repo.days(today, 1)).single.totals.calories,
        closeTo(276.1, .0001),
      );
      await capture(tester, 'nutrition-day');
      await tester.ensureVisible(find.text('Тестовая овсянка'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Тестовая овсянка'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Масса, г'),
        '0',
      );
      await tester.ensureVisible(find.text('Сохранить запись'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Сохранить запись'));
      await tester.pumpAndSettle();
      expect(
        find.text('Введите массу больше 0 и не более 10 000 г'),
        findsOneWidget,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Масса, г'),
        '200',
      );
      await tester.ensureVisible(find.text('Сохранить запись'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Сохранить запись'));
      await tester.pumpAndSettle();
      expect((await repo.days(today, 1)).single.totals.calories, 440);
      await tester.drag(find.byType(ListView).first, const Offset(0, 1000));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Неделя'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Сумма за все 7 дней. День без записей не означает, что вы не ели.',
        ),
        findsOneWidget,
      );
      await capture(tester, 'nutrition-week');
      await tester.tap(find.text('День'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('Удалить запись'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Удалить запись'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Удалить').last);
      await tester.pumpAndSettle();
      expect((await repo.days(today, 1)).single.entryCount, 0);
      await tester.tap(find.text('Тренировки').last);
      await tester.pumpAndSettle();
      expect(find.text('Ноги и грудь — базовый уровень'), findsOneWidget);
      await tester.tap(find.text('Достижения').last);
      await tester.pumpAndSettle();
      expect(find.text('Первая неделя'), findsOneWidget);
      await tester.tap(find.text('Профиль').last);
      await tester.pumpAndSettle();
      expect(find.text('Денис'), findsOneWidget);
      await tester.ensureVisible(find.text('Уведомления'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Уведомления'));
      await tester.pumpAndSettle();
      expect(find.text('Применить настройки'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'Missing profile hides targets, products are still usable; invalid macros rejected',
    (tester) async {
      await tester.pumpWidget(FitnessAssistantApp(profileController: profile));
      await tester.pumpAndSettle();
      expect(find.text('Заполнить профиль'), findsOneWidget);
      await tester.tap(find.byTooltip('Продукты'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Новый продукт'));
      await tester.pumpAndSettle();
      for (final item in {
        'Название продукта': 'Ошибка',
        'Калории, ккал': '200',
        'Белки, г': '80',
        'Жиры, г': '40',
        'Углеводы, г': '0',
      }.entries) {
        await tester.enterText(
          find.widgetWithText(TextFormField, item.key),
          item.value,
        );
      }
      await tester.ensureVisible(find.text('Сохранить продукт'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Сохранить продукт'));
      await tester.pumpAndSettle();
      expect(find.textContaining('БЖУ суммарно'), findsOneWidget);
      expect(await repo.products(query: 'Ошибка'), isEmpty);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
