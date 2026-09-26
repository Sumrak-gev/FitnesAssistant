import 'package:flutter/material.dart';
import 'screens/nutrition/nutrition_screen.dart';
import 'screens/workouts/workouts_screen.dart';
import 'screens/goals/goals_screen.dart';
import 'screens/achievements/achievements_screen.dart';

void main() {
  runApp(const FitnessAssistantApp());
}

class FitnessAssistantApp extends StatelessWidget {
  const FitnessAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Фитнес-помощник',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const RootScreen(),
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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.restaurant), label: 'КБЖУ'),
          NavigationDestination(icon: Icon(Icons.fitness_center), label: 'Тренировки'),
          NavigationDestination(icon: Icon(Icons.flag), label: 'Цели'),
          NavigationDestination(icon: Icon(Icons.emoji_events), label: 'Достижения'),
        ],
      ),
    );
  }
}
