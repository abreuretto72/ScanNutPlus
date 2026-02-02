import 'package:flutter/material.dart';
import 'package:scannutplus/core/presentation/widgets/app_scroll_view.dart';
import 'package:scannutplus/core/services/simple_auth_service.dart';
import 'package:scannutplus/core/theme/app_theme.dart';
import 'package:scannutplus/features/user/presentation/login_page.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/features/food/presentation/food_dashboard.dart';
import 'package:scannutplus/features/navigation/presentation/pets_navigation_page.dart';
import 'package:scannutplus/features/home/presentation/widgets/app_drawer.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:scannutplus/features/pet/presentation/pet_capture_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Future<String> _userNameFuture;

  @override
  void initState() {
    super.initState();
    _userNameFuture = simpleAuthService.getCurrentUserName();
  }

  void _handleLogout() async {
    await simpleAuthService.logout();
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    
    // Green feedback on Logout as requested
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            l10n.logout_success,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.green.shade900,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final domainColors = theme.extension<DomainColors>()!;
    
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.notes_rounded, color: theme.primaryColorLight, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
           IconButton(
            onPressed: _handleLogout,
            icon: Icon(LucideIcons.logOut, color: theme.colorScheme.onSurface),
            tooltip: l10n.common_logout,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: AppScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Header
              FutureBuilder<String>(
                future: _userNameFuture,
                builder: (context, snapshot) {
                  final name = snapshot.data ?? "...";
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.home_welcome_user(name),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.login_subtitle,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Deep Navy Domain Cards (Modern Line Icons)
              _buildDomainCard(
                title: l10n.tab_food,
                accentColor: domainColors.foodAccent,
                icon: LucideIcons.utensils,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const FoodDashboard()),
                  );
                },
              ),
              const SizedBox(height: 16),
              
              _buildDomainCard(
                title: l10n.tab_plant,
                accentColor: domainColors.plantAccent,
                icon: LucideIcons.leaf,
                onTap: () {
                  // Navigate to Plant Domain
                },
              ),
              const SizedBox(height: 16),
              
              _buildDomainCard(
                title: l10n.tab_pet,
                accentColor: domainColors.petAccent,
                icon: LucideIcons.dog,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const PetCaptureView()),
                  );
                },
              ),
              const SizedBox(height: 16),

              _buildDomainCard(
                title: l10n.domain_pets_navigation,
                accentColor: domainColors.petAccent,
                icon: LucideIcons.map,
                onTap: () {
                   Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const PetsNavigationPage()),
                  );
                },
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDomainCard({
    required String title,
    required Color accentColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 120,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.dividerColor,
            width: 2.0,
          ),
        ),
        child: Row(
          children: [
            // Domain Icon (Modern Line)
            Icon(icon, color: accentColor, size: 28), // Size 28.0 as requested
            const SizedBox(width: 24),
            
            // Title with High Contrast Shadow
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleLarge, // Pre-configured with shadows in AppTheme
              ),
            ),
            
            // Arrow indicator
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.chevronRight, color: accentColor, size: 20),
            )
          ],
        ),
      ),
    );
  }
}
