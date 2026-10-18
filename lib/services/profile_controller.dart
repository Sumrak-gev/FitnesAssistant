import 'package:flutter/foundation.dart';
import '../data/profile_repository.dart';
import '../models/goal.dart';
import '../models/user_profile.dart';
import '../models/reminder_settings.dart';
import 'reminder_service.dart';

class ProfileController extends ChangeNotifier {
  ProfileController(this.repository, this.scheduler);
  final ProfileRepository repository;
  final ReminderScheduler scheduler;
  UserProfile profile = const UserProfile();
  ReminderSettings reminders = const ReminderSettings();
  bool loaded = false;
  bool busy = false;
  String? loadError;
  String? reminderWarning;
  bool _disposed = false;

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load() async {
    if (busy) return;
    busy = true;
    loadError = null;
    _changed();
    try {
      profile = await repository.loadProfile();
      reminders = await repository.loadReminders();
      loaded = true;
      await _applyReminders(requestPermission: false);
    } catch (_) {
      loadError = 'Не удалось прочитать данные. Повторите попытку.';
    } finally {
      busy = false;
      _changed();
    }
  }

  Future<void> saveProfile(UserProfile value) async {
    if (busy || !loaded) throw StateError('Дождитесь загрузки данных.');
    busy = true;
    _changed();
    try {
      await repository.saveProfile(value);
      profile = await repository.loadProfile();
    } finally {
      busy = false;
      _changed();
    }
  }

  Future<void> selectGoal(GoalType goal) => saveProfile(profile.withGoal(goal));

  Future<void> saveReminders(ReminderSettings value) async {
    if (busy || !loaded) throw StateError('Дождитесь загрузки данных.');
    busy = true;
    _changed();
    try {
      // Persist desired state first. A failed OS operation is retried at resume.
      await repository.saveReminders(value);
      reminders = value;
      await _applyReminders(
        requestPermission: value.frequency != ReminderFrequency.off,
      );
    } finally {
      busy = false;
      _changed();
    }
  }

  Future<void> reconcileReminders() async {
    if (busy || !loaded) return;
    busy = true;
    _changed();
    try {
      await _applyReminders(requestPermission: false);
    } finally {
      busy = false;
      _changed();
    }
  }

  Future<void> _applyReminders({required bool requestPermission}) async {
    try {
      final allowed = await scheduler.apply(
        reminders,
        requestPermission: requestPermission,
      );
      reminderWarning = allowed
          ? null
          : 'Уведомления запрещены системой. Разрешите их в настройках телефона и вернитесь в приложение.';
    } catch (_) {
      reminderWarning = reminders.frequency == ReminderFrequency.off
          ? 'Не удалось отменить уведомление. Повторите применение настроек.'
          : 'Настройки сохранены, но напоминание не запланировано. Повторите применение настроек.';
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
