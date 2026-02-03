import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/core/presentation/widgets/app_scroll_view.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/features/home/presentation/home_view.dart';
import 'package:scannutplus/core/services/simple_auth_service.dart';
import 'package:scannutplus/features/user/presentation/sign_up_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _localAuth = LocalAuthentication();
  
  bool _keepMeLoggedIn = false;
  bool _isLoading = true; // Start loading for check

  // Feedback visual (Overlay/Status) moved to SnackBar
  // Color? _feedbackColor; // REMOVED
  // String? _feedbackMessage; // REMOVED

  @override
  void initState() {
    super.initState();
    _checkExistingUser();
  }

  Future<void> _checkExistingUser() async {
    // 1. Detecção de Usuário
    final hasUser = await simpleAuthService.hasRegisteredUsers;

    if (!mounted) return;

    if (!hasUser) {
      // 2. Redirecionamento Automático
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignUpPage()),
      );
    } else {
      setState(() {
        _isLoading = false; // Show Login UI
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLocalAuth() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        return;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: mounted ? AppLocalizations.of(context)!.biometric_reason : 'Authenticate',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (!mounted) return;

      if (didAuthenticate) {
        _performSuccessTransition();
      } else {
        _showFeedback(
          isError: true,
          message: AppLocalizations.of(context)!.biometric_error,
        );
      }
    } on PlatformException catch (_) {
      if (!mounted) return;
        _showFeedback(
          isError: true,
          message: AppLocalizations.of(context)!.biometric_error,
        );
    }
  }

  void _handleLogin() {
    final email = _emailController.text;
    final password = _passwordController.text;
    final l10n = AppLocalizations.of(context)!;

    if (email.isNotEmpty && password.isNotEmpty) {
       // Decoupled from local auth. Standard password login success.
       simpleAuthService.quickLogin(email, password).then((_) {
          _performSuccessTransition();
       });
    } else {
       _showFeedback(
        isError: true,
        message: l10n.login_error_credentials,
      );
    }
  }

  void _handleSignUp() {
    // Simulated Sign Up success logic
     final l10n = AppLocalizations.of(context)!;
     _performSuccessTransition();
  }

  void _performSuccessTransition() {
    if (!mounted) return;
    
    // Protocolo Master 2026: Silent Login
    // Explicitly hide any existing snackbars to prevent "Biometrics verified successfully" or similar from lingering.
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // No success SnackBar. Immediate navigation.
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300), // Faster transition
      ),
    );
  }

  void _showFeedback({required bool isError, required String message}) {
    if (!mounted) return;
    
    final snackBar = SnackBar(
      content: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: isError ? Colors.red.shade900 : Colors.green.shade900,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(16),
      duration: isError ? const Duration(seconds: 3) : const Duration(milliseconds: 1500),
    );

    // Only show SnackBar if it is an error (Protocolo Master 2026)
    if (isError) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  // void _updateFeedback... removed

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // 1. Correção do Scaffold: Always Dark
    const backgroundColor = AppColors.backgroundDark;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple)) 
        : AppScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              
              Center(
                child: Column(
                  children: [
                     Image.asset(
                       'assets/images/app_logo.png',
                       height: 120,
                       width: 120,
                       fit: BoxFit.contain,
                     ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.login_title_plus,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.login_subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // if (_feedbackMessage != null) ... removed inline container

              _buildInput(
                controller: _emailController,
                hintText: l10n.login_email_hint,
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              
              _buildInput(
                controller: _passwordController,
                hintText: l10n.login_password_hint,
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Theme(
                    data: ThemeData(
                      checkboxTheme: CheckboxThemeData(
                        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppColors.primaryPurple;
                          }
                          return Colors.transparent;
                        }),
                        side: BorderSide(
                          color: _keepMeLoggedIn ? AppColors.primaryPurple : AppColors.textGrey,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Checkbox(
                      value: _keepMeLoggedIn,
                      onChanged: (val) {
                        setState(() => _keepMeLoggedIn = val ?? false);
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  Text(
                    l10n.login_keep_me,
                    style: const TextStyle(color: AppColors.textGrey),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: AppColors.textWhite,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.login_button_enter,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: _handleLocalAuth,
                icon: const Icon(Icons.fingerprint, color: AppColors.primaryPurple),
                label: Text(
                  l10n.login_button_biometrics,
                  style: const TextStyle(
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.primaryPurple),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              
              // Sign Up link area
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.login_no_account,
                    style: const TextStyle(color: AppColors.textGrey),
                  ),
                  TextButton(
                    onPressed: _handleSignUp,
                    child: Text(
                      l10n.login_sign_up,
                      style: const TextStyle(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),
              
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Text(
                  l10n.common_copyright,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.textGrey),
          prefixIcon: Icon(icon, color: AppColors.textGrey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
