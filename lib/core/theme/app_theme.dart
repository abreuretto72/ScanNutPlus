import 'package:flutter/material.dart';

// Domain Colors Extension
@immutable
class DomainColors extends ThemeExtension<DomainColors> {
  final Color foodAccent;
  final Color plantAccent;
  final Color petAccent;

  const DomainColors({
    required this.foodAccent,
    required this.plantAccent,
    required this.petAccent,
  });

  @override
  DomainColors copyWith({Color? foodAccent, Color? plantAccent, Color? petAccent}) {
    return DomainColors(
      foodAccent: foodAccent ?? this.foodAccent,
      plantAccent: plantAccent ?? this.plantAccent,
      petAccent: petAccent ?? this.petAccent,
    );
  }

  @override
  DomainColors lerp(ThemeExtension<DomainColors>? other, double t) {
    if (other is! DomainColors) {
      return this;
    }
    return DomainColors(
      foodAccent: Color.lerp(foodAccent, other.foodAccent, t)!,
      plantAccent: Color.lerp(plantAccent, other.plantAccent, t)!,
      petAccent: Color.lerp(petAccent, other.petAccent, t)!,
    );
  }
}

class AppTheme {
  // Global Constants
  static const String logoPath = 'assets/images/app_logo.png';
  static const String appNameKey = 'app_name_plus'; // Key for l10n
  static const String copyrightKey = 'pdf_copyright'; // Key for l10n
  static const String repoUrl = 'https://github.com/abreuretto72/ScanNutPlus';

  // Private Palette Constants
  static const Color _kPrimary = Color(0xFF1F3A5F);
  static const Color _kScaffoldBackground = Color(0xFF0B1220);
  static const Color _kCardColor = Color(0xFF121A2B);
  static const Color _kBorderColor = Color(0xFF22304A);
  static const Color _kTextPrimary = Color(0xFFEAF0FF);
  static const Color _kTextSecondary = Color(0xFFA9B4CC);
  
  static const Color _kAccentFood = Color(0xFFC65A1E);
  static const Color _kAccentPlant = Color(0xFF2F7D5B);
  
  // Public Theme Data
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: _kScaffoldBackground,
      primaryColor: _kPrimary,
      cardColor: _kCardColor,
      dividerColor: _kBorderColor,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: _kPrimary,
        surface: _kCardColor,
        error: Color(0xFFCF6679),
        onPrimary: Colors.white,
        onSurface: _kTextPrimary,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent, // Or _kScaffoldBackground depending on preference, usually transparent on scaffold
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: _kTextPrimary),
        titleTextStyle: TextStyle(
          color: _kTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: _kCardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: const BorderSide(color: _kBorderColor, width: 2.0),
        ),
        elevation: 0,
        margin: EdgeInsets.zero,
      ),

      // Floating Action Button Theme (Global Circle)
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        shape: CircleBorder(),
        elevation: 6,
      ),

      // Text Theme
      textTheme: TextTheme(
        // Titles and Headlines (High Contrast + Shadow)
        titleLarge: _buildShadowTextStyle(24, FontWeight.bold),
        titleMedium: _buildShadowTextStyle(20, FontWeight.w600),
        
        // Body Text
        bodyLarge: TextStyle(color: _kTextPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: _kTextSecondary, fontSize: 14),
      ),

      // Domain Extensions
      extensions: const <ThemeExtension<dynamic>>[
        DomainColors(
          foodAccent: _kAccentFood,
          plantAccent: _kAccentPlant,
          petAccent: _kPrimary, // Pet shares Primary/Navy
        ),
      ],
    );
  }

  static TextStyle _buildShadowTextStyle(double size, FontWeight weight) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: _kTextPrimary,
      shadows: const [
        Shadow(
          color: Color(0xFF000000),
          offset: Offset(2.0, 2.0),
          blurRadius: 4.0,
        ),
        Shadow(
          color: Color(0xFF000000),
          offset: Offset(-0.5, -0.5),
          blurRadius: 1.0,
        ),
      ],
    );
  }
}
