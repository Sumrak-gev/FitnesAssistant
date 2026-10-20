import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/db/app_database.dart';
import '../../services/profile_controller.dart';
import '../../models/user_profile.dart';
import '../../core/api/api_client.dart';
import '../../data/catalog_repository.dart';

import '../../data/workout_repository.dart';
import '../../models/exercise.dart';
import '../../models/program.dart';

/// Экран каталога и управления тренировочными программами.
///
/// Использует существующие Program, Exercise и WorkoutRepository.
/// Программы и замены сохраняются в Drift и общей очереди синхронизации.
class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  late final WorkoutRepository _repository;
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
    _repository = WorkoutRepository(context.read<AppDatabase>());
    _activeProgramId = context.read<ProfileController>().profile.programId;
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

  Future<void> _importCatalog() async {
    final api = context.read<ApiClient?>();
    if (api == null) return;
    try {
      await CatalogRepository(
        context.read<AppDatabase>(),
        api,
      ).importExercises();
      await _loadData();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Нет связи. Каталог доступен офлайн.')),
        );
      }
    }
  }

  bool _exerciseMatches(Exercise exercise) {
    final query = _searchController.text.trim().toLowerCase();
    final matchesQuery =
        query.isEmpty ||
        exercise.name.toLowerCase().contains(query) ||
        exercise.muscleGroup.toLowerCase().contains(query) ||
        exercise.equipment.toLowerCase().contains(query);

    final matchesEquipment =
        _selectedEquipment == 'Любое' ||
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
      final matchesQuery =
          query.isEmpty ||
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
                        (item) => _excludedContraindications.contains(
                          item.toLowerCase(),
                        ),
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
                                () {
                                  if (sheetContext.mounted) {
                                    setSheetState(() {});
                                  }
                                },
                              );
                              if (mounted) setState(() {});
                            },
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () async {
                        final controller = this.context
                            .read<ProfileController>();
                        final p = controller.profile;
                        await controller.saveProfile(
                          UserProfile(
                            name: p.name,
                            birthDate: p.birthDate,
                            sex: p.sex,
                            heightCm: p.heightCm,
                            weightKg: p.weightKg,
                            targetWeightKg: p.targetWeightKg,
                            activity: p.activity,
                            goal: p.goal,
                            programId: currentProgram.id,
                          ),
                        );
                        if (!mounted || !sheetContext.mounted) return;
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
                    FilledButton.tonalIcon(
                      onPressed: currentProgram.exercises.isEmpty
                          ? null
                          : () async {
                              await _repository.completeProgram(
                                currentProgram,
                                DateTime.now(),
                              );
                              if (!mounted || !sheetContext.mounted) return;
                              Navigator.of(sheetContext).pop();
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Выполнение программы сохранено',
                                  ),
                                ),
                              );
                            },
                      icon: const Icon(Icons.done_all),
                      label: const Text('Отметить выполнение программы'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Выбор программы и замены сохраняются на устройстве и синхронизируются с аккаунтом.',
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
                subtitle: Text(
                  '${exercise.muscleGroup} · ${exercise.equipment}',
                ),
                onTap: () => Navigator.of(context).pop(exercise),
              ),
            ),
          ],
        ),
      ),
    );

    if (selected == null || !mounted) return;

    await _repository.saveProgram(
      program.replaceExercise(oldExercise.id, selected),
    );
    if (!mounted) return;

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
            tooltip: 'Загрузить каталог упражнений',
            onPressed: _importCatalog,
            icon: const Icon(Icons.cloud_download_outlined),
          ),
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
                    initialValue: _selectedGoal,
                    decoration: const InputDecoration(
                      labelText: 'Цель тренировки',
                      border: OutlineInputBorder(),
                    ),
                    items: _goals
                        .map(
                          (goal) =>
                              DropdownMenuItem(value: goal, child: Text(goal)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedGoal = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedEquipment,
                    decoration: const InputDecoration(
                      labelText: 'Оборудование',
                      border: OutlineInputBorder(),
                    ),
                    items: _equipmentOptions
                        .map(
                          (item) =>
                              DropdownMenuItem(value: item, child: Text(item)),
                        )
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
                      final selected = _excludedContraindications.contains(
                        item.toLowerCase(),
                      );
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondaryContainer,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.fitness_center,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSecondaryContainer,
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
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                          ),
                                          const SizedBox(height: 4),
                                          Text('Цель: ${program.targetGoal}'),
                                          Text(
                                            '${exercises.length} упражнений подходят под фильтры',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
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
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 18,
                                      ),
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
                    'Каталог доступен офлайн. Изменения программ сохраняются автоматически.',
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
