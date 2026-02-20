import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:scannutplus/core/services/universal_pdf_service.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/l10n/app_localizations.dart'; // Added for l10n
import 'package:pdf/pdf.dart';

class UniversalPdfPreviewScreen extends StatelessWidget {
  final String? filePath;
  final String? analysisResult;
  final Map<String, String>? petDetails;
  final Future<Uint8List> Function(PdfPageFormat)? customBuilder;
  final String title;

  const UniversalPdfPreviewScreen({
    super.key,
    this.filePath,
    this.analysisResult,
    this.petDetails,
    this.customBuilder,
    this.title = 'PDF Preview',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.petBackgroundDark,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PdfPreview(
        build: (format) {
          if (customBuilder != null) {
            return customBuilder!(format);
          }
           // Fallback to existing logic if params are present
          if (analysisResult != null && petDetails != null) {
             final l10n = AppLocalizations.of(context)!;
              return UniversalPdfService.generatePdf(
              format,
              filePath, // Can be null
              analysisResult!,
              petDetails!,
              footerText: l10n.pdf_footer_text,
              pageLabel: l10n.pdf_page_label,
              ofLabel: l10n.pdf_of_label,
              colorValue: 0xFFFC2D7C, // ALWAYS force Strong Pink
            );
          }
          return Future.value(Uint8List(0)); // Should handle error ideally
        },
        pdfFileName: 'ScanNut_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        maxPageWidth: 700,
        actions: [
            // Custom actions can be added here if needed, but PdfPreview provides sharing/printing by default
        ],
        scrollViewDecoration: const BoxDecoration(
            color: Colors.white,
        ),
      ),
    );
  }
}
