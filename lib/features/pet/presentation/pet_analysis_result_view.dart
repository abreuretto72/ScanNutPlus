import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scannutplus/core/theme/app_colors.dart'; // AppColors
// import 'package:lucide_icons/lucide_icons.dart'; // Removed
import 'package:scannutplus/features/pet/l10n/generated/pet_localizations.dart';
import 'package:scannutplus/l10n/app_localizations.dart';

import 'package:scannutplus/features/pet/data/pet_constants.dart';

class PetAnalysisResultView extends StatelessWidget {
  final String imagePath;
  final String analysisResult;
  final Duration? executionTime; // Added for telemetry
  final VoidCallback onRetake;
  final VoidCallback onShare;
  final Map<String, String>? petDetails;

  const PetAnalysisResultView({
    super.key,
    required this.imagePath,
    required this.analysisResult,
    this.executionTime,
    required this.onRetake,
    required this.onShare,
    this.petDetails,
  });

  @override
  Widget build(BuildContext context) {
    final appL10n = AppLocalizations.of(context)!;
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // ... (Extraction logic remains) ...
    // Priority 1: petDetails['name']
    String? nameCandidate = petDetails?[PetConstants.fieldName];
    
    // Priority 2: args['name']
    if ((nameCandidate == null || nameCandidate.isEmpty) && args != null) {
      nameCandidate = args[PetConstants.argName]?.toString();
    }
    
    // Priority 3: Fallback localized
    final String displayPetName = (nameCandidate != null && nameCandidate.isNotEmpty) 
        ? nameCandidate 
        : appL10n.pet_unknown;

    final String displayBreed = petDetails?[PetConstants.fieldBreed] ?? args?[PetConstants.argBreed]?.toString() ?? appL10n.pet_breed_unknown;
    
    // Title Logic (Protocol 2026)
    // If we have a specific type (like newProfile/Initial Assessment), use it.
    // Otherwise fallback to "Analyzing: Name".
    String titleText = appL10n.pet_analyzing_x(displayPetName);
    
    if (args != null && args.containsKey(PetConstants.argType)) {
       final type = args[PetConstants.argType]?.toString();
       if (type == PetConstants.typeNewProfile || type == PetConstants.typeNewProfileLegacy) {
          titleText = appL10n.pet_initial_assessment;
       }
    }

    return Scaffold(
      backgroundColor: AppColors.petBackgroundDark, // Deep Dark Background
      appBar: AppBar(
        // Dynamic Title
        title: Text(
          titleText, 
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView( // Ergonomia SM A256E
        physics: const BouncingScrollPhysics(), // Scroll Elastico (Samsung OneUI feel)
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Header
            // Image Header
             Container(
              height: 220, 
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.petPrimary, width: 2), // Pink Border
                image: DecorationImage(
                  image: FileImage(File(imagePath)),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _buildStatusHeader(analysisResult, appL10n),
                  ),
                ],
              ),
            ),
            
            // IDENTITY BADGE (Protocol 2026 - Layout Fix)
            // Moved below image to prevent overflow and allow multi-line breed text
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 24),
              child: _buildIdentityBadge(context, displayPetName, displayBreed),
            ),
            
            // Gerador de Cards Estruturados (Strictly localized)
            
            // Gerador de Cards Dinâmico (Protocolo 2026: Flexible AI Response)
            ..._parseDynamicCards(analysisResult).map((block) => _buildDynamicCard(block)),

            // References Section (Protocol V6)
            _buildSourcesCard(context, _extractSources(analysisResult)),

             // Actions - HIDDEN AS PER USER REQUEST (11/02/2026)
            /*
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                children: [
                   // New Analysis (Pink)
                   _buildActionButton(
                     context,
                     label: appL10n.pet_action_new_analysis, // Fallback for l10n.pet_action_new_analysis
                     icon: Icons.camera_alt,
                     onTap: onRetake,
                     isPrimary: true,
                   ),
                   const SizedBox(height: 16),
                   // Share (Pink)
                   _buildActionButton(
                     context,
                     label: appL10n.pet_action_share, // Fallback for l10n.pet_action_share
                     icon: Icons.share,
                     onTap: onShare,
                     isPrimary: true,
                   ),
                ],
              ),
            ),
            */
          ],
        ),
      ),
    );
  }

  // ... (Regex and parsing logic remains same) ...

  // --- Helper Methods ---
  
  List<_AnalysisBlock> _parseDynamicCards(String rawResponse) {
    List<_AnalysisBlock> blocks = [];
    final blockRegex = RegExp(PetConstants.regexCardStart, dotAll: true);
    final matches = blockRegex.allMatches(rawResponse);

    for (var match in matches) {
      final body = match.group(1) ?? '';
      
      final title = RegExp(PetConstants.regexTitle).firstMatch(body)?.group(1) ?? PetConstants.keyAnalyse;
      // Robust Content Extraction: Capture everything after CONTENT: including newlines
      final content = RegExp(PetConstants.regexContent, dotAll: true).firstMatch(body)?.group(1) ?? '';
      final iconName = RegExp(PetConstants.regexIcon).firstMatch(body)?.group(1) ?? PetConstants.keyInfo;

      // Debug: Check if content is empty
      if (content.isEmpty && body.contains(PetConstants.tagContent)) {
         // Fallback: If regex failed but tag exists, take everything after CONTENT: manually
         final fallbackContent = body.split(PetConstants.tagContent).last.trim();
         blocks.add(_AnalysisBlock(title: title.trim(), content: fallbackContent, icon: _getIconData(iconName.trim())));
      } else if (content.isNotEmpty) {
         blocks.add(_AnalysisBlock(title: title.trim(), content: content.trim(), icon: _getIconData(iconName.trim())));
      } else {
         // Double Fallback: If no CONTENT tag, try to take the whole body if it's not just title/icon
         if (body.length > 20) {
             blocks.add(_AnalysisBlock(title: title.trim(), content: body.replaceAll(RegExp(PetConstants.regexTitleIcon), '').trim(), icon: _getIconData(iconName.trim())));
         }
      }
    }
    
    if (blocks.isEmpty && rawResponse.isNotEmpty) {
       String clean = rawResponse.replaceAll(RegExp(r'\[SYSTEM\]|\[URGENCY\]|\[SUMMARY\]'), '').trim();
       blocks.add(_AnalysisBlock(title: PetConstants.keyAnalysisSummary, content: clean, icon: Icons.description));
    }

    return blocks;
  }
  
  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case PetConstants.keyHeart: return Icons.favorite;
      case PetConstants.iconWarning:
      case PetConstants.keyAlert: return Icons.warning;
      case PetConstants.keyInfo: return Icons.info;
      case PetConstants.iconDoc: return Icons.description;
      default: return Icons.info;
    }
  }

  List<String> _extractSources(String response) {
    final start = response.indexOf(PetConstants.tagSources);
    if (start == -1) return [];
    
    final content = response.substring(start + PetConstants.tagSources.length);
    final end = content.indexOf(PetConstants.tagEndSources);
    final rawSources = (end != -1) ? content.substring(0, end) : content;
    
    return rawSources.split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.length > 3) // Basic filter
        .toList();
  }

  String _resolveSource(String sourceKey, AppLocalizations appL10n) {
     if (sourceKey.contains(PetConstants.keySourceMerck)) return appL10n.source_merck;
     if (sourceKey.contains(PetConstants.keySourceScanNut)) return appL10n.source_scannut;
     if (sourceKey.contains(PetConstants.keySourceAaha)) return appL10n.source_aaha;
     return sourceKey;
  }

  Widget _buildDynamicCard(_AnalysisBlock block) {
    bool isAlert = block.icon == Icons.warning;
    
    final cardColor = isAlert ? const Color(0xFFFF5252) : AppColors.petPrimary;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.petBackgroundDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
           BoxShadow(
             color: cardColor.withValues(alpha: 0.05),
             blurRadius: 10,
             offset: const Offset(0, 4),
           ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(block.icon, color: cardColor, size: 22), // Pink or Red
              const SizedBox(width: 12),
              Expanded(child: Text(block.title, style: TextStyle(color: cardColor, fontWeight: FontWeight.bold, fontSize: 16))),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            block.content, 
            style: const TextStyle(
              color: Color(0xFFEAF0FF), 
              fontSize: 14, 
              height: 1.5
            )
          ),
        ],
      ),
    );
  }

  // ... (Source Extraction remains) ...

  Widget _buildSourcesCard(BuildContext context, List<String> sources) {
    if (sources.isEmpty) return const SizedBox.shrink();

    final l10n = PetLocalizations.of(context)!;
    final appL10n = AppLocalizations.of(context)!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.petBackgroundDark, // Dark Theme
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.petPrimary.withValues(alpha: 0.5), width: 1), // Pink Border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             children: [
               const Icon(Icons.menu_book, color: AppColors.petPrimary, size: 20), // Pink Icon
               const SizedBox(width: 12),
               Text(
                 l10n.pet_section_sources, 
                 style: const TextStyle(color: AppColors.petPrimary, fontWeight: FontWeight.bold, fontSize: 16)
               ),
             ],
           ),
           const SizedBox(height: 12),
            ...sources.map((src) {
              final resolvedSrc = _resolveSource(src, appL10n);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("• ", style: TextStyle(color: Colors.white54)),
                    Expanded(
                      child: Text(resolvedSrc, style: const TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic)),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ... (resolveSource remains) ...

  Widget _buildStatusHeader(String text, AppLocalizations appL10n) {
    // Keep Semantic Colors for Status Badge (Universal UX)
    bool isCrit = text.toLowerCase().contains(PetConstants.keyCritical) || text.toLowerCase().contains(PetConstants.keyImmediateAttention) || text.toLowerCase().contains('urgency: red');
    bool isWarn = text.toLowerCase().contains(PetConstants.keyMonitor) || text.toLowerCase().contains('urgency: yellow');
    
    Color color = const Color(0xFF10AC84); // Green default
    String label = appL10n.pet_status_healthy_simple;

    if (isCrit) {
       color = const Color(0xFFFF5252);
       label = appL10n.pet_status_critical_simple;
    } else if (isWarn) {
       color = const Color(0xFFFFD700);
       label = appL10n.pet_status_attention_simple;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
           Icon(isCrit ? Icons.report_problem : (isWarn ? Icons.warning : Icons.check_circle), color: Colors.white, size: 16),
           const SizedBox(width: 8),
           Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {required String label, required IconData icon, required VoidCallback onTap, bool isPrimary = true}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20, color: AppColors.petText), // Black Icon
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.petPrimary, // Pink
          foregroundColor: AppColors.petText,    // Black Text
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.petText, width: 1.0), // Black Border
          ),
        ),
      ),
    );
  }

  Widget _buildIdentityBadge(BuildContext context, String name, String breed) {
    // Protocol 2026: Pastel Pink Background + Black Text
    // REFACTORED: Layout Expanded for Multi-line Breed Text
    return Container(
      width: double.infinity, // Occupy full width
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.petPrimary, // Pastel Pink (#FFD1DC)
        borderRadius: BorderRadius.circular(16), // Slightly less rounded for a "Block" feel
        border: Border.all(color: AppColors.petText, width: 1.5), // Black Border
        boxShadow: const [
           BoxShadow(
             color: Colors.black26,
             blurRadius: 4,
             offset: Offset(0, 2),
           )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.pets, color: AppColors.petText, size: 24), // Black Icon
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.petText, // Black Text
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                // Use user's rule: Show breed from variable
                if (breed.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      breed,
                      maxLines: null, // Allow unlimited lines
                      style: const TextStyle(
                        color: AppColors.petText, // Black Text
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _AnalysisBlock {
  final String title;
  final String content;
  final IconData icon;

  _AnalysisBlock({required this.title, required this.content, required this.icon});
}
