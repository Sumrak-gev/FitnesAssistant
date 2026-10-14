import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_assistant/main.dart';

void main() {
  testWidgets('Приложение запускается и показывает четыре вкладки',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FitnessAssistantApp());

    expect(find.text('КБЖУ'), findsWidgets);
    expect(find.text('Тренировки'), findsWidgets);
    expect(find.text('Цели'), findsWidgets);
    expect(find.text('Достижения'), findsWidgets);
  });
}
