import 'package:fitness_assistant/models/reminder_settings.dart';
import 'package:fitness_assistant/services/reminder_service.dart';

class FakeReminders implements ReminderScheduler {
  bool allowed = true;
  bool fail = false;
  bool requested = false;
  ReminderSettings? applied;
  @override
  Future<bool> apply(
    ReminderSettings settings, {
    bool requestPermission = false,
  }) async {
    requested = requestPermission;
    if (fail) throw StateError('OS unavailable');
    applied = settings;
    return settings.frequency == ReminderFrequency.off || allowed;
  }
}
