import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/features/pet/l10n/generated/pet_localizations.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/presentation/universal_pdf_preview_screen.dart';

class UniversalOcrResultView extends StatelessWidget {
  final String imagePath;
  final String ocrResult; // O JSON + Cards vindos do motor de OCR
  final Map<String, String>? petDetails;

  const UniversalOcrResultView({
    super.key,
    required this.imagePath,
    required this.ocrResult,
    this.petDetails,
  });

  @override
  Widget build(BuildContext context) {
    final appL10n = AppLocalizations.of(context)!;
    
    // Identidade do Pet (Seguindo seu protocolo de Badge Rosa)
    final String displayPetName = petDetails?[PetConstants.fieldName] ?? appL10n.pet_unknown;
    final String displayBreed = petDetails?[PetConstants.fieldBreed] ?? appL10n.pet_breed_unknown;

    return Scaffold(
      backgroundColor: AppColors.petBackgroundDark,
      appBar: AppBar(
        title: Text(appL10n.pet_initial_assessment, // Ou "Digitalização de Exame"
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: AppColors.petPrimary),
            tooltip: 'Gerar PDF',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UniversalPdfPreviewScreen(
                    filePath: imagePath,
                    analysisResult: ocrResult,
                    petDetails: {
                      PetConstants.fieldName: displayPetName,
                      PetConstants.fieldBreed: displayBreed,
                      PetConstants.keyPageTitle: appL10n.pet_initial_assessment,
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview do Documento Digitalizado
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.black45, // Moved from DecorationImage
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.petPrimary.withAlpha(100), width: 2),
                image: DecorationImage(
                  image: FileImage(File(imagePath)),
                  fit: BoxFit.contain, // Contain para ver o documento todo
                ),
              ),
            ),

            // Badge de Identidade (Rosa Pastel + Texto Preto)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: _buildIdentityBadge(displayPetName, displayBreed),
            ),

            // Título da Seção de Resultados
            const Padding(
              padding: EdgeInsets.only(bottom: 16, left: 4),
              child: Text("DADOS EXTRAÍDOS DO EXAME", 
                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),

            // Cards de Interpretação (Extraídos do OCR)
            if (_parseOcrCards(ocrResult).isEmpty)
              _buildRawTextFallback(ocrResult)
            else
              ..._parseOcrCards(ocrResult).map((block) => _buildOcrDataCard(block)),

            // Seção de Fontes (Validação Científica do OCR)
            _buildSourcesCard(context, _extractSources(ocrResult)),
          ],
        ),
      ),
    );
  }

  // --- Lógica de UI e Parsing ---

  List<_OcrBlock> _parseOcrCards(String rawResponse) {
    List<_OcrBlock> blocks = [];
    Set<String> seenTitles = {}; // DEDUPLICATION ENFORCED

    final blockRegex = RegExp(PetConstants.regexCardStart, dotAll: true);
    final matches = blockRegex.allMatches(rawResponse);

    for (var match in matches) {
      final body = match.group(1) ?? '';
      // Use Polyglot Regex
      final title = RegExp(PetConstants.regexTitle, caseSensitive: false).firstMatch(body)?.group(1)?.trim() ?? 'Dado Extraído';
      
      // STRICT DEDUPLICATION
      if (seenTitles.contains(title.toLowerCase())) continue;
      seenTitles.add(title.toLowerCase());

      final content = RegExp(PetConstants.regexContent, dotAll: true, caseSensitive: false).firstMatch(body)?.group(1) ?? '';
      
      // Clean up potential tags in content
      final cleanContent = content.replaceAll(RegExp(r'(?:ICON|ÍCONE|ICONE|Ícone|Icone):|(?:CONTENT|CONTEÚDO|CONTEUDO|Conteúdo|Conteudo):', caseSensitive: false), '').trim();
      
      final iconName = RegExp(PetConstants.regexIcon, caseSensitive: false).firstMatch(body)?.group(1) ?? 'description';

      if (cleanContent.isNotEmpty) {
        blocks.add(_OcrBlock(
          title: title,
          content: cleanContent,
          icon: _getOcrIcon(iconName.trim()),
        ));
      } else {
         // NUCLEAR FALLBACK
         final fallback = body.replaceAll(RegExp(r'(?:TITLE|TITULO|TÍTULO|Título|Titulo):|(?:ICON|ÍCONE|ICONE|Ícone|Icone):|(?:CONTENT|CONTEÚDO|CONTEUDO|Conteúdo|Conteudo):', caseSensitive: false), '').trim();
         if (fallback.length > 5) {
             debugPrint('[SCAN_NUT_TRACE] OCR Fallback Triggered. Content: ${fallback.substring(0, 10)}...');
             blocks.add(_OcrBlock(
                title: title,
                content: fallback,
                icon: _getOcrIcon(iconName.trim()),
             ));
         }
      }
      debugPrint('[SCAN_NUT_TRACE] OCR Card Parsed -> Title: $title | Icon: $iconName | ContentLen: ${content.length}');
    }
    
    if (blocks.isEmpty) {
       debugPrint('[SCAN_NUT_WARN] No OCR Cards found via Regex. Raw Response Dump: $rawResponse');
    }
    
    return blocks;
  }
  
  // ... (Methods skipped for brevity)

  IconData _getOcrIcon(String icon) {
    final lower = icon.toLowerCase();
    if (lower.contains('🔬') || lower.contains('lab') || lower.contains('biotech')) return Icons.biotech;
    if (lower.contains('💊') || lower.contains('med')) return Icons.medication;
    if (lower.contains('🌿') || lower.contains('florist') || lower.contains('plant')) return Icons.local_florist;
    if (lower.contains('⚠️') || lower.contains('warning') || lower.contains('alert')) return Icons.warning;
    if (lower.contains('✅') || lower.contains('check') || lower.contains('ok')) return Icons.check_circle;
    return Icons.description;
  }

  Widget _buildOcrDataCard(_OcrBlock block) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Darker Grey para contraste de dados
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(block.icon, color: AppColors.petPrimary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(block.title, 
                  style: const TextStyle(color: AppColors.petPrimary, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 20),
          Text(block.content, 
            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5, fontFamily: 'monospace')), // Monospace para parecer dado técnico
        ],
      ),
    );
  }

  Widget _buildIdentityBadge(String name, String breed) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.petPrimary, // Rosa Pastel
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.petText, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.assignment_ind, color: AppColors.petText),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(color: AppColors.petText, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(breed, style: const TextStyle(color: AppColors.petText, fontSize: 13, fontStyle: FontStyle.italic)),
            ],
          ),
        ],
      ),
    );
  }

  List<String> _extractSources(String response) {
    // Robust Regex to find [SOURCES], **[SOURCES]**, [SOURCES]: etc.
    final match = RegExp(r'\[SOURCES\]', caseSensitive: false).firstMatch(response);
    
    if (match == null) {
        debugPrint('[SCAN_NUT_WARN] No [SOURCES] block found. Using DEFAULT FALLBACK.');
        return PetConstants.defaultVerificationSources; // FIX: Returns defaults instead of empty
    }
    
    // Split from the start of the match
    final sourceText = response.substring(match.end).trim();
    
    // Split by newlines and clean up bullets
    final sources = sourceText.split('\n')
        .where((s) => s.trim().length > 5) // Filter empty lines
        .map((s) => s.replaceAll(RegExp(r'^[-*]\s*'), '').trim()) // Remove leading bullets
        .toList();
    
    debugPrint('[SCAN_NUT_TRACE] Extracted ${sources.length} sources.');
    return sources.isNotEmpty ? sources : PetConstants.defaultVerificationSources; // FALLBACK
  }

  Widget _buildSourcesCard(BuildContext context, List<String> sources) {
    if (sources.isEmpty) return const SizedBox.shrink();
    
    // Helper to map keys to text if they are keys
    String getSourceText(String s) {
        if (s == PetConstants.keySourceMerck) return "Merck Veterinary Manual";
        if (s == PetConstants.keySourceAaha) return "AAHA Nutritional Guidelines";
        if (s == PetConstants.keySourceScanNut) return "ScanNut Validation Database";
        return s;
    }

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black45, // Slightly darker for footer feel
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
             Icon(Icons.menu_book, color: Colors.white54, size: 16),
             SizedBox(width: 8),
             Text("Fontes Científicas & Regulatórias", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          ...sources.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("• ", style: TextStyle(color: AppColors.petPrimary)),
                Expanded(child: Text(getSourceText(s), style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.3))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRawTextFallback(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4, fontFamily: 'monospace'),
      ),
    );
  }
}

class _OcrBlock {
  final String title;
  final String content;
  final IconData icon;
  _OcrBlock({required this.title, required this.content, required this.icon});
}