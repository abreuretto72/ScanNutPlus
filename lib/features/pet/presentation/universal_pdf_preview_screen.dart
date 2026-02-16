import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:scannutplus/core/services/universal_pdf_service.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:pdf/pdf.dart';

class UniversalPdfPreviewScreen extends StatelessWidget {
  final String filePath;
  final String analysisResult;
  final Map<String, String> petDetails;

  const UniversalPdfPreviewScreen({
    super.key,
    required this.filePath,
    required this.analysisResult,
    required this.petDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.petBackgroundDark,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PdfPreview(
        build: (format) => UniversalPdfService.generatePdf(
          format,
          filePath,
          analysisResult,
          petDetails,
        ),
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
