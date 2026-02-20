import 'package:flutter/material.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/core/presentation/widgets/app_scroll_view.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/core/services/simple_auth_service.dart';
import 'package:scannutplus/features/pet/presentation/my_pets_view.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Feedback visual (Overlay/Status) moved to SnackBar
  // Color? _feedbackColor;
  // String? _feedbackMessage;

  void _handleSignUp() {
    final l10n = AppLocalizations.of(context)!;
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    // 2. Validação de Senha
    String? validationError;
    if (password.length < 8) {
      validationError = l10n.error_password_short;
    } else if (!RegExp(r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$').hasMatch(password)) {
       validationError = l10n.error_password_weak;
    } else if (password != confirm) {
       validationError = l10n.error_password_mismatch;
    }

    if (validationError != null) {
      _showFeedback(isError: true, message: validationError);
      return;
    }

    // Success Flow
    _showFeedback(isError: false, message: l10n.signup_success);

    simpleAuthService.registerUser(email: _emailController.text, password: _passwordController.text).then((_) {
      if (!mounted) return;
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MyPetsView()),
        );
      });
    });
  }

  void _showPasswordRules(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.pwd_help_title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A4D8C),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildRuleItem(l10n.pwd_rule_length),
                _buildRuleItem(l10n.pwd_rule_uppercase),
                _buildRuleItem(l10n.pwd_rule_number),
                _buildRuleItem(l10n.pwd_rule_special),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRuleItem(String text) {
     return Padding(
       padding: const EdgeInsets.symmetric(vertical: 8.0),
       child: Row(
         children: [
           const Icon(Icons.check_circle_outline, color: Color(0xFF6A4D8C), size: 18),
           const SizedBox(width: 12),
           Expanded(
             child: Text(
               text,
               style: const TextStyle(color: Colors.white70, fontSize: 14),
             ),
           ),
         ],
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

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // 1. Correção do Scaffold: Always Dark
    const backgroundColor = AppColors.backgroundDark;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: AppScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               const SizedBox(height: 60),
               Image.asset(
                 'assets/images/logo_scannut.png',
                 height: 120,
                 width: 120,
                 fit: BoxFit.contain,
               ),
               const SizedBox(height: 24),
               Text(
                 l10n.login_sign_up, 
                 textAlign: TextAlign.center,
                 style: const TextStyle(
                   fontSize: 28,
                   fontWeight: FontWeight.bold,
                   color: AppColors.textWhite,
                 ),
               ),
               const SizedBox(height: 32),

               // Error / Success Feedback
               // Error / Success Feedback
               // if (_feedbackMessage != null) ... removed inline container

               _buildInput(_emailController, l10n.login_email_hint, Icons.email_outlined),
               const SizedBox(height: 16),
               
               // Password Field with Help
               _buildInput(
                 _passwordController, 
                 l10n.login_password_hint, 
                 Icons.lock_outline, 
                 obscureText: true,
                 isPasswordHelp: true,
               ),
               const SizedBox(height: 16),
               
               // Confirm Password Field
               _buildInput(
                 _confirmPasswordController, 
                 l10n.login_confirm_password_hint, 
                 Icons.lock_reset, 
                 obscureText: true,
                 fillColor: const Color(0xFF1E1E1E)
               ),
               const SizedBox(height: 32),

               ElevatedButton(
                 onPressed: _handleSignUp,
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
                   l10n.login_sign_up,
                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                 ),
               ),
               
               const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController ctrl, 
    String hint, 
    IconData icon, 
    {bool obscureText = false, Color? fillColor, bool isPasswordHelp = false}
  ) {
     return Container(
      decoration: BoxDecoration(
        color: fillColor ?? AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textGrey),
          // 1. Gatilho Visual: IconButton no prefixo para ajuda
          prefixIcon: isPasswordHelp 
             ? IconButton(
               icon: Icon(icon, color: AppColors.textGrey),
               onPressed: () => _showPasswordRules(context),
               tooltip: AppLocalizations.of(context)?.pwd_help_title ?? 'Help',
             )
             : Icon(icon, color: AppColors.textGrey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
