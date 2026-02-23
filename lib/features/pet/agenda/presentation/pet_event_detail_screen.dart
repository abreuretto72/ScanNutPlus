import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/features/pet/data/models/pet_event_type.dart';
import 'package:scannutplus/features/pet/agenda/domain/pet_event_type_extension.dart';
import 'package:scannutplus/features/pet/presentation/extensions/pet_ui_extensions.dart';
import 'package:scannutplus/features/pet/agenda/presentation/pet_event_type_label.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/pet/agenda/pet_event.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/presentation/widgets/pet_ai_cards_renderer.dart';

import 'package:just_audio/just_audio.dart';

import 'package:scannutplus/features/pet/presentation/universal_pdf_preview_screen.dart';

class PetEventDetailScreen extends StatelessWidget {
  final PetEvent event;
  final String petName; // For context

  const PetEventDetailScreen({
    super.key,
    required this.event,
    required this.petName,
  });

  // --- HELPER: Source Info ---
  (String, IconData, Color) _getSourceInfo(String? source, AppLocalizations l10n) {
    if (source == null) return (l10n.source_analysis, Icons.analytics, Colors.pink);
    switch (source) {
      case 'walk': return (l10n.source_walk, Icons.directions_walk, Colors.green);
      case 'appointment': return (l10n.source_appointment, Icons.calendar_today, Colors.blue);
      case 'nutrition': return (l10n.source_nutrition, Icons.restaurant, Colors.orange);
      case 'health_summary': return (l10n.source_health, Icons.medical_services, Colors.red);
      case 'profile': return (l10n.source_profile, Icons.badge, Colors.purple);
      case 'journal': return (l10n.source_journal, Icons.edit_note, Colors.grey);
      case 'friend': return (l10n.source_friend, Icons.people, Colors.teal);
      case 'analysis': 
      default: return (l10n.source_analysis, Icons.analytics, Colors.pink);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final type = event.eventTypeIndex.toPetEventType();
    
    // Determine color based on type
    Color typeColor = AppColors.petPrimary;
    if (type == PetEventType.health) {
      typeColor = Colors.redAccent;
    } else if (type == PetEventType.food) {
      typeColor = Colors.orange;
    } else if (event.metrics != null && event.metrics!['is_summary'] == true) {
      typeColor = Colors.amber;
    }
    
    // Determine Title
    final String displayTitle = (event.metrics != null && event.metrics!.containsKey('custom_title'))
                                ? (event.metrics!['custom_title'] as String).toCategoryDisplay(context)
                                : type.label(l10n);

    // Friend Detection via [METADATA] Protocol 2026
    String? tutorName;
    String? myPetName;
    bool isFriend = false;
    String? friendName;
    
    if (event.hasAIAnalysis && event.metrics?[PetConstants.keyAiSummary] != null) {
      final summaryStr = event.metrics![PetConstants.keyAiSummary] as String;
      if (summaryStr.contains('[METADATA]')) {
         final tutorMatch = RegExp(r'tutor_name:\s*(.*?)(?=\n|$)').firstMatch(summaryStr);
         if (tutorMatch != null) {
            tutorName = tutorMatch.group(1)?.trim();
            isFriend = true; // Only guarantee friend if tutor is explicitly in metadata
         }
         
         // AI sometimes outputs the Guest Pet's name as 'my_pet_name' by mistake.
         // If a tutor is present, the 'my_pet_name' from AI metadata is actually the guest.
         final aiPetMatch = RegExp(r'my_pet_name:\s*(.*?)(?=\n|$)').firstMatch(summaryStr);
         if (aiPetMatch != null) {
            String aiExtractedName = aiPetMatch.group(1)?.trim() ?? '';
            if (isFriend && aiExtractedName.isNotEmpty) {
               friendName = aiExtractedName;
            } else {
               myPetName = aiExtractedName;
            }
         }
      }
    }
    
    final String displayNotes = event.notes ?? '';

    // Walk Journal Fallback Regex for Friend Detection
    if (!isFriend && displayNotes.contains('[${l10n.pet_friend_prefix}:')) {
       isFriend = true;
       myPetName = petName; // the petName passed is the main pet
       final regex = RegExp(r'\[' '${RegExp.escape(l10n.pet_friend_prefix)}' r':\s*(.*?)\s*\|\s*' '${RegExp.escape(l10n.pet_label_tutor)}' r':\s*(.*?)\]');
       final match = regex.firstMatch(displayNotes);
       if (match != null) {
          friendName = match.group(1)?.trim();
          tutorName = match.group(2)?.trim();
       }
    }
    
    // Safety Fallback (If friendName was caught by AI Summary but NOT notes, UI still needs it)
    if (isFriend && friendName == null && event.metrics?[PetConstants.keyAiSummary] != null) {
        // AI might have output my_pet_name as the friend if the master prompt was confusing it
        // Let's assume petName is ALWAYS the main pet.
        myPetName = petName; 
    }

    // Determine AppBar Title
    final String screenTitle = type == PetEventType.activity 
            ? (isFriend ? l10n.pet_friend_walk_title_dynamic(friendName ?? l10n.pet_unknown_name) : l10n.pet_walk_title_dynamic(petName)) 
            : l10n.pet_agenda_title_dynamic(petName);

    // Assemble the complete analysis payload (including injected UI cards like Notes) BEFORE building the scaffold
    // so both the UI Renderer and the PDF Generator receive the exact same sequence of data.
    String? finalSummary;
    if (event.metrics?[PetConstants.keyAiSummary] != null) {
       finalSummary = event.metrics![PetConstants.keyAiSummary]!;
       
       if (type == PetEventType.activity && displayNotes.isNotEmpty) {
          String noteContent = displayNotes;
          if (isFriend && friendName != null) {
             noteContent = noteContent.replaceAll(RegExp(r'\[' '${RegExp.escape(l10n.pet_friend_prefix)}' r':.*?\]'), '').trim();
             noteContent += '\n\n**${l10n.pet_label_tutor}:** ${tutorName ?? l10n.value_unknown}';
             noteContent += '\n**${l10n.pet_my_pets_title}:** ${myPetName ?? petName}';
          }

          final noteCard = '''
[CARD_START]
ICON: info
TITLE: ${l10n.pet_event_note}
CONTENT:
$noteContent
[CARD_END]

''';
          finalSummary = noteCard + finalSummary!;
       }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(screenTitle, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
               // Generate PDF PREVIEW using the Standardized Screen
               Navigator.push(context, MaterialPageRoute(builder: (_) => UniversalPdfPreviewScreen(
                 title: screenTitle,
                 filePath: event.mediaPaths?.isNotEmpty == true ? event.mediaPaths!.first : null,
                 // CONTENT: Use the fully assembled AI summary if present, otherwise Notes
                 analysisResult: finalSummary ?? displayNotes,
                 petDetails: {
                   PetConstants.fieldName: isFriend && friendName != null ? friendName : petName,
                   PetConstants.keyPageTitle: screenTitle,
                   // Protocol 2026: Inject true Friend Flags so PDF renders the 3-line layout
                   if (tutorName != null) ...{
                      PetConstants.keyIsFriend: 'true',
                      PetConstants.keyTutorName: tutorName,
                      if (myPetName != null) 'my_pet_name': myPetName,
                   }
                 },
               )));
            },
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: typeColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(type.icon, color: typeColor, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (event.metrics != null && event.metrics!.containsKey('custom_title'))
                              ? (event.metrics!['custom_title'] as String).toCategoryDisplay(context)
                              : type.label(l10n),
                          style: TextStyle(color: typeColor, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat("dd MMMM yyyy • HH:mm").format(event.startDateTime),
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        if ((event.address != null && event.address!.isNotEmpty) || (event.metrics != null && event.metrics![PetConstants.keyAddress] != null))
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    event.address ?? event.metrics![PetConstants.keyAddress],
                                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                        // Source Badge (Detail View)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Builder(
                            builder: (context) {
                               final sourceKey = event.metrics?['source'];
                               final sourceInfo = _getSourceInfo(sourceKey, l10n);
                               return Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                 decoration: BoxDecoration(
                                   color: sourceInfo.$3.withValues(alpha: 0.2),
                                   borderRadius: BorderRadius.circular(8),
                                   border: Border.all(color: sourceInfo.$3.withValues(alpha: 0.5)),
                                 ),
                                 child: Row(
                                   mainAxisSize: MainAxisSize.min,
                                   children: [
                                     Icon(sourceInfo.$2, size: 14, color: sourceInfo.$3),
                                     const SizedBox(width: 6),
                                     Text(
                                       sourceInfo.$1.toUpperCase(),
                                       style: TextStyle(color: sourceInfo.$3, fontSize: 11, fontWeight: FontWeight.bold),
                                     ),
                                   ],
                                 ),
                               );
                            }
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Friend Info Block
            if (isFriend && tutorName != null && tutorName.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.petPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.petPrimary, width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.group, color: AppColors.petPrimary, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${l10n.pet_friend_name_label}: ${friendName ?? l10n.history_guest}",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${l10n.pet_tutor_name_label}: $tutorName",
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Image Section (Visual Evidence)
            if (event.mediaPaths != null && event.mediaPaths!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: FileImage(File(event.mediaPaths!.first)),
                    fit: BoxFit.cover,
                  ),
                border: Border.all(color: Colors.grey.shade800),
                ),
              ),

            // Audio Section (Functional with just_audio)
            if (event.metrics != null && event.metrics![PetConstants.keyAudioPath] != null)
              _AudioPlayerWidget(audioPath: event.metrics![PetConstants.keyAudioPath].toString()),

            // Notes Section (Journal) - HIDE if AI Summary exists to prevent duplication
            if (displayNotes.isNotEmpty && !(event.hasAIAnalysis && event.metrics?[PetConstants.keyAiSummary] != null))
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notes, color: Colors.white70, size: 20),
                        const SizedBox(width: 8),
                        Text(l10n.pet_journal_hint_text, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      displayNotes,
                      style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),

             const SizedBox(height: 24),

            // AI Analysis Placeholder (Simulated for Health)
            // SHOW for Summary events if they have structured data
            if (event.hasAIAnalysis && (event.metrics != null && event.metrics![PetConstants.keyAiSummary] != null))
               Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 8), // Minimal padding instead of full box
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     // Removed "Resumo IA" header and green box
                     // In a real scenario, this would check 'metrics' for the stored analysis text
                    if (finalSummary != null) 
                      Builder(builder: (context) {
                         return PetAiCardsRenderer(
                           analysisResult: finalSummary!,
                         );
                      })
                    else
                      Text(
                        l10n.pet_analysis_data_not_found,
                        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                      ),
                  ],
                ),
              ),

              
            // Extra spacing for scroll comfort
            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
    );
  }
}

/// Widget interno para tocar áudio sem reconstruir a tela toda
class _AudioPlayerWidget extends StatefulWidget {
  final String audioPath;
  const _AudioPlayerWidget({required this.audioPath});

  @override
  State<_AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<_AudioPlayerWidget> {
  late AudioPlayer _player;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      await _player.setFilePath(widget.audioPath);
      _duration = _player.duration ?? Duration.zero;
      
      _player.playerStateStream.listen((state) {
        if (mounted) {
           setState(() {
             _isPlaying = state.playing;
             if (state.processingState == ProcessingState.completed) {
               _isPlaying = false;
               _player.seek(Duration.zero);
               _player.pause();
             }
           });
        }
      });

      _player.positionStream.listen((pos) {
        if (mounted) setState(() => _position = pos);
      });
    } catch (e) {
      debugPrint("Erro ao carregar áudio: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose(); // Memory Leak Prevention
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.graphic_eq, color: Colors.purpleAccent, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.label_sounds, 
                      style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.audioPath.split('/').last,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.purpleAccent, size: 36),
                onPressed: () {
                   if (_isPlaying) {
                     _player.pause();
                   } else {
                     _player.play();
                   }
                },
              ),
            ],
          ),
          if (_duration.inSeconds > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(
                value: _position.inMilliseconds / (_duration.inMilliseconds > 0 ? _duration.inMilliseconds : 1),
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
              ),
            )
        ],
      ),
    );
  }
}
