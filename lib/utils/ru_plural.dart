/// Выбор формы слова по числу: 1 тренировка, 2 тренировки, 5 тренировок.
String pluralRu(int n, String one, String few, String many) {
  final n100 = n.abs() % 100;
  final n10 = n.abs() % 10;
  if (n100 >= 11 && n100 <= 14) return many;
  if (n10 == 1) return one;
  if (n10 >= 2 && n10 <= 4) return few;
  return many;
}
