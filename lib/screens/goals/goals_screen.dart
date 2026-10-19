import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/goal.dart';
import '../../services/profile_controller.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Цели')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: GoalType.values.map((type) {
          final goal = Goal(type: type, startDate: DateTime.now());
          return Card(
            child: ListTile(
              title: Text(goal.label),
              selected: profile.loaded && profile.profile.goal == type,
              trailing: profile.loaded && profile.profile.goal == type
                  ? const Icon(Icons.check_circle)
                  : const Icon(Icons.circle_outlined),
              onTap: !profile.loaded || profile.busy
                  ? null
                  : () async {
                      try {
                        await profile.selectGoal(type);
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Не удалось сохранить цель. Повторите попытку.',
                              ),
                            ),
                          );
                        }
                      }
                    },
            ),
          );
        }).toList(),
      ),
    );
  }
}
