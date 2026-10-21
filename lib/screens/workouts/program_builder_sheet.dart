import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/exercise.dart';
import '../../models/program.dart';

/// One place to choose exercises and save a personal program for offline use.
class ProgramBuilderSheet extends StatefulWidget {
  const ProgramBuilderSheet({super.key, required this.exercises});
  final List<Exercise> exercises;

  @override
  State<ProgramBuilderSheet> createState() => _ProgramBuilderSheetState();
}

class _ProgramBuilderSheetState extends State<ProgramBuilderSheet> {
  final _title = TextEditingController();
  final _search = TextEditingController();
  final _selected = <String>{};
  String _goal = 'поддержание веса';
  String? _error;

  static const goals = [
    'похудение',
    'набор массы',
    'поддержание веса',
    'выносливость',
  ];

  @override
  void dispose() {
    _title.dispose();
    _search.dispose();
    super.dispose();
  }

  void _save() {
    final title = _title.text.trim();
    if (title.isEmpty || title.length > 80 || _selected.isEmpty) {
      setState(
        () => _error = 'Укажите название до 80 символов и выберите упражнения.',
      );
      return;
    }
    final picked = widget.exercises
        .where((e) => _selected.contains(e.id))
        .toList();
    Navigator.of(context).pop(
      Program(
        id: const Uuid().v4(),
        title: title,
        targetGoal: _goal,
        exercises: picked,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final visible = widget.exercises
        .where(
          (e) =>
              query.isEmpty ||
              e.name.toLowerCase().contains(query) ||
              e.muscleGroup.toLowerCase().contains(query),
        )
        .take(60)
        .toList();
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: FractionallySizedBox(
          heightFactor: .92,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Свой план',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Соберите тренировку из каталога. План останется доступным без сети.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _title,
                      maxLength: 80,
                      decoration: const InputDecoration(
                        labelText: 'Название плана',
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: _goal,
                      decoration: const InputDecoration(
                        labelText: 'Цель плана',
                      ),
                      items: [
                        for (final goal in goals)
                          DropdownMenuItem(value: goal, child: Text(goal)),
                      ],
                      onChanged: (value) =>
                          setState(() => _goal = value ?? _goal),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _search,
                      decoration: const InputDecoration(
                        labelText: 'Найти упражнение',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Выбрано: ${_selected.length}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final exercise = visible[index];
                    return CheckboxListTile(
                      value: _selected.contains(exercise.id),
                      onChanged: (value) => setState(() {
                        if (value == true && _selected.length >= 100) {
                          _error = 'В одном плане не более 100 упражнений.';
                        } else {
                          if (value == true) {
                            _selected.add(exercise.id);
                          } else {
                            _selected.remove(exercise.id);
                          }
                          _error = null;
                        }
                      }),
                      title: Text(exercise.name),
                      subtitle: Text(
                        '${exercise.muscleGroup} · ${exercise.equipment}'
                        '${exercise.contraindications.isEmpty ? '' : '\nОграничения: ${exercise.contraindications.join(', ')}'}',
                      ),
                      isThreeLine: exercise.contraindications.isNotEmpty,
                    );
                  },
                ),
              ),
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Сохранить план'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
