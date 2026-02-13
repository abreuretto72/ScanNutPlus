// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_event_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetEventAdapter extends TypeAdapter<PetEvent> {
  @override
  final int typeId = 202;

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
      eventType: fields[4] as PetEventType,
      eventSubType: fields[5] as String?,
      notes: fields[6] as String?,
      metrics: (fields[7] as Map?)?.cast<String, dynamic>(),
      mediaPaths: (fields[8] as List?)?.cast<String>(),
      partnerId: fields[9] as String?,
      hasAIAnalysis: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PetEvent obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startDateTime)
      ..writeByte(2)
      ..write(obj.endDateTime)
      ..writeByte(3)
      ..write(obj.petIds)
      ..writeByte(4)
      ..write(obj.eventType)
      ..writeByte(5)
      ..write(obj.eventSubType)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.metrics)
      ..writeByte(8)
      ..write(obj.mediaPaths)
      ..writeByte(9)
      ..write(obj.partnerId)
      ..writeByte(10)
      ..write(obj.hasAIAnalysis);
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
