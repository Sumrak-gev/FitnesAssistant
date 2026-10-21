import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/workout_repository.dart';
import '../../core/db/app_database.dart';
import '../../core/api/api_client.dart';
import '../../core/sync/sync_engine.dart';
import '../../models/goal.dart';
import '../../models/program.dart';
import '../../services/profile_controller.dart';
import '../../services/theme_controller.dart';
import '../../widgets/israel_flag_icon.dart';
import '../goals/goals_screen.dart';
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
    final appearance = context.watch<ThemeController>();
    final sync = context.watch<SyncEngine?>();
    final api = context.watch<ApiClient?>();
    final profile = controller.profile;
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 22,
                              child: Icon(Icons.person_outline, size: 26),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                profile.name.isEmpty
                                    ? 'Ваш профиль'
                                    : profile.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          profile.birthDate == null
                              ? 'Добавьте личные данные, чтобы настроить профиль.'
                              : 'Рождение: ${formatProfileDate(profile.birthDate!)}',
                        ),
                        Text(
                          'Рост: ${_measure(profile.heightCm, 'см')} · Вес: ${_measure(profile.weightKg, 'кг')}',
                        ),
                        Text(
                          '${profile.sex.label} · ${profile.activity.label}',
                        ),
                        const SizedBox(height: 8),
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
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const GoalsScreen(),
                          ),
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Тема интерфейса',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<ThemeMode>(
                            segments: const [
                              ButtonSegment(
                                value: ThemeMode.system,
                                icon: Icon(Icons.brightness_auto),
                                label: Text('Авто'),
                              ),
                              ButtonSegment(
                                value: ThemeMode.light,
                                icon: Icon(Icons.light_mode),
                                label: Text('День'),
                              ),
                              ButtonSegment(
                                value: ThemeMode.dark,
                                icon: Icon(Icons.dark_mode),
                                label: Text('Ночь'),
                              ),
                            ],
                            selected: {appearance.mode},
                            onSelectionChanged: (value) =>
                                appearance.select(value.single),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Text(
                              'Палитра',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(width: 8),
                            const IsraelFlagIcon(),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<AppPalette>(
                            segments: const [
                              ButtonSegment(
                                value: AppPalette.israel,
                                icon: IsraelFlagIcon(),
                                label: Text('Белый и синий'),
                              ),
                              ButtonSegment(
                                value: AppPalette.mint,
                                icon: Icon(Icons.spa_outlined),
                                label: Text('Мятный'),
                              ),
                            ],
                            selected: {appearance.palette},
                            onSelectionChanged: (value) =>
                                appearance.selectPalette(value.single),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (sync != null)
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.cloud_sync_outlined),
                          title: const Text('Синхронизация'),
                          subtitle: Text(sync.status),
                          trailing: IconButton(
                            tooltip: 'Синхронизировать',
                            onPressed: sync.synchronize,
                            icon: const Icon(Icons.sync),
                          ),
                        ),
                        if (api != null)
                          ListTile(
                            leading: const Icon(Icons.logout),
                            title: const Text('Выйти из аккаунта'),
                            onTap: api.logout,
                          ),
                      ],
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
