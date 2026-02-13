// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_map_alert.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetMapAlertAdapter extends TypeAdapter<PetMapAlert> {
  @override
  final int typeId = 20;

  @override
  PetMapAlert read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PetMapAlert(
      id: fields[0] as String,
      latitude: fields[1] as double,
      longitude: fields[2] as double,
      category: fields[3] as String,
      description: fields[4] as String,
      timestamp: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PetMapAlert obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.latitude)
      ..writeByte(2)
      ..write(obj.longitude)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetMapAlertAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
