import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/workout_repository.dart';
import '../../core/db/app_database.dart';
import '../../models/goal.dart';
import '../../models/program.dart';
import '../../models/user_profile.dart';
import '../../services/profile_controller.dart';

String formatProfileDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key, required this.initial});
  final UserProfile initial;
  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _height;
  late final TextEditingController _weight;
  late final TextEditingController _target;
  late DateTime? _birthDate;
  late ProfileSex _sex;
  late ActivityLevel _activity;
  late GoalType _goal;
  late String? _programId;
  late final Future<List<Program>> _programs = WorkoutRepository(
    context.read<AppDatabase>(),
  ).getPrograms();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _name = TextEditingController(text: p.name);
    _height = TextEditingController(text: p.heightCm?.toString() ?? '');
    _weight = TextEditingController(text: p.weightKg?.toString() ?? '');
    _target = TextEditingController(text: p.targetWeightKg?.toString() ?? '');
    _birthDate = p.birthDate;
    _sex = p.sex;
    _activity = p.activity;
    _goal = p.goal;
    _programId = p.programId;
  }

  @override
  void dispose() {
    for (final field in [_name, _height, _weight, _target]) {
      field.dispose();
    }
    super.dispose();
  }

  double? _number(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.'));

  Widget _measurement(
    String label,
    TextEditingController controller,
    double min,
    double max, {
    bool optional = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (text) {
        if (optional && (text ?? '').trim().isEmpty) return null;
        final value = _number(text ?? '');
        return value == null || !value.isFinite || value < min || value > max
            ? 'Введите число от ${min.toInt()} до ${max.toInt()}'
            : null;
      },
    ),
  );

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final invalid = _form.currentState!.validateGranularly();
    if (invalid.isNotEmpty) {
      await Scrollable.ensureVisible(invalid.first.context);
      return;
    }
    setState(() => _saving = true);
    try {
      await context.read<ProfileController>().saveProfile(
        UserProfile(
          name: _name.text.trim(),
          birthDate: _birthDate,
          sex: _sex,
          heightCm: _number(_height.text),
          weightKg: _number(_weight.text),
          targetWeightKg: _number(_target.text),
          activity: _activity,
          goal: _goal,
          programId: _programId,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Профиль сохранён')));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось сохранить профиль. Повторите попытку.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Редактирование профиля')),
    body: SafeArea(
      child: AbsorbPointer(
        absorbing: _saving,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  maxLength: 80,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Имя'),
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Введите имя' : null,
                ),
                const SizedBox(height: 16),
                FormField<DateTime>(
                  initialValue: _birthDate,
                  validator: (_) =>
                      _birthDate == null ? 'Выберите дату рождения' : null,
                  builder: (field) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_month),
                        label: Text(
                          _birthDate == null
                              ? 'Дата рождения'
                              : formatProfileDate(_birthDate!),
                        ),
                        onPressed: () async {
                          final now = DateTime.now();
                          final date = await showDatePicker(
                            context: context,
                            initialDate:
                                _birthDate ??
                                DateTime(now.year - 20, now.month, now.day),
                            firstDate: DateTime(1900),
                            lastDate: now,
                            helpText: 'Дата рождения',
                          );
                          if (date != null && mounted) {
                            setState(() => _birthDate = date);
                            field.didChange(date);
                          }
                        },
                      ),
                      if (field.hasError)
                        Text(
                          field.errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ProfileSex>(
                  initialValue: _sex,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Пол'),
                  items: ProfileSex.values
                      .map(
                        (v) => DropdownMenuItem(value: v, child: Text(v.label)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _sex = v!),
                ),
                const SizedBox(height: 16),
                _measurement('Рост, см', _height, 50, 260),
                _measurement('Вес, кг', _weight, 20, 500),
                DropdownButtonFormField<ActivityLevel>(
                  initialValue: _activity,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Уровень активности',
                  ),
                  items: ActivityLevel.values
                      .map(
                        (v) => DropdownMenuItem(value: v, child: Text(v.label)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _activity = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<GoalType>(
                  initialValue: _goal,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Фитнес-цель'),
                  items: GoalType.values
                      .map(
                        (v) => DropdownMenuItem(
                          value: v,
                          child: Text(
                            Goal(type: v, startDate: DateTime.now()).label,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _goal = v!),
                ),
                const SizedBox(height: 16),
                _measurement(
                  'Целевой вес, кг (необязательно)',
                  _target,
                  20,
                  500,
                  optional: true,
                ),
                FutureBuilder<List<Program>>(
                  future: _programs,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text(
                        'Каталог программ недоступен. Текущий выбор сохранится.',
                      );
                    }
                    if (!snapshot.hasData) {
                      return const LinearProgressIndicator();
                    }
                    final programs = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      initialValue: _programId ?? '',
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Тренировочная программа',
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: '',
                          child: Text('Не выбрана'),
                        ),
                        if (_programId != null &&
                            !programs.any((p) => p.id == _programId))
                          DropdownMenuItem(
                            value: _programId,
                            child: const Text(
                              'Ранее выбранная программа недоступна',
                            ),
                          ),
                        ...programs.map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(
                              p.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => _programId = v == '' ? null : v),
                    );
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving || context.watch<ProfileController>().busy
                      ? null
                      : _save,
                  child: Text(_saving ? 'Сохранение…' : 'Сохранить профиль'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
