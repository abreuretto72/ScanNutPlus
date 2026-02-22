import 'dart:io';
// Added for JSON parsing
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart'; // Added for Audio Files
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart'; // For generating video thumbnails // Added for Video Preview
import 'package:uuid/uuid.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/core/theme/app_colors.dart'; // AppColors
// import 'package:scannutplus/features/pet/l10n/generated/pet_localizations.dart'; // Removed
import 'package:scannutplus/features/pet/data/models/pet_entity.dart';
import 'package:scannutplus/features/pet/data/pet_service.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/services/pet_ai_service.dart';
// import 'package:scannutplus/features/pet/presentation/pet_generic_result_view.dart'; // Deprecated Protocol 2026

import 'package:scannutplus/features/pet/services/pet_base_ai_service.dart'; // Added for PetAiOverloadException

import 'package:scannutplus/features/pet/data/pet_rag_service.dart'; // For saving identity
import 'package:scannutplus/features/pet/data/pet_repository.dart';
import 'package:scannutplus/core/services/universal_ai_service.dart'; // New Engine
import 'package:scannutplus/core/services/universal_result_view.dart'; // New View
import 'package:scannutplus/core/services/universal_ocr_service.dart'; // New OCR Engine
import 'package:scannutplus/core/services/universal_ocr_result_view.dart'; // New OCR View
import 'package:gal/gal.dart'; // Added for saving camera captures to gallery

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
  bool _isAddingNewPet = false; // [STATE] Controls UI for New Pet vs Existing
  PetImageType? _forcedType;
  
  // Friend State
  bool _isFriend = false;
  String? _tutorName;
  bool _isNewFriend = false;
  String? _ownerName;

  final ImagePicker _picker = ImagePicker();
  String? _errorMessage; // State to track analysis errors for Retry UI
  VideoPlayerController? _videoController; // Video Preview

  @override
  void initState() {
    super.initState();
    _selectedSpecies = null; // Explicit reset for Step 4
  }

  @override
  void dispose() {
    _clearImageCache();
    _videoController?.dispose(); // Dispose Video Controller
    super.dispose();
  }

  void _clearImageCache() {
    if (_imagePath != null) {
      FileImage(File(_imagePath!)).evict();
      if (kDebugMode) debugPrint('[SCAN_NUT_MEMORY] Evicted image from cache: $_imagePath');
    }
    _videoController?.dispose();
    _videoController = null;
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
      _isAddingNewPet = args[PetConstants.argIsAddingNewPet] ?? false; // Extract State Flag
      
      // Friend Logic (Module 2026)
      final l10n = AppLocalizations.of(context)!;
      _isFriend = args[l10n.tech_is_friend] ?? false;
      _tutorName = args[l10n.tech_tutor_name];
      _isNewFriend = args[l10n.tech_is_new_friend] ?? false;
      _ownerName = args[l10n.tech_my_pet_name];
      
      debugPrint('[TUTOR_TRACE] Capture recebeu: $_tutorName usando chave ${l10n.tech_tutor_name}');

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

  // Add at top imports if not present, checking manually first.
  
  // Inside _PetCaptureViewState
  Future<void> _generateThumbnail(String videoPath) async {
    try {
      final String? thumbPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: '$videoPath.thumb.jpg',
        imageFormat: ImageFormat.JPEG,
        maxHeight: 256, // Smaller for list view
        quality: 75,
      );
      
      if (kDebugMode) debugPrint('[PET_CAPTURE] Thumbnail generated at: $thumbPath');
    } catch (e) {
      if (kDebugMode) debugPrint('[PET_CAPTURE] Error generating thumbnail: $e');
    }
  }

  Future<void> _pickImage(ImageSource source, {bool isVideo = false}) async {
    try {
      XFile? media;
      
      // [VOCAL LOGIC - AUDIO/VIDEO SPECIAL CASE]
      if (_forcedType == PetImageType.vocal) {
         if (source == ImageSource.camera) {
           media = await _picker.pickVideo(source: source, maxDuration: const Duration(seconds: 15));
         } else {
             List<String> extensions = [...PetConstants.audioExtensions, ...PetConstants.videoExtensions];
             FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: extensions);
             if (result != null && result.files.single.path != null) media = XFile(result.files.single.path!);
         }
      } 
      // [STRICT IMAGE ONLY LOGIC - LAB & LABEL (OCR)]
      else if (_forcedType == PetImageType.lab || _forcedType == PetImageType.label) {
          if (source == ImageSource.camera) {
              media = await _picker.pickImage(source: source);
          } else {
              // Standard Image Picker for Gallery (System Default)
              media = await _picker.pickImage(source: source);
          }
      }
      // [HYBRID LOGIC - ALL OTHER TYPES (BEHAVIOR, POSTURE, GENERAL, ETC.)]
      // Allows both Video and Image
      else {
          if (source == ImageSource.camera) {
              if (isVideo) {
                 media = await _picker.pickVideo(source: source, maxDuration: const Duration(seconds: 15));
              } else {
                 media = await _picker.pickImage(source: source);
              }
          } else {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: PetConstants.galleryExtensions,
              );
              if (result != null && result.files.single.path != null) media = XFile(result.files.single.path!);
          }
      }

      if (media != null) {
      // [SIZE CHECK] Enforce 20MB Limit for Gemini Inline
      final file = File(media.path);
      final sizeInBytes = await file.length();
      final sizeInMb = sizeInBytes / (1024 * 1024);

      if (sizeInMb > 20.0) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.error_file_too_large), backgroundColor: Colors.red));
         }
         return; // ABORT
      }

      // Clear previous image from memory before setting new one
      _clearImageCache();
        
        final path = media.path;
        final ext = path.split('.').last.toLowerCase();
        final isVideoFile = isVideo || PetConstants.videoExtensions.contains(ext);

        // Save to gallery if taken with camera
        if (source == ImageSource.camera) {
           try {
              if (isVideoFile) {
                 await Gal.putVideo(path);
              } else {
                 await Gal.putImage(path);
              }
              if (kDebugMode) debugPrint('[GAL] Saved media to gallery: $path');
           } catch (e) {
              if (kDebugMode) debugPrint('[GAL_ERROR] Failed to save media to gallery: $e');
           }
        }

        if (isVideoFile) {
           // Generate Thumbnail in Background
           _generateThumbnail(path);
           
           _videoController = VideoPlayerController.file(File(path))
             ..initialize().then((_) {
               if (mounted) setState(() {}); // Refresh to show video
               _videoController!.setLooping(true);
               _videoController!.play();
             });
        }

        setState(() {
          _imagePath = path;
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
      final String breedToUse = _existingBreed ?? PetConstants.legacyUnknownBreed;

      if (kDebugMode) {
         debugPrint('[SCAN_NUT_LOG] Imagem carregada: $_imagePath');
         print('[PET_STEP_1]: Analyze button pressed. Starting flow.');
      }
      debugPrint('[VOCAL_TRACE] State set to _isAnalyzing = true. UI should show Loading indicator.');

      try {
        String result = '';
        String foundName = '';

        // [UNIVERSAL OCR SWITCH - 2026]
        // Dedicated Engine for Documents (Lab Exams, Prescriptions, Food Labels)
        // [UNIVERSAL OCR SWITCH - 2026]
        // Dedicated Engine for Documents (Lab Exams, Prescriptions, Food Labels)
        // REMOVED: Plant Mode from OCR (Moved to Universal AI for Visual Analysis)
        if (type == PetImageType.lab || type == PetImageType.label) {
             debugPrint('[UNIVERSAL_OCR_TRACE] Step 1: Document/Label Detected. Selecting OCR Engine.');
             
             final ocrService = UniversalOcrService();
             String expertise = '';
             
             if (type == PetImageType.label) {
               expertise = 'Veterinary Nutritionist';
             } else if (type == PetImageType.lab) expertise = 'Veterinary Clinical Pathologist';

             debugPrint('[UNIVERSAL_OCR_TRACE] Step 2: Calling UniversalOcrService with expertise: $expertise');
             
             result = await ocrService.processOcr(
               documentImage: File(_imagePath!), 
               expertise: expertise, 
               languageCode: lang,
               l10n: AppLocalizations.of(context)!,
             );
             
             debugPrint('[UNIVERSAL_OCR_TRACE] Step 3: OCR Analysis Complete. Length: ${result.length}');

             // [FRIEND METADATA DICTIONARY KEY FOR OCR]
             // Force metadata string into raw JSON so History Tab reg-ex can pull it
             if (_isFriend) {
                 result += '\n\n[METADATA]';
                 if (_tutorName != null && _tutorName!.isNotEmpty) {
                     result += '\ntutor_name: ${_tutorName!}';
                 }
                 if (_ownerName != null && _ownerName!.isNotEmpty) {
                     result += '\nmy_pet_name: ${_ownerName!}';
                 }
                 result += '\n[END_METADATA]';
             }

             // [AUTO-SAVE] Save to History (Critical Fix 2026)
             try {
                final repo = PetRepository();
                // Basic extraction of sources for metadata (robustness)
                List<String> extractedSources = [];
                if (result.contains('[SOURCES]')) {
                   final sourceBlock = result.split('[SOURCES]').last.trim();
                   extractedSources = sourceBlock.split('\n').where((s) => s.length > 5).toList();
                }

                await repo.saveAnalysis(
                  petUuid: uuidToUse,
                  petName: nameToUse,
                  analysisResult: result, // Save the FULL raw result including [SOURCES] and new [METADATA]
                  sources: extractedSources,
                  imagePath: _imagePath!,
                  breed: breedToUse,
                  analysisType: type == PetImageType.label ? PetConstants.typeLabel : PetConstants.typeLab,
                  tutorName: _tutorName,
                  isFriend: _isFriend,
                );
                debugPrint('[UNIVERSAL_OCR_TRACE] Step 3.1: Analysis saved to History.');
             } catch (e) {
                debugPrint('[UNIVERSAL_OCR_ERROR] Failed to save history: $e');
             }

             if (!mounted) return;

             // Navigate to UniversalOcrResultView
             Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => UniversalOcrResultView(
                  imagePath: _imagePath!,
                  ocrResult: result,
                  petDetails: {
                    PetConstants.fieldName: nameToUse,
                    PetConstants.fieldBreed: breedToUse,
                    PetConstants.keyIsFriend: _isFriend.toString(),
                    if (_isFriend) 'my_pet_name': _ownerName ?? '',
                    PetConstants.keyTutorName: _tutorName ?? '',
                    PetConstants.keyPageTitle: AppLocalizations.of(context)!.general_analysis,
                  },
                ),
              ),
            );
            return; // Stop execution here for OCR flow
        }

        // [UNIVERSAL AI SWITCH - 2026]
        // Updated to include Dentist, Dermatology, Gastro, Ophthalmology, Otology, Posture & Vocal Modules
        if (type == PetImageType.newProfile || _isAddingNewPet || type == PetImageType.mouth || type == PetImageType.skin || type == PetImageType.stool || type == PetImageType.eyes || type == PetImageType.ears || type == PetImageType.posture || type == PetImageType.vocal || type == PetImageType.foodBowl || type == PetImageType.behavior || type == PetImageType.general || type == PetImageType.plantCheck) {
            String expertise = 'Veterinary Generalist & Geneticist';
            String aiContext = 'Visual Breed & Health Analysis: 1. BREED & GENETICS: Identify breed/mix and potential genetic predispositions (e.g. hip dysplasia, heart issues). 2. STRUCTURE: Evaluate posture and body condition score (nutritional impact). 3. ENERGY/METABOLISM: Assess energy level needs based on breed (e.g. Border Collie vs Pug). 4. BEHAVIOR: Observe posture/expression for signs of anxiety or pain.';
            
            debugPrint('[UNIVERSAL_FLOW_TRACE] Step 1: Selecting Engine for Type: $type');

            if (type == PetImageType.mouth) {
                expertise = 'Veterinary Dentist';
                aiContext = 'Clinical assessment of Oral Health: Tartar (Calculus), Gums (Gingivitis/Periodontitis), Broken Teeth, and general hygiene. Look for signs of pain or infection.';
                debugPrint('[DENTISTRY_FLOW_TRACE] Context Injected: $aiContext');
            } else if (type == PetImageType.skin) {
                expertise = 'Veterinary Dermatologist';
                aiContext = 'Clinical assessment of Skin & Coat: Alopecia, Dermatitis, Wounds, Parasites (Fleas/Ticks), and lumps/bumps. Look for redness, crusts, or signs of infection.';
                debugPrint('[DERMATOLOGY_FLOW_TRACE] Context Injected: $aiContext');
            } else if (type == PetImageType.stool) {
                expertise = 'Veterinary Gastroenterologist';
                aiContext = 'Clinical assessment of Stool/Feces: Consistency (Bristol Scale), Color, presence of Blood/Mucus, and signs of Parasites. Evaluate digestive health.';
                debugPrint('[GASTRO_FLOW_TRACE] Context Injected: $aiContext');
                debugPrint('[UNIVERSAL_AI] Iniciando análise GASTROINTESTINAL via engine v2...');
            } else if (type == PetImageType.eyes) {
                expertise = 'Veterinary Ophthalmologist';
                aiContext = 'Clinical assessment of Eyes: Discharge (Epiphora/Purulent), Hyperemia (Redness), Cloudiness (Cataracts/Edema), Masses, and Anisocoria. Look for signs of uveitis or glaucoma.';
                debugPrint('[OPHTHALMOLOGY_FLOW_TRACE] Context Injected: $aiContext');
            } else if (type == PetImageType.ears) {
                expertise = 'Veterinary Otologist';
                aiContext = 'Clinical assessment of Ears/Otoscopy: Cerumen accumulation, Erythema (Redness), Stenosis, Discharge (Exudate), and signs of Otitis Externa. Look for mites or foreign bodies.';
                debugPrint('[OTOLOGY_FLOW_TRACE] Context Injected: $aiContext');
            } else if (type == PetImageType.posture) {
                expertise = 'Veterinary Nutritionist & Orthopedist';
                aiContext = 'Clinical assessment of Posture & Body Condition: Body Condition Score (BCS 1-9), Muscle Mass Index (MMI), Posture alignment (Spine/Limbs), and detection of Obesity or Emaciation.';
                debugPrint('[POSTURE_FLOW_TRACE] Context Injected: $aiContext');
            } else if (type == PetImageType.vocal) {
                expertise = 'Veterinary Behaviorist & Pulmonologist';
                aiContext = 'Audio Analysis: Listen for coughs, breathing, barks. Identify distress.';
                debugPrint('[VOCAL_FLOW_TRACE] Context Injected: $aiContext');
            } else if (type == PetImageType.behavior) {
                expertise = 'Veterinary Neurologist & Behaviorist & Geneticist';
                aiContext = 'Behavioral & Breed Analysis (Visual/Video): 1. BREED & GENETICS: Identify breed/mix and potential genetic predispositions (e.g. hip dysplasia, heart issues). 2. STRUCTURE: Evaluate gait, posture, and body condition score (nutritional impact). 3. ENERGY/METABOLISM: Assess energy level needs based on breed (e.g. Border Collie vs Pug). 4. BEHAVIOR: Observe circling, head pressing, anxiety, or neurological signs. If video, analyze vocalizations.';
                debugPrint('[BEHAVIOR_FLOW_TRACE] Context Injected (Enriched): $aiContext');
            } else if (type == PetImageType.plantCheck) {
                expertise = 'Veterinary Toxicologist & Botanist';
                aiContext = '''
Act as a Specialist in Botany, Phytopathology, and Agronomic Engineering.
Task: Perform an exhaustive visual inspection of the plant and provide the data below structured for the ScanNut+ Card System using the STANDARD [CARD_START] FORMAT.

1. Technical Identification: Scientific name (genus/species), common names, family, origin.
2. Biological Safety (Pet Focus): Toxicity Level (0-4), Toxic Principles, Clinical Signs.
3. Soil & Substrate: Texture, pH, Drainage.
4. Precision Nutrition: Lighting (Lux/PAR), NPK Schedule, Watering.
5. Visual Diagnosis: Pathogens, Pests, Deficiencies.
6. Action Plan: Recovery or Safe Positioning.

REQUIRED OUTPUT STRUCTURE (Strictly follow [CARD_START] ... [CARD_END]):

[CARD_START]
TITLE: [Scientific Name]
ICON: [If Toxic: "warning" | If Safe: "check_circle"]
CONTENT: [Common Names] | Family: [Family] | Origin: [Origin] | [Toxic/Safe Status Summary]
[CARD_END]

[CARD_START]
TITLE: Safety & Toxicity
ICON: health_and_safety
CONTENT: Level: [0-4] | Active Principles: [List] | Clinical Signs: [Symptoms] | First Aid: [Measures]
[CARD_END]

[CARD_START]
TITLE: Soil & Care
ICON: eco
CONTENT: Soil: [Texture/pH] | Light: [Lux/PAR] | Water: [Method] | NPK: [Schedule]
[CARD_END]

[CARD_START]
TITLE: Plant Health Diagnosis
ICON: local_florist
CONTENT: Pathogens: [Fungi/Bacteria] | Pests: [Mites/Insects] | Nutrition: [Chlorosis/Necrosis]
[CARD_END]

[CARD_START]
TITLE: Action Plan
ICON: info
CONTENT: [Step-by-step recovery guide or positioning suggestion]
[CARD_END]

REQUIRED: List 3-5 scientific references or authoritative sources (e.g. Embrapa, USDA) used for this analysis in the following format:
[SOURCES]
- Short Citation 1
- Short Citation 2
- Short Citation 3
''';
                debugPrint('[PLANT_FLOW_TRACE] Context Injected: Deep Botanical Protocol (Standard Format)');
            } else if (type == PetImageType.foodBowl) {
                expertise = 'Veterinary Nutritionist';
                aiContext = 'Visual Food Analysis (Kibble/Homemade). Analyze quality, texture, color, and ingredients. Estimate nutritional balance. Look for foreign objects or mold. Ignore label text, focus on food appearance.';
                debugPrint('[FOOD_BOWL_FLOW_TRACE] Context Injected: $aiContext');
            } else {
                debugPrint('[UNIVERSAL_AI] Iniciando análise de NOVO PET com engine v2...');
            }
            
            debugPrint('[UNIVERSAL_FLOW_TRACE] Step 3: Calling UniversalAiService...');
            debugPrint('[VOCAL_TRACE] Sending payload to UniversalAiService.analyze(...)');
            final universalService = UniversalAiService();
            result = await universalService.analyze(
              file: File(_imagePath!), 
              expertise: expertise, 
              context: aiContext, 
              languageCode: lang,
              petName: nameToUse,
              l10n: AppLocalizations.of(context)!,
            );
            debugPrint('[VOCAL_TRACE] Successfully received result from UniversalAiService. Length: ${result.length}');
            debugPrint('[UNIVERSAL_FLOW_TRACE] Step 4: Analysis returned. Length: ${result.length}');
            foundName = nameToUse;
        } else {
            // LEGACY FLOW
            final (legacyResult, _, legacyName) = await petAiService.analyzePetImage(
              _imagePath!, 
              lang, 
              type: type,
              petName: nameToUse,
              petUuid: uuidToUse,
            );
            result = legacyResult;
            foundName = legacyName;
        }
        
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

        // [FRIEND METADATA DICTIONARY KEY]
        // Força a injeção do nome do tutor e do pet dono no arquivo bruto
        // para que a tela de histórico consiga resgatar via regex.
        if (_isFriend) {
            cleanResult += '\n\n[METADATA]';
            if (_tutorName != null && _tutorName!.isNotEmpty) {
                cleanResult += '\ntutor_name: ${_tutorName!}';
            }
            if (_ownerName != null && _ownerName!.isNotEmpty) {
                cleanResult += '\nmy_pet_name: ${_ownerName!}';
            }
            cleanResult += '\n[END_METADATA]';
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
            breed: finalBreed, // Pass extracted breed for New Profile Creation
            analysisType: finalType, // Preserve actual analysis type
            tutorName: _tutorName, // Pass Tutor Name
            isFriend: _isFriend,
          );
           
           if (kDebugMode) debugPrint('[PET_STEP_3]: Auto-saved to SharedPreferences.');
        } catch (e) {
           if (kDebugMode) debugPrint('[PET_ERROR]: Failed to auto-save: $e');
        }

        
        if (!mounted) return;

        if (type == PetImageType.newProfile || _isAddingNewPet || type == PetImageType.behavior || type == PetImageType.plantCheck || type == PetImageType.mouth || type == PetImageType.skin || type == PetImageType.stool || type == PetImageType.eyes || type == PetImageType.ears || type == PetImageType.posture || type == PetImageType.foodBowl || type == PetImageType.vocal) {
            // [UNIVERSAL RESULT VIEW]
             Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => UniversalResultView(
                  filePath: _imagePath!,
                  analysisResult: cleanResult,
                  onRetake: () => Navigator.pop(context),
                  onShare: () {},
                  petDetails: {
                    PetConstants.fieldName: finalName,
                    PetConstants.fieldBreed: finalBreed,
                    PetConstants.keyIsFriend: _isFriend.toString(),
                    if (_isFriend) 'my_pet_name': _ownerName ?? '',
                    PetConstants.keyTutorName: _tutorName ?? '',
                    PetConstants.keyPageTitle: _getAnalysisTitle(type, AppLocalizations.of(context)!),
                  },
                ),
              ),
            );
        } else {
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
                PetConstants.keyIsFriend: _isFriend.toString(),
                if (_isFriend) 'my_pet_name': _ownerName ?? '',
                PetConstants.keyTutorName: _tutorName ?? '',
                PetConstants.keyPageTitle: _getAnalysisTitle(type, AppLocalizations.of(context)!),
             }
           },
        ).then((_) {
           // [STATE RESET] Force reset to 'Existing Pet' mode after return
        });
      } // End else
      
      // Clear state after navigation returns or completes


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
                    PetConstants.keyIsFriend: _isFriend.toString(),
                    PetConstants.keyTutorName: _tutorName ?? '',
                    PetConstants.keyPageTitle: _getAnalysisTitle(type, AppLocalizations.of(context)!),
                 }
              }
            );
          }
       } on PetAiOverloadException catch (_) {
         if (mounted) {
            setState(() {
               _isAnalyzing = false;
               _errorMessage = AppLocalizations.of(context)!.pet_ai_overloaded_message;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.pet_ai_overloaded_message), 
                backgroundColor: Colors.amber[900], // Orange/Amber for Overload
                behavior: SnackBarBehavior.floating,
              ),
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
    
    // FIX: Use existing UUID/Name to prevents duplicates (Ghost Records)
    final uuid = _existingUuid ?? const Uuid().v4();
    final name = _existingName;

    final pet = PetEntity(
      uuid: uuid,
      name: name, // Prevent null name if we already have it
      species: _selectedSpecies!,
      imagePath: _imagePath!,
      tutorName: _tutorName,
      type: _isFriend ? PetConstants.typeFriend : (_isLabel ? AppLocalizations.of(context)!.pet_type_label : PetConstants.typePet),
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
    
    // [DEBUG] Trace Removed - Logic Blindada
    // final bool isExistingPet = !_isAddingNewPet;

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

                      // 1. PHOTO BUTTON (Camera)
                      // Visible for ALL types except Vocal (Audio only)
                      if (_forcedType != PetImageType.vocal)
                      _buildCaptureButton(
                        context,
                        icon: Icons.camera_alt_outlined,
                        label: l10n.action_take_photo,
                        onTap: () => _pickImage(ImageSource.camera),
                      ),
                      
                      const SizedBox(height: 24),

                      // 2. VIDEO BUTTON (Camera) - UNIVERSAL SUPPORT (EXCEPT LAB/LABEL)
                      if (_forcedType != PetImageType.lab && _forcedType != PetImageType.label) ...[
                         _buildCaptureButton(
                           context,
                           icon: Icons.videocam,
                           label: l10n.action_record_video_audio, // "Gravar"
                           onTap: () => _pickImage(ImageSource.camera, isVideo: true),
                         ),
                         const SizedBox(height: 24),
                      ],

                      // 3. GALLERY / UPLOAD BUTTON
                      // Visible for ALL types
                      _buildCaptureButton(
                        context,
                        icon: (_forcedType == PetImageType.vocal) 
                               ? Icons.perm_media // Changed to Media to imply multi-format
                               : Icons.photo_library_outlined, 
                        label: (_forcedType == PetImageType.vocal) 
                               ? l10n.action_upload_video_audio // "Carregar" (or generic upload) - checking arb
                               : l10n.action_upload_gallery, 
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                    ] else ...[
                      // Image Preview
                      // Media Preview (Image or Video)
                      Container(
                        height: 300,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.petPrimary, width: 2), // Pink Border
                          color: Colors.black, // Background for video
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14), // Inner radius
                          child: _videoController != null && _videoController!.value.isInitialized
                              ? Stack(
                                  alignment: Alignment.center,
                                  children: [
                                     AspectRatio(
                                       aspectRatio: _videoController!.value.aspectRatio,
                                       child: VideoPlayer(_videoController!),
                                     ),
                                     // Optional: Play Icon overlay if needed, but we auto-play
                                  ],
                                )
                              : Image.file(
                                  File(_imagePath!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                     // Fallback if image load fails (e.g. video without controller yet)
                                     return const Center(child: Icon(Icons.videocam, color: Colors.white, size: 50)); 
                                  },
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Species Selector
                      // Species Selector (Conditionally hidden for Existing Pets)
                      // Species Selector (Visible ONLY for New Pet Flow)
                      if (_isAddingNewPet) ...[
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
                      ],
                      
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
                      else if (_isAddingNewPet)
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
                  // [STEP 4: MANDATORY SPECIES SELECTION OR EXISTING PET]
                  // Enable 'New Analysis' if (State is NOT Adding New Pet OR Species Selected) AND Not Analyzing.
                  onPressed: ((!_isAddingNewPet || _selectedSpecies != null) && !_isAnalyzing)
                      ? _processAnalysis 
                      : null,
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

  String _getAnalysisTitle(PetImageType type, AppLocalizations l10n) {
    switch (type) {
      case PetImageType.mouth:
        return l10n.pet_module_dentistry;
      case PetImageType.skin:
        return l10n.pet_module_dermatology;
      case PetImageType.stool:
        return l10n.pet_module_gastro;
      case PetImageType.eyes:
        return l10n.pet_module_ophthalmology;
      case PetImageType.ears:
        return l10n.pet_module_ears;
      case PetImageType.posture:
        return l10n.pet_module_physique;
      case PetImageType.vocal:
        return l10n.pet_module_vocal;
      case PetImageType.behavior:
        return l10n.pet_module_behavior;
      case PetImageType.plantCheck:
        return l10n.pet_module_plant;
      case PetImageType.foodBowl:
        return l10n.pet_module_food_bowl;
      case PetImageType.lab:
        return l10n.pet_module_lab;
      case PetImageType.label:
        return l10n.pet_module_nutrition;
      default:
        return l10n.pet_analysis_title(_existingName ?? l10n.pet_label_pet);
    }
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
