# Фитнес-помощник

Мобильное приложение (Flutter): расчёт КБЖУ, тренировочные программы с заменой упражнений, система целей и достижений.

## Стек
- Flutter (Dart)
- Provider — состояние
- sqflite — локальная БД
- flutter_local_notifications — уведомления

## Структура
```
lib/
├── main.dart
├── models/       # Product, Exercise, Program, Goal, Achievement
├── services/     # бизнес-логика (КБЖУ, тренировки, достижения)
├── data/         # репозитории (заглушка над локальной БД)
├── screens/      # экраны по модулям
└── widgets/      # переиспользуемые компоненты
```

## Запуск
```
flutter pub get
flutter run
```
