import 'dart:io';
import 'package:flutter/foundation.dart'; // Add this line
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:scannutplus/features/pet/l10n/generated/pet_localizations.dart';
import 'package:scannutplus/core/constants/app_keys.dart';
import 'package:scannutplus/features/pet/presentation/widgets/pet_visual_dashboard.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';

class PetAnalysisResultView extends StatelessWidget {
  final String imagePath;
  final String analysisResult;
  final Duration? executionTime; // Added for telemetry
  final VoidCallback onRetake;
  final VoidCallback onShare;

  const PetAnalysisResultView({
    super.key,
    required this.imagePath,
    required this.analysisResult,
    this.executionTime,
    required this.onRetake,
    required this.onShare,
    this.petDetails,
  });

  final Map<String, String>? petDetails;

  @override
  Widget build(BuildContext context) {
    final l10n = PetLocalizations.of(context)!;
    
    // Split result to find sources if possible
    String observations = analysisResult;
    String? sources;
    
    final lower = analysisResult.toLowerCase();
    
    for (final kw in AppKeys.sourceKeywords) {
      final idx = lower.lastIndexOf(kw);
      if (idx != -1 && idx > analysisResult.length * 0.5) { // Must be in second half
        observations = analysisResult.substring(0, idx).trim();
        sources = analysisResult.substring(idx).trim();
        break;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17), // Deep Dark Background
      appBar: AppBar(
        title: Text(l10n.pet_result_title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1F3A5F),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Header
            Container(
              margin: const EdgeInsets.all(16),
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1F3A5F), width: 3),
                image: DecorationImage(
                  image: FileImage(File(imagePath)),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Analysis Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CARD 1: Visual Dashboard
                  PetVisualDashboard(
                    analysisText: analysisResult,
                    petName: petDetails?[PetConstants.fieldName],
                  ),
                  const SizedBox(height: 16),

                  // CARD 2: Pet Details
                  if (petDetails != null)
                    Card(
                      elevation: 2,
                      color: const Color(0xFF121A2B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                children: [
                                   const Icon(LucideIcons.dog, color: Color(0xFFEAF0FF)),
                                   const SizedBox(width: 8),
                                   Text(
                                     petDetails![PetConstants.fieldName] ?? PetConstants.defaultPetName,
                                     style: const TextStyle(color: Color(0xFFEAF0FF), fontSize: 18, fontWeight: FontWeight.bold),
                                   ),
                                   const Spacer(),
                                   if (petDetails![PetConstants.fieldIsNeutered] == PetConstants.valTrue)
                                      Container(
                                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                         decoration: BoxDecoration(color: const Color(0xFF10AC84), borderRadius: BorderRadius.circular(8)),
                                         child: Text(PetConstants.parseNeutered.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildDetailItem(LucideIcons.scale, petDetails![PetConstants.parseWeight] ?? '-'),
                                _buildDetailItem(LucideIcons.calendar, petDetails![PetConstants.parseAge] ?? '-'),
                                _buildDetailItem(LucideIcons.dna, petDetails![PetConstants.parseSex] ?? '-'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  // CARD 3: Analysis
                  Card(
                    elevation: 2,
                    color: const Color(0xFF121A2B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                       padding: const EdgeInsets.all(16),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(
                             l10n.pet_section_observations,
                             style: const TextStyle(
                               color: Colors.white,
                               fontSize: 18,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                           const SizedBox(height: 12),
                           Text(
                             observations,
                             style: const TextStyle(
                               color: Color(0xFFEAF0FF),
                               fontSize: 16,
                               height: 1.5,
                             ),
                           ),
                         ],
                       ),
                    ),
                  ),
                ],
              ),
            ),



            // Debug Performance Badge
            if (kDebugMode && executionTime != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      '⏱️ ${executionTime!.inMilliseconds}ms',
                      style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: AppKeys.fontMonospace),
                    ),
                  ),
                ),
              ),

            // CARD 4: Sources
            if (sources != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                   elevation: 2,
                   color: const Color(0xFF0F1623),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFF10AC84), width: 1)),
                   margin: const EdgeInsets.only(bottom: 16),
                   child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                             const Icon(LucideIcons.bookOpen, color: Color(0xFF10AC84), size: 24),
                             const SizedBox(width: 8),
                             Text(
                               l10n.pet_section_sources,
                               style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                             ),
                          ]),
                          const SizedBox(height: 12),
                          Text(
                            sources,
                            style: const TextStyle(
                              color: Color(0xFFA9B4CC),
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                   ),
                ),
              ),
            ],

            // Disclaimer
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0x26FF5252), // Low opacity red
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFF5252).withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.alertTriangle, color: Color(0xFFFF5252), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.pet_disclaimer,
                        style: const TextStyle(
                          color: Color(0xFFFF5252),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onRetake,
                      icon: const Icon(LucideIcons.camera, size: 20),
                      label: Text(l10n.pet_action_new_analysis),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F3A5F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onShare,
                      icon: const Icon(LucideIcons.share2, size: 20),
                      label: Text(l10n.pet_action_share),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10AC84), // Share usually positive/active
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Footer
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  l10n.pet_footer_text,
                  style: const TextStyle(
                    color: Color(0xFF53647C),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
}
