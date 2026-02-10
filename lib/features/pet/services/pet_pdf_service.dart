import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

/// Pet Domain PDF Service
/// Adheres to Protocolo Master 2026 for Pet branding.
class PetPdfService {
  static const String _kLogoPath = 'assets/images/app_logo.png';
  static const PdfColor _kBrandColor = PdfColor.fromInt(0xFF6A4D8C); // Pet Purple
  static const PdfColor _kBackgroundColor = PdfColor.fromInt(0xFF1E1E1E); // Dark Background
  static const PdfColor _kTextColor = PdfColors.white; 

  Future<Uint8List> generatePetReport({
    required String analysisResult,
    required String imagePath, // path to image logic if needed
    required String title,
    required String appName,
    required String copyright,
    required String pageLabel,
    required String sourcesLabel,
  }) async {
    final pdf = pw.Document();
    
    // Load Logo
    final logoData = await rootBundle.load(_kLogoPath);
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    // Formatting
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final nowStr = dateFormat.format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(32),
          buildBackground: (context) => pw.Container(color: _kBackgroundColor), 
          theme: pw.ThemeData.withFont(
            base: pw.Font.courier(),
            bold: pw.Font.courierBold(),
          ),
        ),
        header: (context) => _buildHeader(logoImage, appName, nowStr),
        footer: (context) => _buildFooter(context, copyright, pageLabel),
        build: (context) => [
          pw.Header(
            level: 1,
            child: pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: _kBrandColor)),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            analysisResult,
            style: const pw.TextStyle(color: _kTextColor, fontSize: 12),
          ),
          pw.SizedBox(height: 20),
          pw.Divider(color: _kBrandColor),
          pw.SizedBox(height: 10),
          pw.Text(
            sourcesLabel,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _kBrandColor),
          ),
           pw.Text(
            "• Google Gemini Vet Knowledge Base 2024\n• ScanNut Multiverso Digital", // Placeholder/Static for now, or extracted from analysis if available
            style: const pw.TextStyle(color: PdfColors.grey400, fontSize: 10),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(pw.MemoryImage logo, String appName, String dateTime) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
             pw.Container(
               height: 40,
               width: 40,
               child: pw.Image(logo),
             ),
             pw.Column(
               crossAxisAlignment: pw.CrossAxisAlignment.end,
               children: [
                 pw.Text(
                   appName,
                   style: pw.TextStyle(
                     fontSize: 18,
                     fontWeight: pw.FontWeight.bold,
                     color: _kBrandColor,
                   ),
                 ),
                 pw.Text(
                   dateTime,
                   style: const pw.TextStyle(
                     fontSize: 10,
                     color: PdfColors.grey400,
                   ),
                 ),
               ],
             ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(color: _kBrandColor, thickness: 1),
        pw.SizedBox(height: 20),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context, String copyright, String pageLabel) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey700, thickness: 0.5),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              "$pageLabel ${context.pageNumber} | $copyright",
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
            ),
          ],
        ),
      ],
    );
  }
}

final petPdfService = PetPdfService();
