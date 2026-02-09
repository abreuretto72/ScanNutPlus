import 'dart:io';
// Added for JSON parsing
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/core/theme/app_colors.dart'; // AppColors
// import 'package:scannutplus/features/pet/l10n/generated/pet_localizations.dart'; // Removed
import 'package:scannutplus/features/pet/data/models/pet_entity.dart';
import 'package:scannutplus/features/pet/data/pet_service.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/services/pet_ai_service.dart';
// import 'package:scannutplus/features/pet/presentation/pet_generic_result_view.dart'; // Deprecated Protocol 2026

import 'package:scannutplus/features/pet/data/pet_rag_service.dart'; // For saving identity
import 'package:scannutplus/features/pet/data/pet_repository.dart';

class PetCaptureView extends StatefulWidget {
  const PetCaptureView({super.key});

  @override
  State<PetCaptureView> createState() => _PetCaptureViewState();
}

class _PetCaptureViewState extends State<PetCaptureView> {
  String? _imagePath;
  String? _selectedSpecies; // Nullable for forced selection
  final bool _isLabel = false;
  
  // Arguments
  String? _existingUuid;
  String? _existingName;
  String? _existingBreed; // New
  PetImageType? _forcedType;

  final ImagePicker _picker = ImagePicker();
  String? _errorMessage; // State to track analysis errors for Retry UI

  @override
  void initState() {
    super.initState();
    _selectedSpecies = null; // Explicit reset for Step 4
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _existingUuid = args[PetConstants.argUuid];
      _existingName = args[PetConstants.argName];
      _existingBreed = args[PetConstants.argBreed]; // New
      _forcedType = args[PetConstants.argType] as PetImageType?;
      final source = args[PetConstants.argSource] as String?;
      
      // Auto-open camera/gallery if requested
      if (source == PetConstants.valCamera && _imagePath == null) {
         WidgetsBinding.instance.addPostFrameCallback((_) => _pickImage(ImageSource.camera));
      } else if (source == PetConstants.valGallery && _imagePath == null) {
         WidgetsBinding.instance.addPostFrameCallback((_) => _pickImage(ImageSource.gallery));
      }

      // Legacy Support: Pre-select Dog for existing pets to avoid blocking flow
      // [STEP 4: MANDATORY SPECIES SELECTION CHECK]
      // Enforce User Selection: Do NOT pre-select Dog. User must click.
      // Legacy block removed to strictly enforce null state.
    }
  }

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
    
    setState(() {
      _isAnalyzing = true;
      _errorMessage = null; // Reset error state
    });
    
    try {
      // 1. Save locally first (already handled by _autoSave but let's be safe)
      await _autoSave(); 
      
      if (!mounted) return;

      // 2. Analyze
      // For now, hardcode 'pt' or get from User settings. 
      // Ideally get from Localizations.localeOf(context).languageCode
      final lang = Localizations.localeOf(context).languageCode;
      
      // AI Auto-Inference: Default to general, let AI classify internal context
      // Unless forced by Dashboard
      final type = _forcedType ?? PetImageType.general;
      
      // Use existing name/uuid if available
      final String nameToUse = _existingName ?? PetConstants.defaultPetName;
      final String uuidToUse = _existingUuid ?? PetConstants.defaultPetUuid;

      if (kDebugMode) {
         debugPrint('[SCAN_NUT_LOG] Imagem carregada: $_imagePath');
         print('[PET_STEP_1]: Analyze button pressed. Starting flow.');
      }

      try {
        final (result, duration, foundName) = await petAiService.analyzePetImage(
          _imagePath!, 
          lang, 
          type: type,
          petName: nameToUse,
          petUuid: uuidToUse,
        );
        
        if (kDebugMode) debugPrint('[PET_STEP_2]: Analysis Analysis complete. Result len: ${result.length}. Name found: $foundName');

        // 2.1. AUTO-SAVE to Repository (Crucial for MyPetsView to list it)
        // 2.1. PRE-PROCESS: Extract Breed & Name for Identity
        String extractedBreed = '';
        String cleanResult = result;
        
        // METADATA Extraction Strategy (Protocol 2026 - Structured Block)
        try {
           final metadataMatch = RegExp(r'\[METADATA\](.*?)\[END_METADATA\]', dotAll: true).firstMatch(result);
           
           if (metadataMatch != null && metadataMatch.groupCount >= 1) {
              final metadataContent = metadataMatch.group(1)?.trim() ?? '';
              
              // Extract Breed
              final breedMatch = RegExp(r'breed_name:\s*(.*?)(?:\||$)', caseSensitive: false).firstMatch(metadataContent);
              if (breedMatch != null) {
                 extractedBreed = breedMatch.group(1)?.trim() ?? '';
              }
              
              // Extract Species (Optional validation, could update _selectedSpecies)
              // final speciesMatch = RegExp(r'species:\s*(.*?)(?:\||$)', caseSensitive: false).firstMatch(metadataContent);

              // Clean the result by removing the METADATA block to avoid showing it in the UI
              cleanResult = result.replaceAll(metadataMatch.group(0)!, '').trim();
              
              if (kDebugMode) {
                 debugPrint('[PET_DATA_LOG]: Metadata Extracted. Breed: $extractedBreed');
              }
           } else {
              // Legacy/Fallback: Check for old FINAL_BREED tag just in case
              final legacyMatch = RegExp(PetConstants.regexLegacyFinalBreed).firstMatch(result);
              if (legacyMatch != null) {
                  extractedBreed = legacyMatch.group(1)?.trim() ?? '';
                  cleanResult = result.replaceAll(legacyMatch.group(0)!, '').trim();
              }
           }
        } catch (e) {
           if (kDebugMode) debugPrint('[PET_FATAL]: Metadata Extraction Failed ($e).');
        }

        // Secondary Fallback: Keyword Scan
        if (extractedBreed.isEmpty || extractedBreed == PetConstants.valueUnknown) {
           final scanText = cleanResult.length > 500 ? cleanResult.substring(0, 500) : cleanResult;
           final commonBreeds = PetConstants.commonBreedsList;
           
           for (final breed in commonBreeds) {
              if (scanText.contains(breed)) {
                 extractedBreed = breed;
                 break;
              }
           }
        }

        // Determine final Identity values
        final finalName = foundName.isNotEmpty ? foundName : nameToUse;
        final finalBreed = extractedBreed.isNotEmpty ? extractedBreed : (_existingBreed ?? PetConstants.valueUnknown);
        final finalType = type == PetImageType.newProfile ? PetConstants.typeNewProfile : type.toString().split('.').last;

        if (kDebugMode) debugPrint('[PET_DATA_LOG]: Saving Analysis. Type: $finalType | Breed: $finalBreed');

        // 2.2. AUTO-SAVE to Repository
        try {
          final repo = PetRepository();
          await repo.saveAnalysis(
            petUuid: uuidToUse,
            petName: finalName,
            analysisResult: cleanResult, // Save CLEAN visual report
            sources: [], 
            imagePath: _imagePath!,
            breed: finalBreed, // Pass extracted breed for New Profile creation
            analysisType: finalType, // Ensure validation checks match
          );
           
           if (kDebugMode) debugPrint('[PET_STEP_3]: Auto-saved to SharedPreferences.');
        } catch (e) {
           if (kDebugMode) debugPrint('[PET_ERROR]: Failed to auto-save: $e');
        }

        
        if (!mounted) return;

        // 3. Navigate to Specialized Result View (Restructuring 2026)
        // 3. Navigate to Generic Result View (Protocol Card 2026)
        // Configuration for specialized views (Kept for arguments)
        // 3. Navigate to Specialized Result View (Restructuring 2026)
        // 3. Navigate to Generic Result View (Protocol Card 2026)
        // Configuration for specialized views (Kept for arguments)


        // 3. Navigate to Standardized Result View (Protocol 2026 - Golden Standard)
        Navigator.of(context).pushReplacementNamed(
          '/pet_analysis_result',
          arguments: {
             PetConstants.argUuid: uuidToUse,
             PetConstants.argName: foundName.isNotEmpty ? foundName : nameToUse,
             PetConstants.argType: type,
             PetConstants.argImagePath: _imagePath!,
             PetConstants.argResult: cleanResult,
             PetConstants.argBreed: finalBreed, // Explicitly passing breed to Result View
             PetConstants.argPetDetails: {
                PetConstants.fieldName: foundName.isNotEmpty ? foundName : nameToUse,
                PetConstants.fieldBreed: finalBreed,
             }
          },
        );
      } on PetIdentityException catch (_) {
         if (kDebugMode) debugPrint('[SCAN_NUT_LOG] Identidade não confirmada. Solicitando nome...');
         
         // If we already have a UUID, this shouldn't happen unless logic in service forces check.
         // If it happens, we request name only if we don't have it.
         
         String name = _existingName ?? '';
         
         if (name.isEmpty) {
            // 1. Request Name Directly
            final nameInput = await _requestNameInput();
            if (nameInput == null || nameInput.isEmpty) {
               // User cancelled
               if (kDebugMode) debugPrint('[SCAN_NUT_LOG] Usuário cancelou a identificação.');
               setState(() => _isAnalyzing = false);
               return;
            }
            name = nameInput;
         }
         
         if (name.isNotEmpty) {
            if (kDebugMode) debugPrint('[SCAN_NUT_LOG] Nome capturado/usado: $name');
            
            // 3. Save Identity for RAG (Name only, leave others for later)
            // Only new identity if we don't have one
            String uuid = _existingUuid ?? DateTime.now().millisecondsSinceEpoch.toString();

            if (kDebugMode) debugPrint('[SCAN_NUT_LOG] Salvando identidade no RAG...');
            final bytes = await File(_imagePath!).readAsBytes();
            
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
             Navigator.of(context).pushNamed(
              '/pet_analysis_result',
              arguments: {
                 PetConstants.argUuid: uuid,
                 PetConstants.argName: name, 
                 PetConstants.argType: type,
                 PetConstants.argImagePath: _imagePath!,
                 PetConstants.argResult: result,
                 PetConstants.argBreed: PetConstants.valueUnknown,
                 PetConstants.argPetDetails: {
                    PetConstants.fieldName: name,
                    PetConstants.fieldBreed: PetConstants.valueUnknown,
                 }
              }
            );
         }
      } catch (e, stack) {
         if (kDebugMode) {
            debugPrint('[SCAN_NUT_ERROR] Erro na View: $e');
            debugPrint('[SCAN_NUT_ERROR] Stack: $stack');
         }
         
         if (mounted) {
           setState(() {
              _isAnalyzing = false;
              _errorMessage = e.toString();
           });
         }
         
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
                       const Icon(Icons.auto_awesome, color: Color(0xFFFFD1DC), size: 20),
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



  Future<void> _autoSave() async {
    if (_imagePath == null) return;
    if (_imagePath == null) return;
    // [STEP 4: MANDATORY SPECIES SELECTION]
    // Guard: Prevent auto-save until species (Dog/Cat) is explicitly selected.
    if (_selectedSpecies == null) return; 
    
    // l10n usage removed
    
    final pet = PetEntity(
      uuid: const Uuid().v4(),
      species: _selectedSpecies!,
      imagePath: _imagePath!,
      type: _isLabel ? AppLocalizations.of(context)!.pet_type_label : PetConstants.typePet,
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


  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context); // Unused
    final l10n = AppLocalizations.of(context)!;
    
    // Custom Navy Colors for this domain - UPDATED to AppColors.petBackgroundDark for consistency


    return Scaffold(
      backgroundColor: AppColors.petBackgroundDark, // Dark Theme
      appBar: AppBar(
        // Dynamic Title: Analisando: [Nome] or Captura Pet
        title: Text(
          _existingName != null && _existingName!.isNotEmpty
             ? l10n.pet_analyzing_x(_existingName!)
             : l10n.pet_capture_title
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white), // Enforce white back icon
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                      // SMART UPDATE PROTOCOL: Visual Badge for Known Pet
                      if (_existingName != null && _existingName!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.petPrimary.withValues(alpha: 0.1), // Pink Tint
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.petPrimary, width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                               const Icon(Icons.qr_code_scanner, color: AppColors.petPrimary, size: 20),
                               const SizedBox(width: 10),
                               Text(
                                 AppLocalizations.of(context)!.pet_analyzing_x(_existingName!), 
                                 style: const TextStyle(
                                   color: AppColors.petPrimary,
                                   fontWeight: FontWeight.bold,
                                   fontSize: 16,
                                 ),
                               ),
                            ],
                          ),
                        ),

                      _buildCapabilitiesCard(context),

                      _buildCaptureButton(
                        context,
                        icon: Icons.camera_alt_outlined,
                        label: l10n.action_take_photo,
                        onTap: () => _pickImage(ImageSource.camera),
                      ),
                      const SizedBox(height: 24),
                      _buildCaptureButton(
                        context,
                        icon: Icons.photo_library_outlined,
                        label: l10n.action_upload_gallery,
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                    ] else ...[
                      // Image Preview
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.petPrimary, width: 2), // Pink Border
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
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
                              color: AppColors.petPrimary, // Select = Pink
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSpeciesChip(
                              context,
                              label: l10n.species_cat,
                              selected: _selectedSpecies == PetConstants.speciesCat,
                              onTap: () => _onSpeciesChanged(PetConstants.speciesCat),
                              color: AppColors.petPrimary,
                            ),
                          ),
                        ],
                      ),
                      
                      // Type Switch removed - AI auto-inference

                      
                      const SizedBox(height: 24),
                      
                      const SizedBox(height: 24),

                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                                const Icon(Icons.error_outline, color: Colors.amber, size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.pet_analysis_error_generic(_errorMessage!.length > 50 ? '${_errorMessage!.substring(0, 50)}...' : _errorMessage!),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: _processAnalysis,
                                  icon: const Icon(Icons.refresh, color: Colors.black),
                                  label: Text(l10n.action_retake, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFD1DC), // Pastel Pink
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  ),
                                ),
                             ],
                          ),
                        )
                      else if (_isAnalyzing)
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                 const CircularProgressIndicator(color: AppColors.petPrimary),
                                 const SizedBox(height: 16),
                                 const SizedBox(height: 16),
                                 Text(
                                   _existingName != null 
                                     ? AppLocalizations.of(context)!.pet_analyzing_x(_existingName!)
                                     : AppLocalizations.of(context)!.generic_analyzing, // Generic fallback
                                   style: const TextStyle(color: Colors.white70),
                                 ),
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
                             icon: const Icon(Icons.refresh, color: Colors.white54),
                             label: Text(l10n.action_retake, style: const TextStyle(color: Colors.white54)),
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
                  // [STEP 4: MANDATORY SPECIES SELECTION]
                  // Enable 'New Analysis' only if species is selected.
                  // Visual Feedback: Button is disabled (null onPressed) if species is null.
                  onPressed: (_selectedSpecies == null || _isAnalyzing) ? null : _processAnalysis,
                  icon: const Icon(Icons.qr_code_scanner, color: AppColors.petText), // Alert Icon Black
                  label: Text(
                      AppLocalizations.of(context)!.pet_action_new_analysis,
                      style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.petPrimary, // Pink
                    foregroundColor: AppColors.petText,    // Black
                    shadowColor: Colors.black, // Hard shadow
                    elevation: 6,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.petText, width: 1.0),
                    ),
                  ),
               ),
            ),
          
          if (!_isAnalyzing && _imagePath != null)
             const SizedBox(height: 12),

          // Fixed Footer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: AppColors.petBackgroundDark, // Match background
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.pet_footer_brand,
                style: TextStyle(
                  color: Theme.of(context).disabledColor,
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
  }) {
    // ScanNut+ Pet Style: Illuminated Borders & Left Icon (Pink/Black/Dark)
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20), // Height controlled by padding
        decoration: BoxDecoration(
          color: AppColors.petBackgroundDark, // Dark
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
             color: AppColors.petPrimary.withValues(alpha: 0.5), // Pink Border
             width: 1.5
          ),
          boxShadow: [
             BoxShadow(
               color: AppColors.petPrimary.withValues(alpha: 0.1), // Pink Glow
               blurRadius: 12,
               offset: const Offset(0, 4),
             ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Hug content
          mainAxisAlignment: MainAxisAlignment.center, // Center the block
          children: [
            Icon(icon, size: 28, color: AppColors.petPrimary), // Pink Icon
            const SizedBox(width: 12), // Standard spacing
            Text(
              label,
              style: const TextStyle(
                color: Colors.white, // High contrast on Dark
                fontWeight: FontWeight.bold,
                fontSize: 16,
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
    // Color is passed as AppColors.petPrimary when selected
    // final theme = Theme.of(context); // Unused
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? color : AppColors.petBackgroundDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.petText : Colors.grey.withValues(alpha: 0.3), // Black border if selected
            width: selected ? 2 : 1, // Thicker if selected
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.petText : Colors.white54, // Black text if selected
            fontWeight: FontWeight.bold,
            fontSize: 16,
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
               const Icon(Icons.auto_awesome, color: Color(0xFFFFD1DC), size: 20), // Pet Pink
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
          _buildInfoRow(Icons.qr_code_scanner, l10n.pet_capture_capability_visual),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.description, l10n.pet_capture_capability_exams),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.label, l10n.pet_capture_capability_labels),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.monitor_heart, l10n.pet_capture_capability_biometrics),
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
