import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/db/app_database.dart';
import '../../data/fitness_repository.dart';
import '../../models/goal.dart';
import '../../services/profile_controller.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key, this.onboarding = false, this.onSaved});

  final bool onboarding;
  final VoidCallback? onSaved;

  static const _icons = [
    Icons.monitor_weight_outlined,
    Icons.fitness_center,
    Icons.balance_outlined,
    Icons.directions_run,
  ];
  static const _descriptions = [
    'Постепенно снижать вес и следить за питанием',
    'Укреплять мышцы и регулярно тренироваться',
    'Сохранять привычный ритм и баланс',
    'Развивать выносливость и двигаться больше',
  ];

  Future<void> _choose(BuildContext context, GoalType goal) async {
    try {
      await context.read<ProfileController>().selectGoal(goal);
      if (!context.mounted) return;
      await FitnessRepository(
        context.read<AppDatabase>(),
      ).setSetting('goalSelected', '1');
      if (!context.mounted) return;
      if (onSaved != null) {
        onSaved!();
      } else {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось сохранить цель. Повторите попытку.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileController>();
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(onboarding ? 'Первый шаг' : 'Моя цель')),
      body: !profile.loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                Text(
                  onboarding ? 'К чему идём?' : 'Выберите направление',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  onboarding
                      ? 'Цель поможет подобрать ориентир калорий и программы тренировок. Её можно изменить в настройках.'
                      : 'Ориентир калорий обновится после выбора.',
                ),
                const SizedBox(height: 20),
                for (var i = 0; i < GoalType.values.length; i++)
                  Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: profile.busy
                          ? null
                          : () => _choose(context, GoalType.values[i]),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: scheme.primaryContainer,
                              child: Icon(
                                _icons[i],
                                color: scheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Goal(
                                      type: GoalType.values[i],
                                      startDate: DateTime.now(),
                                    ).label,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _descriptions[i],
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            if (!onboarding &&
                                profile.profile.goal == GoalType.values[i])
                              Icon(Icons.check_circle, color: scheme.primary),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
