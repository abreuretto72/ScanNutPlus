import 'package:scannutplus/features/pet/data/models/pet_event_type.dart';

extension PetEventTypeExtension on int {
  PetEventType toPetEventType() {
    return PetEventType.values[this];
  }
}
