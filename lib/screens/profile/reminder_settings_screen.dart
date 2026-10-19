import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/reminder_settings.dart';
import '../../services/profile_controller.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});
  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  late ReminderFrequency _frequency;
  late TimeOfDay _time;
  late int _weekday;
  late int _monthDay;
  static const _days = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье',
  ];

  @override
  void initState() {
    super.initState();
    final value = context.read<ProfileController>().reminders;
    _frequency = value.frequency;
    _time = TimeOfDay(hour: value.hour, minute: value.minute);
    _weekday = value.weekday;
    _monthDay = value.monthDay;
  }

  Future<void> _save() async {
    final controller = context.read<ProfileController>();
    try {
      await controller.saveReminders(
        ReminderSettings(
          frequency: _frequency,
          hour: _time.hour,
          minute: _time.minute,
          weekday: _weekday,
          monthDay: _monthDay,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.reminderWarning ??
                (_frequency == ReminderFrequency.off
                    ? 'Уведомления отключены'
                    : 'Напоминание запланировано'),
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось сохранить настройки. Повторите попытку.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Уведомления')),
      body: AbsorbPointer(
        absorbing: controller.busy,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Напоминания необязательны. Выберите удобный ритм или отключите их.',
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<ReminderFrequency>(
              initialValue: _frequency,
              decoration: const InputDecoration(labelText: 'Частота'),
              items: ReminderFrequency.values
                  .map((v) => DropdownMenuItem(value: v, child: Text(v.label)))
                  .toList(),
              onChanged: (v) => setState(() => _frequency = v!),
            ),
            if (_frequency != ReminderFrequency.off) ...[
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Время на устройстве'),
                subtitle: Text(_time.format(context)),
                trailing: const Icon(Icons.schedule),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _time,
                  );
                  if (time != null && mounted) setState(() => _time = time);
                },
              ),
            ],
            if (_frequency == ReminderFrequency.weekly)
              DropdownButtonFormField<int>(
                initialValue: _weekday,
                decoration: const InputDecoration(labelText: 'День недели'),
                items: List.generate(
                  7,
                  (i) => DropdownMenuItem(value: i + 1, child: Text(_days[i])),
                ),
                onChanged: (v) => setState(() => _weekday = v!),
              ),
            if (_frequency == ReminderFrequency.monthly) ...[
              DropdownButtonFormField<int>(
                initialValue: _monthDay,
                decoration: const InputDecoration(labelText: 'День месяца'),
                items: List.generate(
                  28,
                  (i) =>
                      DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
                ),
                onChanged: (v) => setState(() => _monthDay = v!),
              ),
              const SizedBox(height: 8),
              const Text('Дни 1–28 есть в каждом месяце.'),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: controller.busy ? null : _save,
              child: Text(
                controller.busy ? 'Применение…' : 'Применить настройки',
              ),
            ),
            if (controller.reminderWarning != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  controller.reminderWarning!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Телефон может задерживать доставку при энергосбережении. '
              'После смены часового пояса откройте приложение для обновления расписания.',
            ),
          ],
        ),
      ),
    );
  }
}
