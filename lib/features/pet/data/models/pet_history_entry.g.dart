// GENERATED CODE - DO NOT MODIFY BY HAND (MANUALLY OVERRIDDEN DUE TO CONFLICT)

part of 'pet_history_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetHistoryEntryAdapter extends TypeAdapter<PetHistoryEntry> {
  @override
  final int typeId = 1;

  @override
  PetHistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PetHistoryEntry(
      id: fields[0] as String,
      petUuid: fields[1] as String,
      rawJson: fields[2] as String,
      timestamp: fields[3] as DateTime,
      category: fields[4] as String,
      severityIndex: fields[5] as int,
      trendAnalysis: fields[6] as String,
      tags: (fields[7] as List).cast<String>(),
      petName: fields[8] as String,
      imagePath: fields[9] as String,
      analysisCards: (fields[10] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>()).toList(),
    );
  }

  @override
  void write(BinaryWriter writer, PetHistoryEntry obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petUuid)
      ..writeByte(2)
      ..write(obj.rawJson)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.severityIndex)
      ..writeByte(6)
      ..write(obj.trendAnalysis)
      ..writeByte(7)
      ..write(obj.tags)
      ..writeByte(8)
      ..write(obj.petName)
      ..writeByte(9)
      ..write(obj.imagePath)
      ..writeByte(10)
      ..write(obj.analysisCards);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetHistoryEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
