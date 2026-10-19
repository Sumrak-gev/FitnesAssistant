import 'package:flutter/material.dart';

import '../../data/workout_repository.dart';
import '../../models/exercise.dart';
import '../../models/program.dart';

/// Экран каталога и управления тренировочными программами.
///
/// Использует существующие Program, Exercise и WorkoutRepository.
/// Изменения программ пока хранятся только в памяти приложения:
/// для постоянного хранения потребуется отдельная интеграция с SQLite.
class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final WorkoutRepository _repository = WorkoutRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Program> _programs = [];
  List<Exercise> _allExercises = [];
  bool _isLoading = true;
  String? _error;

  String _selectedGoal = 'Все цели';
  String _selectedEquipment = 'Любое';
  final Set<String> _excludedContraindications = <String>{};
  String? _activeProgramId;

  static const List<String> _goals = <String>[
    'Все цели',
    'похудение',
    'набор массы',
    'поддержание веса',
    'выносливость',
  ];

  static const List<String> _equipmentOptions = <String>[
    'Любое',
    'без инвентаря',
    'гантели',
    'штанга',
    'тренажёр',
  ];

  static const List<String> _contraindicationOptions = <String>[
    'травма колена',
    'травма плеча',
    'боль в спине',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final programs = await _repository.getPrograms();
      final exercises = await _repository.getAllExercises();
      if (!mounted) return;
      setState(() {
        _programs = programs;
        _allExercises = exercises;
        _isLoading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Не удалось загрузить тренировки: $error';
      });
    }
  }

  bool _exerciseMatches(Exercise exercise) {
    final query = _searchController.text.trim().toLowerCase();
    final matchesQuery = query.isEmpty ||
        exercise.name.toLowerCase().contains(query) ||
        exercise.muscleGroup.toLowerCase().contains(query) ||
        exercise.equipment.toLowerCase().contains(query);

    final matchesEquipment = _selectedEquipment == 'Любое' ||
        exercise.equipment.toLowerCase() == _selectedEquipment.toLowerCase();

    final hasExcludedContraindication = exercise.contraindications.any(
      (item) => _excludedContraindications.contains(item.toLowerCase()),
    );

    return matchesQuery && matchesEquipment && !hasExcludedContraindication;
  }

  List<Exercise> _visibleExercises(Program program) =>
      program.exercises.where(_exerciseMatches).toList();

  List<Program> get _visiblePrograms {
    final query = _searchController.text.trim().toLowerCase();
    return _programs.where((program) {
      final matchesGoal =
          _selectedGoal == 'Все цели' || program.targetGoal == _selectedGoal;
      final matchingExercises = _visibleExercises(program);
      final matchesQuery = query.isEmpty ||
          program.title.toLowerCase().contains(query) ||
          program.targetGoal.toLowerCase().contains(query) ||
          matchingExercises.isNotEmpty;
      return matchesGoal && matchesQuery && matchingExercises.isNotEmpty;
    }).toList();
  }

  void _showProgramDetails(Program program) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            // Берём актуальную версию программы: она может измениться после замены.
            final currentProgram = _programs.firstWhere(
              (item) => item.id == program.id,
              orElse: () => program,
            );
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.78,
              minChildSize: 0.45,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      currentProgram.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          avatar: const Icon(Icons.flag_outlined, size: 18),
                          label: Text(currentProgram.targetGoal),
                        ),
                        Chip(
                          avatar: const Icon(Icons.fitness_center, size: 18),
                          label: Text(
                            '${currentProgram.exercises.length} упражнений',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Упражнения',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (currentProgram.exercises.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Text('В этой программе пока нет упражнений.'),
                      ),
                    ...currentProgram.exercises.map((exercise) {
                      final excluded = exercise.contraindications.any(
                        (item) => _excludedContraindications
                            .contains(item.toLowerCase()),
                      );
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(
                              excluded
                                  ? Icons.warning_amber_rounded
                                  : Icons.fitness_center,
                            ),
                          ),
                          title: Text(exercise.name),
                          subtitle: Text(
                            '${exercise.muscleGroup} · ${exercise.equipment}'
                            '${exercise.contraindications.isEmpty ? '' : '\nОграничения: ${exercise.contraindications.join(', ')}'}',
                          ),
                          isThreeLine: exercise.contraindications.isNotEmpty,
                          trailing: IconButton(
                            tooltip: 'Заменить упражнение',
                            icon: const Icon(Icons.swap_horiz),
                            onPressed: () async {
                              await _replaceExercise(
                                currentProgram,
                                exercise,
                                () => setSheetState(() {}),
                              );
                              if (mounted) setState(() {});
                            },
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        setState(() => _activeProgramId = currentProgram.id);
                        Navigator.of(sheetContext).pop();
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Выбрана программа «${currentProgram.title}»',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Выбрать эту программу'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Выбор программы и замена упражнений действуют в текущем '
                      'сеансе приложения. Сохранение в SQLite пока не подключено.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _replaceExercise(
    Program program,
    Exercise oldExercise,
    VoidCallback refreshDetails,
  ) async {
    final alternatives = _allExercises.where((candidate) {
      if (candidate.id == oldExercise.id) return false;
      if (candidate.muscleGroup.toLowerCase() !=
          oldExercise.muscleGroup.toLowerCase()) {
        return false;
      }
      if (_selectedEquipment != 'Любое' &&
          candidate.equipment.toLowerCase() !=
              _selectedEquipment.toLowerCase()) {
        return false;
      }
      return !candidate.contraindications.any(
        (item) => _excludedContraindications.contains(item.toLowerCase()),
      );
    }).toList();

    if (alternatives.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Подходящих замен нет. Измените фильтры или добавьте упражнения в каталог.',
          ),
        ),
      );
      return;
    }

    final selected = await showModalBottomSheet<Exercise>(
      context: context,
      useSafeArea: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Замена: ${oldExercise.name}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...alternatives.map(
              (exercise) => ListTile(
                leading: const Icon(Icons.fitness_center),
                title: Text(exercise.name),
                subtitle: Text('${exercise.muscleGroup} · ${exercise.equipment}'),
                onTap: () => Navigator.of(context).pop(exercise),
              ),
            ),
          ],
        ),
      ),
    );

    if (selected == null || !mounted) return;

    setState(() {
      final index = _programs.indexWhere((item) => item.id == program.id);
      if (index >= 0) {
        _programs[index] = _programs[index].replaceExercise(
          oldExercise.id,
          selected,
        );
      }
    });
    refreshDetails();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Упражнение заменено на «${selected.name}»')),
    );
  }

  void _toggleContraindication(String value, bool selected) {
    setState(() {
      if (selected) {
        _excludedContraindications.add(value.toLowerCase());
      } else {
        _excludedContraindications.remove(value.toLowerCase());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final programs = _visiblePrograms;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Тренировки'),
        actions: [
          IconButton(
            tooltip: 'Обновить список',
            onPressed: _isLoading ? null : _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorView(message: _error!, onRetry: _loadData)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Подбери тренировку под свою цель',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Выбирай программу, изучай упражнения и при необходимости заменяй их.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Поиск программы или упражнения',
                          hintText: 'Например, ноги или отжимания',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Очистить поиск',
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedGoal,
                        decoration: const InputDecoration(
                          labelText: 'Цель тренировки',
                          border: OutlineInputBorder(),
                        ),
                        items: _goals
                            .map((goal) => DropdownMenuItem(
                                  value: goal,
                                  child: Text(goal),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedGoal = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedEquipment,
                        decoration: const InputDecoration(
                          labelText: 'Оборудование',
                          border: OutlineInputBorder(),
                        ),
                        items: _equipmentOptions
                            .map((item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedEquipment = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Исключить ограничения',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Упражнения с отмеченными противопоказаниями будут скрыты.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _contraindicationOptions.map((item) {
                          final selected = _excludedContraindications
                              .contains(item.toLowerCase());
                          return FilterChip(
                            label: Text(item),
                            selected: selected,
                            onSelected: (value) =>
                                _toggleContraindication(item, value),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Программы',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Text('${programs.length}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (programs.isEmpty)
                        const _EmptyView()
                      else
                        ...programs.map((program) {
                          final exercises = _visibleExercises(program);
                          final isActive = _activeProgramId == program.id;
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => _showProgramDetails(program),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.fitness_center,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSecondaryContainer,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                program.title,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              const SizedBox(height: 4),
                                              Text('Цель: ${program.targetGoal}'),
                                              Text(
                                                '${exercises.length} упражнений подходят под фильтры',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.chevron_right),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: exercises.take(3).map((exercise) {
                                        return Chip(
                                          visualDensity: VisualDensity.compact,
                                          label: Text(exercise.name),
                                        );
                                      }).toList(),
                                    ),
                                    if (isActive) ...[
                                      const SizedBox(height: 8),
                                      const Row(
                                        children: [
                                          Icon(Icons.check_circle,
                                              color: Colors.green, size: 18),
                                          SizedBox(width: 6),
                                          Text('Выбрана'),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton.icon(
                                        onPressed: () =>
                                            _showProgramDetails(program),
                                        icon: const Icon(Icons.open_in_new),
                                        label: const Text('Подробнее'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 20),
                      Text(
                        'Каталог содержит демонстрационные данные. Чтобы выбор и '
                        'замены сохранялись после перезапуска, нужно подключить SQLite.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 42),
            const SizedBox(height: 12),
            Text(
              'Подходящих программ не найдено',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              'Попробуй изменить цель, оборудование или ограничения.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 42),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}
