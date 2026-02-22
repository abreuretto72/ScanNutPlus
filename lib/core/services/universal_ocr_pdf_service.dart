import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class UniversalOcrPdfService {
  static const PdfColor _colorBackground = PdfColor.fromInt(0xFFFFFFFF);
  static const PdfColor _colorText = PdfColor.fromInt(0xFF000000);
  static const PdfColor _colorAccent = PdfColor.fromInt(0xFFFC2D7C); // Strong Pink (Pet Domain)
  static const PdfColor _colorTableBorder = PdfColor.fromInt(0xFFCCCCCC);
  static const PdfColor _colorTableHeader = PdfColor.fromInt(0xFFF9F9F9);

  static Future<Uint8List> generatePdf(
    PdfPageFormat format,
    String? filePath,
    String analysisResult,
    Map<String, String> petDetails,
    AppLocalizations l10n,
  ) async {
    final pdf = pw.Document();
    
    // Load Image
    pw.MemoryImage? image;
    if (filePath != null && filePath.isNotEmpty) {
      final file = File(filePath);
      if (file.existsSync()) {
         final imageBytes = await file.readAsBytes();
         image = pw.MemoryImage(imageBytes);
      }
    }

    // Font Loading
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontMono = await PdfGoogleFonts.robotoMonoRegular();

    final theme = pw.ThemeData.withFont(base: fontRegular, bold: fontBold);

    // Pet Info
    final name = petDetails[PetConstants.fieldName] ?? l10n.error_unknown;
    final breed = petDetails[PetConstants.fieldBreed] ?? l10n.error_unknown;
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          theme: theme,
          pageFormat: format.applyMargin(left: 2.0 * PdfPageFormat.cm, top: 2.0 * PdfPageFormat.cm, right: 2.0 * PdfPageFormat.cm, bottom: 2.0 * PdfPageFormat.cm),
        ),
        header: (context) => _buildHeader(dateStr, l10n),
        footer: (context) => _buildFooter(context, l10n),
        build: (context) => [
          // 1. Identity
          _buildIdentitySection(name, breed, image),
          pw.SizedBox(height: 20),

          // 2. Content (Parsed with Tables)
          ..._parseAndBuildContent(analysisResult, fontMono, fontBold, l10n),
          
          // 3. Signature / Disclaimer
          pw.SizedBox(height: 30),
          pw.Divider(color: PdfColors.grey300),
          pw.Text(l10n.pdf_report_disclaimer, 
            style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 8),
            textAlign: pw.TextAlign.center
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(String date, AppLocalizations l10n) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _colorAccent, width: 2)),
      ),
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(l10n.pdf_analysis_report, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _colorAccent)),
          pw.Text(date, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context, AppLocalizations l10n) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      alignment: pw.Alignment.centerRight,
      child: pw.Text(l10n.pdf_page_count(context.pageNumber, context.pagesCount), style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
    );
  }

  static pw.Widget _buildIdentitySection(String name, String breed, pw.MemoryImage? image) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (image != null)
          pw.Container(
            width: 60,
            height: 60,
            margin: const pw.EdgeInsets.only(right: 15),
            decoration: pw.BoxDecoration(
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.grey300),
              image: pw.DecorationImage(image: image, fit: pw.BoxFit.cover),
            ),
          ),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(name, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Text(breed, style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
            ],
          ),
        ),
      ],
    );
  }

  static List<pw.Widget> _parseAndBuildContent(String text, pw.Font fontMono, pw.Font fontBold, AppLocalizations l10n) {
    final widgets = <pw.Widget>[];
    final lines = text.split('\n');
    
    // Any line with at least two '|' characters is highly likely a Markdown table row
    final tableLineRegex = RegExp(r'\|.*\|');

    List<pw.TableRow> tableRows = [];

    void flushTable() {
      if (tableRows.isEmpty) return;
      
      widgets.add(
        pw.Table(
          border: pw.TableBorder.all(color: _colorTableBorder, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(3), // Parameter
            1: const pw.FlexColumnWidth(1.5), // Value
            2: const pw.FlexColumnWidth(1.5), // Ref
            3: const pw.FixedColumnWidth(40), // Status
          },
          children: tableRows,
        ),
      );
      widgets.add(pw.SizedBox(height: 15));
      tableRows = [];
    }

    // State flags for parsing
    bool inSourceSection = false;

    for (var i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      
      // 1. Skip Empty & Noise
      if (line.isEmpty) {
        flushTable();
        continue;
      }
      
      // 2. Strip Internal Tags / Metadata
      if (line.startsWith('PART ') || 
          line.contains('[CARD_START]') || 
          line.contains('[CARD_END]') ||
          line.contains('[VISUAL_SUMMARY]')) {
         continue;
      }

      // 3. Handle Sources Section (Visual Break)
      if (line.contains('[SOURCES]')) {
         flushTable();
         inSourceSection = true;
         widgets.add(pw.SizedBox(height: 10));
         widgets.add(pw.Divider(color: _colorAccent, thickness: 0.5));
         widgets.add(pw.Text(l10n.pdf_references_sources, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _colorAccent)));
         widgets.add(pw.SizedBox(height: 5));
         continue;
      }

      // 4. Handle Table Rows
      if (tableLineRegex.hasMatch(line)) {
        // Parse cells
        if (line.startsWith('|')) line = line.substring(1);
        if (line.endsWith('|')) line = line.substring(0, line.length - 1);
        
        final cells = line.split('|').map((s) => s.trim()).toList();
        
        // Skip separator
        if (cells.any((c) => c.contains('---'))) continue;

        // Header Detection (First row of block)
        final isHeader = tableRows.isEmpty;
        
        tableRows.add(
          pw.TableRow(
            decoration: isHeader ? const pw.BoxDecoration(color: _colorAccent) : null,
            children: cells.map((c) {
               // Assuming the last column might be a status column
               bool isStatusCol = cells.indexOf(c) == cells.length - 1 && cells.length >= 2;
               return isStatusCol ? _buildStatusCell(c, isHeader) : _buildCell(c, isHeader, fontBold, alignLeft: cells.indexOf(c) == 0);
            }).toList(),
          )
        );

      } else {
        flushTable();

        // 5. Transform specific keys (TITLE, CONTENT)
        if (line.toUpperCase().startsWith('TITLE:') || line.toUpperCase().startsWith('TÍTULO:')) {
           final title = line.replaceFirst(RegExp(r'(?:TITLE|TÍTULO):\s*', caseSensitive: false), '').trim();
           // Render as Card Header
           widgets.add(pw.Container(
             width: double.infinity,
             padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 8),
             decoration: const pw.BoxDecoration(
               color: PdfColors.grey200,
               border: pw.Border(left: pw.BorderSide(color: _colorAccent, width: 3))
             ),
             child: pw.Text(title, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black))
           ));
           widgets.add(pw.SizedBox(height: 8));
           continue;
        }

        // Remove CONTENT: prefix if present, but keep the text
        if (line.toUpperCase().startsWith('CONTENT:') || line.toUpperCase().startsWith('CONTEÚDO:')) {
           line = line.replaceFirst(RegExp(r'(?:CONTENT|CONTEÚDO|CONTEUDO):\s*', caseSensitive: false), '').trim();
        }
        
        // Remove ICON: line completely (rendered visually if needed, but usually redundant in PDF text flow)
        if (line.toUpperCase().startsWith('ICON:') || line.toUpperCase().startsWith('ÍCONE:')) {
           continue;
        }

        // 6. Process Normal Text (with Bold support)
        if (line.startsWith('#')) {
           final heading = line.replaceAll('#', '').trim();
           widgets.add(pw.Padding(
             padding: const pw.EdgeInsets.only(top: 10, bottom: 5),
             child: pw.Text(heading, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _colorAccent)),
           ));
        } 
        else if (line.contains('**')) {
             widgets.add(pw.RichText(
                text: _parseRichTextSpan(line, fontBold, fontSize: inSourceSection ? 9 : 10),
                textAlign: pw.TextAlign.justify
             ));
             widgets.add(pw.SizedBox(height: 4));
        }
        else {
           // Standard Paragraph
           widgets.add(pw.Text(
             line, 
             style: pw.TextStyle(fontSize: inSourceSection ? 9 : 10, lineSpacing: 1.4, color: inSourceSection ? PdfColors.grey700 : PdfColors.black)
           ));
           widgets.add(pw.SizedBox(height: 4));
        }
      }
    }
    flushTable();

    return widgets;
  }

  static pw.Widget _buildCell(String text, bool isHeader, pw.Font fontBold, {bool alignLeft = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      alignment: alignLeft ? pw.Alignment.centerLeft : pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: isHeader ? PdfColors.white : PdfColors.black,
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : null,
          font: isHeader ? fontBold : null,
        ),
        textAlign: alignLeft ? pw.TextAlign.left : pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildStatusCell(String text, bool isHeader) {
    if (isHeader) return _buildCell(text, true, pw.Font.courier()); // Placeholder font, ignored
    
    // Check for Emojis/Status
    PdfColor? dotColor;
    if (text.contains('🔴') || text.contains('🟥')) {
      dotColor = PdfColors.red;
    } else if (text.contains('🟢') || text.contains('🟩')) dotColor = PdfColors.green;
    else if (text.contains('🟡') || text.contains('🟨')) dotColor = PdfColors.amber;
    
    if (dotColor != null) {
       return pw.Container(
         alignment: pw.Alignment.center,
         padding: const pw.EdgeInsets.all(5),
         child: pw.Container(
           width: 8,
           height: 8,
           decoration: pw.BoxDecoration(
             color: dotColor,
             shape: pw.BoxShape.circle,
           ),
         ),
       );
    }
    
    return _buildCell(text, false, pw.Font.courier());
  }

  static pw.TextSpan _parseRichTextSpan(String line, pw.Font fontBold, {double fontSize = 10}) {
     final spans = <pw.TextSpan>[];
     final regex = RegExp(r'\*\*(.*?)\*\*');
     int start = 0;
     
     for (var match in regex.allMatches(line)) {
        if (match.start > start) {
           spans.add(pw.TextSpan(text: line.substring(start, match.start), style: pw.TextStyle(fontSize: fontSize)));
        }
        spans.add(pw.TextSpan(text: match.group(1), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: fontBold, fontSize: fontSize)));
        start = match.end;
     }
     
     if (start < line.length) {
        spans.add(pw.TextSpan(text: line.substring(start), style: pw.TextStyle(fontSize: fontSize)));
     }
     return pw.TextSpan(children: spans);
  }
}
