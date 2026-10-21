import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/db/app_database.dart';
import '../../services/profile_controller.dart';
import '../../data/progress_repository.dart';
import '../../models/streak.dart';
import '../../models/weekly_summary.dart';
import '../../services/nutrition_service.dart';
import '../../services/progress_service.dart';
import '../../utils/date_helpers.dart';
import '../../utils/ru_plural.dart';
import '../../widgets/section_card.dart';
import '../../widgets/progress_journey.dart';
import '../../widgets/passport_reward.dart';

/// Вкладка «Прогресс»: уровень, серии и недельные итоги.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  static const _workoutGoal = 3;
  static const _dayLabels = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  double? _dailyTarget;
  bool _loaded = false;
  StreamSubscription<Object?>? _changes;
  late final ProfileController _profile;
  late final ProgressRepository _repository;
  final _service = ProgressService();
  ProgressSnapshot? _snapshot;

  @override
  void initState() {
    super.initState();
    _profile = context.read<ProfileController>();
    _profile.addListener(_reload);
    _repository = ProgressRepository(context.read<AppDatabase>());
    _changes = _repository.database.tableUpdates().listen((_) => _load());
    _load();
  }

  void _reload() {
    if (_profile.loaded) _load();
  }

  @override
  void dispose() {
    _profile.removeListener(_reload);
    _changes?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final logs = await _repository.getLogs();
    if (!mounted) return;
    setState(() {
      _loaded = true;
      try {
        _dailyTarget = NutritionService()
            .normForProfile(_profile.profile)
            .calories;
      } on ArgumentError {
        _dailyTarget = null;
      }
      _snapshot = _service.build(
        logs: logs,
        today: dateOnly(DateTime.now()),
        dailyTarget: _dailyTarget,
        workoutGoal: _workoutGoal,
      );
    });
  }

  Future<void> _markWorkoutToday() async {
    await _repository.markWorkout(DateTime.now());
    await _load();
  }

  bool get _workoutDoneToday {
    final snapshot = _snapshot;
    if (snapshot == null) return false;
    final index = DateTime.now().weekday - DateTime.monday;
    return snapshot.currentWeek.workoutByDay[index];
  }

  Future<void> _openPassportChannel() async {
    try {
      final opened = await launchUrl(
        Uri.parse('https://t.me/+HW7EBXn31DVkNjMy'),
        mode: LaunchMode.externalApplication,
      );
      if (opened || !mounted) return;
    } catch (_) {
      if (!mounted) return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Не удалось открыть Telegram-ссылку')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    return Scaffold(
      appBar: AppBar(title: const Text('Прогресс')),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : snapshot == null
          ? const Center(child: Text('Не удалось загрузить прогресс'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildLevel(context, snapshot),
                PassportReward(
                  level: snapshot.level.level,
                  onOpen: _openPassportChannel,
                ),
                if (!snapshot.nutritionTargetAvailable)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Заполните профиль, чтобы получать опыт за дни в норме калорий.',
                    ),
                  ),
                _buildStreaks(context, snapshot),
                _buildCurrentWeek(context, snapshot),
                _buildPreviousWeek(context, snapshot),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _workoutDoneToday ? null : _markWorkoutToday,
                  icon: const Icon(Icons.check),
                  label: Text(
                    _workoutDoneToday
                        ? 'Тренировка сегодня отмечена'
                        : 'Отметить тренировку сегодня',
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLevel(BuildContext context, ProgressSnapshot s) {
    final theme = Theme.of(context);
    final level = s.level;
    return SectionCard(
      title: 'Уровень',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProgressJourney(level: level.level),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  '${level.level}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(level.title, style: theme.textTheme.titleMedium),
                    Text(
                      '${level.totalXp} XP · ${s.totalWorkouts} '
                      '${pluralRu(s.totalWorkouts, 'тренировка', 'тренировки', 'тренировок')}',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: level.progress, minHeight: 8),
          const SizedBox(height: 6),
          Text(
            level.level == 10
                ? 'Максимальный уровень достигнут'
                : 'До уровня ${level.level + 1} осталось ${level.xpToNext} XP',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('Тренировки +${s.totalWorkouts * 50} XP')),
              Chip(label: Text('Питание +${s.nutritionDays * 20} XP')),
              Chip(label: Text('Недели +${s.completedGoalWeeks * 100} XP')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreaks(BuildContext context, ProgressSnapshot s) {
    return SectionCard(
      title: 'Серии',
      child: Column(
        children: [
          _StreakRow(
            icon: Icons.fitness_center,
            streak: s.workoutWeekStreak,
            unitOne: 'неделя',
            unitFew: 'недели',
            unitMany: 'недель',
            description: 'подряд с $_workoutGoal+ тренировками',
            pendingHint: 'Выполните цель этой недели, чтобы продолжить серию',
          ),
          const Divider(height: 24),
          _StreakRow(
            icon: Icons.restaurant,
            streak: s.nutritionDayStreak,
            unitOne: 'день',
            unitFew: 'дня',
            unitMany: 'дней',
            description: 'подряд в пределах нормы КБЖУ',
            pendingHint: 'Сегодня ещё не засчитано — серия не прервана',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeek(BuildContext context, ProgressSnapshot s) {
    final week = s.currentWeek;
    return SectionCard(
      title: 'Эта неделя · ${_range(week)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.currentWeekHeadline,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          _DayStrip(week: week, labels: _dayLabels),
          const SizedBox(height: 12),
          _WeekStats(week: week, hasTarget: s.nutritionTargetAvailable),
        ],
      ),
    );
  }

  Widget _buildPreviousWeek(BuildContext context, ProgressSnapshot s) {
    final week = s.previousWeek;
    return SectionCard(
      title: 'Итоги прошлой недели · ${_range(week)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.previousWeekHeadline,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 4),
          Text(
            s.previousWeekComparison,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          _WeekStats(week: week, hasTarget: s.nutritionTargetAvailable),
        ],
      ),
    );
  }

  String _range(WeeklySummary w) => '${_fmt(w.weekStart)} – ${_fmt(w.weekEnd)}';

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';
}

class _StreakRow extends StatelessWidget {
  final IconData icon;
  final StreakInfo streak;
  final String unitOne;
  final String unitFew;
  final String unitMany;
  final String description;
  final String pendingHint;

  const _StreakRow({
    required this.icon,
    required this.streak,
    required this.unitOne,
    required this.unitFew,
    required this.unitMany,
    required this.description,
    required this.pendingHint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = streak.current > 0;
    return Row(
      children: [
        Icon(
          active ? Icons.local_fire_department : icon,
          size: 32,
          color: active ? Colors.deepOrange : theme.disabledColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${streak.current} ${pluralRu(streak.current, unitOne, unitFew, unitMany)}',
                style: theme.textTheme.titleMedium,
              ),
              Text(description, style: theme.textTheme.bodyMedium),
              if (!streak.currentPeriodDone)
                Text(pendingHint, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Рекорд', style: theme.textTheme.bodySmall),
            Text('${streak.best}', style: theme.textTheme.titleMedium),
          ],
        ),
      ],
    );
  }
}

class _DayStrip extends StatelessWidget {
  final WeeklySummary week;
  final List<String> labels;

  const _DayStrip({required this.week, required this.labels});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todayIndex = DateTime.now().weekday - DateTime.monday;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final done = week.workoutByDay[i];
        final isToday = week.isCurrent && i == todayIndex;
        return Column(
          children: [
            Text(
              labels[i],
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isToday ? FontWeight.bold : null,
              ),
            ),
            const SizedBox(height: 4),
            CircleAvatar(
              radius: 14,
              backgroundColor: done
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              child: Icon(
                done ? Icons.check : Icons.remove,
                size: 16,
                color: done
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.outline,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _WeekStats extends StatelessWidget {
  final WeeklySummary week;
  final bool hasTarget;

  const _WeekStats({required this.week, required this.hasTarget});

  @override
  Widget build(BuildContext context) {
    final balance = week.calorieBalance;
    final balanceText =
        '${balance > 0 ? '+' : ''}${balance.toStringAsFixed(0)} ккал';
    return Column(
      children: [
        _StatLine('Тренировки', '${week.workouts} из ${week.workoutGoal}'),
        _StatLine(
          'Дней в норме КБЖУ',
          week.loggedDays == 0 || !hasTarget
              ? '—'
              : '${week.daysInNorm} из ${week.loggedDays}',
        ),
        _StatLine(
          'Средние калории',
          week.avgCalories == null
              ? '—'
              : '${week.avgCalories!.toStringAsFixed(0)} ккал/день',
        ),
        _StatLine(
          'Баланс калорий',
          week.loggedDays == 0 || !hasTarget ? '—' : balanceText,
        ),
      ],
    );
  }
}

class _StatLine extends StatelessWidget {
  final String label;
  final String value;

  const _StatLine(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
