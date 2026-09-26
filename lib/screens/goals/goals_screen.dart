import 'package:flutter/material.dart';
import '../../models/goal.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Цели')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: GoalType.values.map((type) {
          final goal = Goal(type: type, startDate: DateTime.now());
          return Card(
            child: ListTile(
              title: Text(goal.label),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: выбор цели пользователем, сохранение в профиль
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
