import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/db/app_database.dart';
import 'data/profile_repository.dart';
import 'services/profile_controller.dart';
import 'services/reminder_service.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/nutrition/nutrition_screen.dart';
import 'screens/workouts/workouts_screen.dart';
import 'screens/goals/goals_screen.dart';
import 'screens/achievements/achievements_screen.dart';

void main() {
  runApp(const FitnessAssistantApp());
}

class FitnessAssistantApp extends StatefulWidget {
  const FitnessAssistantApp({super.key, this.profileController});
  final ProfileController? profileController;

  @override
  State<FitnessAssistantApp> createState() => _FitnessAssistantAppState();
}

class _FitnessAssistantAppState extends State<FitnessAssistantApp>
    with WidgetsBindingObserver {
  AppDatabase? _database;
  late final ProfileController _profile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _profile =
        widget.profileController ??
        ProfileController(
          ProfileRepository(_database = AppDatabase()),
          LocalReminderService(),
        );
    _profile.load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _profile.reconcileReminders();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.profileController == null) _profile.dispose();
    _database?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _profile,
      child: MaterialApp(
        title: 'Фитнес-помощник',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ru'),
        supportedLocales: const [Locale('ru')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        home: const RootScreen(),
      ),
    );
  }
}

/// Корневой экран с нижней навигацией между основными модулями приложения.
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;

  final _screens = const [
    NutritionScreen(),
    WorkoutsScreen(),
    GoalsScreen(),
    AchievementsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.restaurant), label: 'КБЖУ'),
          NavigationDestination(
            icon: Icon(Icons.fitness_center),
            label: 'Тренировки',
          ),
          NavigationDestination(icon: Icon(Icons.flag), label: 'Цели'),
          NavigationDestination(
            icon: Icon(Icons.emoji_events),
            label: 'Достижения',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
