import 'package:hive_flutter/hive_flutter.dart';
import 'package:scannutplus/features/pet/agenda/data/models/pending_analysis.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class PendingAnalysisRepository {
  static const String boxPendingAnalyses = 'pet_pending_analyses';

  Future<Box<PendingAnalysis>> _openBox() async {
    if (!Hive.isBoxOpen(boxPendingAnalyses)) {
      return await Hive.openBox<PendingAnalysis>(boxPendingAnalyses);
    }
    return Hive.box<PendingAnalysis>(boxPendingAnalyses);
  }

  Future<String?> savePendingAnalysis(PendingAnalysis analysis) async {
    try {
      final box = await _openBox();
      await box.put(analysis.eventId, analysis);
      return analysis.eventId;
    } catch (e) {
      debugPrint('[PendingAnalysisRepository] Error saving analysis: $e');
      return null;
    }
  }

  Future<List<PendingAnalysis>> getAllPendingAnalyses() async {
    try {
      final box = await _openBox();
      return box.values.toList();
    } catch (e) {
      debugPrint('[PendingAnalysisRepository] Error fetching all pending analyses: $e');
      return [];
    }
  }

  Future<bool> deletePendingAnalysis(String eventId) async {
    try {
      final box = await _openBox();
      await box.delete(eventId);
      return true;
    } catch (e) {
      debugPrint('[PendingAnalysisRepository] Error deleting pending analysis $eventId: $e');
      return false;
    }
  }
}
