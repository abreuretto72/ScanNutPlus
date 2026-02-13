import 'package:hive/hive.dart';
import 'package:scannutplus/pet/agenda/pet_event.dart';

enum PetEventRepoStatus {
  success,
  notFound,
  storageError,
  invalidInput,
}

class PetEventRepoResult<T> {
  final T? data;
  final PetEventRepoStatus status;

  const PetEventRepoResult.success(this.data)
      : status = PetEventRepoStatus.success;

  const PetEventRepoResult.failure(this.status) : data = null;

  bool get isSuccess => status == PetEventRepoStatus.success;
}

class PetEventRepository {
  // Nome da box definido como constante técnica sem exposição a UI
  // Importante: não alterar após produção
  static const _boxName = 'pet_agenda_events_v1'; // identificador técnico simbólico

  Future<PetEventRepoResult<Box<PetEvent>>> _getBox() async {
    try {
      final box = Hive.isBoxOpen(_boxName.toString())
          ? Hive.box<PetEvent>(_boxName.toString())
          : await Hive.openBox<PetEvent>(_boxName.toString());

      return PetEventRepoResult.success(box);
    } catch (_) {
      return const PetEventRepoResult.failure(
        PetEventRepoStatus.storageError,
      );
    }
  }

  Future<PetEventRepoResult<void>> saveEvent(PetEvent event) async {
    if (event.id.isEmpty) {
      return const PetEventRepoResult.failure(
        PetEventRepoStatus.invalidInput,
      );
    }

    final boxResult = await _getBox();
    if (!boxResult.isSuccess) {
      return PetEventRepoResult.failure(boxResult.status);
    }

    final box = boxResult.data!;

    try {
      if (box.containsKey(event.id)) {
        return const PetEventRepoResult.failure(
          PetEventRepoStatus.invalidInput,
        );
      }

      await box.put(event.id, event);
      return const PetEventRepoResult.success(null);
    } catch (_) {
      return const PetEventRepoResult.failure(
        PetEventRepoStatus.storageError,
      );
    }
  }

  Future<PetEventRepoResult<void>> update(PetEvent event) async {
    final boxResult = await _getBox();
    if (!boxResult.isSuccess) {
      return PetEventRepoResult.failure(boxResult.status);
    }

    final box = boxResult.data!;

    try {
      if (!box.containsKey(event.id)) {
        return const PetEventRepoResult.failure(
          PetEventRepoStatus.notFound,
        );
      }

      await box.put(event.id, event);
      return const PetEventRepoResult.success(null);
    } catch (_) {
      return const PetEventRepoResult.failure(
        PetEventRepoStatus.storageError,
      );
    }
  }

  Future<PetEventRepoResult<void>> delete(String id) async {
    final boxResult = await _getBox();
    if (!boxResult.isSuccess) {
      return PetEventRepoResult.failure(boxResult.status);
    }

    final box = boxResult.data!;

    try {
      if (!box.containsKey(id)) {
        return const PetEventRepoResult.failure(
          PetEventRepoStatus.notFound,
        );
      }

      await box.delete(id);
      return const PetEventRepoResult.success(null);
    } catch (_) {
      return const PetEventRepoResult.failure(
        PetEventRepoStatus.storageError,
      );
    }
  }

  Future<PetEventRepoResult<PetEvent>> getById(String id) async {
    final boxResult = await _getBox();
    if (!boxResult.isSuccess) {
      return PetEventRepoResult.failure(boxResult.status);
    }

    final box = boxResult.data!;

    try {
      final event = box.get(id);
      return event == null
          ? const PetEventRepoResult.failure(
              PetEventRepoStatus.notFound,
            )
          : PetEventRepoResult.success(event);
    } catch (_) {
      return const PetEventRepoResult.failure(
        PetEventRepoStatus.storageError,
      );
    }
  }

  Future<PetEventRepoResult<List<PetEvent>>> getAll() async {
    final boxResult = await _getBox();
    if (!boxResult.isSuccess) {
      return PetEventRepoResult.failure(boxResult.status);
    }

    final box = boxResult.data!;

    try {
      final events = box.values.toList()
        ..sort((a, b) => b.startDateTime.compareTo(a.startDateTime));

      return PetEventRepoResult.success(events);
    } catch (_) {
      return const PetEventRepoResult.failure(
        PetEventRepoStatus.storageError,
      );
    }
  }

  Future<PetEventRepoResult<List<PetEvent>>> getByPetId(String petId) async {
    final boxResult = await _getBox();
    if (!boxResult.isSuccess) {
      return PetEventRepoResult.failure(boxResult.status);
    }

    final box = boxResult.data!;

    try {
      final events = box.values
          .where((e) => e.petIds.contains(petId))
          .toList()
        ..sort((a, b) => b.startDateTime.compareTo(a.startDateTime));

      return PetEventRepoResult.success(events);
    } catch (_) {
      return const PetEventRepoResult.failure(
        PetEventRepoStatus.storageError,
      );
    }
  }
}
