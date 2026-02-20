import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // Alias to avoid conflicts with Flutter widgets
import 'package:printing/printing.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:intl/intl.dart';

class UniversalPdfService {
  // PDF Base Colors (Always White Background for printing/reading)
  static const PdfColor _colorBackground = PdfColor.fromInt(0xFFFFFFFF); // White
  static const PdfColor _colorCardBg = PdfColor.fromInt(0xFFF9F9F9); // Crisp White/Gray for cards
  
  static const PdfColor _colorText = PdfColor.fromInt(0xFF000000); // Black
  static const PdfColor _colorTextDim = PdfColor.fromInt(0xFF666666); // Standard Gray


  
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
    
    // Default to Strong Pink (#FC2D7C) if no dynamic color is provided
    final accentColor = colorValue != null ? PdfColor.fromInt(colorValue) : PdfColor.fromInt(0xFFFC2D7C);
    
    // Load Image (Optional)
    pw.MemoryImage? image;
    if (filePath != null && filePath.isNotEmpty) {
      final file = File(filePath);
      if (file.existsSync()) {
         try {
           final imageBytes = await file.readAsBytes();
           image = pw.MemoryImage(imageBytes);
         } catch (e) {
           debugPrint('[PDF_WARN] Could not load image (likely video or unsupported format): $e');
           image = null;
         }
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

    // --- PDF TRACE LOGS ---
    debugPrint('[PDF_TRACE] Generating PDF for: $pageTitle');
    debugPrint('[PDF_TRACE] Analysis Result Length: ${analysisResult.length}');
    debugPrint('[PDF_TRACE] Cards Parsed: ${cards.length}');
    if (cards.isNotEmpty) {
       for (var i = 0; i < cards.length; i++) {
          debugPrint('[PDF_TRACE] Card $i Title: ${cards[i]['title']}');
          debugPrint('[PDF_TRACE] Card $i Content Length: ${cards[i]['content']?.length ?? 0}');
       }
    } else {
       debugPrint('[PDF_TRACE] No Cards found! Using Fallback Mode (Full Text Dump).');
    }
    // ---------------------

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4.applyMargin(left: 1.0 * PdfPageFormat.cm, top: 1.0 * PdfPageFormat.cm, right: 1.0 * PdfPageFormat.cm, bottom: 1.0 * PdfPageFormat.cm),
          theme: pw.ThemeData.withFont(
            base: await PdfGoogleFonts.robotoRegular(),
            bold: await PdfGoogleFonts.robotoBold(),
            fontFallback: [await PdfGoogleFonts.notoColorEmoji()], // Renderize Emojis properly
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
            child: pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Nome: $name', style: pw.TextStyle(color: _colorText, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Raça: $breed', style: pw.TextStyle(color: _colorText, fontSize: 14)),
                  ],
                ),
                if (petDetails.containsKey('friend_name')) ...[
                   pw.Divider(color: accentColor, thickness: 0.5),
                   pw.Row(
                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                     children: [
                        pw.Text('Amigo Presente: ${petDetails['friend_name']}', style: pw.TextStyle(color: _colorText, fontSize: 13, fontWeight: pw.FontWeight.bold)),
                        if (petDetails.containsKey('tutor_name'))
                          pw.Text('Tutor(a): ${petDetails['tutor_name']}', style: pw.TextStyle(color: _colorText, fontSize: 12)),
                     ]
                   )
                ]
              ]
            ),
          ),
          pw.SizedBox(height: 20),

          // 3. Analysis Cards (Flattened List for Pagination)
          if (cards.isNotEmpty)
             ...cards.expand((card) => _buildCard(card, accentColor))
          else if (analysisResult.isNotEmpty)
             // Fallback for unstructured reports (Health/Nutrition)
             // FIX: Split huge text into paragraphs to allow MultiPage to handle pagination safely.
             // FIX 2: Remove [SOURCES] block from body to prevent duplication.
             ..._removeSourcesBlock(analysisResult).replaceAll('\r\n', '\n').split('\n').map((line) {
                if (line.trim().isEmpty) return pw.SizedBox(height: 3); // Reduced from 5
                
                // Simple Bold detection for lines that look like headers
                final isHeader = line.trim().length < 60 && (line.trim().endsWith(':') || !line.trim().contains('. '));
                
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 1, horizontal: 10), // Reduced spacing
                  child: pw.Text(
                    _sanitizeText(line),
                    style: isHeader 
                        ? pw.TextStyle(color: accentColor, fontSize: 11, fontWeight: pw.FontWeight.bold) // Sligthly smaller header
                        : pw.TextStyle(color: _colorText, fontSize: 10, lineSpacing: 1.3), // Tighter line spacing
                    textAlign: isHeader ? pw.TextAlign.left : pw.TextAlign.justify
                  )
                );
             }),
          
          // 4. Sources Section
           if (_extractSources(analysisResult).isNotEmpty) ...[
              pw.SizedBox(height: 10), // Reduced from 20
              pw.Wrap(
                 children: [
                    pw.Text('Referências Científicas:', style: pw.TextStyle(color: accentColor, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Divider(color: accentColor, thickness: 0.5),
                 ]
              ),
              ..._extractSources(analysisResult).map((s) => pw.Bullet(text: s, style: pw.TextStyle(color: _colorTextDim, fontSize: 9))),
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

  static List<pw.Widget> _buildCard(Map<String, String> card, PdfColor accentColor) {
    // SAFE LAYOUT V2: Return a List of widgets so MultiPage can handle pagination for each element individually.
    // DO NOT use Column/Container wrappers for the *entire* card content.
    
    return [
        // 1. Header (Partitioned) - Keep this distinct
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 0, vertical: 5),
          decoration: const pw.BoxDecoration(
             border: pw.Border(bottom: pw.BorderSide(color: _colorTextDim, width: 0.5)),
          ),
          child: pw.Row(
              children: [
                pw.Text(_getIconSymbol(card['icon']), style: const pw.TextStyle(fontSize: 14)),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: pw.Text(
                    _sanitizeText(card['title'] ?? 'Section').toUpperCase(), 
                    style: pw.TextStyle(color: accentColor, fontSize: 10, fontWeight: pw.FontWeight.bold)
                  ),
                ),
              ],
            ),
        ),
        
        // 2. Content (Flowable) - Direct child of MultiPage allows splitting!
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8, bottom: 12),
          child: pw.Text(
            _sanitizeText(card['content'] ?? ''), 
            style: const pw.TextStyle(color: _colorText, fontSize: 10, lineSpacing: 1.5),
            textAlign: pw.TextAlign.justify
          ),
        ),
    ];
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
      int end = rawResponse.indexOf('[END_SOURCES]');
      if (end == -1) {
         // Fallback: Check for Metadata start or End of string logic
         end = rawResponse.indexOf('[METADATA]');
      }
      if (end == -1) {
         // Final Fallback: End of String (if reasonable length)
         if (rawResponse.length - start < 500) { 
            end = rawResponse.length;
         } else {
             return []; // Too risky
         }
      }
      
      if (end < start) return [];
      
      final sourceBlock = rawResponse.substring(start, end).trim();
      List<String> rawList;

      if (sourceBlock.contains('\n')) {
         rawList = sourceBlock.split('\n');
      } else {
         rawList = sourceBlock.split(',');
      }

      return rawList
          .map((s) => s.replaceAll(RegExp(r'^[\-\*]|\d+\.\s*'), '').trim()) // Cleanup bullets
          .where((s) => s.length > 3)
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Basic Sanitizer for Universal PDF (Simple replacement)
  static String _sanitizeText(String? text) {
      if (text == null) return '';
      // 1. Specific Replacements (Keep context for known icons if needed, or just strip all)
      // For stability, we will strip ALL emojis that don't have a specific text equivalent yet.
      
      return text
        .replaceAll(RegExp(r'\*\*|__'), '') // Remove Markdown
        // Remove Internal AI Tags if they leak into fallback text
        .replaceAll(RegExp(r'\[CARD_START\]|\[CARD_END\]|\[VISUAL_SUMMARY\]|\[END_SUMMARY\]|\[SOURCES\]|\[END_SOURCES\]|\[METADATA\]|\[END_METADATA\]', caseSensitive: false), '')
        .replaceAll(RegExp(r'(?:TITLE|TÍTULO):|(?:ICON|ÍCONE|ICONE):|(?:CONTENT|CONTEÚDO|CONTEUDO):', caseSensitive: false), '')
        .trim();
  }

  // Helper Methods
  static String _removeSourcesBlock(String text) {
    // Case Insensitive Removal using Regex
    final regex = RegExp(r'\[SOURCES\]', caseSensitive: false);
    final match = regex.firstMatch(text);
    if (match != null) {
      return text.substring(0, match.start).trim();
    }
    
    final metadataRegex = RegExp(r'\[METADATA\]', caseSensitive: false);
    final metaMatch = metadataRegex.firstMatch(text);
    if (metaMatch != null) {
       return text.substring(0, metaMatch.start).trim();
    }
    
    return text;
  }
}
