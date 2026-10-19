/// Вспомогательные функции для работы с датами без учёта времени суток.
/// Через конструктор DateTime(y, m, d + n) — без ошибок при переходе на летнее время.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime addDays(DateTime d, int days) =>
    DateTime(d.year, d.month, d.day + days);

/// Понедельник недели, в которую попадает дата (неделя — с понедельника по воскресенье).
DateTime startOfWeek(DateTime d) =>
    DateTime(d.year, d.month, d.day - (d.weekday - DateTime.monday));
