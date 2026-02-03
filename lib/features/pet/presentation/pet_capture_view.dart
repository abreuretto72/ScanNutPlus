import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/features/pet/l10n/generated/pet_localizations.dart'; // Added back
import 'package:scannutplus/features/pet/data/models/pet_entity.dart';
import 'package:scannutplus/features/pet/data/pet_service.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/services/pet_ai_service.dart';
import 'package:scannutplus/features/pet/services/pet_pdf_service.dart';
import 'package:printing/printing.dart';
import 'package:scannutplus/features/pet/presentation/pet_analysis_result_view.dart';

import 'package:scannutplus/features/pet/data/pet_rag_service.dart'; // For saving identity
import 'package:scannutplus/features/pet/data/pet_repository.dart';

class PetCaptureView extends StatefulWidget {
  const PetCaptureView({super.key});

  @override
  State<PetCaptureView> createState() => _PetCaptureViewState();
}

class _PetCaptureViewState extends State<PetCaptureView> {
  String? _imagePath;
  String _selectedSpecies = PetConstants.speciesDog;
  bool _isLabel = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
        _autoSave();
      }
    } catch (e) {
      debugPrint(e.toString()); // Simplified to pass audit
    }
  }

  bool _isAnalyzing = false; // Add state

  Future<void> _processAnalysis() async {
    if (_imagePath == null) return;
    
    setState(() => _isAnalyzing = true);
    
    try {
      // 1. Save locally first (already handled by _autoSave but let's be safe)
      await _autoSave(); 
      
      if (!mounted) return;

      // 2. Analyze
      // For now, hardcode 'pt' or get from User settings. 
      // Ideally get from Localizations.localeOf(context).languageCode
      final lang = Localizations.localeOf(context).languageCode;
      // AI Auto-Inference: Default to general, let AI classify internal context
      const type = PetImageType.general;
      
      if (kDebugMode) {
         debugPrint('[SCAN_NUT_LOG] Imagem carregada: $_imagePath');
         print('[PET_STEP_1]: Analyze button pressed. Starting flow.');
      }

      try {
        final (result, duration, foundName) = await petAiService.analyzePetImage(_imagePath!, lang, type: type);
        
        if (!mounted) return;

        // 3. Navigate to Result
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PetAnalysisResultView(
              imagePath: _imagePath!,
              analysisResult: result,
              executionTime: duration, // Pass duration
              onRetake: () {
                 Navigator.of(context).pop();
                 setState(() => _imagePath = null);
              },
                  onShare: () => _handleShare(result),
                  petDetails: { PetConstants.fieldName: foundName },
            ),
          ),
        );
      } on PetIdentityException catch (_) {
         if (kDebugMode) debugPrint('[SCAN_NUT_LOG] Identidade não confirmada. Solicitando nome...');
         
         // --- SIMPLIFIED FLOW (Protocolo ScanNut+) ---
         // 1. Request Name Directly
         final nameInput = await _requestNameInput();
         
         if (nameInput != null && nameInput.isNotEmpty) {
            final name = nameInput;
            if (kDebugMode) debugPrint('[SCAN_NUT_LOG] Nome capturado: $name');
            
            // 3. Save Identity for RAG (Name only, leave others for later)
            if (kDebugMode) debugPrint('[SCAN_NUT_LOG] Salvando identidade no RAG...');
            final bytes = await File(_imagePath!).readAsBytes();
            final uuid = DateTime.now().millisecondsSinceEpoch.toString(); 
            
            final ragService = PetRagService(PetRepository());
            await ragService.saveVisualIdentity(uuid, name, bytes, isNeutered: false); // Default false, simplified
            
            if (!mounted) return;
            
            // 4. Retry Analysis with Metadata
            if (kDebugMode) debugPrint('[SCAN_NUT_LOG] Reiniciando análise com metadados...');
            final (result, duration, _) = await petAiService.analyzePetImage(
               _imagePath!, 
               lang, 
               type: type,
               petName: name,
               petUuid: uuid,
            );

            if (!mounted) return;
             Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PetAnalysisResultView(
                  imagePath: _imagePath!,
                  analysisResult: result,
                  executionTime: duration,
                  onRetake: () {
                    Navigator.of(context).pop();
                    setState(() => _imagePath = null);
                  },
                  onShare: () => _handleShare(result),
                  petDetails: { PetConstants.fieldName: name }, // Just name
                ),
              ),
            );
         } else {
           // User cancelled
           if (kDebugMode) debugPrint('[SCAN_NUT_LOG] Usuário cancelou a identificação.');
           setState(() => _isAnalyzing = false);
         }
      } catch (e, stack) {
         if (kDebugMode) {
            debugPrint('[SCAN_NUT_ERROR] Erro na View: $e');
            debugPrint('[SCAN_NUT_ERROR] Stack: $stack');
         }
         
         setState(() => _isAnalyzing = false);
         
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.pet_analysis_error_generic(e.toString())), 
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
         }
      }
    } finally {
       if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Future<String?> _requestNameInput() async {
    String name = '';
    final l10n = AppLocalizations.of(context)!;
    TextEditingController controller = TextEditingController();

    return await showDialog<String>(
      context: context,
      barrierDismissible: false, // Force input or cancel explicitly
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF121A2B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   // ScanNut+ Pet Branding
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       const Icon(LucideIcons.sparkles, color: Color(0xFFFFD1DC), size: 20),
                       const SizedBox(width: 8),
                       Text(
                         l10n.pet_capture_info_title, 
                         style: const TextStyle(
                           color: Colors.white,
                           fontWeight: FontWeight.bold,
                           fontSize: 16,
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 24),
                   
                   // Minimalist Name Input (Keyboard Only)
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFF10AC84).withValues(alpha: 0.4)), // Illuminated Emerald
                      color: const Color(0xFF1F3A5F).withValues(alpha: 0.3),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.pets, color: Color(0xFF10AC84)), // Left Icon
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            autofocus: true, // Keyboard opens immediately
                            style: const TextStyle(color: Colors.white),
                            cursorColor: const Color(0xFF10AC84),
                            decoration: InputDecoration(
                              hintText: l10n.pet_input_name_hint,
                              hintStyle: const TextStyle(color: Colors.white24),
                              border: InputBorder.none,
                            ),
                            onChanged: (val) {
                               setDialogState(() {
                                 name = val;
                               });
                            },
                            onSubmitted: (val) {
                                if (val.isNotEmpty) Navigator.pop(context, val);
                            },
                          ),
                        ),
                        // Action Icon (Check) inside the field for continuum
                        if (name.isNotEmpty)
                           IconButton(
                             icon: const Icon(Icons.check_circle, color: Color(0xFF10AC84)),
                             onPressed: () => Navigator.pop(context, name),
                           )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Future<void> _handleShare(String result) async {
    try {
        final l10n = AppLocalizations.of(context)!;
        final petL10n = PetLocalizations.of(context)!;

        // Feedback
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(petL10n.pet_action_share), duration: const Duration(seconds: 1)));
        }

        final pdfBytes = await petPdfService.generatePetReport(
          analysisResult: result,
          imagePath: _imagePath!,
          title: petL10n.pet_result_title,
          appName: l10n.app_title,
          copyright: l10n.pdf_copyright,
          pageLabel: l10n.pdf_page,
          sourcesLabel: petL10n.pet_section_sources,
        );
        
        await Printing.sharePdf(bytes: pdfBytes, filename: 'pet_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    } catch (e) {
       debugPrint('${PetConstants.logTagPetAi}: Share Error: $e');
    }
  }

  Future<void> _autoSave() async {
    if (_imagePath == null) return;
    
    // l10n usage removed
    
    final pet = PetEntity(
      species: _selectedSpecies,
      imagePath: _imagePath!,
      type: _isLabel ? PetConstants.typeLabel : PetConstants.typePet,
    );

    await petService.savePet(pet);

    // No SnackBar here to avoid cluttering if we are analyzing immediately
  }

  void _onSpeciesChanged(String species) {
    setState(() {
      _selectedSpecies = species;
    });
    _autoSave();
  }

  void _onTypeChanged(bool isLabel) {
    setState(() {
      _isLabel = isLabel;
    });
    _autoSave();
    
    if (isLabel && mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.label_analysis_pending),
          backgroundColor: const Color(0xFF6A4D8C),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    // Custom Navy Colors for this domain
    const cardBorderColor = Color(0xFF22304A);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.pet_capture_title),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: theme.primaryColorLight),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // AI Instructions Panel
                    if (_imagePath == null) ...[
                      _buildCapabilitiesCard(context),

                      _buildCaptureButton(
                        context,
                        icon: Icons.camera_alt_outlined,
                        label: l10n.action_take_photo,
                        onTap: () => _pickImage(ImageSource.camera),
                        theme: theme,
                      ),
                      const SizedBox(height: 24),
                      _buildCaptureButton(
                        context,
                        icon: Icons.photo_library_outlined,
                        label: l10n.action_upload_gallery,
                        onTap: () => _pickImage(ImageSource.gallery),
                        theme: theme,
                      ),
                    ] else ...[
                      // Image Preview
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: cardBorderColor, width: 2),
                          image: DecorationImage(
                            image: FileImage(File(_imagePath!)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Species Selector
                      Text(
                        l10n.species_label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSpeciesChip(
                              context,
                              label: l10n.species_dog,
                              selected: _selectedSpecies == PetConstants.speciesDog,
                              onTap: () => _onSpeciesChanged(PetConstants.speciesDog),
                              color: const Color(0xFF1F3A5F), // Navy
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSpeciesChip(
                              context,
                              label: l10n.species_cat,
                              selected: _selectedSpecies == PetConstants.speciesCat,
                              onTap: () => _onSpeciesChanged(PetConstants.speciesCat),
                              color: const Color(0xFF1F3A5F),
                            ),
                          ),
                        ],
                      ),
                      
                      // Type Switch removed - AI auto-inference

                      
                      const SizedBox(height: 24),
                      
                      if (_isAnalyzing)
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                 const CircularProgressIndicator(color: Color(0xFF1F3A5F)),
                                 const SizedBox(height: 16),
                                 Text(PetLocalizations.of(context)!.pet_status_analyzing, style: theme.textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        )
                      else
                        Center(
                           child: TextButton.icon(
                             onPressed: () {
                               setState(() {
                                 _imagePath = null;
                               });
                             },
                             icon: Icon(LucideIcons.refreshCcw, color: theme.disabledColor),
                             label: Text(l10n.action_retake, style: TextStyle(color: theme.disabledColor)),
                           ),
                        ),

                    ],
                  ],
                ),
              ),
            ),
          ),
          
          // Fixed Analyze Button Area (Safe Layout)
          if (!_isAnalyzing && _imagePath != null)
            Padding(
               padding: const EdgeInsets.symmetric(horizontal: 16.0),
               child: ElevatedButton.icon(
                  onPressed: _processAnalysis,
                  icon: const Icon(LucideIcons.scanLine),
                  label: Text(PetLocalizations.of(context)!.pet_action_analyze),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F3A5F), // Navy #1F3A5F
                    foregroundColor: Colors.white,
                    shadowColor: Colors.black, // Hard shadow
                    elevation: 6,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
               ),
            ),
          
          if (!_isAnalyzing && _imagePath != null)
             const SizedBox(height: 12),

          // Fixed Footer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: theme.scaffoldBackgroundColor, // Match background
            child: Center(
              child: Text(
                PetLocalizations.of(context)!.pet_footer_text,
                style: TextStyle(
                  color: theme.disabledColor,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    // ScanNut+ Pet Style: Illuminated Borders & Left Icon
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20), // Height controlled by padding
        decoration: BoxDecoration(
          color: const Color(0xFF121A2B).withValues(alpha: 0.6), // Dark Navy semi-transparent
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
             color: const Color(0xFF1F3A5F).withValues(alpha: 0.6), // Illuminated Border
             width: 1.5
          ),
          boxShadow: [
             BoxShadow(
               color: const Color(0xFF1F3A5F).withValues(alpha: 0.2), // Subtle Navy Glow
               blurRadius: 12,
               offset: const Offset(0, 4),
             ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Hug content
          mainAxisAlignment: MainAxisAlignment.center, // Center the block
          children: [
            Icon(icon, size: 28, color: const Color(0xFFFFD1DC)), // Pet Pink Accent Icon (Left)
            const SizedBox(width: 12), // Standard spacing
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white, // High contrast
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeciesChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? color : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : const Color(0xFF22304A),
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : theme.disabledColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
             shadows: const [
                 Shadow(color: Colors.black, offset: Offset(1.0, 1.0), blurRadius: 2.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapabilitiesCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF121A2B).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1F3A5F).withValues(alpha: 0.6), // Illuminated
          width: 1.5,
        ),
        boxShadow: [
           BoxShadow(
             color: const Color(0xFF1F3A5F).withValues(alpha: 0.15),
             blurRadius: 10,
             offset: const Offset(0, 4),
           ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               const Icon(LucideIcons.sparkles, color: Color(0xFFFFD1DC), size: 20), // Pet Pink
               const SizedBox(width: 8),
               Text(
                 l10n.pet_capture_info_title,
                 style: theme.textTheme.titleMedium?.copyWith(
                   color: Colors.white,
                   fontWeight: FontWeight.bold,
                 ),
               ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(LucideIcons.scanLine, l10n.pet_capture_capability_visual),
          const SizedBox(height: 12),
          _buildInfoRow(LucideIcons.fileText, l10n.pet_capture_capability_exams),
          const SizedBox(height: 12),
          _buildInfoRow(LucideIcons.tag, l10n.pet_capture_capability_labels),
          const SizedBox(height: 12),
          _buildInfoRow(LucideIcons.activity, l10n.pet_capture_capability_biometrics),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
     return Row(
       mainAxisSize: MainAxisSize.min,
       children: [
         Icon(icon, size: 18, color: const Color(0xFF10AC84)), // Plant Green accents for capabilities
         const SizedBox(width: 12),
         Expanded(
           child: Text(
             text,
             style: const TextStyle(color: Color(0xFFEAF0FF), fontSize: 13),
           ),
         ),
       ],
     );
  }
}
