// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_analysis.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingAnalysisAdapter extends TypeAdapter<PendingAnalysis> {
  @override
  final int typeId = 204;

  @override
  PendingAnalysis read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingAnalysis(
      eventId: fields[0] as String,
      eventType: fields[1] as PetEventType,
      imagePath: fields[2] as String?,
      audioPath: fields[3] as String?,
      videoPath: fields[4] as String?,
      notes: fields[5] as String,
      metrics: (fields[6] as Map).cast<String, dynamic>(),
      isFriendUrl: fields[7] as bool,
      petUuid: fields[8] as String,
      petName: fields[9] as String,
      timestamp: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PendingAnalysis obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.eventId)
      ..writeByte(1)
      ..write(obj.eventType)
      ..writeByte(2)
      ..write(obj.imagePath)
      ..writeByte(3)
      ..write(obj.audioPath)
      ..writeByte(4)
      ..write(obj.videoPath)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.metrics)
      ..writeByte(7)
      ..write(obj.isFriendUrl)
      ..writeByte(8)
      ..write(obj.petUuid)
      ..writeByte(9)
      ..write(obj.petName)
      ..writeByte(10)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingAnalysisAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
