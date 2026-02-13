import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/features/pet/data/models/pet_event_type.dart';
import 'package:scannutplus/features/pet/agenda/domain/pet_event_type_extension.dart';
import 'package:scannutplus/features/pet/agenda/presentation/pet_event_type_label.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/pet/agenda/pet_event.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/presentation/widgets/pet_ai_cards_renderer.dart';

import 'package:just_audio/just_audio.dart';

class PetEventDetailScreen extends StatelessWidget {
  final PetEvent event;
  final String petName; // For context

  const PetEventDetailScreen({
    super.key,
    required this.event,
    required this.petName,
  });

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
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.pet_agenda_title_dynamic(petName), style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
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
                          type.label(l10n),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

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

            // Notes Section (Journal)
            if (event.notes != null && event.notes!.isNotEmpty)
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
                      event.notes!,
                      style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),

             const SizedBox(height: 24),

            // AI Analysis Placeholder (Simulated for Health)
            if (event.hasAIAnalysis)
               Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2F2B), // Very deep green/teal
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF10AC84)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Color(0xFF10AC84), size: 20),
                        SizedBox(width: 8),
                        Text(l10n.pet_label_ai_summary, style: const TextStyle(color: Color(0xFF10AC84), fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                     // In a real scenario, this would check 'metrics' for the stored analysis text
                    if (event.metrics?[PetConstants.keyAiSummary] != null)
                      PetAiCardsRenderer(
                        analysisResult: event.metrics![PetConstants.keyAiSummary]!,
                      )
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
