import 'dart:convert';
import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/db/app_database.dart';
import '../../data/fitness_repository.dart';
import '../../services/achievement_service.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final database = context.read<AppDatabase>();
    final achievements = AchievementService().defaultAchievements();
    return Scaffold(
      appBar: AppBar(title: const Text('Достижения')),
      body: StreamBuilder(
        stream: database.tableUpdates(
          TableUpdateQuery.onTable(database.fitnessRecords),
        ),
        builder: (context, _) => FutureBuilder<List<FitnessRecord>>(
          future: FitnessRepository(database).rows('achievement'),
          builder: (context, snapshot) {
            final unlocked = (snapshot.data ?? [])
                .where((r) => (jsonDecode(r.data) as Map)['unlocked'] == true)
                .map((r) => (jsonDecode(r.data) as Map)['key'])
                .toSet();
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final a = achievements[index];
                return ListTile(
                  leading: Icon(
                    unlocked.contains(a.id)
                        ? Icons.emoji_events
                        : Icons.emoji_events_outlined,
                    color: unlocked.contains(a.id) ? Colors.amber : Colors.grey,
                  ),
                  title: Text(a.title),
                  subtitle: Text(a.description),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
