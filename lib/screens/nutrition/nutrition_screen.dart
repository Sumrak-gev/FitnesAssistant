import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/db/app_database.dart';
import '../../data/nutrition_repository.dart';
import '../../models/daily_ration.dart';
import '../../models/nutrition_values.dart';
import '../../services/nutrition_service.dart';
import '../../services/profile_controller.dart';
import '../profile/profile_edit_screen.dart';
import 'nutrition_edit_screens.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});
  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final _service = NutritionService();
  DateTime _day = dayOnly(DateTime.now());
  bool _weekly = false;
  late final NutritionRepository _repository;
  late Future<List<DailyRation>> _data;
  @override
  void initState() {
    super.initState();
    _repository = NutritionRepository(context.read<AppDatabase>());
    _data = _load();
  }

  Future<List<DailyRation>> _load() async {
    return _repository.days(_service.weekStart(_day), 7);
  }

  void _refresh() => setState(() {
    _data = _load();
  });
  void _select(DateTime date) => setState(() {
    _day = dayOnly(date);
    _data = _load();
  });
  Future<void> _edit({
    RationEntry? entry,
    MealKind kind = MealKind.breakfast,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EntryEditScreen(
          repository: _repository,
          day: _day,
          kind: kind,
          initial: entry,
        ),
      ),
    );
    if (mounted) _refresh();
  }

  Future<void> _delete(Future<void> Function() action, String message) async {
    if (!await confirmNutritionDelete(context, message) || !mounted) return;
    try {
      await action();
      if (mounted) _refresh();
    } catch (_) {
      if (mounted) {
        showNutritionError(
          context,
          'Не удалось удалить запись. Повторите попытку.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileController>();
    DailyNorm? norm;
    String? normError;
    if (profile.loaded) {
      try {
        norm = _service.normForProfile(profile.profile);
      } on ArgumentError catch (error) {
        normError = error.message.toString();
      }
    } else {
      normError = 'Дождитесь загрузки профиля.';
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('КБЖУ'),
        actions: [
          IconButton(
            tooltip: 'Продукты',
            icon: const Icon(Icons.kitchen_outlined),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ProductCatalogScreen(repository: _repository),
                ),
              );
              if (mounted) _refresh();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(),
        icon: const Icon(Icons.add),
        label: const Text('Добавить еду'),
      ),
      body: FutureBuilder<List<DailyRation>>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Не удалось загрузить дневник.'),
                  TextButton(
                    onPressed: _refresh,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final days = snapshot.data!;
          final day = days.firstWhere(
            (d) => nutritionDay(d.day) == nutritionDay(_day),
          );
          final totals = _weekly ? _service.weekTotals(days) : day.totals;
          return RefreshIndicator(
            onRefresh: () async {
              _refresh();
              await _data;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Предыдущий день',
                      onPressed: !_day.isAfter(DateTime(1900))
                          ? null
                          : () => _select(
                              DateTime(_day.year, _day.month, _day.day - 1),
                            ),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _day,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100, 12, 31),
                          );
                          if (date != null && mounted) _select(date);
                        },
                        child: Text(formatProfileDate(_day)),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Следующий день',
                      onPressed: !_day.isBefore(DateTime(2100, 12, 31))
                          ? null
                          : () => _select(
                              DateTime(_day.year, _day.month, _day.day + 1),
                            ),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('День')),
                    ButtonSegment(value: true, label: Text('Неделя')),
                  ],
                  selected: {_weekly},
                  onSelectionChanged: (values) =>
                      setState(() => _weekly = values.single),
                ),
                const SizedBox(height: 16),
                Text(
                  _weekly
                      ? 'Неделя ${formatProfileDate(days.first.day)} — ${formatProfileDate(days.last.day)}'
                      : 'Итоги за день',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (normError != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(normError),
                          if (profile.loaded)
                            TextButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => ProfileEditScreen(
                                    initial: profile.profile,
                                  ),
                                ),
                              ),
                              child: const Text('Заполнить профиль'),
                            ),
                        ],
                      ),
                    ),
                  ),
                _TotalsCard(totals: totals, norm: norm, days: _weekly ? 7 : 1),
                if (norm != null)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Ориентир по текущему профилю. Расчёт приблизительный; индивидуальные рекомендации даёт специалист.',
                    ),
                  ),
                if (_weekly) ...[
                  const Text(
                    'Сумма за все 7 дней. День без записей не означает, что вы не ели.',
                  ),
                  for (final ration in days)
                    Card(
                      child: ListTile(
                        title: Text(formatProfileDate(ration.day)),
                        subtitle: Text(
                          ration.entryCount == 0
                              ? 'Нет записей'
                              : '${ration.entryCount} записей · ${ration.totals.calories.toStringAsFixed(0)} ккал',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: ration.day.year > 2100
                            ? null
                            : () => setState(() {
                                _day = ration.day;
                                _weekly = false;
                              }),
                      ),
                    ),
                ] else ...[
                  for (final kind in MealKind.values) _mealCard(day, kind),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _mealCard(DailyRation day, MealKind kind) {
    final matches = day.meals.where((m) => m.kind == kind);
    final meal = matches.isEmpty ? null : matches.first;
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(kind.label),
            subtitle: Text(
              '${meal?.totals.calories.toStringAsFixed(0) ?? '0'} ккал',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (meal != null && meal.entries.isNotEmpty)
                  IconButton(
                    tooltip: 'Удалить приём пищи',
                    onPressed: () => _delete(
                      () => _repository.deleteMeal(meal.id),
                      'Удалить все записи этого приёма пищи?',
                    ),
                    icon: const Icon(Icons.delete_outline),
                  ),
                IconButton(
                  tooltip: 'Добавить в ${kind.label.toLowerCase()}',
                  onPressed: () => _edit(kind: kind),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          if (meal == null || meal.entries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Пока нет записей'),
            ),
          if (meal != null)
            for (final entry in meal.entries)
              ListTile(
                title: Text(entry.product.name),
                subtitle: Text(
                  '${entry.grams} г · ${entry.totals.calories.toStringAsFixed(0)} ккал\n'
                  'Б ${entry.totals.protein.toStringAsFixed(1)} · Ж ${entry.totals.fat.toStringAsFixed(1)} · У ${entry.totals.carbs.toStringAsFixed(1)} г',
                ),
                onTap: () => _edit(entry: entry, kind: kind),
                trailing: IconButton(
                  tooltip: 'Удалить запись',
                  icon: const Icon(Icons.close),
                  onPressed: () => _delete(
                    () => _repository.deleteEntry(entry.id),
                    'Удалить запись из дневника?',
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({
    required this.totals,
    required this.norm,
    required this.days,
  });
  final NutritionValues totals;
  final DailyNorm? norm;
  final int days;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _line(context, 'Калории', totals.calories, norm?.calories, 'ккал'),
          _line(context, 'Белки', totals.protein, norm?.protein, 'г'),
          _line(context, 'Жиры', totals.fat, norm?.fat, 'г'),
          _line(context, 'Углеводы', totals.carbs, norm?.carbs, 'г'),
        ],
      ),
    ),
  );
  Widget _line(
    BuildContext context,
    String label,
    double value,
    double? dailyTarget,
    String unit,
  ) {
    final target = dailyTarget == null ? null : dailyTarget * days;
    final ratio = target == null ? null : value / target;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ${value.toStringAsFixed(1)}${target == null ? '' : ' / ${target.toStringAsFixed(1)}'} $unit',
          ),
          if (ratio != null) ...[
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              color: ratio > 1 ? Theme.of(context).colorScheme.tertiary : null,
              semanticsLabel: '$label относительно ориентира',
              semanticsValue: '${(ratio * 100).round()}%',
            ),
            Text(
              '${(ratio * 100).round()}% · ${value > target! ? 'Выше' : 'Осталось'} ${(target - value).abs().toStringAsFixed(1)} $unit',
            ),
          ],
        ],
      ),
    );
  }
}
