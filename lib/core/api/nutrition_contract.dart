import 'package:uuid/uuid.dart';

/// Сущности модуля питания в общей очереди синхронизации.
const nutritionEntities = ['product', 'meal', 'entry'];

/// Shared envelope from docs/nutrition-openapi.json. Transport/authentication are separate.
class NutritionMutation {
  NutritionMutation({
    required this.mutationId,
    required this.id,
    required this.entity,
    required this.operation,
    required this.baseVersion,
    required this.clientRevision,
    required this.data,
  }) {
    if (!Uuid.isValidUUID(fromString: mutationId) ||
        !Uuid.isValidUUID(fromString: id) ||
        !nutritionEntities.contains(entity) ||
        !['upsert', 'delete'].contains(operation) ||
        baseVersion < 0 ||
        clientRevision < 1 ||
        (operation == 'upsert') != (data != null)) {
      throw ArgumentError('Некорректное изменение питания для синхронизации.');
    }
  }
  final String mutationId, id, entity, operation;
  final int baseVersion, clientRevision;
  final Map<String, dynamic>? data;
  Map<String, dynamic> toJson() => {
    'mutationId': mutationId,
    'id': id,
    'entity': entity,
    'operation': operation,
    'baseVersion': baseVersion,
    'clientRevision': clientRevision,
    'data': data,
  };
  factory NutritionMutation.fromJson(Map<String, dynamic> json) =>
      NutritionMutation(
        mutationId: json['mutationId'] as String,
        id: json['id'] as String,
        entity: json['entity'] as String,
        operation: json['operation'] as String,
        baseVersion: json['baseVersion'] as int,
        clientRevision: json['clientRevision'] as int,
        data: json['data'] as Map<String, dynamic>?,
      );
}

class NutritionPushRequest {
  NutritionPushRequest(List<NutritionMutation> changes)
    : changes = List.unmodifiable(changes) {
    if (changes.isEmpty ||
        changes.length > 100 ||
        changes.map((c) => '${c.entity}:${c.id}').toSet().length !=
            changes.length ||
        changes.map((c) => c.mutationId).toSet().length != changes.length) {
      throw ArgumentError(
        'Пакет должен содержать 1–100 различных сущностей и идентификаторов изменений.',
      );
    }
  }
  final List<NutritionMutation> changes;
  Map<String, dynamic> toJson() => {
    'changes': changes.map((c) => c.toJson()).toList(),
  };
}
