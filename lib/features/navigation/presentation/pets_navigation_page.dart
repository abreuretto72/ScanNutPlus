import 'package:flutter/material.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/l10n/app_localizations.dart';

class PetsNavigationPage extends StatelessWidget {
  const PetsNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(l10n.domain_pets_navigation, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_walk, size: 80, color: const Color(0xFFFFD1DC)),
            const SizedBox(height: 16),
            Text(
              l10n.pets_navigation_subtitle,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 18),
            ),
            const SizedBox(height: 32),
            Text(l10n.stub_map_module, style: const TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}
