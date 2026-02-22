import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
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
    
    // [FALLBACK PROTOCOLO 2026] Absolute Friend State Recovery
    bool isFriend = petDetails?[PetConstants.keyIsFriend] == 'true';
    if (!isFriend && ocrResult.contains('[METADATA]')) {
       isFriend = true;
    }
    
    final String tutorName = petDetails?[PetConstants.keyTutorName] ?? '';

    return Scaffold(
      backgroundColor: AppColors.petBackgroundDark,
      appBar: AppBar(
        title: Text(appL10n.ocr_scan_title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: AppColors.petPrimary),
            tooltip: appL10n.action_generate_pdf,
            onPressed: () {
              // Extract Variables Fallback Protocol 2026
              bool isFriend = petDetails?[PetConstants.keyIsFriend] == 'true';
              if (!isFriend && ocrResult.contains('[METADATA]')) isFriend = true;
              
              String tutorName = petDetails?[PetConstants.keyTutorName] ?? '';
              String myPetName = petDetails?['my_pet_name'] ?? '';
              
              if (isFriend && (tutorName.isEmpty || myPetName.isEmpty)) {
                 if (ocrResult.contains('[METADATA]')) {
                    if (tutorName.isEmpty) {
                       final tutorMatch = RegExp(r'tutor_name:\s*(.*?)(?=\n|$)').firstMatch(ocrResult);
                       if (tutorMatch != null) tutorName = tutorMatch.group(1)?.trim() ?? '';
                    }
                    if (myPetName.isEmpty) {
                       final myPetMatch = RegExp(r'my_pet_name:\s*(.*?)(?=\n|$)').firstMatch(ocrResult);
                       if (myPetMatch != null) myPetName = myPetMatch.group(1)?.trim() ?? '';
                    }
                 }
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UniversalPdfPreviewScreen(
                    filePath: imagePath,
                    analysisResult: ocrResult,
                    petDetails: {
                      PetConstants.fieldName: displayPetName,
                      PetConstants.fieldBreed: displayBreed,
                      PetConstants.keyPageTitle: petDetails?[PetConstants.keyPageTitle] ?? appL10n.pet_initial_assessment,
                      if (isFriend) ...{
                         PetConstants.keyIsFriend: 'true',
                         PetConstants.keyTutorName: tutorName,
                         'friend_name': displayPetName,
                         'my_pet_name': myPetName,
                      }
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
            
            // [ANALYSIS TYPE LABEL]
            if (petDetails?[PetConstants.keyPageTitle] != null)
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Center(
                  child: Text(
                    petDetails![PetConstants.keyPageTitle]!.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.petPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),

            // Badge de Identidade (Rosa Pastel + Texto Preto)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: _buildIdentityBadge(context, displayPetName, displayBreed, isFriend: isFriend, tutorName: tutorName),
            ),

            // Título da Seção de Resultados
            Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 4),
              child: Text(appL10n.ocr_extracted_data_title, 
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),

            // Cards de Interpretação (Extraídos do OCR)
            if (_parseOcrCards(ocrResult, appL10n).isEmpty)
              _buildRawTextFallback(ocrResult)
            else
              ..._parseOcrCards(ocrResult, appL10n).map((block) => _buildOcrDataCard(block)),

            // Seção de Fontes (Validação Científica do OCR)
            _buildSourcesCard(context, _extractSources(ocrResult)),

            // AI Disclaimer Footer
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
              child: Text(
                appL10n.ai_disclaimer_footer,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Lógica de UI e Parsing ---

  List<_OcrBlock> _parseOcrCards(String rawResponse, AppLocalizations appL10n) {
    List<_OcrBlock> blocks = [];
    Set<String> seenTitles = {}; // DEDUPLICATION ENFORCED

    final blockRegex = RegExp(PetConstants.regexCardStart, dotAll: true);
    final matches = blockRegex.allMatches(rawResponse);

    for (var match in matches) {
      final body = match.group(1) ?? '';
      // Use Polyglot Regex
      final title = RegExp(PetConstants.regexTitle, caseSensitive: false).firstMatch(body)?.group(1)?.trim() ?? appL10n.ocr_extracted_item;
      
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
          MarkdownBody(
            data: block.content,
            selectable: true,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5, fontFamily: 'monospace'),
              strong: const TextStyle(color: AppColors.petPrimary, fontWeight: FontWeight.bold),
              tableBody: const TextStyle(color: Colors.white, fontSize: 12),
              tableHead: const TextStyle(color: AppColors.petPrimary, fontWeight: FontWeight.bold),
              tableBorder: TableBorder.all(color: Colors.white24, width: 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityBadge(BuildContext context, String name, String breed, {bool isFriend = false, String tutorName = ''}) {
    final String analysisName = petDetails?[PetConstants.keyPageTitle] ?? AppLocalizations.of(context)!.general_analysis;
    String myPetName = petDetails?['my_pet_name'] ?? '';
    
    // [FALLBACK PROTOCOLO 2026]
    // If dictionary arguments are dropped by the Route navigator, we forcefully rip them from the raw AI result.
    // Ensure isFriend is overridden if metadata exists
    if (ocrResult.contains('[METADATA]')) {
       isFriend = true;
    }
    
    if (isFriend && (tutorName.isEmpty || myPetName.isEmpty)) {
       final resultText = ocrResult;
       if (resultText.contains('[METADATA]')) {
          if (tutorName.isEmpty) {
             final tutorMatch = RegExp(r'tutor_name:\s*(.*?)(?=\n|$)').firstMatch(resultText);
             if (tutorMatch != null) tutorName = tutorMatch.group(1)?.trim() ?? '';
          }
          if (myPetName.isEmpty) {
             final myPetMatch = RegExp(r'my_pet_name:\s*(.*?)(?=\n|$)').firstMatch(resultText);
             if (myPetMatch != null) myPetName = myPetMatch.group(1)?.trim() ?? '';
          }
       }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.petPrimary, // Rosa Pastel
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.petText, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.assignment_ind, color: AppColors.petText, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isFriend) ...[
                   // Linha 1: [nome da analise]: [nome do pet amigo] (Anti-duplicidade)
                   Text(
                       analysisName.toLowerCase().contains(name.toLowerCase()) ? analysisName : "$analysisName: $name", 
                       style: const TextStyle(color: AppColors.petText, fontWeight: FontWeight.bold, fontSize: 16)
                   ),
                   // Linha 2: [nome do tutor]
                   if (tutorName.isNotEmpty)
                     Padding(
                       padding: const EdgeInsets.only(top: 4.0),
                       child: Text("${AppLocalizations.of(context)!.label_tutor_name}: $tutorName", style: const TextStyle(color: AppColors.petText, fontSize: 14, fontStyle: FontStyle.italic)),
                     ),
                   // Linha 3: [nome do meu pet]
                   if (myPetName.isNotEmpty)
                     Padding(
                       padding: const EdgeInsets.only(top: 2.0),
                       child: Text("${AppLocalizations.of(context)!.pdf_my_pet_name_prefix}: $myPetName", style: const TextStyle(color: AppColors.petText, fontSize: 14, fontStyle: FontStyle.italic)),
                     ),
                ] else ...[
                   Text(name, style: const TextStyle(color: AppColors.petText, fontWeight: FontWeight.bold, fontSize: 16)),
                   if (breed.isNotEmpty)
                     Text(breed, style: const TextStyle(color: AppColors.petText, fontSize: 13, fontStyle: FontStyle.italic)),
                ],
              ],
            ),
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
             const Icon(Icons.menu_book, color: Colors.white54, size: 16),
             const SizedBox(width: 8),
             Text(AppLocalizations.of(context)!.ocr_scientific_sources, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
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