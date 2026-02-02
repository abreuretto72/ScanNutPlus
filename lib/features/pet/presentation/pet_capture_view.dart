import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/features/pet/data/models/pet_entity.dart';
import 'package:scannutplus/features/pet/data/pet_service.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/services/pet_ai_service.dart';
import 'package:scannutplus/features/pet/services/pet_pdf_service.dart';
import 'package:printing/printing.dart';
import 'package:scannutplus/features/pet/presentation/pet_analysis_result_view.dart';
import 'package:scannutplus/features/pet/services/pet_voice_parser_service.dart';
import 'package:scannutplus/features/pet/l10n/generated/pet_localizations.dart';
import 'package:scannutplus/features/pet/data/pet_rag_service.dart'; // For saving identity
import 'package:scannutplus/features/pet/data/pet_repository.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class PetCaptureView extends StatefulWidget {
  const PetCaptureView({super.key});

  @override
  State<PetCaptureView> createState() => _PetCaptureViewState();
}

class _PetCaptureViewState extends State<PetCaptureView> {
  String? _imagePath;
  String _selectedSpecies = PetConstants.speciesDog;
  bool _isLabel = false; 
  final SpeechToText _speechToText = SpeechToText();

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
      final type = _isLabel ? PetImageType.label : PetImageType.general;
      
      if (kDebugMode) {
         print('[PET_STEP_1]: Analyze button pressed. Starting flow.');
         print('[PET_STEP_2]: Validating image path: $_imagePath');
         print('[PET_STEP_3]: Calling petAiService...');
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
         // --- VOICE FLOW (AUTOMATED STT) ---
         // 1. Start Listening Automatically
         final voiceInput = await _startListening();
         
         if (voiceInput != null && voiceInput.isNotEmpty) {
            // 2. Parse
            final data = petVoiceParserService.parse(voiceInput);
            final name = data[PetConstants.fieldName] ?? PetConstants.defaultPetName;
            final isNeutered = data[PetConstants.fieldIsNeutered] == PetConstants.valTrue;
            
            // 3. Save Identity for RAG
            final bytes = await File(_imagePath!).readAsBytes();
            final uuid = DateTime.now().millisecondsSinceEpoch.toString(); 
            
            final ragService = PetRagService(PetRepository());
            await ragService.saveVisualIdentity(uuid, name, bytes, isNeutered: isNeutered); 
            
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text(PetLocalizations.of(context)!.pet_rag_new_identity(name))),
            );

            // 4. Retry Analysis with Metadata
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
                  petDetails: data, // Pass parsed data map directly
                ),
              ),
            );
         } else {
           // User cancelled voice or no input
           setState(() => _isAnalyzing = false);
         }
      } catch (e) {
         debugPrint(e.toString());
         setState(() => _isAnalyzing = false);
      }
    } finally {
       if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Future<String?> _startListening() async {
    // 1. Permission
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) return null;
    }

    // 2. Init
    bool available = await _speechToText.initialize();
    if (!available) return null;

    if (!mounted) return null;
    
    // 3. Show UI (Dialog with Listening State)
    String recognizedText = '';
    
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            
            // Auto start logic inside dialog
            if (!_speechToText.isListening && recognizedText.isEmpty) {
               _speechToText.listen(
                 onResult: (result) {
                    setDialogState(() {
                      recognizedText = result.recognizedWords;
                    });
                 },
                 localeId: Localizations.localeOf(context).toString(),
                 cancelOnError: true,
               );
            }

            return AlertDialog(
              backgroundColor: const Color(0xFF121A2B),
              title: Row(children: [
                 const Icon(LucideIcons.mic, color: Color(0xFF10AC84)), // Green for listening
                 const SizedBox(width: 8),
                 Text(PetLocalizations.of(ctx)!.pet_voice_who_is_this, style: const TextStyle(color: Colors.white))
              ]),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Text(PetLocalizations.of(ctx)!.pet_voice_instruction, style: const TextStyle(color: Colors.white70)),
                   const SizedBox(height: 24),
                   
                   // Dynamic Wave/Text
                   Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       color: const Color(0xFF1F3A5F),
                       borderRadius: BorderRadius.circular(12),
                       border: Border.all(color: _speechToText.isListening ? const Color(0xFF10AC84) : Colors.transparent),
                     ),
                     child: Text(
                       recognizedText.isEmpty ? PetLocalizations.of(ctx)!.pet_voice_hint : recognizedText,
                       style: TextStyle(
                         color: recognizedText.isEmpty ? Colors.white30 : Colors.white,
                         fontStyle: recognizedText.isEmpty ? FontStyle.italic : FontStyle.normal,
                       ),
                       textAlign: TextAlign.center,
                     ),
                   ),
                ],
              ),
              actions: [
                TextButton(
                   onPressed: () {
                     _speechToText.stop();
                     Navigator.pop(ctx, null);
                   },
                   child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel, style: const TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                   onPressed: () {
                     _speechToText.stop();
                     Navigator.pop(ctx, recognizedText);
                   },
                   style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10AC84)),
                   child: Text(PetLocalizations.of(ctx)!.pet_voice_action),
                ),
              ],
            );
          },
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
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121A2B), // Dark Navy Card
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1F3A5F), width: 2), // Navy Accent
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             const Icon(LucideIcons.info, color: Color(0xFFEAF0FF), size: 24),
                             const SizedBox(width: 12),
                             Expanded(
                               child: Text(
                                 l10n.pet_capture_instructions,
                                 style: theme.textTheme.bodyMedium?.copyWith(
                                   color: const Color(0xFFEAF0FF),
                                   height: 1.4,
                                   shadows: const [
                                      Shadow(color: Colors.black, offset: Offset(2.0, 2.0), blurRadius: 4.0),
                                      Shadow(color: Colors.black, offset: Offset(-0.5, -0.5), blurRadius: 1.0),
                                   ],
                                 ),
                               ),
                             ),
                          ],
                        ),
                      ),

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
                      
                      const SizedBox(height: 32),
                      
                      // Type Switch (Pet vs Label)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cardBorderColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.image_type_label,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.disabledColor
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _isLabel ? l10n.type_label : l10n.type_pet,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: _isLabel,
                              onChanged: _onTypeChanged,
                            ),
                          ],
                        ),
                      ),
                      
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFF121A2B), // Dark Navy Card
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF22304A), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: const Color(0xFF1F3A5F)), // Navy Accent
            const SizedBox(height: 16),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                shadows: const [
                   Shadow(color: Colors.black, offset: Offset(2.0, 2.0), blurRadius: 4.0),
                   Shadow(color: Colors.black, offset: Offset(-0.5, -0.5), blurRadius: 1.0),
                ],
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
}
