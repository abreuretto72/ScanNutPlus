import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // Alias to avoid conflicts with Flutter widgets
import 'package:printing/printing.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:intl/intl.dart';

class UniversalPdfService {
  // Domain Colors
  static const PdfColor _colorBackground = PdfColor.fromInt(0xFFFFFFFF); // White
  static const PdfColor _colorCardBg = PdfColor.fromInt(0xFFF5F5F5); // Very Light Gray
  static const PdfColor _colorAccent = PdfColor.fromInt(0xFFFF4081); // Darker Pink for visibility on White (or keep 0xFFFFD1DC if using as bg)
  // Let's use a slightly darker pink for text/borders on white to ensure contrast, or keep the original if it's just an accent.
  // Original Pink: 0xFFFFD1DC (Light Pink). On white, this is very faint.
  // Let's use a standard ScanNut Pink or maybe a bit darker.
  // Actually, let's keep the exact requested "Rosa Claro" (Pastel) for backgrounds/borders but maybe darker for text?
  // User said "respeitando a cor do domínio que é ros claro".
  // I will keep the accent as is, but maybe use black for text.
  static const PdfColor _colorAccentLine = PdfColor.fromInt(0xFFFF80AB); // Slightly darker pink for lines if needed
  
  static const PdfColor _colorText = PdfColor.fromInt(0xFF000000); // Black
  static const PdfColor _colorTextDim = PdfColor.fromInt(0xFF666666); // Dark Gray


  
  static Future<Uint8List> generatePdf(
    PdfPageFormat format,
    String filePath,
    String analysisResult,
    Map<String, String> petDetails,
  ) async {
    final pdf = pw.Document();
    
    // Load Image
    final imageBytes = await File(filePath).readAsBytes();
    final image = pw.MemoryImage(imageBytes);

    // Font Loading (Standard or custom if needed)
    // For now using standard fonts to ensure compatibility
    
    // Parse Cards for Structured Data
    final cards = _parseCards(analysisResult);
    
    // Pet Info
    final name = petDetails[PetConstants.fieldName] ?? 'Unknown Pet';
    final breed = petDetails[PetConstants.fieldBreed] ?? 'Unknown Breed';
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    
    // Dynamic Title (e.g. "ScanNut+: Avaliação da Condição Corporal" or fallback)
    final moduleName = petDetails[PetConstants.keyPageTitle];
    final pageTitle = moduleName != null 
        ? 'ScanNut+: $moduleName' 
        : 'Relatório ScanNut+';

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(
            base: await PdfGoogleFonts.robotoRegular(),
            bold: await PdfGoogleFonts.robotoBold(),
          ),
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(color: _colorBackground),
          ),
        ),
        header: (context) => _buildHeader(pageTitle, dateStr),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          // 1. Image Section
          pw.Container(
            height: 200,
            width: double.infinity,
            alignment: pw.Alignment.center,
            decoration: pw.BoxDecoration(
               border: pw.Border.all(color: _colorAccent, width: 2),
               borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Image(image, fit: pw.BoxFit.contain),
          ),
          pw.SizedBox(height: 20),
          
          // 2. Identity Section
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: _colorCardBg,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: _colorAccent),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Nome: $name', style: pw.TextStyle(color: _colorText, fontSize: 14)),
                pw.Text('Raça: $breed', style: pw.TextStyle(color: _colorText, fontSize: 14)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // 3. Analysis Cards
          ...cards.map((card) => _buildCard(card)),
          
          // 4. Sources Section
           if (_extractSources(analysisResult).isNotEmpty) ...[
              pw.SizedBox(height: 20),
              pw.Text('Referências Científicas:', style: pw.TextStyle(color: _colorAccent, fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Divider(color: _colorAccent),
              ..._extractSources(analysisResult).map((s) => pw.Bullet(text: s, style: pw.TextStyle(color: _colorTextDim, fontSize: 10))),
           ]
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(String title, String date) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _colorAccent, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title, style: pw.TextStyle(color: _colorAccent, fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
               pw.Text('Data: $date', style: pw.TextStyle(color: _colorText, fontSize: 10)),
               pw.Text('Protocolo Master 2026', style: pw.TextStyle(color: _colorTextDim, fontSize: 8)),
            ]
          )
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _colorAccent, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: const pw.TextStyle(color: _colorTextDim, fontSize: 8),
          ),
          pw.Text(
            '© 2026 ScanNut Multiverso Digital | contato@multiversodigital.com.br',
            style: const pw.TextStyle(color: _colorAccent, fontSize: 8),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCard(Map<String, String> card) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _colorCardBg,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: _colorAccent, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              // Icon Placeholder (Text based for now as icons are tricky in PDF without font)
              pw.Container(
                width: 20, height: 20, 
                decoration: const pw.BoxDecoration(shape: pw.BoxShape.circle, color: _colorAccent),
                alignment: pw.Alignment.center,
                child: pw.Text('•', style: const pw.TextStyle(color: _colorBackground))
              ),
              pw.SizedBox(width: 8),
              pw.Text(card['title'] ?? 'Section', style: pw.TextStyle(color: _colorAccent, fontSize: 14, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Text(card['content'] ?? '', style: pw.TextStyle(color: _colorText, fontSize: 10)),
        ],
      ),
    );
  }

  // Helper Parsing Methods (Duplicated logic from View but adapted for Map structure)
  static List<Map<String, String>> _parseCards(String rawResponse) {
    List<Map<String, String>> blocks = [];
    final blockRegex = RegExp(PetConstants.regexCardStart, dotAll: true);
    final matches = blockRegex.allMatches(rawResponse);

    for (var match in matches) {
      final body = match.group(1) ?? '';
      
      final title = RegExp(PetConstants.regexTitle, caseSensitive: false).firstMatch(body)?.group(1) ?? 'Análise';
      final contentRaw = RegExp(PetConstants.regexContent, dotAll: true, caseSensitive: false).firstMatch(body)?.group(1) ?? '';
      final cleanContent = contentRaw.replaceAll(RegExp(r'(?:ICON|ÍCONE|ICONE|Ícone|Icone):|(?:CONTENT|CONTEÚDO|CONTEUDO|Conteúdo|Conteudo):', caseSensitive: false), '').trim();
      final iconName = RegExp(PetConstants.regexIcon, caseSensitive: false).firstMatch(body)?.group(1) ?? 'info';

      if (cleanContent.isNotEmpty) {
          blocks.add({'title': title.trim(), 'content': cleanContent, 'icon': iconName.trim()});
      }
    }
    return blocks;
  }
  
  static List<String> _extractSources(String rawResponse) {
    if (!rawResponse.contains('[SOURCES]')) return [];
    final sourceBlock = rawResponse.split('[SOURCES]').last.trim();
    return sourceBlock.split('\n').where((s) => s.length > 5).toList();
  }
}
