import 'package:flutter/material.dart';

import 'package:scannutplus/core/services/simple_auth_service.dart';
import 'package:scannutplus/l10n/app_localizations.dart';

import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:scannutplus/features/user/data/models/user_entity.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  // Use Controllers for editable fields
  final TextEditingController _nameController = TextEditingController();
  
  String _userEmail = '...';
  String? _userPhotoPath;
  UserEntity? _userEntity;
  
  // Logic placehodler
  bool _biometricEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = await simpleAuthService.getCurrentUser();
    final bioEnabled = await simpleAuthService.isBiometricEnabled;
    
    if (!mounted) return;
    setState(() {
      _userEntity = user;
      // If user exists, populate controller. If name is empty, use default.
      final savedName = user?.name ?? "";
      _nameController.text = savedName.isNotEmpty ? savedName : AppLocalizations.of(context)!.default_user_name;
      
      // Email is read-only
      _userEmail = user?.email ?? "";
      _userPhotoPath = user?.photoPath;
      
      _biometricEnabled = bioEnabled; // Load from Service
    });
  }

  // Reactive Save for Name
  Future<void> _updateName(String newName) async {
    if (_userEntity != null) {
      _userEntity!.name = newName;
      await simpleAuthService.updateUser(_userEntity!);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.password_save, // Reusing save string or generic 'Saved'
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.green.shade900,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Widget _buildLabeledField(String labelText, Widget child) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10), // Reduced from 12 to bring the field up slightly
          child: child,
        ),
        Positioned(
          left: 24, // Shifted away from the 16px border-radius curve exactly onto the flat line
          top: 3, // Pushed down exactly to center over the Y=10 border outline
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2), // Thinner height so it doesn't invade
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4),
              // Border width 0 removed to eliminate subpixel white aliasing (the "teeth")
            ),
            child: Text(
              labelText.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Neo-Brutalist Styles
    const cardBackgroundColor = Colors.white;
    const cardBorderColor = Colors.black;
    const textColor = Colors.black;
    const emailColor = Colors.black54;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.profile_title),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: theme.primaryColorLight),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Header & Account Data Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: cardBorderColor, width: 3),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(6, 6))],
                ),
                child: Column(
                  children: [
                    // Photo
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: _userPhotoPath == null ? const EdgeInsets.all(16) : null,
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.black, width: 3),
                          image: _userPhotoPath != null
                              ? DecorationImage(
                                  image: FileImage(File(_userPhotoPath!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _userPhotoPath == null
                            ? const Icon(Icons.person_outline, size: 48, color: Colors.black)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Section Title
                    Text(
                      l10n.section_account_data.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name Input
                    _buildLabeledField(l10n.label_name, TextField(
                      controller: _nameController,
                      onEditingComplete: () {
                         _updateName(_nameController.text);
                         FocusScope.of(context).unfocus();
                      },
                      style: TextStyle(
                        color: textColor,
                        fontSize: 22,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: l10n.hint_user_name,
                        hintStyle: const TextStyle(color: Colors.black),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: cardBorderColor, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black, width: 3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        alignLabelWithHint: true,
                        floatingLabelAlignment: FloatingLabelAlignment.center,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    )),
                    
                    const SizedBox(height: 16),
                    
                    // Email Read-Only
                    _buildLabeledField(l10n.label_email, TextField(
                      enabled: false,
                      controller: TextEditingController(text: _userEmail), // Display only
                      style: TextStyle(
                        color: emailColor,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        disabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black12, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        alignLabelWithHint: true,
                        floatingLabelAlignment: FloatingLabelAlignment.center,
                         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    )),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Settings Section
              Text(
                l10n.menu_settings.toUpperCase(),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9), // Light Greyish Blue
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(5, 5))],
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(l10n.profile_biometric_enable, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
                      value: _biometricEnabled,
                      activeThumbColor: Colors.black,
                      activeTrackColor: const Color(0xFF10AC84), // Neo-green
                      inactiveThumbColor: Colors.black54,
                      inactiveTrackColor: Colors.grey.shade400,
                      trackOutlineColor: WidgetStateProperty.all(Colors.black), // Pro-max thick outline
                      onChanged: (val) async {
                         setState(() {
                           _biometricEnabled = val;
                         });
                         await simpleAuthService.setBiometricEnabled(val); // Save to Service
                      },
                      secondary: const Icon(LucideIcons.fingerprint, color: Colors.black, size: 28),
                    ),
                     const Divider(height: 2, thickness: 2, color: Colors.black),
                     ListTile(
                       leading: const Icon(LucideIcons.lock, color: Colors.black, size: 28),
                       title: Text(l10n.profile_change_password, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
                       trailing: Container(
                         padding: const EdgeInsets.all(4),
                         decoration: BoxDecoration(
                           color: Colors.grey.shade200, 
                           borderRadius: BorderRadius.circular(8), 
                           border: Border.all(color: Colors.black, width: 2)
                         ),
                         child: const Icon(LucideIcons.chevronRight, color: Colors.black, size: 20)
                       ),
                       onTap: _showChangePasswordSheet,
                     ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Footer
              Text(
                l10n.copyright_label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.disabledColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // Pick an image
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
       setState(() {
         _userPhotoPath = image.path;
       });
       
       if (_userEntity != null) {
          _userEntity!.photoPath = image.path;
          await simpleAuthService.updateUser(_userEntity!);
       }
    }
  }

  void _showChangePasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121212), // Dark aesthetic for modal
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: Colors.white24, width: 2),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: const _ChangePasswordForm(),
      ),
    );
  }
}

class _ChangePasswordForm extends StatefulWidget {
  const _ChangePasswordForm();

  @override
  State<_ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<_ChangePasswordForm> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.profile_change_password.toUpperCase(),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          _buildPasswordField(l10n.password_current, _currentController, theme),
          const SizedBox(height: 16),
          _buildPasswordField(l10n.password_new, _newController, theme),
          const SizedBox(height: 16),
          _buildPasswordField(l10n.password_confirm, _confirmController, theme),
          
          const SizedBox(height: 32),
          
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [BoxShadow(color: Colors.white24, offset: Offset(4, 4))],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                : Text(
                    l10n.password_save.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1.0,
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, ThemeData theme) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10), // Reduced from 12 to bring the field up slightly
          child: TextField(
            controller: controller,
            obscureText: true,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: const TextStyle(color: Colors.black),
              floatingLabelBehavior: FloatingLabelBehavior.never,
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6A4D8C), width: 3),
              ),
            ),
          ),
        ),
        Positioned(
          left: 24, // Shifted away from the 16px border-radius curve exactly onto the flat line
          top: 3, // Pushed down exactly to center over the Y=10 border outline
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2), // Thinner height so it doesn't invade
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4),
              // Border width 0 removed to eliminate subpixel white aliasing (the "teeth")
            ),
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (_newController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.password_match_error),
          backgroundColor: Colors.red.shade900,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // TODO: Integrate actual SimpleAuthService update logic here when available
    
    if (!mounted) return;
    setState(() => _isLoading = false);
    
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.password_success),
        backgroundColor: Colors.green.shade900,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
