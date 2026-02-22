import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart'; // Removed
// import 'package:lucide_icons/lucide_icons.dart'; // Removed
import 'package:intl/intl.dart';

import 'package:flutter/foundation.dart';
import 'package:scannutplus/features/pet/data/models/pet_history_entry.dart';
import 'package:scannutplus/features/pet/data/models/pet_entity.dart'; // ObjectBox Entity
import 'package:scannutplus/features/pet/data/pet_constants.dart';       // Import Constants
import 'package:scannutplus/core/data/objectbox_manager.dart'; // ObjectBox
import 'package:scannutplus/objectbox.g.dart';

import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/features/pet/presentation/history/pet_history_detail_screen.dart';
import 'package:scannutplus/features/pet/presentation/extensions/pet_ui_extensions.dart';
import 'package:scannutplus/core/services/universal_ocr_result_view.dart'; // Added Import

class PetHistoryListView extends StatefulWidget {
  const PetHistoryListView({super.key});

  @override
  State<PetHistoryListView> createState() => _PetHistoryListViewState();
}

class _PetHistoryListViewState extends State<PetHistoryListView> {
  late Box<PetHistoryEntry> _historyBox;
  late Box<PetEntity> _petBox;

  @override
  void initState() {
    super.initState();
    _historyBox = ObjectBoxManager.currentStore.box<PetHistoryEntry>();
    _petBox = ObjectBoxManager.currentStore.box<PetEntity>();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to ObjectBox changes
    return StreamBuilder<List<PetHistoryEntry>>(
      stream: _historyBox.query()
          .order(PetHistoryEntry_.timestamp, flags: Order.descending)
          .watch(triggerImmediately: true)
          .map((query) => query.find()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF10AC84)));
        }

        final entries = snapshot.data ?? [];

         // INJECTED TRACE
        if (kDebugMode) {
           debugPrint('[PET_TRACE_UI] Itens detectados na Box (ObjectBox): ${entries.length}');
           if (entries.isNotEmpty) {
              debugPrint('[PET_TRACE_UI] Primeiro item: ${entries.first.petName}');
           } else {
              debugPrint('[PET_TRACE_UI] Box vazia - exibindo Empty State');
           }
        }

        if (entries.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.pet_history_empty, 
              style: const TextStyle(color: Colors.white54),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80), // Prevent footer overlap
          child: Column(
            children: entries.map((entry) => _buildHistoryTile(context, entry)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTile(BuildContext context, PetHistoryEntry entry) {
    final l10n = AppLocalizations.of(context)!;
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(entry.timestamp);
    
    // Species Lookup (ObjectBox)
    String speciesDisplay = l10n.value_unknown;
    if (entry.petUuid != PetConstants.tagEnvironment) {
         final profile = _petBox.query(PetEntity_.uuid.equals(entry.petUuid)).build().findFirst();
         if (profile != null) {
             // Assuming conversion extension exists for String species
             speciesDisplay = profile.species; 
             // Or verify if conversion is needed: profile.species.toSpeciesDisplay(context)
             // Keeping simple for now as per ObjectBox usage
         }
    }
    
    // Urgency Logic
    // entry.trendAnalysis is String, need to check if extension applies or logic needs update
    // Assuming extension applies to String
    final urgencyDisplay = entry.trendAnalysis; // Simplify or use extension if available
    final isCritical = urgencyDisplay == 'Critico' || urgencyDisplay == 'Red' || urgencyDisplay == l10n.key_red; 

    return GestureDetector(
      onTap: () {
        // [OCR FLOW REDIRECT]
        if (entry.category == PetConstants.typeLabel || entry.category == PetConstants.typeLab || entry.category == PetConstants.typeLabel.toLowerCase() || entry.category == PetConstants.typeLab.toLowerCase()) {
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UniversalOcrResultView(
                  imagePath: entry.imagePath,
                  ocrResult: entry.rawJson, // Passing raw JSON/Text
                  petDetails: {
                    PetConstants.fieldName: entry.petName,
                    PetConstants.fieldBreed: speciesDisplay, // Using display species as breed fallback or fetch real breed if needed
                    PetConstants.keyPageTitle: "${entry.category.toCategoryDisplay(context)}: ${entry.petName}",
                  },
                ),
              ),
            );
        } else {
            // [LEGACY FLOW]
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PetHistoryDetailScreen(entry: entry),
              ),
            );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFD1DC), // Rosa Pastel (Domain Identity)
          borderRadius: BorderRadius.circular(16),
          border: isCritical 
              ? Border.all(color: Colors.red, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 60,
                height: 60,
                child: entry.imagePath.isNotEmpty
                    ? Image.file(
                        File(entry.imagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.black54),
                      )
                    : const Icon(Icons.pets, color: Colors.black54),
              ),
            ),
            const SizedBox(width: 16),
            
            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.getPlantTitle(context) ?? entry.category.toCategoryDisplay(context),
                    style: const TextStyle(
                      color: Color(0xFF2D3436), 
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Species & Date
                  Row(
                    children: [
                      Icon(Icons.pets, size: 12, color: Colors.black54), // Species Icon
                      const SizedBox(width: 4),
                      Text(
                        speciesDisplay,
                        style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.access_time, size: 12, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        dateStr,
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // Urgency / Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                       color: Colors.white.withValues(alpha: 0.6),
                       borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                       // Display Analysis Type + Urgency if available
                       '${entry.category} • $urgencyDisplay',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isCritical ? Colors.red : Colors.black87
                      ),
                    ),
                  )
                ],
              ),
            ),
            
            const Icon(Icons.chevron_right, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}
