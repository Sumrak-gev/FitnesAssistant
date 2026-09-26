import 'package:flutter/material.dart';
import '../../services/achievement_service.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = AchievementService().defaultAchievements();

    return Scaffold(
      appBar: AppBar(title: const Text('Достижения')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final a = achievements[index];
          return ListTile(
            leading: Icon(
              a.unlocked ? Icons.emoji_events : Icons.emoji_events_outlined,
              color: a.unlocked ? Colors.amber : Colors.grey,
            ),
            title: Text(a.title),
            subtitle: Text(a.description),
          );
        },
      ),
    );
  }
}
