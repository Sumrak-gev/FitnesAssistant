import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/workout_repository.dart';
import '../../core/db/app_database.dart';
import '../../models/goal.dart';
import '../../models/program.dart';
import '../../services/profile_controller.dart';
import 'legal_screen.dart';
import 'profile_edit_screen.dart';
import 'reminder_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final Future<List<Program>> _programs = WorkoutRepository(
    context.read<AppDatabase>(),
  ).getPrograms();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();
    final profile = controller.profile;
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: controller.loadError != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(controller.loadError!),
                  TextButton(
                    onPressed: controller.busy ? null : controller.load,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            )
          : !controller.loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          child: Icon(Icons.person_outline, size: 32),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          profile.name.isEmpty ? 'Ваш профиль' : profile.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          profile.birthDate == null
                              ? 'Добавьте личные данные, чтобы настроить профиль.'
                              : 'Дата рождения: ${formatProfileDate(profile.birthDate!)}',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Рост: ${_measure(profile.heightCm, 'см')} · Вес: ${_measure(profile.weightKg, 'кг')}',
                        ),
                        Text('Пол: ${profile.sex.label}'),
                        Text('Активность: ${profile.activity.label}'),
                        const SizedBox(height: 12),
                        FilledButton.tonalIcon(
                          onPressed: controller.busy
                              ? null
                              : () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        ProfileEditScreen(initial: profile),
                                  ),
                                ),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Редактировать профиль'),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.flag_outlined),
                        title: const Text('Фитнес-цель'),
                        subtitle: Text(
                          Goal(
                            type: profile.goal,
                            startDate: DateTime.now(),
                          ).label,
                        ),
                      ),
                      if (profile.targetWeightKg != null)
                        ListTile(
                          title: const Text('Целевой вес'),
                          subtitle: Text(
                            _measure(profile.targetWeightKg, 'кг'),
                          ),
                        ),
                      FutureBuilder<List<Program>>(
                        future: _programs,
                        builder: (context, snapshot) {
                          final matches = snapshot.data?.where(
                            (p) => p.id == profile.programId,
                          );
                          final title = profile.programId == null
                              ? 'Не выбрана'
                              : matches != null && matches.isNotEmpty
                              ? matches.first.title
                              : 'Программа недоступна';
                          return ListTile(
                            leading: const Icon(Icons.fitness_center),
                            title: const Text('Выбранная программа'),
                            subtitle: Text(title),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('Уведомления'),
                    subtitle: Text(controller.reminders.frequency.label),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ReminderSettingsScreen(),
                      ),
                    ),
                  ),
                ),
                if (controller.reminderWarning != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      controller.reminderWarning!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Профиль хранится на этом устройстве и доступен без интернета.',
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      for (final document in LegalDocument.values)
                        ListTile(
                          title: Text(document.title),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => LegalScreen(document: document),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  String _measure(double? value, String unit) =>
      value == null ? 'не указан' : '$value $unit';
}
