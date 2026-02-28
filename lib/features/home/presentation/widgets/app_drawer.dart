import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scannutplus/l10n/app_localizations.dart';


import 'package:scannutplus/features/settings/presentation/about_view.dart';
import 'package:scannutplus/features/profile/presentation/profile_view.dart';
import 'package:scannutplus/core/services/simple_auth_service.dart';
import 'package:scannutplus/features/user/presentation/login_page.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:scannutplus/core/data/objectbox_manager.dart';
import 'package:scannutplus/features/user/data/models/user_entity.dart';
import 'package:scannutplus/features/help/presentation/help_screen.dart';
import 'package:scannutplus/features/settings/presentation/backup_screen.dart';
import 'package:scannutplus/objectbox.g.dart'; // generated

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    // Deep Navy Styles & Hard Shadow
    const textColor = Color(0xFFEAF0FF);
    const emailColor = Color(0xFFA9B4CC);
    const shadowStyle = [
       Shadow(color: Colors.black, offset: Offset(2.0, 2.0), blurRadius: 4.0),
       Shadow(color: Colors.black, offset: Offset(-0.5, -0.5), blurRadius: 1.0),
    ];
    
    // Reactive User Stream
    final userStream = ObjectBoxManager.currentStore.box<UserEntity>()
        .query(UserEntity_.isActive.equals(true))
        .watch(triggerImmediately: true)
        .map((query) => query.findFirst());

    return Drawer(
      backgroundColor: theme.canvasColor, // Deep Navy from theme
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header (Reactive)
              StreamBuilder<UserEntity?>(
                stream: userStream,
                builder: (context, snapshot) {
                  final user = snapshot.data;
                  final rawName = user?.name ?? "";
                  final userName = rawName.isNotEmpty ? rawName : l10n.user_default_name;
                  final userEmail = user?.email ?? "";
                  final userPhoto = user?.photoPath;

                  return Container(
                     padding: const EdgeInsets.all(24),
                     decoration: BoxDecoration(
                       color: theme.colorScheme.surface,
                       border: Border(bottom: BorderSide(color: theme.dividerColor)),
                     ),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Container(
                           width: 64,
                           height: 64,
                           decoration: BoxDecoration(
                             shape: BoxShape.circle,
                             color: const Color(0xFF6A4D8C),
                             border: Border.all(color: const Color(0xFF1F3A5F), width: 2),
                             image: userPhoto != null 
                                ? DecorationImage(
                                    image: ResizeImage(FileImage(File(userPhoto)), width: 250),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                           ),
                           child: userPhoto == null 
                              ? const Icon(Icons.person, color: Colors.white, size: 32)
                              : null,
                         ),
                         const SizedBox(height: 16),
                         Text(
                           userName, 
                           style: theme.textTheme.titleLarge?.copyWith(
                             color: textColor,
                             fontWeight: FontWeight.bold,
                             shadows: shadowStyle,
                           ),
                         ),
                         const SizedBox(height: 4),
                         Text(
                           userEmail, 
                           style: theme.textTheme.bodyMedium?.copyWith(
                             color: emailColor,
                             fontSize: 12,
                             shadows: shadowStyle,
                           ),
                         ),
                       ],
                     ),
                  );
                }
              ),
              
              const SizedBox(height: 16),
              
              // Menu Items
              _buildMenuItem(context, Icons.person_outline, l10n.menu_profile, () {
                 Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfileView()),
                );
              }),
              _buildMenuItem(context, Icons.settings_outlined, l10n.menu_settings, () {}),
              _buildMenuItem(context, Icons.cloud_sync_outlined, l10n.menu_backup, () {
                 Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const BackupScreen()),
                );
              }),
              _buildMenuItem(context, Icons.help_outline, l10n.menu_help, () {
                 Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const HelpScreen()),
                );
              }),
              _buildMenuItem(context, Icons.info_outline, l10n.about_title, () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AboutView()),
                );
              }),
              
              const SizedBox(height: 32),
              const Divider(color: Color(0xFF22304A)),
              const SizedBox(height: 16),
              
              // Logout Item
              ListTile(
                leading: Icon(LucideIcons.logOut, color: theme.colorScheme.error),
                title: Text(
                  l10n.common_logout,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () async {
                  await simpleAuthService.logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
                horizontalTitleGap: 0,
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              
              const SizedBox(height: 32),
              
              // Footer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.copyright_label,
                      style: TextStyle(fontSize: 12, color: theme.disabledColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6A4D8C)),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white70, fontSize: 16),
      ),
      onTap: onTap,
      horizontalTitleGap: 0,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
