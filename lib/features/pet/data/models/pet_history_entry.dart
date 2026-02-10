import 'package:objectbox/objectbox.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'dart:convert';

@Entity()
class PetHistoryEntry {
  @Id()
  int id = 0;

  @Index()
  String petUuid;
  
  String rawJson;
  
  @Property(type: PropertyType.date)
  DateTime timestamp;
  
  String category;
  int severityIndex;
  String trendAnalysis;
  
  // ObjectBox doesn't support Lists directly, store as JSON/String
  String tagsString; 
  String petName;
  String imagePath;
  String analysisCardsJson;

  PetHistoryEntry({
    this.id = 0,
    required this.petUuid,
    required this.rawJson,
    DateTime? timestamp,
    this.category = PetConstants.valGeneral,
    this.severityIndex = 0,
    this.trendAnalysis = PetConstants.valStable,
    List<String> tags = const [],
    this.petName = '',
    this.imagePath = '',
    List<Map<String, dynamic>> analysisCards = const [],
  }) : 
    timestamp = timestamp ?? DateTime.now(),
    tagsString = jsonEncode(tags),
    analysisCardsJson = jsonEncode(analysisCards);

  // Helper getters/setters for Lists
  List<String> get tags {
      if (tagsString.isEmpty) return [];
      try {
        return List<String>.from(jsonDecode(tagsString));
      } catch (_) { return []; }
  }
  
  List<Map<String, dynamic>> get analysisCards {
      if (analysisCardsJson.isEmpty) return [];
      try {
        return List<Map<String, dynamic>>.from(jsonDecode(analysisCardsJson));
      } catch (_) { return []; }
  }
}