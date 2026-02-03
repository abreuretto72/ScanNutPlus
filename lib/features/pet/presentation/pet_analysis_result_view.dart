import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:scannutplus/features/pet/l10n/generated/pet_localizations.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/core/constants/app_keys.dart';
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
    final l10n = PetLocalizations.of(context)!;
    final appL10n = AppLocalizations.of(context)!;

    // Use local variables for access inside methods if needed, or pass contexts


    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17), // Deep Dark Background
      appBar: AppBar(
        title: Text(l10n.pet_result_title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1F3A5F),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView( // Ergonomia SM A256E
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Header
             Container(
              margin: const EdgeInsets.only(bottom: 24),
              height: 220, 
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1F3A5F), width: 2),
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
            
            // Gerador de Cards Estruturados (Strictly localized)
            
            // Gerador de Cards Dinâmico (Protocolo 2026: Flexible AI Response)
            ..._parseDynamicCards(analysisResult).map((block) => _buildDynamicCard(block)),


             // Actions
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Row(
                children: [
                   Expanded(
                    child: _buildActionButton(
                      context,
                      label: l10n.pet_action_new_analysis,
                      icon: LucideIcons.camera,
                      color: const Color(0xFF1F3A5F),
                      onTap: onRetake,
                    ),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                    child: _buildActionButton(
                      context,
                      label: l10n.pet_action_share,
                      icon: LucideIcons.share2,
                      color: const Color(0xFF10AC84),
                      onTap: onShare,
                    ),
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Lógica para limpar tags [VISUAL_SUMMARY], Line 1, etc.
  List<_AnalysisBlock> _parseDynamicCards(String rawResponse) {
    List<_AnalysisBlock> blocks = [];
    
    // Regex para capturar tudo entre [CARD_START] e [CARD_END]
    final blockRegex = RegExp(PetConstants.regexCardStart, dotAll: true);
    final matches = blockRegex.allMatches(rawResponse);

    for (var match in matches) {
      final body = match.group(1) ?? '';
      
      final title = RegExp(PetConstants.regexTitle).firstMatch(body)?.group(1) ?? PetConstants.keyAnalyse;
      final content = RegExp(PetConstants.regexContent, dotAll: true).firstMatch(body)?.group(1) ?? '';
      final iconName = RegExp(PetConstants.regexIcon).firstMatch(body)?.group(1) ?? PetConstants.keyInfo;

      blocks.add(_AnalysisBlock(
        title: title.trim(),
        content: content.trim(),
        icon: _getIconData(iconName.trim()),
      ));
    }
    
    // Fallback: If no blocks found (legacy or error), try old heuristic or create generic block
    if (blocks.isEmpty && rawResponse.isNotEmpty) {
       // Clean up raw response for generic card
       String clean = rawResponse
         .replaceAll(RegExp(r'\[SYSTEM\]|\[URGENCY\]|\[SUMMARY\]'), '')
         .trim();
       blocks.add(_AnalysisBlock(
         title: PetConstants.keyAnalysisSummary, 
         content: clean, 
         icon: LucideIcons.fileText
       ));
    }

    return blocks;
  }

  // Mapeia o nome enviado pela IA para o IconData do Flutter
  IconData _getIconData(String name) {
    switch (name.toLowerCase()) {
      case PetConstants.typePet: return LucideIcons.dog; // Using Lucide
      case PetConstants.keyHeart: return LucideIcons.heart;
      case PetConstants.keyScissors: case PetConstants.keyCoat: return LucideIcons.scissors;
      case PetConstants.keySearch: case PetConstants.keySkin: return LucideIcons.search;
      case PetConstants.keyEar: return LucideIcons.ear;
      case PetConstants.keyWind: case PetConstants.keyNose: return LucideIcons.wind;
      case PetConstants.keyEye: case PetConstants.keyEyes: return LucideIcons.eye;
      case PetConstants.keyScale: case PetConstants.keyBody: return LucideIcons.scale;
      case PetConstants.keyAlert: case PetConstants.keyIssues: return LucideIcons.alertTriangle;
      case PetConstants.keyFileText: case PetConstants.keySummary: return LucideIcons.fileText;
      default: return LucideIcons.info;
    }
  }

  Widget _buildDynamicCard(_AnalysisBlock block) {
    bool isAlert = block.icon == LucideIcons.alertTriangle;
    final accentColor = isAlert ? const Color(0xFFFF5252) : const Color(0xFF10AC84);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: isAlert ? 0.6 : 0.3), width: 1.5),
        boxShadow: [
           BoxShadow(
             color: accentColor.withValues(alpha: 0.05),
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
              Icon(block.icon, color: accentColor, size: 22),
              const SizedBox(width: 12),
              Expanded(child: Text(block.title, style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 16))),
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

  Widget _buildStatusHeader(String text, AppLocalizations appL10n) {
    // Heuristic: Check for Red flag / Critical keywords
    bool isCrit = text.toLowerCase().contains(PetConstants.keyCritical) || text.toLowerCase().contains(PetConstants.keyImmediateAttention) || text.toLowerCase().contains('urgency: red');
    bool isWarn = text.toLowerCase().contains(PetConstants.keyMonitor) || text.toLowerCase().contains('urgency: yellow');
    
    Color color = const Color(0xFF10AC84); // Green default
    String label = appL10n.pet_status_healthy;

    if (isCrit) {
       color = const Color(0xFFFF5252);
       label = appL10n.pet_status_critical;
    } else if (isWarn) {
       color = const Color(0xFFFFD700);
       label = appL10n.pet_status_attention;
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
           Icon(isCrit ? LucideIcons.alertOctagon : (isWarn ? LucideIcons.alertTriangle : LucideIcons.checkCircle), color: Colors.white, size: 16),
           const SizedBox(width: 8),
           Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
