// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_event_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetEventTypeAdapter extends TypeAdapter<PetEventType> {
  @override
  final int typeId = 203;

  @override
  PetEventType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PetEventType.food;
      case 1:
        return PetEventType.health;
      case 2:
        return PetEventType.weight;
      case 3:
        return PetEventType.hygiene;
      case 4:
        return PetEventType.activity;
      case 5:
        return PetEventType.other;
      case 6:
        return PetEventType.friend;
      case 7:
        return PetEventType.aiChat;
      case 8:
        return PetEventType.appointment;
      case 9:
        return PetEventType.partner;
      case 10:
        return PetEventType.behavior;
      case 11:
        return PetEventType.plant;
      default:
        return PetEventType.food;
    }
  }

  @override
  void write(BinaryWriter writer, PetEventType obj) {
    switch (obj) {
      case PetEventType.food:
        writer.writeByte(0);
        break;
      case PetEventType.health:
        writer.writeByte(1);
        break;
      case PetEventType.weight:
        writer.writeByte(2);
        break;
      case PetEventType.hygiene:
        writer.writeByte(3);
        break;
      case PetEventType.activity:
        writer.writeByte(4);
        break;
      case PetEventType.other:
        writer.writeByte(5);
        break;
      case PetEventType.friend:
        writer.writeByte(6);
        break;
      case PetEventType.aiChat:
        writer.writeByte(7);
        break;
      case PetEventType.appointment:
        writer.writeByte(8);
        break;
      case PetEventType.partner:
        writer.writeByte(9);
        break;
      case PetEventType.behavior:
        writer.writeByte(10);
        break;
      case PetEventType.plant:
        writer.writeByte(11);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetEventTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
