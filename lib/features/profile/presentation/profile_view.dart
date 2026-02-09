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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Deep Navy Styles & Hard Shadow
    const cardBackgroundColor = Color(0xFF121A2B);
    const cardBorderColor = Color(0xFF22304A);
    const textColor = Color(0xFFEAF0FF);
    const emailColor = Color(0xFFA9B4CC);
    const shadowStyle = [
       Shadow(color: Colors.black, offset: Offset(2.0, 2.0), blurRadius: 4.0),
       Shadow(color: Colors.black, offset: Offset(-0.5, -0.5), blurRadius: 1.0),
    ];

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
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cardBorderColor, width: 2),
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
                          color: theme.scaffoldBackgroundColor,
                          border: Border.all(color: const Color(0xFF1F3A5F), width: 2),
                          image: _userPhotoPath != null
                              ? DecorationImage(
                                  image: FileImage(File(_userPhotoPath!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _userPhotoPath == null
                            ? Icon(Icons.person_outline, size: 48, color: theme.primaryColorLight)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Section Title
                    Text(
                      l10n.section_account_data,
                      style: TextStyle(
                        color: theme.primaryColorLight,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        shadows: shadowStyle,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name Input
                    TextField(
                      controller: _nameController,
                      onEditingComplete: () {
                         _updateName(_nameController.text);
                         FocusScope.of(context).unfocus();
                      },
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: shadowStyle,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: l10n.label_name,
                        hintText: l10n.hint_user_name,
                        hintStyle: TextStyle(color: theme.disabledColor),
                        labelStyle: TextStyle(
                            color: theme.disabledColor,
                            shadows: shadowStyle,
                            fontSize: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: cardBorderColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: theme.primaryColorLight),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.black.withValues(alpha: 0.2),
                        alignLabelWithHint: true,
                        floatingLabelAlignment: FloatingLabelAlignment.center,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Email Read-Only
                    TextField(
                      enabled: false,
                      controller: TextEditingController(text: _userEmail), // Display only
                      style: TextStyle(
                        color: emailColor,
                        fontSize: 14,
                        shadows: shadowStyle,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: l10n.label_email,
                        labelStyle: TextStyle(
                            color: theme.disabledColor,
                            shadows: shadowStyle,
                            fontSize: 12,
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        filled: false,
                        alignLabelWithHint: true,
                        floatingLabelAlignment: FloatingLabelAlignment.center,
                         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Settings Section
              Text(
                l10n.menu_settings,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(l10n.profile_biometric_enable, style: theme.textTheme.bodyLarge),
                      value: _biometricEnabled,

                      onChanged: (val) async {
                         setState(() {
                           _biometricEnabled = val;
                         });
                         await simpleAuthService.setBiometricEnabled(val); // Save to Service
                      },
                      secondary: Icon(LucideIcons.fingerprint, color: theme.primaryColorLight),
                    ),
                     const Divider(height: 1),
                     ListTile(
                       leading: Icon(LucideIcons.lock, color: theme.primaryColorLight),
                       title: Text(l10n.profile_change_password, style: theme.textTheme.bodyLarge),
                       trailing: Icon(LucideIcons.chevronRight, color: theme.disabledColor, size: 20),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
    
    // Purple accent for confirmation
    const purpleAccent = Color(0xFF6A4D8C);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.profile_change_password,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              shadows: const [
                 Shadow(color: Colors.black, offset: Offset(2.0, 2.0), blurRadius: 4.0),
                 Shadow(color: Colors.black, offset: Offset(-0.5, -0.5), blurRadius: 1.0),
              ],
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
          
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: purpleAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(
                  l10n.password_save,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                       Shadow(color: Colors.black, offset: Offset(2.0, 2.0), blurRadius: 4.0),
                    ],
                  ),
                ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, ThemeData theme) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: theme.disabledColor,
          shadows: const [
             Shadow(color: Colors.black, offset: Offset(1.0, 1.0), blurRadius: 2.0),
          ],
        ),
        filled: true,
        fillColor: theme.cardColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6A4D8C), width: 2),
        ),
      ),
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
