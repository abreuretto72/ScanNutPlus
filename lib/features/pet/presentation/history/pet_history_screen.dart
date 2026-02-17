import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kDebugMode
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/data/models/pet_history_entry.dart';
import 'package:scannutplus/core/data/objectbox_manager.dart'; // ObjectBox
import 'package:scannutplus/objectbox.g.dart';

import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/features/pet/presentation/pet_analysis_result_view.dart';
import 'package:scannutplus/core/services/universal_result_view.dart'; // Universal Video/Image Viewer

import 'package:scannutplus/features/pet/presentation/extensions/pet_ui_extensions.dart';
import 'package:scannutplus/features/pet/presentation/universal_pdf_preview_screen.dart';

class PetHistoryScreen extends StatefulWidget {
  final String? petUuid; // Filter by Pet
  final String? petName; // For Title
  final String? petBreed; // For New Analysis (Dashboard)
  final String? petImagePath; // For New Analysis (Dashboard)

  const PetHistoryScreen({
    super.key, 
    this.petUuid, 
    this.petName,
    this.petBreed,
    this.petImagePath,
  });

  @override
  State<PetHistoryScreen> createState() => _PetHistoryScreenState();
}

class _PetHistoryScreenState extends State<PetHistoryScreen> {
  late Box<PetHistoryEntry> _historyBox;
  late Stream<List<PetHistoryEntry>> _stream;

  @override
  void initState() {
    super.initState();
    _historyBox = ObjectBoxManager.currentStore.box<PetHistoryEntry>();
    
    // Construct Query
    final queryBuilder = widget.petUuid != null
        ? _historyBox.query(PetHistoryEntry_.petUuid.equals(widget.petUuid!))
        : _historyBox.query();
        
    _stream = queryBuilder
        .order(PetHistoryEntry_.timestamp, flags: Order.descending)
        .watch(triggerImmediately: true)
        .map((query) => query.find());

    if (widget.petUuid != null) {
        if (kDebugMode) debugPrint('${PetConstants.logTagPetData} [HISTORY] Inicializando tela para UUID: ${widget.petUuid}');
    } else {
        if (kDebugMode) debugPrint('${PetConstants.logTagPetData} [HISTORY] Inicializando tela para TODOS (Modo Global)');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
        // Dynamic Title: Análise: [Nome]
        title: Text(
          widget.petName != null 
            ? l10n.pet_analysis_title(widget.petName!) 
            : l10n.pet_history_button, 
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
        ),
        backgroundColor: Colors.transparent, // Restore to dark/transparent
        iconTheme: const IconThemeData(color: Colors.white), // Ensure back arrow is white
        centerTitle: true,
        elevation: 0,
      ),
      // Use StreamBuilder to listen to ObjectBox changes
      body: StreamBuilder<List<PetHistoryEntry>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator(color: Color(0xFF10AC84)));
          }

          if (snapshot.hasError) {
             return Center(child: Text(l10n.pet_error_history_load(snapshot.error.toString()), style: const TextStyle(color: Colors.red)));
          }
          
          var entries = snapshot.data ?? [];

          // ACTIVE PROFILES LOGIC (Global Mode)
          if (widget.petUuid == null && entries.isNotEmpty) {
             final Map<String, PetHistoryEntry> latestMap = {};
             for (var entry in entries) {
                // If petUuid is empty or generic, use Name as key
                final key = (entry.petUuid.isEmpty || entry.petUuid == PetConstants.tagEnvironment) 
                    ? entry.petName 
                    : entry.petUuid;
                
                if (!latestMap.containsKey(key)) {
                   latestMap[key] = entry; // First found is latest due to query order (descending)
                }
             }
             entries = latestMap.values.toList();
          }

          if (entries.isEmpty) {
             return Center(
               child: Text(l10n.pet_history_empty, 
               style: const TextStyle(color: Colors.white54, fontSize: 16)),
             );
          }

          return SingleChildScrollView( 
            child: Column(
              children: entries.map((pet) { 
                return Card(
                  color: const Color(0xFFFFD1DC), // Rosa Pastel (Restored)
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: _buildLeadingIcon(pet),
                    title: Text(
                      pet.getPlantTitle(context) ?? pet.category.toCategoryDisplay(context), // Localized Fallback
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                    ),
                    subtitle: Text(
                       '${pet.petName} • ${pet.timestamp.toString().substring(0, 16)}', // Name second (Normal)
                       style: const TextStyle(color: Colors.black54),
                    ),
                    trailing: IconButton(
                       icon: const Icon(Icons.delete, color: Colors.redAccent),
                       onPressed: () => _confirmDelete(context, pet.id), 
                    ),
                   onTap: () {
                       // Extract Breed from rawJson (Logic restoration from main flow)
                       String breed = '';
                       // Try multiple patterns to catch various LLM output formats
                       final breedPatterns = [
                           RegExp(r'breed_name:\s*([^|\]\n]*)', caseSensitive: false), // Metadata format
                           RegExp(r'\[BREED\]:\s*([^\n]*)', caseSensitive: false),     // Tag format
                           RegExp(r'\*\*Breed\*\*:\s*([^\n]*)', caseSensitive: false), // Bold format
                           RegExp(PetConstants.regexBreedPt, caseSensitive: false),          // Portuguese
                           RegExp(PetConstants.regexBreedEn, caseSensitive: false),          // English fallback
                       ];

                       for (final pattern in breedPatterns) {
                           final match = pattern.firstMatch(pet.rawJson);
                           if (match != null && match.group(1) != null) {
                               breed = match.group(1)!.trim();
                               breed = breed.replaceAll(RegExp(r'[*_\]|]'), '').trim();
                               if (breed.isNotEmpty && breed.length < 50) break; 
                           }
                       }

                       // Fallback: Deep Scan for known breeds in text (Dictionary Match)
                       if (breed.isEmpty) {
                           for (final knownBreed in PetConstants.commonBreedsList) {
                               if (pet.rawJson.contains(knownBreed)) {
                                   breed = knownBreed;
                                   break; // Found a known breed
                               }
                           }
                       }

                       final ext = pet.imagePath.split('.').last.toLowerCase();
                       final isVideo = PetConstants.videoExtensions.contains(ext);

                       if (isVideo) {
                           // Use UniversalResultView for Video Playback
                           Navigator.of(context).push(
                             MaterialPageRoute(
                               builder: (_) => UniversalResultView(
                                 filePath: pet.imagePath,
                                 analysisResult: pet.rawJson,
                                 petDetails: {
                                    PetConstants.fieldName: pet.petName,
                                    PetConstants.fieldBreed: breed,
                                    PetConstants.keyIsFriend: 'false', // History assumes own pets? Or check category
                                    PetConstants.keyTutorName: '',
                                 },
                                 onRetake: () => Navigator.of(context).pop(), 
                                 onShare: () {
                                     Navigator.push(
                                       context,
                                       MaterialPageRoute(
                                         builder: (context) => UniversalPdfPreviewScreen(
                                           filePath: pet.imagePath,
                                           analysisResult: pet.rawJson,
                                           petDetails: {
                                              PetConstants.fieldName: pet.petName,
                                              PetConstants.fieldBreed: breed,
                                              PetConstants.keyPageTitle: l10n.pet_analysis_result_title,
                                           },
                                         ),
                                       ),
                                     );
                                 },
                               ),
                             ),
                           );
                       } else {
                           // Use Standard Result View for Images
                           Navigator.of(context).push(
                             MaterialPageRoute(
                               builder: (_) => PetAnalysisResultView(
                                 imagePath: pet.imagePath,
                                 analysisResult: pet.rawJson,
                                 petDetails: {
                                     PetConstants.fieldName: pet.petName, 
                                     PetConstants.fieldBreed: breed,      
                                 },
                                 onRetake: () => Navigator.of(context).pop(), 
                                 onShare: () {
                                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pet_share_not_implemented)));
                                 },
                               ),
                             ),
                           );
                       }
                    },
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),

      floatingActionButton: widget.petUuid != null ? FloatingActionButton(
        onPressed: () {
          // Navigate to New Analysis Screen (Dashboard)
          Navigator.pushNamed(
            context, 
            '/pet_dashboard', // The screen with the dropdown
            arguments: {
              PetConstants.argUuid: widget.petUuid,
              PetConstants.argName: widget.petName,
              PetConstants.argBreed: widget.petBreed,
              PetConstants.argImagePath: widget.petImagePath,
            },
          ).then((_) => setState(() {})); // Refresh history on return
        },
        backgroundColor: const Color(0xFFFFD1DC), // Pink Pastel (Domain Color)
        child: const Icon(Icons.add, color: Colors.black), // Black Icon for Contrast
      ) : null,
    );
  }


  Future<void> _confirmDelete(BuildContext context, int id) async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.pet_delete_title),
        content: Text(l10n.pet_msg_confirm_delete_entry),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: () {
              _historyBox.remove(id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.pet_entry_deleted)),
              );
            },
            child: Text(l10n.common_delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),

    );
  }

  Widget _buildLeadingIcon(PetHistoryEntry pet) {
      if (pet.imagePath.isEmpty) {
          // Text-only report icons
          if (pet.category == PetConstants.catHealthSummary) {
              return const CircleAvatar(radius: 25, backgroundColor: Color(0xFF10AC84), child: Icon(Icons.medical_services, color: Colors.white)); // Green
          } else if (pet.category == PetConstants.catNutritionPlan) {
              return const CircleAvatar(radius: 25, backgroundColor: Color(0xFFFF9800), child: Icon(Icons.restaurant, color: Colors.white)); // Orange
          }
           // Fallback for other text entries
          return const CircleAvatar(radius: 25, backgroundColor: Colors.black12, child: Icon(Icons.pets, color: Colors.black54));
      }
      
      final imageFile = File(pet.imagePath);
      // Check if video and has thumbnail
      final ext = pet.imagePath.split('.').last.toLowerCase();
      final isVideo = PetConstants.videoExtensions.contains(ext);
      
      File? displayImage = imageFile;
      if (isVideo) {
         final thumbFile = File('${pet.imagePath}.thumb.jpg');
         if (thumbFile.existsSync()) {
            displayImage = thumbFile;
         } else {
            displayImage = null; 
         }
      }

      if (displayImage != null) {
         return CircleAvatar(
          radius: 25,
          backgroundImage: FileImage(displayImage),
          onBackgroundImageError: (_, __) {},
          child: isVideo ? const Icon(Icons.play_circle_fill, color: Colors.white54) : null,
        );
      } else {
        return CircleAvatar(
          radius: 25,
          backgroundColor: Colors.black12,
          child: Icon(isVideo ? Icons.videocam : Icons.broken_image, color: Colors.black54),
        );
      }
  }
}
