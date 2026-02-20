import 'package:hive/hive.dart';

@HiveType(typeId: 201)
class PetEvent extends HiveObject {
  // Campos obrigatórios (sem late para evitar crash em migrações)
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime startDateTime;

  @HiveField(3)
  final List<String> petIds;

  @HiveField(4)
  final int eventTypeIndex;

  @HiveField(10)
  final bool hasAIAnalysis;

  @HiveField(11)
  final String? address;

  // Campos opcionais
  @HiveField(2)
  final DateTime? endDateTime;

  @HiveField(5)
  final int? eventSubTypeIndex;

  @HiveField(6)
  final String? notes;

  @HiveField(7)
  final Map<String, dynamic>? metrics;

  @HiveField(8)
  final List<String>? mediaPaths;

  @HiveField(9)
  final String? partnerId;

  PetEvent({
    required this.id,
    required this.startDateTime,
    required this.petIds,
    required this.eventTypeIndex,
    required this.hasAIAnalysis,
    this.address,
    this.endDateTime,
    this.eventSubTypeIndex,
    this.notes,
    this.metrics,
    this.mediaPaths,
    this.partnerId,
  });

  PetEvent copyWith({
    String? id,
    DateTime? startDateTime,
    List<String>? petIds,
    int? eventTypeIndex,
    bool? hasAIAnalysis,
    String? address,
    DateTime? endDateTime,
    int? eventSubTypeIndex,
    String? notes,
    Map<String, dynamic>? metrics,
    List<String>? mediaPaths,
    String? partnerId,
  }) {
    return PetEvent(
      id: id ?? this.id,
      startDateTime: startDateTime ?? this.startDateTime,
      petIds: petIds ?? this.petIds,
      eventTypeIndex: eventTypeIndex ?? this.eventTypeIndex,
      hasAIAnalysis: hasAIAnalysis ?? this.hasAIAnalysis,
      address: address ?? this.address,
      endDateTime: endDateTime ?? this.endDateTime,
      eventSubTypeIndex: eventSubTypeIndex ?? this.eventSubTypeIndex,
      notes: notes ?? this.notes,
      metrics: metrics ?? this.metrics,
      mediaPaths: mediaPaths ?? this.mediaPaths,
      partnerId: partnerId ?? this.partnerId,
    );
  }
}

/// Adapter manual para garantir controle total de leitura/escrita.
/// IMPORTANTE:
/// - Nunca reutilizar typeId
/// - Nunca mudar índices dos HiveField
class PetEventAdapter extends TypeAdapter<PetEvent> {
  static const int _fieldCount = 12;

  @override
  final int typeId = 201;

  @override
  PetEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return PetEvent(
      id: fields[0] as String,
      startDateTime: fields[1] as DateTime,
      endDateTime: fields[2] as DateTime?,
      petIds: (fields[3] as List).cast<String>(),
      eventTypeIndex: fields[4] as int,
      eventSubTypeIndex: fields[5] as int?,
      notes: fields[6] as String?,
      metrics: (fields[7] as Map?)?.cast<String, dynamic>(),
      mediaPaths: (fields[8] as List?)?.cast<String>(),
      partnerId: fields[9] as String?,
      hasAIAnalysis: fields[10] as bool,
      address: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PetEvent obj) {
    writer
      ..writeByte(_fieldCount)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startDateTime)
      ..writeByte(2)
      ..write(obj.endDateTime)
      ..writeByte(3)
      ..write(obj.petIds)
      ..writeByte(4)
      ..write(obj.eventTypeIndex)
      ..writeByte(5)
      ..write(obj.eventSubTypeIndex)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.metrics)
      ..writeByte(8)
      ..write(obj.mediaPaths)
      ..writeByte(9)
      ..write(obj.partnerId)
      ..writeByte(10)
      ..write(obj.hasAIAnalysis)
      ..writeByte(11)
      ..write(obj.address);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
