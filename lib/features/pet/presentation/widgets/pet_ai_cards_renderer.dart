import 'package:flutter/material.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/features/pet/l10n/generated/pet_localizations.dart';

class PetAiCardsRenderer extends StatelessWidget {
  final String analysisResult;

  const PetAiCardsRenderer({
    super.key,
    required this.analysisResult,
  });

  @override
  Widget build(BuildContext context) {
    if (analysisResult.isEmpty) return const SizedBox.shrink();

    final cards = _parseDynamicCards(context, analysisResult);

    if (cards.isEmpty) {
      // Fallback if no cards found but text exists
      return Container(
         padding: const EdgeInsets.all(16),
         decoration: BoxDecoration(
           color: AppColors.petBackgroundDark,
           borderRadius: BorderRadius.circular(20),
           border: Border.all(color: Colors.white24),
         ),
         child: Text(
           analysisResult, 
           style: const TextStyle(color: Colors.white, height: 1.5)
         ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...cards.map((block) => _buildDynamicCard(block)),
        _buildSourcesCard(context, _extractSources(analysisResult)),
      ],
    );
  }

  // ... (existing _parseDynamicCards) ...

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

  Widget _buildSourcesCard(BuildContext context, List<String> sources) {
    if (sources.isEmpty) return const SizedBox.shrink();

    // Use safe access for PetLocalizations as it might not be generated/available in all contexts if not initialized properly,
    // although assuming standard usage it should be fine. AppLocalizations is standard.
    // If PetLocalizations is null, fallback to hardcoded string or empty.
    final l10n = PetLocalizations.of(context);
    final appL10n = AppLocalizations.of(context)!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.petBackgroundDark, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.petPrimary.withValues(alpha: 0.5), width: 1), 
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             children: [
               const Icon(Icons.menu_book, color: AppColors.petPrimary, size: 20), 
               const SizedBox(width: 12),
               Text(
                 l10n?.pet_section_sources ?? 'References', 
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

  List<_AnalysisBlock> _parseDynamicCards(BuildContext context, String rawResponse) {
    List<_AnalysisBlock> blocks = [];

    // 1. Extract Visual Summary (Protocol 2026)
    final visualSummaryRegex = RegExp(r'\[VISUAL_SUMMARY\](.*?)\[END_SUMMARY\]', dotAll: true);
    final visualMatch = visualSummaryRegex.firstMatch(rawResponse);
    if (visualMatch != null) {
      blocks.add(_AnalysisBlock(
        title: AppLocalizations.of(context)!.pet_analysis_visual_title, 
        content: visualMatch.group(1)?.trim() ?? '',
        icon: Icons.visibility,
      ));
    }

    final blockRegex = RegExp(PetConstants.regexCardStart, dotAll: true);
    final matches = blockRegex.allMatches(rawResponse);

    for (var match in matches) {
      final body = match.group(1) ?? '';
      
      final title = RegExp(PetConstants.regexTitle).firstMatch(body)?.group(1) ?? PetConstants.keyAnalyse;
      final content = RegExp(PetConstants.regexContent, dotAll: true).firstMatch(body)?.group(1) ?? '';
      
      // [SANITIZER] Remove structural tags from the content to be displayed
      final cleanContent = content.replaceAll(RegExp(r'(ICON:|CONTENT:)'), '').trim();

      final iconName = RegExp(PetConstants.regexIcon).firstMatch(body)?.group(1) ?? PetConstants.keyInfo;

      if (cleanContent.isEmpty && body.contains(PetConstants.tagContent)) {
         var fallbackContent = body.split(PetConstants.tagContent).last.trim();
         fallbackContent = fallbackContent.replaceAll(RegExp(r'(ICON:|CONTENT:)'), '').trim();
         blocks.add(_AnalysisBlock(title: title.trim(), content: fallbackContent, icon: _getIconData(iconName.trim())));
      } else if (cleanContent.isNotEmpty) {
         blocks.add(_AnalysisBlock(title: title.trim(), content: cleanContent, icon: _getIconData(iconName.trim())));
      } else {
         if (body.length > 20) {
             blocks.add(_AnalysisBlock(title: title.trim(), content: body.replaceAll(RegExp(PetConstants.regexTitleIcon), '').trim(), icon: _getIconData(iconName.trim())));
         }
      }
    }
    
    // Also try to capture Visual Summary if cards are present but we want to show it?
    // User requested "fix [CARD_START]".
    // For now, let's stick to the exact logic from PetAnalysisResultView to ensure consistency.
    
    if (blocks.isEmpty && rawResponse.isNotEmpty) {
       // Only if NO cards were found at all, we fallback to showing cleaned text as a summary card
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
      case PetConstants.valIconPet: return Icons.pets;
      default: return Icons.info;
    }
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
              Icon(block.icon, color: cardColor, size: 22), 
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
}

class _AnalysisBlock {
  final String title;
  final String content;
  final IconData icon;

  _AnalysisBlock({required this.title, required this.content, required this.icon});
}
