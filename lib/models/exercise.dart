/// Упражнение: описание, целевая группа мышц, противопоказания.
class Exercise {
  final String id;
  final String name;
  final String muscleGroup;      // напр. "спина", "ноги", "грудь"
  final String equipment;        // напр. "гантели", "без инвентаря"
  final List<String> contraindications; // список противопоказаний

  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    this.contraindications = const [],
  });

  factory Exercise.fromMap(Map<String, dynamic> map) => Exercise(
        id: map['id'] as String,
        name: map['name'] as String,
        muscleGroup: map['muscleGroup'] as String,
        equipment: map['equipment'] as String,
        contraindications:
            (map['contraindications'] as List?)?.cast<String>() ?? const [],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'muscleGroup': muscleGroup,
        'equipment': equipment,
        'contraindications': contraindications,
      };
}
