enum ReminderFrequency {
  off('Выключены'),
  daily('Ежедневно'),
  weekly('Еженедельно'),
  monthly('Ежемесячно');

  const ReminderFrequency(this.label);
  final String label;
}

class ReminderSettings {
  const ReminderSettings({
    this.frequency = ReminderFrequency.off,
    this.hour = 19,
    this.minute = 0,
    this.weekday = 1,
    this.monthDay = 1,
  });

  final ReminderFrequency frequency;
  final int hour;
  final int minute;
  final int weekday;
  // 1–28 ensures a reminder exists in every month, including February.
  final int monthDay;

  void validate() {
    if (hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59 ||
        weekday < 1 ||
        weekday > 7 ||
        monthDay < 1 ||
        monthDay > 28) {
      throw ArgumentError('Некорректное расписание уведомлений.');
    }
  }
}
