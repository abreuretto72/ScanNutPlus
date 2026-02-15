import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/features/pet/l10n/generated/pet_localizations.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';

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
    // Regex para pegar os cards interpretativos do OCR
    final blockRegex = RegExp(r'\[CARD_START\](.*?)\[CARD_END\]', dotAll: true);
    final matches = blockRegex.allMatches(rawResponse);

    for (var match in matches) {
      final body = match.group(1) ?? '';
      final title = RegExp(r'TITLE:\s*(.*)').firstMatch(body)?.group(1) ?? 'Dado Extraído';
      final content = RegExp(r'CONTENT:\s*(.*)', dotAll: true).firstMatch(body)?.group(1) ?? '';
      final iconName = RegExp(r'ICON:\s*(.*)').firstMatch(body)?.group(1) ?? 'description';

      blocks.add(_OcrBlock(
        title: title.trim(),
        content: content.trim(),
        icon: _getOcrIcon(iconName.trim()),
      ));
    }
    return blocks;
  }

  IconData _getOcrIcon(String icon) {
    if (icon.contains('🔬') || icon.contains('lab')) return Icons.biotech;
    if (icon.contains('💊') || icon.contains('med')) return Icons.medication;
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
              Text(block.title, style: const TextStyle(color: AppColors.petPrimary, fontWeight: FontWeight.bold)),
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
    if (!response.contains('[SOURCES]')) return [];
    return response.split('[SOURCES]').last.trim().split('\n').where((s) => s.length > 5).toList();
  }

  Widget _buildSourcesCard(BuildContext context, List<String> sources) {
    if (sources.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Referências de Valores", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...sources.map((s) => Text(s, style: const TextStyle(color: Colors.white38, fontSize: 11))),
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