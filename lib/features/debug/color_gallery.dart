import 'package:flutter/material.dart';
import 'package:scannutplus/core/presentation/widgets/app_scroll_view.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/l10n/app_localizations.dart';

class ColorGallery extends StatelessWidget {
  const ColorGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundDark, // #121212
      appBar: AppBar(
        title: Text(l10n.debug_gallery_title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AppScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTestCard(
                label: l10n.test_food,
                backgroundColor: const Color(0xFFE67E22),
                borderColor: const Color(0xFF935116),
              ),
              const SizedBox(height: 20),
              _buildTestCard(
                label: l10n.test_plants,
                backgroundColor: const Color(0xFF27AE60),
                borderColor: const Color(0xFF1D8348),
              ),
              const SizedBox(height: 20),
              _buildTestCard(
                label: l10n.test_pets,
                backgroundColor: const Color(0xFFEC407A),
                borderColor: const Color(0xFFAD1457),
              ),
              const SizedBox(height: 20),
              _buildTestCard(
                label: l10n.test_navigation,
                backgroundColor: const Color(0xFFD81B60),
                borderColor: const Color(0xFF880E4F),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestCard({
    required String label,
    required Color backgroundColor,
    required Color borderColor,
  }) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 2.5, color: borderColor),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white, // Standardized White
          shadows: [
            Shadow(
              offset: const Offset(1.1, 1.1),
              blurRadius: 2.0,
              color: Colors.black54, // Better contrast for white text
            ),
          ],
        ),
      ),
    );
  }
}
