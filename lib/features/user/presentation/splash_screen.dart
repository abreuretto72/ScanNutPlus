import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scannutplus/features/home/presentation/home_view.dart';
import 'package:scannutplus/features/onboarding/presentation/onboarding_screen.dart';
import 'package:scannutplus/features/user/presentation/login_page.dart';
import 'package:scannutplus/core/services/simple_auth_service.dart';
import 'package:scannutplus/core/theme/app_design.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/core/constants/app_keys.dart';
import 'package:scannutplus/core/services/biometric_auth_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  static const bool forceLoginDebug = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.3, 0.8, curve: Curves.easeOut)),
    );

    _controller.forward();

    // 4. Ergonomia: Reduza o tempo do Timer para 1500ms
    Timer(const Duration(milliseconds: 1500), _checkSessionAndNavigate);
  }

  Future<void> _checkSessionAndNavigate() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final bool onboardingCompleted = prefs.getBool(AppKeys.onboardingCompleted) ?? false;
    final bool isLoggedIn = await simpleAuthService.checkPersistentSession();

    if (!mounted) return;
    
    // Ensure l10n is available (safe force unwrap as we are in a widget tree)
    final local = AppLocalizations.of(context)!;
    
    Widget nextScreen;
    String decisionLog = "";

    if (forceLoginDebug) {
      nextScreen = const LoginPage();
      decisionLog = local.debug_nav_login_forced;
    } else if (!onboardingCompleted) {
      nextScreen = const OnboardingScreen();
      decisionLog = local.debug_nav_onboarding;
    } else if (!isLoggedIn) {
      nextScreen = const LoginPage();
      decisionLog = local.debug_nav_login_no_session;
    } else {
      // 3. Trigger Biometrics for Recurrent User (Anti-Gravity Auth)
      final authenticated = await biometricAuthService.authenticate(
        localizedReason: local.auth_biometric_reason,
      );

      if (!mounted) return;

      if (authenticated) {
        nextScreen = const HomeView();
        decisionLog = local.debug_nav_home_bio_success;
        
        // Protocolo Master 2026: Silent Login (No SnackBar)
      } else {
        // Fallback or Cancel
        nextScreen = const LoginPage();
        decisionLog = local.debug_nav_login_bio_fail;
      }
    }
    
    // debugPrint is allowed for logs
    debugPrint(decisionLog);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 2. BLOQUEIO SISTÊMICO: Chamadas obrigatórias ao AppLocalizations
    final l10n = AppLocalizations.of(context)!;
    
    // 1. Sincronização Visual: Cor roxa oficial
    const purpleAccent = Color(0xFF6A4D8C);

    return Scaffold(
      backgroundColor: AppDesign.backgroundDark,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Gradient minimalista dark
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppDesign.backgroundDark,
              AppDesign.surfaceDark,
              AppDesign.backgroundDark,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Partículas
            ...List.generate(15, (index) => _buildParticle(index, purpleAccent)),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                   // Logo
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.1),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        // 1. Logo: Atualizado para PNG conforme solicitado
                        child: Image.asset(
                          'assets/images/logo_scannut.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // App Name
                  AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      l10n.login_title_plus,
                      style: GoogleFonts.poppins(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppDesign.textPrimaryDark,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                   // Tagline (only if keys exist - they do)
                  AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideAnimation.value + 20),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTag('🍎', l10n.tabFood),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppDesign.foodOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildTag('🌿', l10n.tabPlants),
                         const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppDesign.foodOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildTag('', l10n.tabPets, icon: Icons.pets, iconColor: AppDesign.petPink),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Spinner
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(purpleAccent),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Footer Powered By
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: FadeTransition(
                     opacity: _fadeAnimation,
                     child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppDesign.textPrimaryDark.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome,
                              color: AppDesign.foodOrange, size: 14),
                          const SizedBox(width: 8),
                          Text(
                            l10n.splashPoweredBy,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: AppDesign.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String emoji, String label,
      {IconData? icon, Color? iconColor}) {
    return Row(
      children: [
        if (icon != null)
          Icon(icon, size: 14, color: iconColor ?? AppDesign.textSecondaryDark)
        else
          Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppDesign.textSecondaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildParticle(int index, Color color) {
    final random = (index * 37) % 100;
    final size = 2.0 + (random % 4);
    final left = (random * 3.7) % 100;
    final top = (random * 5.3) % 100;

    return Positioned(
      left: MediaQuery.of(context).size.width * (left / 100),
      top: MediaQuery.of(context).size.height * (top / 100),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}