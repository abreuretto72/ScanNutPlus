import 'package:flutter/material.dart';
import 'package:scannutplus/core/presentation/widgets/app_scroll_view.dart';
import 'package:scannutplus/l10n/app_localizations.dart';

class ThemeTestPage extends StatelessWidget {
  const ThemeTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Palette Constants (Deep Navy Professional)
    const kBackground = Color(0xFF0B1220);
    const kAppBarIcon = Color(0xFFEAF0FF);
    const kCardBackground = Color(0xFF121A2B);
    const kCardBorder = Color(0xFF22304A);
    const kTextPrimary = Color(0xFFEAF0FF);
    
    // Domain Accents
    const kAccentFood = Color(0xFFC65A1E);
    const kAccentPlant = Color(0xFF2F7D5B);
    const kAccentPet = Color(0xFF1F3A5F);
    
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: kAppBarIcon),
            onPressed: () {}, 
          ),
        ),
      ),
      body: AppScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildThemeCard(l10n.tab_food, kAccentFood, kCardBackground, kCardBorder, kTextPrimary, Icons.restaurant_menu),
              const SizedBox(height: 16),
              _buildThemeCard(l10n.tab_plant, kAccentPlant, kCardBackground, kCardBorder, kTextPrimary, Icons.local_florist),
              const SizedBox(height: 16),
              _buildThemeCard(l10n.tab_pet, kAccentPet, kCardBackground, kCardBorder, kTextPrimary, Icons.pets),
              const SizedBox(height: 16),
              _buildThemeCard(l10n.domain_pets_navigation, kAccentPet, kCardBackground, kCardBorder, kTextPrimary, Icons.explore_outlined),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCard(String title, Color accent, Color bg, Color border, Color text, IconData icon) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12), // Radius 12.0
        border: Border.all(color: border, width: 2.0),
      ),
      child: Row(
        children: [
          // Domain Icon with Accent Color
          Icon(icon, color: accent, size: 32),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: text,
                shadows: const [
                  Shadow(
                    color: Color(0xFF000000), // Pure black for max contrast
                    offset: Offset(2.0, 2.0),
                    blurRadius: 6.0,
                  ),
                  Shadow(
                    color: Color(0xFF000000), // Second layer for outline effect
                    offset: Offset(-1.0, -1.0),
                    blurRadius: 1.0,
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_forward_ios, color: accent, size: 20),
          )
        ],
      ),
    );
  }
}
