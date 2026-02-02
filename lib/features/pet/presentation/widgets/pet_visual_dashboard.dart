import 'package:flutter/material.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/l10n/generated/pet_localizations.dart';

class PetVisualDashboard extends StatelessWidget {
  final String analysisText;
  final String? petName;

  const PetVisualDashboard({super.key, required this.analysisText, this.petName});

  @override
  Widget build(BuildContext context) {
    // Simple parsing logic (robustness depends on AI adherence)
    
    final startIndex = analysisText.indexOf(PetConstants.visualSummaryStart);
    final endIndex = analysisText.indexOf(PetConstants.visualSummaryEnd);

    if (startIndex == -1 || endIndex == -1) {
      return const SizedBox.shrink(); // Or generic header
    }

    final summaryBlock = analysisText.substring(startIndex + PetConstants.visualSummaryStart.length, endIndex).trim();
    final lines = summaryBlock.split('\n');

    String urgency = '?'; 
    String emoji = '🐾';
    String summary = '';
    Color statusColor = Colors.grey;

    for (var line in lines) {
      final lowerLine = line.toLowerCase();
      if (lowerLine.contains(PetConstants.urgencyData.toLowerCase())) {
        if (line.split(':').length > 1) {
             urgency = line.split(':')[1].trim();
        }
        final lowerUrgency = urgency.toLowerCase();
        
        if (lowerUrgency.contains(PetConstants.parseGreen) || lowerUrgency.contains(PetConstants.parseVerde)) {
          statusColor = const Color(0xFF10AC84);
        } else if (lowerUrgency.contains(PetConstants.parseYellow) || lowerUrgency.contains(PetConstants.parseAmarelo)) {
          statusColor = const Color(0xFFFFC107);
        } else if (lowerUrgency.contains(PetConstants.parseRed) || lowerUrgency.contains(PetConstants.parseVermelho)) {
          statusColor = const Color(0xFFD13131);
        }
      } else if (lowerLine.contains(PetConstants.systemData.toLowerCase())) {
        if (line.split(':').length > 1) {
             emoji = line.split(':')[1].trim();
        }
      } else if (lowerLine.contains(PetConstants.summaryData.toLowerCase())) {
        if (line.split(':').length > 1) {
             summary = line.split(':')[1].trim();
        }
      }
    }

    if (summary.isEmpty && lines.length >= 3) {
         // Fallback loose parsing
         summary = lines.last;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        border: Border.all(color: statusColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Pilar 0 Ergonomics
        children: [
          if (petName != null)
            Padding(
               padding: const EdgeInsets.only(bottom: 12),
               child: Text(
                 PetLocalizations.of(context)!.pet_analysis_for(petName!),
                 style: TextStyle(
                   color: statusColor,
                   fontSize: 20,
                   fontWeight: FontWeight.bold,
                 ),
               ),
            ),
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  urgency.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            summary,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white, // Colors.black87 is invisible on dark bg
            ),
          ),
        ],
      ),
    );
  }
}
