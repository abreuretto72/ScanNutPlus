
import 'package:objectbox/objectbox.dart';
import 'package:scannutplus/core/data/objectbox_manager.dart';
import 'package:scannutplus/features/pet/data/models/pet_entity.dart';
import 'package:scannutplus/features/pet/data/models/pet_history_entry.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/objectbox.g.dart';
import 'package:intl/intl.dart';

class PetAiRepository {
  late Box<PetEntity> _petBox;
  late Box<PetHistoryEntry> _historyBox;

  PetAiRepository() {
    _petBox = ObjectBoxManager.currentStore.box<PetEntity>();
    _historyBox = ObjectBoxManager.currentStore.box<PetHistoryEntry>();
  }

  /// Retrieves the full context for a specific pet to be used in RAG (Retrieval-Augmented Generation).
  /// Includes:
  /// - Pet Profile (Identity, Breed, Age)
  /// - Recent History (Last 5 analysis results)
  Future<String> getPetContext(String uuid) async {
    final buffer = StringBuffer();

    // 1. Fetch Profile
    final pet = _petBox.query(PetEntity_.uuid.equals(uuid)).build().findFirst();
    
    if (pet != null) {
      buffer.writeln(PetConstants.ragProfileHeader);
      buffer.writeln('${PetConstants.labelName}${pet.name}');
      buffer.writeln('${PetConstants.labelBreed}${pet.breed}');
      buffer.writeln('${PetConstants.labelSpecies}${pet.species}');
      // buffer.writeln('Age: ${pet.age}'); // If available in Entity
      // buffer.writeln('Weight: ${pet.weight}'); // If available
      buffer.writeln(PetConstants.ragSeparator);
    } else {
      buffer.writeln(PetConstants.ragUnknownProfile.replaceFirst('{}', uuid));
    }

    // 2. Fetch History (Limit to last 5 for context window efficiency)
    final query = _historyBox
        .query(PetHistoryEntry_.petUuid.equals(uuid))
        .order(PetHistoryEntry_.timestamp, flags: Order.descending)
        .build();
    
    // Get top 5 most recent
    final history = query.find().take(5).toList();
    query.close();

    if (history.isNotEmpty) {
      buffer.writeln(PetConstants.ragHistoryHeader.replaceFirst('{}', history.length.toString()));
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
      
      for (var entry in history) {
        buffer.writeln('${PetConstants.labelDate}${dateFormat.format(entry.timestamp)}');
        buffer.writeln('${PetConstants.labelCategory}${entry.category}');
        buffer.writeln('${PetConstants.labelSummary}${entry.rawJson}'); // Pass full raw text for AI to reason
        buffer.writeln('---');
      }
      buffer.writeln(PetConstants.ragEndBlock);
    } else {
      buffer.writeln(PetConstants.ragNoHistory);
    }

    return buffer.toString();
  }
}
