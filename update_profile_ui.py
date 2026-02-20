import re

file_path = "lib/features/profile/presentation/profile_view.dart"

with open(file_path, "r", encoding="utf-8") as f:
    text = f.read()

# 1. Colors and Shadow style
old_styles = """    // Deep Navy Styles & Hard Shadow
    const cardBackgroundColor = Color(0xFF121A2B);
    const cardBorderColor = Color(0xFF22304A);
    const textColor = Color(0xFFEAF0FF);
    const emailColor = Color(0xFFA9B4CC);
    const shadowStyle = [
       Shadow(color: Colors.black, offset: Offset(2.0, 2.0), blurRadius: 4.0),
       Shadow(color: Colors.black, offset: Offset(-0.5, -0.5), blurRadius: 1.0),
    ];"""

new_styles = """    // Neo-Brutalist Styles
    const cardBackgroundColor = Colors.white;
    const cardBorderColor = Colors.black;
    const textColor = Colors.black;
    const emailColor = Colors.black54;
    const shadowStyle = <Shadow>[]; // Clean UI, no text shadow"""
text = text.replace(old_styles, new_styles)

# 2. Card Container
old_card_box = """              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cardBorderColor, width: 2),
                ),"""
new_card_box = """              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: cardBorderColor, width: 3),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(6, 6))],
                ),"""
text = text.replace(old_card_box, new_card_box)

# 3. Avatar box
old_avatar = """                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.scaffoldBackgroundColor,
                          border: Border.all(color: const Color(0xFF1F3A5F), width: 2),"""
new_avatar = """                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.black, width: 3),"""
text = text.replace(old_avatar, new_avatar)

# 4. Avatar placeholder icon
old_icon = """                        child: _userPhotoPath == null
                            ? Icon(Icons.person_outline, size: 48, color: theme.primaryColorLight)
                            : null,"""
new_icon = """                        child: _userPhotoPath == null
                            ? const Icon(Icons.person_outline, size: 48, color: Colors.black)
                            : null,"""
text = text.replace(old_icon, new_icon)

# 5. Section title
old_section_title = """                    Text(
                      l10n.section_account_data,
                      style: TextStyle(
                        color: theme.primaryColorLight,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        shadows: shadowStyle,
                      ),
                    ),"""
new_section_title = """                    Text(
                      l10n.section_account_data.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),"""
text = text.replace(old_section_title, new_section_title)

# 6. Name input
old_name_input = """                    TextField(
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
                    ),"""
new_name_input = """                    TextField(
                      controller: _nameController,
                      onEditingComplete: () {
                         _updateName(_nameController.text);
                         FocusScope.of(context).unfocus();
                      },
                      style: TextStyle(
                        color: textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: l10n.label_name,
                        hintText: l10n.hint_user_name,
                        hintStyle: const TextStyle(color: Colors.black38),
                        labelStyle: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w900,
                            backgroundColor: Colors.white,
                            fontSize: 14,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
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
                    ),"""
text = text.replace(old_name_input, new_name_input)

# 7. Email Input
old_email_input = """                    TextField(
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
                    ),"""

new_email_input = """                    TextField(
                      enabled: false,
                      controller: TextEditingController(text: _userEmail), // Display only
                      style: TextStyle(
                        color: emailColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: l10n.label_email,
                        labelStyle: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w900,
                            backgroundColor: Colors.white,
                            fontSize: 12,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
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
                    ),"""
text = text.replace(old_email_input, new_email_input)

# 8. Settings Text
old_settings_title = """              Text(
                l10n.menu_settings,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),"""
new_settings_title = """              Text(
                l10n.menu_settings.toUpperCase(),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 1.0,
                ),
              ),"""
text = text.replace(old_settings_title, new_settings_title)

# 9. Settings container
old_settings_container = """              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),"""
new_settings_container = """              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9), // Light Greyish Blue
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(5, 5))],
                ),"""
text = text.replace(old_settings_container, new_settings_container)


# 10. SwitchListTile / ListTile
old_settings_content = """                    SwitchListTile(
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
                     ),"""

new_settings_content = """                    SwitchListTile(
                      title: Text(l10n.profile_biometric_enable, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
                      value: _biometricEnabled,
                      activeColor: Colors.black,
                      activeTrackColor: const Color(0xFF10AC84), // Neo-green
                      inactiveThumbColor: Colors.black54,
                      inactiveTrackColor: Colors.grey.shade400,
                      trackOutlineColor: WidgetStateProperty.all(Colors.black), // Pro-max thick outline
                      trackOutlineWidth: WidgetStateProperty.all(2.0),
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
                     ),"""
text = text.replace(old_settings_content, new_settings_content)


# 11. Bottom sheet styling (AppBar shadow is replaced via regex for simpler change, but here let's just replace the title text and button)
old_pw_title = """          Text(
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
          ),"""

new_pw_title = """          Text(
            l10n.profile_change_password.toUpperCase(),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),"""
text = text.replace(old_pw_title, new_pw_title)

# 12. PW Sheet Button
old_pw_btn = """          ElevatedButton(
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
          ),"""

new_pw_btn = """          Container(
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
          ),"""
text = text.replace(old_pw_btn, new_pw_btn)

# 13. PW fields `_buildPasswordField`
old_pw_field = """  Widget _buildPasswordField(String label, TextEditingController controller, ThemeData theme) {
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
  }"""
new_pw_field = """  Widget _buildPasswordField(String label, TextEditingController controller, ThemeData theme) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w900,
          backgroundColor: Colors.white,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
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
    );
  }"""
text = text.replace(old_pw_field, new_pw_field)

# 14. Fix the bottom sheet background to tie into the ProMax Aesthetic
old_bottom_sheet = """    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),"""
new_bottom_sheet = """    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121212), // Dark aesthetic for modal
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: Colors.white24, width: 2),
      ),"""
text = text.replace(old_bottom_sheet, new_bottom_sheet)

with open(file_path, "w", encoding="utf-8") as f:
    f.write(text)
print("Updated profile_view.dart via python replacement")
