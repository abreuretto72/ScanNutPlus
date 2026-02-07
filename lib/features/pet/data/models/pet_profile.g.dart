// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetProfileAdapter extends TypeAdapter<PetProfile> {
  @override
  final int typeId = 12;

  @override
  PetProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PetProfile(
      uuid: fields[0] as String,
      name: fields[1] as String,
      profileImagePath: fields[2] as String,
      breed: fields[3] as String,
      age: fields[4] as String,
      createdAt: fields[5] as DateTime?,
      updatedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PetProfile obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.profileImagePath)
      ..writeByte(3)
      ..write(obj.breed)
      ..writeByte(4)
      ..write(obj.age)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
