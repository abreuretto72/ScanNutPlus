import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import 'package:flutter/foundation.dart';
import 'package:scannutplus/features/pet/data/models/pet_history_entry.dart';
import 'package:scannutplus/features/pet/data/models/pet_profile.dart'; // Import Profile
import 'package:scannutplus/features/pet/data/pet_constants.dart';       // Import Constants
import 'package:scannutplus/features/pet/data/pet_history_repository.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/features/pet/presentation/history/pet_history_detail_screen.dart';
import 'package:scannutplus/features/pet/presentation/extensions/pet_ui_extensions.dart';

class PetHistoryListView extends StatelessWidget {
  const PetHistoryListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensuring box is open before listening
    return FutureBuilder(
      future: Hive.isBoxOpen(PetConstants.boxPetHistory) 
          ? Future.value(Hive.box<PetHistoryEntry>(PetConstants.boxPetHistory))
          : Hive.openBox<PetHistoryEntry>(PetConstants.boxPetHistory),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF10AC84)));
        }

        // Panic Button Fix: Listen directly to the box instance
        return ValueListenableBuilder<Box<PetHistoryEntry>>(
          valueListenable: Hive.box<PetHistoryEntry>(PetConstants.boxPetHistory).listenable(),
          builder: (context, historyBox, _) {
            final entries = historyBox.values.toList()
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

             // INJECTED TRACE
            if (kDebugMode) {
               debugPrint('[PET_TRACE_UI] Itens detectados na Box: ${historyBox.length}');
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
      },
    );
  }

  Widget _buildHistoryTile(BuildContext context, PetHistoryEntry entry) {
    final l10n = AppLocalizations.of(context)!;
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(entry.timestamp);
    
    // Species Lookup (Pilar 0)
    String speciesDisplay = l10n.value_unknown;
    if (Hive.isBoxOpen(PetConstants.boxPetProfiles)) {
        final profileBox = Hive.box<PetProfile>(PetConstants.boxPetProfiles);
        // Try to find profile by UUID
        // If UUID is Environment tag, we might not have a profile, or use Name
        if (entry.petUuid != PetConstants.tagEnvironment && entry.petUuid != null) {
             final profile = profileBox.values.firstWhere(
                 (p) => p.uuid == entry.petUuid, 
                 orElse: () => PetProfile(uuid: '', name: '', profileImagePath: '', species: PetConstants.speciesUnknown) // Dummy
             );
             if (profile.uuid.isNotEmpty) {
                 speciesDisplay = profile.species.toSpeciesDisplay(context);
             }
        }
    }
    
    // Urgency Logic
    final urgencyDisplay = entry.trendAnalysis.toUrgencyDisplay(context);
    final isCritical = urgencyDisplay == l10n.key_red; // "Crítico"

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PetHistoryDetailScreen(entry: entry),
          ),
        );
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
                        errorBuilder: (_, __, ___) => const Icon(LucideIcons.image, color: Colors.black54),
                      )
                    : const Icon(LucideIcons.dog, color: Colors.black54),
              ),
            ),
            const SizedBox(width: 16),
            
            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.petName,
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
                      Icon(LucideIcons.dog, size: 12, color: Colors.black54), // Species Icon
                      const SizedBox(width: 4),
                      Text(
                        speciesDisplay,
                        style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 10),
                      Icon(LucideIcons.clock, size: 12, color: Colors.black54),
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
                       '${entry.category.toCategoryDisplay(context)} • $urgencyDisplay',
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
            
            const Icon(LucideIcons.chevronRight, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}
