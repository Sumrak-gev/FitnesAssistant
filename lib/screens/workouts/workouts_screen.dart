import 'package:flutter/material.dart';
import '../../data/workout_repository.dart';
import '../../models/program.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final _repository = WorkoutRepository();
  List<Program> _programs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final programs = await _repository.getPrograms();
    setState(() => _programs = programs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Тренировки')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _programs.length,
        itemBuilder: (context, index) {
          final program = _programs[index];
          return Card(
            child: ListTile(
              title: Text(program.title),
              subtitle: Text('Цель: ${program.targetGoal} · ${program.exercises.length} упражнений'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: открыть детали программы, показать замену упражнений
              },
            ),
          );
        },
      ),
    );
  }
}
