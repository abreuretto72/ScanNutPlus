import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:scannutplus/core/presentation/widgets/app_scroll_view.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:gal/gal.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

class FoodDashboard extends StatefulWidget {
  const FoodDashboard({super.key});

  @override
  State<FoodDashboard> createState() => _FoodDashboardState();
}

class _FoodDashboardState extends State<FoodDashboard> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isAnalyzing = false;
  
  // Simulation results
  Map<String, dynamic>? _analysisResult;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      if (source == ImageSource.camera) {
         try {
            await Gal.putImage(pickedFile.path);
            if (kDebugMode) debugPrint('[GAL] Saved food photo to gallery: ${pickedFile.path}');
         } catch (e) {
            if (kDebugMode) debugPrint('[GAL_ERROR] Failed to save food photo to gallery: $e');
         }
      }

      setState(() {
        _image = File(pickedFile.path);
        _isAnalyzing = true;
        _analysisResult = null;
      });
      
      // Simulate AI Analysis
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      
      setState(() {
        _isAnalyzing = false;
        final l10n = AppLocalizations.of(context)!;
        // Mock Data
        _analysisResult = {
          l10n.food_key_calories: 450,
          l10n.food_key_protein: 25.5,
          l10n.food_key_carbs: 40.0,
          l10n.food_key_fat: 15.0,
          l10n.food_key_name: l10n.food_mock_grilled_chicken
        };
      });
      
      // Green Feedback on Success (Component Only)
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.food_analysis_success,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.green.shade900,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(milliseconds: 1500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(l10n.food_scan_title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AppScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Scanner Area
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFF9800).withValues(alpha: 0.3)),
                ),
                child: _isAnalyzing 
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Color(0xFFFF9800)),
                        const SizedBox(height: 16),
                        Text(l10n.food_analyzing, style: const TextStyle(color: AppColors.textGrey)),
                      ],
                    )
                  : _image != null 
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 64, color: const Color(0xFFFF9800).withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text(l10n.food_scan_title, style: const TextStyle(color: AppColors.textGrey)),
                        ],
                      ),
              ),
              
              const SizedBox(height: 24),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera),
                      label: Text(l10n.food_btn_scan),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800), // Food Orange
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: Text(l10n.food_btn_gallery),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF9800),
                        side: const BorderSide(color: Color(0xFFFF9800)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Result Area
              if (_analysisResult != null) ...[
                Text(
                  _analysisResult![l10n.food_key_name],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMacroCard(l10n.food_calories, "${_analysisResult![l10n.food_key_calories]}", const Color(0xFFFF9800)),
                    _buildMacroCard(l10n.food_protein, "${_analysisResult![l10n.food_key_protein]}g", Colors.blue),
                    _buildMacroCard(l10n.food_carbs, "${_analysisResult![l10n.food_key_carbs]}g", Colors.green),
                    _buildMacroCard(l10n.food_fat, "${_analysisResult![l10n.food_key_fat]}g", Colors.red),
                  ],
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroCard(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }
}
