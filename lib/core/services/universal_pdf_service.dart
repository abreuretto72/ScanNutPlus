import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // Alias to avoid conflicts with Flutter widgets
import 'package:printing/printing.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:intl/intl.dart';

class UniversalPdfService {
  static const PdfColor _colorBackground = PdfColor.fromInt(0xFFFFFFFF); // White
  static const PdfColor _colorCardBg = PdfColor.fromInt(0xFFF5F5F5); // Very Light Gray
  
  static const PdfColor _colorText = PdfColor.fromInt(0xFF000000); // Black
  static const PdfColor _colorTextDim = PdfColor.fromInt(0xFF666666); // Dark Gray


  
  static Future<Uint8List> generatePdf(
    PdfPageFormat format,
    String? filePath,
    String analysisResult,
    Map<String, String> petDetails, {
    required String footerText,
    required String pageLabel,
    required String ofLabel,
    int? colorValue, // Dynamic Accent Color
  }) async {
    final pdf = pw.Document();
    
    final accentColor = colorValue != null ? PdfColor.fromInt(colorValue) : PdfColor.fromInt(0xFFFF4081);
    
    // Load Image (Optional)
    pw.MemoryImage? image;
    if (filePath != null && filePath.isNotEmpty) {
      final file = File(filePath);
      if (file.existsSync()) {
         final imageBytes = await file.readAsBytes();
         image = pw.MemoryImage(imageBytes);
      }
    }

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
          pageFormat: PdfPageFormat.a4.applyMargin(left: 1.0 * PdfPageFormat.cm, top: 1.0 * PdfPageFormat.cm, right: 1.0 * PdfPageFormat.cm, bottom: 1.0 * PdfPageFormat.cm),
          theme: pw.ThemeData.withFont(
            base: await PdfGoogleFonts.robotoRegular(),
            bold: await PdfGoogleFonts.robotoBold(),
          ),
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(color: _colorBackground),
          ),
        ),
        header: (context) => _buildHeader(pageTitle, dateStr, accentColor),
        footer: (context) => _buildFooter(context, footerText, pageLabel, ofLabel, accentColor),
        build: (context) => [
          // 1. Image Section (Conditional)
          if (image != null)
            pw.Container(
              height: 200,
              width: double.infinity,
              alignment: pw.Alignment.center,
              decoration: pw.BoxDecoration(
                 border: pw.Border.all(color: accentColor, width: 2),
                 borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Image(image, fit: pw.BoxFit.contain),
            ),
          if (image != null) pw.SizedBox(height: 20),
          
          // 2. Identity Section
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: _colorCardBg,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: accentColor),
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
          if (cards.isNotEmpty)
             ...cards.map((card) => _buildCard(card, accentColor))
          else if (analysisResult.isNotEmpty)
             // Fallback for unstructured reports (Health/Nutrition)
             pw.Padding(
               padding: const pw.EdgeInsets.all(12),
               child: pw.Text(
                 _sanitizeText(analysisResult), // Basic sanitization
                 style: pw.TextStyle(color: _colorText, fontSize: 12)
               ),
             ),
          
          // 4. Sources Section
           if (_extractSources(analysisResult).isNotEmpty) ...[
              pw.SizedBox(height: 20),
              pw.Text('Referências Científicas:', style: pw.TextStyle(color: accentColor, fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Divider(color: accentColor),
              ..._extractSources(analysisResult).map((s) => pw.Bullet(text: s, style: pw.TextStyle(color: _colorTextDim, fontSize: 10))),
           ]
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(String title, String date, PdfColor accentColor) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: accentColor, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title, style: pw.TextStyle(color: accentColor, fontSize: 20, fontWeight: pw.FontWeight.bold)),
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

  static pw.Widget _buildFooter(pw.Context context, String footerText, String pageLabel, String ofLabel, PdfColor accentColor) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: accentColor, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '$pageLabel ${context.pageNumber} $ofLabel ${context.pagesCount}',
            style: const pw.TextStyle(color: _colorTextDim, fontSize: 8),
          ),
          pw.Text(
            footerText,
            style: pw.TextStyle(color: accentColor, fontSize: 8),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCard(Map<String, String> card, PdfColor accentColor) {
    // WRAP: Using Wrap or just Column is fine, but Container with borders sometimes causes split issues if content is huge.
    // OPTIMIZATION: Use pw.Partitions or just simple Column with Spans if possible, but Card style is requested.
    // FIX: Ensure the inner Container for content does NOT have a fixed height (it doesn't).
    // The issue might be the decoration causing issues on split.
    // Let's try splitting the header and content into separate widgets in the list if possible, or just keeping them together but allowing wrap.
    // pw.Container can wrap if it's not in a constrained parent.
    
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _colorCardBg, width: 0.0), // Invisible border to help layout? No.
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // 1. Header (Compact)
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Reduced padding
            decoration: pw.BoxDecoration(
              color: _colorCardBg,
              borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(6)), // Smaller radius
              border: pw.Border.all(color: accentColor, width: 0.5),
            ),
            child: pw.Row(
              children: [
                pw.Container(
                  width: 20, height: 20, // Smaller icon container
                  decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: accentColor),
                  alignment: pw.Alignment.center,
                  child: pw.Text(_getIconSymbol(card['icon']), style: const pw.TextStyle(color: _colorBackground, fontSize: 12))
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: pw.Text(
                    _sanitizeText(card['title'] ?? 'Section'), 
                    style: pw.TextStyle(color: accentColor, fontSize: 12, fontWeight: pw.FontWeight.bold) // Smaller font
                  ),
                ),
              ],
            ),
          ),
          // 2. Content (Compact)
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.fromLTRB(10, 8, 10, 12), // Tighter content padding
            decoration: pw.BoxDecoration(
               border: pw.Border.fromBorderSide(pw.BorderSide(color: accentColor, width: 0.5)),
            ),
            child: pw.Text(
              _sanitizeText(card['content'] ?? ''), 
              style: pw.TextStyle(color: _colorText, fontSize: 10, lineSpacing: 1.5) // Smaller font and tighter line spacing
            ),
          ),
          pw.SizedBox(height: 8), // Reduced gap between cards
        ],
      )
    );
  }

  static String _getIconSymbol(String? iconName) {
     final lower = iconName?.toLowerCase() ?? '';
     if (lower.contains('map')) return '📍';
     if (lower.contains('fire')) return '🔥';
     if (lower.contains('tree') || lower.contains('plant') || lower.contains('florist')) return '🌿';
     if (lower.contains('cal')) return '📅';
     if (lower.contains('heart')) return '♥';
     if (lower.contains('biotech') || lower.contains('lab')) return '🔬';
     if (lower.contains('med')) return '💊';
     if (lower.contains('warn') || lower.contains('alert')) return '!';
     if (lower.contains('check')) return '✓';
     if (lower.contains('food') || lower.contains('bowl')) return '🍲';
     return '•';
  }

  // Helper Parsing Methods (Duplicated logic from View but adapted for Map structure)
  static List<Map<String, String>> _parseCards(String rawResponse) {
    List<Map<String, String>> blocks = [];
    // Improved Parsing Logic matched to UniversalOcrResultView
    try {
      final blockRegex = RegExp(PetConstants.regexCardStart, dotAll: true);
      final matches = blockRegex.allMatches(rawResponse);

      for (var match in matches) {
        final body = match.group(1) ?? '';
        
        // Robust Title
        final title = RegExp(PetConstants.regexTitle, caseSensitive: false).firstMatch(body)?.group(1)?.trim() ?? 'Seção';
        
        // Robust Content
        final content = RegExp(PetConstants.regexContent, dotAll: true, caseSensitive: false).firstMatch(body)?.group(1) ?? '';
        String cleanContent = content.replaceAll(RegExp(r'(?:ICON|ÍCONE|ICONE|Ícone|Icone):|(?:CONTENT|CONTEÚDO|CONTEUDO|Conteúdo|Conteudo):', caseSensitive: false), '').trim();
        
        final iconName = RegExp(PetConstants.regexIcon, caseSensitive: false).firstMatch(body)?.group(1) ?? 'info';

        if (cleanContent.isNotEmpty) {
             blocks.add({'title': title, 'content': cleanContent, 'icon': iconName.trim()});
        }
      }
    } catch (e) {
       // Silent Fallback
    }
    return blocks.isNotEmpty ? blocks : [];
  }
  
  static List<String> _extractSources(String rawResponse) {
    if (!rawResponse.contains('[SOURCES]')) return [];
    try {
      final start = rawResponse.indexOf('[SOURCES]') + '[SOURCES]'.length;
      final end = rawResponse.indexOf('[END_SOURCES]');
      if (end == -1 || end < start) return [];
      
      final sourceBlock = rawResponse.substring(start, end).trim();
      return sourceBlock.split('\n')
          .map((s) => s.trim())
          .where((s) => s.length > 3) // Basic length check
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Basic Sanitizer for Universal PDF (Simple replacement)
  static String _sanitizeText(String? text) {
      if (text == null) return '';
      return text
        // Extended Emoji Support
        .replaceAll('🥩', '[Carne]')
        .replaceAll('🍗', '[Frango]')
        .replaceAll('🥦', '[Vegetais]')
        .replaceAll('💊', '[Sup]')
        .replaceAll('⚠️', '[ATENÇÃO]')
        .replaceAll('🚨', '[CRÍTICO]')
        .replaceAll('✅', '[OK]')
        .replaceAll('❌', '[X]')
        .replaceAll('🩺', '[Exame]')
        .replaceAll('💉', '[Vacina]')
        .replaceAll('🦠', '[Parasita]')
        .replaceAll('📋', '[Prontuário]')
        .replaceAll('🥗', '[Dieta]')
        .replaceAll('🛒', '[Compras]')
        .replaceAll('📅', '[Agenda]')
        .replaceAll('🏥', '[Saúde]')
        .replaceAll('📉', '[Baixa]')
        .replaceAll('📈', '[Alta]')
        .replaceAll('⚖️', '[Peso]')
        .replaceAll('🐕', '[Cão]')
        .replaceAll('🐈', '[Gato]')
        .replaceAll('🍚', '[Arroz]')
        .replaceAll('🥕', '[Cenoura]')
        .replaceAll('🍎', '[Fruta]')
        .replaceAll('📍', '[Local]')
        .replaceAll('⛰️', '[Alt]')
        .replaceAll('🌳', '[Parque]')
        .replaceAll('☀️', '[Sol]')
        .replaceAll('🔥', '[Cal]')
        .replaceAll('💧', '[H2O]')
        .replaceAll('🐾', '[Patas]');
  }
}
