import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/core/presentation/widgets/app_scroll_view.dart';
import 'package:scannutplus/core/constants/app_keys.dart';
import 'package:scannutplus/features/user/presentation/login_page.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppKeys.onboardingCompleted, true);

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Estilização: Visual Dark/Purple (BackgroundColor hardcoded as requested via hex class/const if available, using strict Color for safety or AppColors if valid)
    // Using const Color(0xFF121212) as per prompt
    const backgroundColor = Color(0xFF121212);
    // Button color 
    const buttonColor = Color(0xFF6A4D8C);

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: backgroundColor,
      // 1. Estilização: AppBar transparente/removida
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      // 4. Ergonomia: AppScrollView
      body: AppScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              
              // Logo or Image Placeholder could go here, but let's stick to text as requested
               Center(
                  child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo_scannut.jpg',
                    height: 120,
                    width: 120,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // 1. Conteúdo: Título (Bold, White)
              Text(
                l10n.onboarding_title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 16),

              // 1. Conteúdo: Welcome (Light Grey)
              Text(
                l10n.onboarding_welcome,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFFB0B0B0), // Light Grey
                ),
              ),

              const Spacer(),

              // 1. Botão de Ação: Next/Start (Purple)
              ElevatedButton(
                onPressed: () => _completeOnboarding(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.onboarding_button_start,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
