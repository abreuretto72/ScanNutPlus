import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
part 'pet_history_entry.g.dart';

@HiveType(typeId: 11) // Verifique se o ID não conflita
class PetHistoryEntry extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String petUuid;
  @HiveField(2) final String rawJson;
  @HiveField(3) final DateTime timestamp;
  @HiveField(4) final String category;

  PetHistoryEntry({
    required this.id,
    required this.petUuid,
    required this.rawJson,
    required this.timestamp,
    this.category = PetConstants.valGeneral,
    this.severityIndex = 0,
    this.trendAnalysis = PetConstants.valStable,
    this.tags = const [],
    this.petName = '',
    this.imagePath = '',
    this.analysisCards = const [],
  });

  @HiveField(5) final int severityIndex;
  @HiveField(6) final String trendAnalysis;
  @HiveField(7) final List<String> tags;
  @HiveField(8) final String petName;
  @HiveField(9) final String imagePath;
  @HiveField(10) final List<Map<String, dynamic>> analysisCards;
}