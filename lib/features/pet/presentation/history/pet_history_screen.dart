import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kDebugMode
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/data/models/pet_history_entry.dart';
import 'package:scannutplus/features/pet/data/models/pet_entity.dart';
import 'package:scannutplus/core/data/objectbox_manager.dart'; // ObjectBox
import 'package:scannutplus/objectbox.g.dart';

import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/core/services/universal_result_view.dart'; // Universal Video/Image Viewer
import 'package:scannutplus/core/services/universal_ocr_result_view.dart'; // Universal OCR Viewer

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
  late Box<PetEntity> _petBox;
  late Stream<List<PetHistoryEntry>> _stream;
  List<String> _friendUuidsCache = [];

  @override
  void initState() {
    super.initState();
    _historyBox = ObjectBoxManager.currentStore.box<PetHistoryEntry>();
    _petBox = ObjectBoxManager.currentStore.box<PetEntity>();
    
    // We now fetch ALL history to allow Splitting into Tabs
    final queryBuilder = _historyBox.query();
        
    _stream = queryBuilder
        .order(PetHistoryEntry_.timestamp, flags: Order.descending)
        .watch(triggerImmediately: true)
        .map((query) => query.find());

    // Cache friend UUIDs for synchronous filtering in the StreamBuilder
    _updateFriendCache();

    if (widget.petUuid != null) {
        if (kDebugMode) debugPrint('${PetConstants.logTagPetData} [HISTORY] Inicializando tela em Modo Filtrado para: ${widget.petUuid}');
    } else {
        if (kDebugMode) debugPrint('${PetConstants.logTagPetData} [HISTORY] Inicializando tela para TODOS (Modo Global)');
    }
  }

  void _updateFriendCache() {
    final friends = _petBox.query(PetEntity_.type.equals(PetConstants.typeFriend)).build().find();
    _friendUuidsCache = friends.map((e) => e.uuid).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E17),
        appBar: AppBar(
          title: Text(
            widget.petName != null 
              ? l10n.pet_analyses_title(widget.petName!).toUpperCase() 
              : l10n.pet_history_button.toUpperCase(), 
            style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 18, letterSpacing: 1.0)
          ),
          backgroundColor: const Color(0xFF121212),
          iconTheme: const IconThemeData(color: Colors.white, size: 28),
          centerTitle: true,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Builder(
              builder: (context) {
                final tabController = DefaultTabController.of(context);
                return AnimatedBuilder(
                  animation: tabController,
                  builder: (context, child) {
                    return TabBar(
                      indicator: BoxDecoration(
                        color: tabController.index == 1 ? const Color(0xFFE0BBE4) : const Color(0xFFFFD1DC), // Lilac for Friends, Pink for Pets 
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      indicatorPadding: const EdgeInsets.symmetric(horizontal: -8, vertical: 6),
                      labelColor: Colors.black,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                      unselectedLabelColor: Colors.white54,
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      dividerColor: Colors.transparent,
                      tabs: [
                         Tab(text: l10n.pet_my_pets_title.toUpperCase()),
                         Tab(text: l10n.pet_friend_list_label.toUpperCase()),
                      ],
                    );
                  }
                );
              }
            ),
          ),
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
            
            var allEntries = snapshot.data ?? [];
            
            // Partition data based on Friend UUID Cache
            List<PetHistoryEntry> myPetsEntries = [];
            List<PetHistoryEntry> friendEntries = [];

            for (var entry in allEntries) {
               if (_friendUuidsCache.contains(entry.petUuid)) {
                   friendEntries.add(entry);
               } else {
                   // If in single-pet mode, only add if uuid matches.
                   if (widget.petUuid != null) {
                       if (entry.petUuid == widget.petUuid) {
                           myPetsEntries.add(entry);
                       }
                   } else {
                       myPetsEntries.add(entry);
                   }
               }
            }

            // ACTIVE PROFILES LOGIC (Global Mode - My Pets)
            if (widget.petUuid == null && myPetsEntries.isNotEmpty) {
               final Map<String, PetHistoryEntry> latestMap = {};
               for (var entry in myPetsEntries) {
                  final key = (entry.petUuid.isEmpty || entry.petUuid == PetConstants.tagEnvironment) 
                      ? entry.petName 
                      : entry.petUuid;
                  
                  if (!latestMap.containsKey(key)) {
                     latestMap[key] = entry; 
                  }
               }
               myPetsEntries = latestMap.values.toList();
            }

            // ACTIVE PROFILES LOGIC (Global Mode - Friends)
            if (widget.petUuid == null && friendEntries.isNotEmpty) {
               final Map<String, PetHistoryEntry> latestMap = {};
               for (var entry in friendEntries) {
                  final key = entry.petUuid; // Friends always have UUIDs
                  if (!latestMap.containsKey(key)) {
                     latestMap[key] = entry; 
                  }
               }
               friendEntries = latestMap.values.toList();
            }

            return TabBarView(
              children: [
                 _buildListTab(myPetsEntries, l10n),
                 _buildListTab(friendEntries, l10n, isFriendTab: true),
              ],
            );
          },
        ),

        floatingActionButton: widget.petUuid != null ? Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
          ),
          child: FloatingActionButton(
            onPressed: () {
              // Navigate to New Analysis Screen (Dashboard)
              final tabController = DefaultTabController.of(context);
              Navigator.pushNamed(
                context, 
                '/pet_dashboard', // The screen with the dropdown
                arguments: {
                  PetConstants.argUuid: widget.petUuid,
                  PetConstants.argName: widget.petName,
                  PetConstants.argBreed: widget.petBreed,
                  PetConstants.argImagePath: widget.petImagePath,
                  'my_pet_name': widget.petName, // Route the owner's name downstream
                  'is_friend_tab': tabController.index == 1, // Pass Active Tab State
                },
              ).then((_) => setState(() {})); // Refresh history on return
            },
            backgroundColor: const Color(0xFFFFD1DC), // Pink Pastel (Domain Color)
            elevation: 0,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.black, size: 32),
          ), 
        ) : null,
      ),
    );
  }

  Widget _buildListTab(List<PetHistoryEntry> entries, AppLocalizations l10n, {bool isFriendTab = false}) {
      if (entries.isEmpty) {
         return Center(
           child: Text(l10n.pet_history_empty, 
           style: const TextStyle(color: Colors.white54, fontSize: 16)),
         );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: entries.length,
        itemBuilder: (context, index) {
            final pet = entries[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isFriendTab ? const Color(0xFFE0BBE4) : const Color(0xFFFFD1DC), // Domain Colors: Lilac for Friends, Pink for Pets
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: const [
                   BoxShadow(color: Colors.black, offset: Offset(5, 5))
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                   debugPrint('\n\n[SCAN_NUT_DEBUG] TAP TRIGGERED! UUID: ${pet.petUuid} | isFriendTab: $isFriendTab');
                   debugPrint('[SCAN_NUT_DEBUG] Raw JSON Snippet: ${pet.rawJson.length > 100 ? pet.rawJson.substring(0, 100) : pet.rawJson}...');

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
                           breed = breed.replaceAll('*', '').replaceAll('_', '').replaceAll('[', '').replaceAll(']', '').replaceAll('|', '').trim();
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

                   // Clean metadata block so UI Regex doesn't break
                   String cleanResult = '';
                   String safeMyPetName = '';
                   String safeTutorName = '';

                   try {
                       cleanResult = pet.rawJson.replaceAll(RegExp(r'\[METADATA\](.*?)\[END_METADATA\]', dotAll: true), '').trim();
                       
                       // Safe extraction of injected identities
                       final petNameMatch = RegExp(r'my_pet_name:\s*([^\|\n]*)', caseSensitive: false).firstMatch(pet.rawJson);
                       safeMyPetName = petNameMatch?.group(1)?.trim() ?? '';

                       final tutorNameMatch = RegExp(r'tutor_name:\s*([^\|\n]*)', caseSensitive: false).firstMatch(pet.rawJson);
                       safeTutorName = tutorNameMatch?.group(1)?.trim() ?? '';
                       
                       // OVERRIDE: Resgata o Tutor Real e fidedigno direto do banco de dados (ignorando problemas de parse do OCR)
                       try {
                           final petBox = ObjectBoxManager.currentStore.box<PetEntity>();
                           debugPrint('[SCAN_NUT_TRACE] Querying PetEntity for UUID: ${pet.petUuid}');
                           final petEntity = petBox.query(PetEntity_.uuid.equals(pet.petUuid)).build().findFirst();
                           
                           if (petEntity == null) {
                               debugPrint('[SCAN_NUT_TRACE] PetEntity NOT FOUND in DB for UUID: ${pet.petUuid}');
                           } else {
                               debugPrint('[SCAN_NUT_TRACE] PetEntity Found. Tutor Name in DB: "${petEntity.tutorName}"');
                               if (petEntity.tutorName != null && petEntity.tutorName!.isNotEmpty) {
                                   safeTutorName = petEntity.tutorName!;
                               }
                           }
                       } catch (e) {
                           debugPrint('[SCAN_NUT_WARN] Could not fetch native PetEntity for tutorname fallback: $e');
                       }
                   } catch (e) {
                       debugPrint('[SCAN_NUT_WARN] RegExp Parsing Error in History tap: $e');
                       cleanResult = pet.rawJson; // Fallback to raw if regex breaks
                   }

                   final ext = pet.imagePath.isNotEmpty ? pet.imagePath.split('.').last.toLowerCase() : '';
                   final isVideo = pet.imagePath.isNotEmpty && PetConstants.videoExtensions.contains(ext);
                   final isOcr = pet.category == PetConstants.typeLabel || pet.category == PetConstants.typeLab || pet.category == PetConstants.typeLabel.toLowerCase() || pet.category == PetConstants.typeLab.toLowerCase();

                   if (isOcr) {
                       // Use UniversalOcrResultView for OCR/Labels
                       Navigator.of(context).push(
                         MaterialPageRoute(
                           builder: (_) => UniversalOcrResultView(
                             imagePath: pet.imagePath,
                             ocrResult: cleanResult,
                             petDetails: {
                                PetConstants.fieldName: pet.petName,
                                PetConstants.fieldBreed: breed,
                                PetConstants.keyIsFriend: isFriendTab ? 'true' : 'false',
                                'my_pet_name': widget.petName != null && widget.petName!.isNotEmpty ? widget.petName! : safeMyPetName,
                                PetConstants.keyTutorName: safeTutorName,
                                PetConstants.keyPageTitle: "${pet.category.toCategoryDisplay(context)}: ${pet.petName}",
                             },
                           ),
                         ),
                       );
                   } else if (isVideo) {
                       // Use UniversalResultView for Video Playback
                       Navigator.of(context).push(
                         MaterialPageRoute(
                           builder: (_) => UniversalResultView(
                             filePath: pet.imagePath,
                             analysisResult: cleanResult,
                             petDetails: {
                                PetConstants.fieldName: pet.petName,
                                PetConstants.fieldBreed: breed,
                                PetConstants.keyIsFriend: isFriendTab ? 'true' : 'false',
                                'my_pet_name': widget.petName != null && widget.petName!.isNotEmpty ? widget.petName! : safeMyPetName,
                                PetConstants.keyTutorName: safeTutorName,
                                PetConstants.keyPageTitle: "${pet.category.toCategoryDisplay(context)}: ${pet.petName}",
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
                                          PetConstants.keyPageTitle: pet.category.toCategoryDisplay(context),
                                          PetConstants.keyTutorName: safeTutorName,
                                          PetConstants.keyIsFriend: isFriendTab ? 'true' : 'false',
                                       },
                                     ),
                                   ),
                                 );
                             },
                           ),
                         ),
                       );
                   } else {
                       // Use UniversalResultView for Images/Text
                       Navigator.of(context).push(
                         MaterialPageRoute(
                           builder: (_) => UniversalResultView(
                             filePath: pet.imagePath,
                             analysisResult: cleanResult,
                             petDetails: {
                                 PetConstants.fieldName: pet.petName, 
                                 PetConstants.fieldBreed: breed,      
                                 PetConstants.keyIsFriend: isFriendTab ? 'true' : 'false',
                                 'my_pet_name': widget.petName != null && widget.petName!.isNotEmpty ? widget.petName! : safeMyPetName,
                                 PetConstants.keyTutorName: safeTutorName,
                                 PetConstants.keyPageTitle: "${pet.category.toCategoryDisplay(context)}: ${pet.petName}",
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
                                          PetConstants.keyPageTitle: pet.category.toCategoryDisplay(context),
                                          PetConstants.keyTutorName: safeTutorName,
                                          PetConstants.keyIsFriend: isFriendTab ? 'true' : 'false',
                                       },
                                     ),
                                   ),
                                 );
                             },
                           ),
                         ),
                       );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        _buildLeadingIcon(pet),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isFriendTab 
                                   ? '${l10n.pet_friend_prefix.toUpperCase()}: ${pet.getPlantTitle(context) ?? (pet.category == PetConstants.typeFriend ? l10n.pet_section_general.toUpperCase() : pet.category.toCategoryDisplay(context).toUpperCase())}'
                                   : (pet.getPlantTitle(context) ?? pet.category.toCategoryDisplay(context).toUpperCase()),
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${pet.petName} • ${pet.timestamp.toString().substring(0, 16)}',
                                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
                          onPressed: () => _confirmDelete(context, pet.id),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
        },
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
              return Container(
                 width: 50, height: 50,
                 decoration: BoxDecoration(color: const Color(0xFF10AC84), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black, width: 2)),
                 child: const Icon(Icons.medical_services, color: Colors.black),
              );
          } else if (pet.category == PetConstants.catNutritionPlan) {
              return Container(
                 width: 50, height: 50,
                 decoration: BoxDecoration(color: const Color(0xFFFF9800), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black, width: 2)),
                 child: const Icon(Icons.restaurant, color: Colors.black),
              );
          }
          // Fallback for other text entries
          return Container(
             width: 50, height: 50,
             decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black, width: 2)),
             child: const Icon(Icons.pets, color: Colors.black),
          );
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
         return Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 2.5),
            image: DecorationImage(
              image: ResizeImage(FileImage(displayImage), width: 150), 
              fit: BoxFit.cover
            ),
          ),
          child: isVideo ? const Center(child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 28)) : null,
        );
      } else {
        return Container(
          width: 50, height: 50,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black, width: 2.5)),
          child: Center(child: Icon(isVideo ? Icons.videocam : Icons.broken_image, color: Colors.black)),
        );
      }
  }
}

