import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:scannutplus/l10n/app_localizations.dart';


class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Deep Navy Professional Theme
    const backgroundColor = Color(0xFF0B1220);
    const cardColor = Color(0xFF121A2B);
    const borderColor = Color(0xFF22304A);
    const textColor = Color(0xFFEAF0FF);
    const shadowStyle = [
      Shadow(color: Colors.black, offset: Offset(2.0, 2.0), blurRadius: 4.0),
      Shadow(color: Colors.black, offset: Offset(-0.5, -0.5), blurRadius: 1.0),
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(l10n.help_title, style: TextStyle(color: textColor, shadows: shadowStyle)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Intro Icon
              const Center(
                child: Icon(LucideIcons.helpCircle, size: 64, color: textColor),
              ),
              const SizedBox(height: 32),


              const SizedBox(height: 16),
              
              // Privacy Section
              _buildExpansionTile(
                theme, l10n.help_privacy_policy, l10n.help_privacy_content, cardColor, borderColor, textColor, shadowStyle
              ),
              const SizedBox(height: 16),

              // Story Section

              // Story Section
              _buildExpansionTile(
                theme, l10n.help_story_title, l10n.help_origin_story, cardColor, borderColor, textColor, shadowStyle
              ),
              const SizedBox(height: 32),

              // Domain Guide (How to Use)
              Text(
                l10n.help_how_to_use,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  shadows: shadowStyle,
                ),
              ),
              const SizedBox(height: 16),
              
              // Pet Domain Tile
              _buildDomainTile(
                theme,
                Icons.pets,
                l10n.help_domain_pet_title,
                l10n.help_domain_pet_desc,
                const Color(0xFF6A4D8C), // Purple Accent
                cardColor,
                borderColor,
                textColor,
                shadowStyle,
              ),
              const SizedBox(height: 16),

              // Food Domain Tile
              _buildDomainTile(
                theme,
                Icons.restaurant,
                l10n.help_domain_food_title,
                l10n.help_domain_food_desc,
                const Color(0xFFFF9800), // Orange Accent
                cardColor,
                borderColor,
                textColor,
                shadowStyle,
              ),
              const SizedBox(height: 16),

              // Plant Domain Tile
              _buildDomainTile(
                theme,
                LucideIcons.leaf,
                l10n.help_domain_plant_title,
                l10n.help_domain_plant_desc,
                const Color(0xFF10AC84), // Green Accent
                cardColor,
                borderColor,
                textColor,
                shadowStyle,
              ),
              const SizedBox(height: 32),

              // Technical Analysis Guide Header
              Text(
                l10n.help_analysis_guide_title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  shadows: shadowStyle,
                ),
              ),
              const SizedBox(height: 16),

              // Analysis Sections
              _buildAnalysisTile(theme, l10n.help_section_pet_title, l10n.help_section_pet_desc, cardColor, borderColor, textColor, shadowStyle),
              const SizedBox(height: 8),
              _buildAnalysisTile(theme, l10n.help_section_stool_title, l10n.help_section_stool_desc, cardColor, borderColor, textColor, shadowStyle),
              const SizedBox(height: 8),
              _buildAnalysisTile(theme, l10n.help_section_wound_title, l10n.help_section_wound_desc, cardColor, borderColor, textColor, shadowStyle),
              const SizedBox(height: 8),
              _buildAnalysisTile(theme, l10n.help_section_mouth_title, l10n.help_section_mouth_desc, cardColor, borderColor, textColor, shadowStyle),
              const SizedBox(height: 8),
              _buildAnalysisTile(theme, l10n.help_section_eyes_title, l10n.help_section_eyes_desc, cardColor, borderColor, textColor, shadowStyle),
              const SizedBox(height: 8),
              _buildAnalysisTile(theme, l10n.help_section_skin_title, l10n.help_section_skin_desc, cardColor, borderColor, textColor, shadowStyle),
              
              const SizedBox(height: 16),
              // Disclaimer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.alertTriangle, color: Colors.amber, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.help_disclaimer,
                        style: const TextStyle(color: Colors.amber, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Contact Section
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: ListTile(
                  title: Text(l10n.help_contact_support, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, shadows: shadowStyle)),
                  subtitle: const Text("contato@multiversodigital.com.br", style: TextStyle(color: Color(0xFFA9B4CC))),
                  trailing: const Icon(LucideIcons.mail, color: textColor),
                  onTap: () => _launchEmail(context),
                ),
              ),


              const SizedBox(height: 48),
              Text(
                l10n.help_dev_info,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF5F6A80), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionTile(
    ThemeData theme,
    String title,
    String content,
    Color cardColor,
    Color borderColor,
    Color textColor,
    List<Shadow> shadowStyle,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              shadows: shadowStyle,
            ),
          ),
          iconColor: textColor,
          collapsedIconColor: textColor,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                content,
                style: const TextStyle(color: Color(0xFFA9B4CC), height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisTile(
    ThemeData theme,
    String title,
    String desc,
    Color cardColor,
    Color borderColor,
    Color textColor,
    List<Shadow> shadowStyle,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: const Icon(LucideIcons.scanLine, color: Color(0xFF10AC84)),
          title: Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              shadows: shadowStyle,
            ),
          ),
          iconColor: textColor,
          collapsedIconColor: textColor,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline, color: Color(0xFF10AC84), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          desc,
                          style: const TextStyle(color: Color(0xFFA9B4CC), height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildDomainTile(
    ThemeData theme,
    IconData icon,
    String title,
    String desc,
    Color accentColor,
    Color cardColor,
    Color borderColor,
    Color textColor,
    List<Shadow> shadowStyle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    shadows: shadowStyle,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: const TextStyle(color: Color(0xFFA9B4CC), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const String _mailScheme = 'mailto';
  static const String _supportEmail = 'contato@multiversodigital.com.br';

  Future<void> _launchEmail(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    final Uri emailLaunchUri = Uri(
      scheme: _mailScheme,
      path: _supportEmail,
      query: 'subject=${l10n.help_email_subject}',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }
}
