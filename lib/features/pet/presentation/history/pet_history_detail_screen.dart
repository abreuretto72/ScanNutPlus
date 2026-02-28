import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scannutplus/features/pet/data/models/pet_history_entry.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/l10n/generated/pet_localizations.dart';
import 'package:scannutplus/features/pet/presentation/universal_pdf_preview_screen.dart';

class PetHistoryDetailScreen extends StatelessWidget {
  final PetHistoryEntry entry;

  const PetHistoryDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImageHeader(context),
            // Reconstruct Cards
            ...entry.analysisCards.map((cardData) => _buildDynamicCard(cardData)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final l10n = PetLocalizations.of(context)!;
    return AppBar(
      title: Text(l10n.pet_result_title, style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: const Color(0xFF1F3A5F),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.picture_as_pdf, color: Colors.blue), // Blue Icon
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UniversalPdfPreviewScreen(
                  filePath: entry.imagePath,
                  analysisResult: entry.rawJson,
                  petDetails: {
                     PetConstants.fieldName: entry.petName,
                     // Extract breed if available or use generic
                     PetConstants.fieldBreed: PetConstants.legacyUnknownBreed, 
                     PetConstants.keyPageTitle: PetLocalizations.of(context)!.pet_result_title,
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildImageHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F3A5F), width: 2),
        image: DecorationImage(
          image: FileImage(File(entry.imagePath)),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) => const Icon(Icons.broken_image),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 12,
            right: 12,
            child: _buildStatusBadge(entry.category),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _formatDate(context, entry.timestamp),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String type) {
    // Simplified status badge based on type or derived logic
    Color color = const Color(0xFF10AC84);
    IconData icon = Icons.check_circle;
    String text = type.toUpperCase();

    if (type == PetConstants.keyCritical) {
      color = const Color(0xFFFF5252);
      icon = Icons.report_problem;
    } else if (type == PetConstants.keyMonitor) {
      color = const Color(0xFFFFD700);
      icon = Icons.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicCard(Map<String, dynamic> cardData) {
    final title = cardData[PetConstants.keyTitle] ?? '';
    final content = cardData[PetConstants.keyContent] ?? '';
    final iconKey = cardData[PetConstants.keyIcon] ?? '';
    final icon = _getIconData(iconKey);

    // Style logic matching ResultView
    final isAlert = icon == Icons.warning;
    final isSource = icon == Icons.menu_book;
    
    final accentColor = isAlert 
        ? const Color(0xFFFF5252) 
        : (isSource ? Colors.white70 : const Color(0xFF10AC84));
    
    final bgColor = isSource 
        ? Colors.white.withValues(alpha: 0.05) 
        : accentColor.withValues(alpha: 0.05);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isSource ? Colors.white24 : accentColor.withValues(alpha: isAlert ? 0.6 : 0.3), 
            width: 1.5
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title, 
                  style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 16)
                )
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
                color: isSource ? Colors.white38 : const Color(0xFFEAF0FF), 
                fontSize: isSource ? 12 : 14, 
                height: 1.5,
                fontStyle: isSource ? FontStyle.italic : FontStyle.normal
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name.toLowerCase()) {
      case PetConstants.typePet: return Icons.pets;
      case PetConstants.keyHeart: return Icons.favorite;
      case PetConstants.keyCoat: return Icons.content_cut;
      case PetConstants.keySkin: return Icons.search;
      case PetConstants.keyEar: return Icons.hearing;
      case PetConstants.keyWind: case PetConstants.keyNose: return Icons.air;
      case PetConstants.keyEye: case PetConstants.keyEyes: return Icons.visibility;
      case PetConstants.keyScale: case PetConstants.keyBody: return Icons.monitor_weight;
      case PetConstants.keyAlert: case PetConstants.keyIssues: return Icons.warning;
      case PetConstants.keyFileText: case PetConstants.keySummary: return Icons.description;
      case PetConstants.iconMenuBook: case PetConstants.iconBook: return Icons.menu_book;
      default: return Icons.info;
    }
  }

  String _formatDate(BuildContext context, DateTime date) {
    return DateFormat.yMd(Localizations.localeOf(context).languageCode).add_Hm().format(date);
  }
}
