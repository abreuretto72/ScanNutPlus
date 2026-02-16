import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/features/pet/l10n/generated/pet_localizations.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:video_player/video_player.dart'; // Necessário para o preview de vídeo
import 'package:path/path.dart' as p;

class UniversalResultView extends StatefulWidget {
  final String filePath; // Pode ser imagem ou vídeo
  final String analysisResult;
  final Duration? executionTime;
  final VoidCallback onRetake;
  final VoidCallback onShare;
  final Map<String, String>? petDetails;

  const UniversalResultView({
    super.key,
    required this.filePath,
    required this.analysisResult,
    this.executionTime,
    required this.onRetake,
    required this.onShare,
    this.petDetails,
  });

  @override
  State<UniversalResultView> createState() => _UniversalResultViewState();
}

class _UniversalResultViewState extends State<UniversalResultView> {
  VideoPlayerController? _videoController;
  bool _isVideo = false;
  bool _isAudio = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[DENTIST_FLOW_TRACE] UniversalResultView loaded. Result length: ${widget.analysisResult.length}');
    _checkMediaType();
  }

  void _checkMediaType() {
    final extension = p.extension(widget.filePath).toLowerCase().replaceAll('.', '');
    _isVideo = PetConstants.videoExtensions.contains(extension);
    
    debugPrint('[UNIVERSAL_RESULT] Checking Media Type. Path: ${widget.filePath} | Ext: $extension | IsVideo: $_isVideo');

    if (_isVideo) {
      _videoController = VideoPlayerController.file(File(widget.filePath))
        ..initialize().then((_) {
            debugPrint('[UNIVERSAL_RESULT] Video Controller Initialized. AspectRatio: ${_videoController?.value.aspectRatio}');
            setState(() {});
        }).catchError((error) {
            debugPrint('[UNIVERSAL_RESULT] Video Initialization Error: $error');
        });
        
      _videoController?.setLooping(true);
      _videoController?.play();
    } else {
       _isAudio = PetConstants.audioExtensions.contains(extension);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appL10n = AppLocalizations.of(context)!;
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Lógica de Identidade (Nome e Raça)
    String? nameCandidate = widget.petDetails?[PetConstants.fieldName];
    if ((nameCandidate == null || nameCandidate.isEmpty) && args != null) {
      nameCandidate = args[PetConstants.argName]?.toString();
    }
    final String displayPetName = (nameCandidate != null && nameCandidate.isNotEmpty) 
        ? nameCandidate 
        : appL10n.pet_unknown;

    final String displayBreed = widget.petDetails?[PetConstants.fieldBreed] ?? 
                               args?[PetConstants.argBreed]?.toString() ?? 
                               appL10n.pet_breed_unknown;

    // FRIEND TITLE LOGIC
    String displayTitle = appL10n.pet_analyzing_x(displayPetName);
    final isFriend = widget.petDetails?[PetConstants.keyIsFriend] == 'true';
    final tutorName = widget.petDetails?[PetConstants.keyTutorName] ?? '';

    if (isFriend) {
       displayTitle = appL10n.pet_result_title_friend_pet(displayPetName, tutorName);
    } else {
       // Only use My Pet format if explicitly standard, else generic
       displayTitle = appL10n.pet_result_title_my_pet(displayPetName);
    }

    return Scaffold(
      backgroundColor: AppColors.petBackgroundDark,
      appBar: AppBar(
        title: Text(displayTitle, 
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Imagem ou Vídeo
            _buildMediaHeader(),
            
            // Badge de Identidade (Rosa Pastel + Texto Preto)
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 24),
              child: _buildIdentityBadge(context, displayPetName, displayBreed),
            ),
            
            // Cards Dinâmicos do Laudo
            ..._parseDynamicCards(widget.analysisResult).map((block) => _buildDynamicCard(block)),

            // Seção de Fontes Científicas
            _buildSourcesCard(context, _extractSources(widget.analysisResult)),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaHeader() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.black, // Better background for video
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.petPrimary, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_isVideo && _videoController != null && _videoController!.value.isInitialized) ...[
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
              // Video Controls Overlay
              _buildVideoControls(),
            ]
            else if (_isAudio)
              Container(
                color: Colors.black12,
                alignment: Alignment.center,
                child: const Icon(Icons.graphic_eq, size: 80, color: AppColors.petPrimary), // Audio Icon (Not Mic)
              )
            else if (!_isVideo)
              Image.file(File(widget.filePath), fit: BoxFit.cover, width: double.infinity, height: double.infinity) // Ensure filled
            else
              const Center(child: CircularProgressIndicator(color: AppColors.petPrimary)),
            
            Positioned(
              top: 12,
              right: 12,
              child: _buildStatusHeader(widget.analysisResult, AppLocalizations.of(context)!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoControls() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (_videoController!.value.isPlaying) {
              _videoController!.pause();
            } else {
              _videoController!.play();
            }
          });
        },
        child: Container(
          color: Colors.black.withValues(alpha: 0.1), // Touch target
          child: Center(
            child: AnimatedOpacity(
              opacity: _videoController!.value.isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Métodos de Parsing e UI herdados da PetAnalysisResultView ---

  List<_AnalysisBlock> _parseDynamicCards(String rawResponse) {
    List<_AnalysisBlock> blocks = [];
    debugPrint('[SCAN_NUT_TRACE] Start Parsing Dynamic Cards. Raw Length: ${rawResponse.length}');
    
    // Regex for grabbing the block content between tags
    final blockRegex = RegExp(PetConstants.regexCardStart, dotAll: true);
    final matches = blockRegex.allMatches(rawResponse);
    debugPrint('[SCAN_NUT_TRACE] Dynamic Cards Matches Found: ${matches.length}');

    for (var match in matches) {
      final body = match.group(1) ?? '';
      
      // Polyglot Regex from PetConstants
      final title = RegExp(PetConstants.regexTitle, caseSensitive: false).firstMatch(body)?.group(1) ?? 'Análise';
      // Robust Content Extraction
      // Use dotAll: true to capture multiline content
      final content = RegExp(PetConstants.regexContent, dotAll: true, caseSensitive: false).firstMatch(body)?.group(1) ?? '';
      
      // [SANITIZER] Remove structural tags (English + Portuguese variants)
      final cleanContent = content.replaceAll(RegExp(r'(?:ICON|ÍCONE|ICONE|Ícone|Icone):|(?:CONTENT|CONTEÚDO|CONTEUDO|Conteúdo|Conteudo):', caseSensitive: false), '').trim();

      final iconName = RegExp(PetConstants.regexIcon, caseSensitive: false).firstMatch(body)?.group(1) ?? 'info';


      if (cleanContent.isNotEmpty) {
          debugPrint('[SCAN_NUT_TRACE] Card Parsed -> Title: $title | Icon: $iconName | Content: ${cleanContent.substring(0, cleanContent.length > 20 ? 20 : cleanContent.length)}...');
          blocks.add(_AnalysisBlock(title: title.trim(), content: cleanContent, icon: _getIconData(iconName.trim())));
      } else {
         // Fallback: If regex failed but tag exists, try to clean blindly
         final doubleFallback = body.replaceAll(RegExp(r'(?:TITLE|TITULO|TÍTULO|Título|Titulo):|(?:ICON|ÍCONE|ICONE|Ícone|Icone):'), '').trim();
         if (doubleFallback.length > 5) {
             debugPrint('[SCAN_NUT_TRACE] Card Parsed (Fallback) -> Title: $title | Content: ${doubleFallback.substring(0, doubleFallback.length > 20 ? 20 : doubleFallback.length)}...');
             blocks.add(_AnalysisBlock(title: title.trim(), content: doubleFallback, icon: _getIconData(iconName.trim())));
         } else {
             debugPrint('[SCAN_NUT_WARN] Card Skipped (Empty Content). Body dump: $body');
         }
      }
    }
    return blocks;
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'favorite': case '❤️': return Icons.favorite;
      case 'warning': case '⚠️': return Icons.warning;
      case 'info': case 'ℹ️': return Icons.info;
      case 'check_circle': case 'check': case '✅': return Icons.check_circle;
      case 'local_florist': case '🌻': case 'plant': return Icons.local_florist;
      case 'eco': case '🍃': return Icons.eco;
      case 'health_and_safety': case 'safe': case 'shield': return Icons.health_and_safety;
      default: return Icons.pets;
    }
  }

  Widget _buildDynamicCard(_AnalysisBlock block) {
    final isAlert = block.icon == Icons.warning;
    final cardColor = isAlert ? const Color(0xFFFF5252) : AppColors.petPrimary;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.petBackgroundDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardColor.withAlpha(128), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(block.icon, color: cardColor, size: 22),
              const SizedBox(width: 12),
              Expanded(child: Text(block.title, style: TextStyle(color: cardColor, fontWeight: FontWeight.bold, fontSize: 16))),
            ],
          ),
          const SizedBox(height: 12),
          Text(block.content, style: const TextStyle(color: Color(0xFFEAF0FF), fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildIdentityBadge(BuildContext context, String name, String breed) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.petPrimary, 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.petText, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.pets, color: AppColors.petText, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: AppColors.petText, fontWeight: FontWeight.bold, fontSize: 16)),
                if (breed.isNotEmpty)
                  Text(breed, style: const TextStyle(color: AppColors.petText, fontSize: 13, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Lógica de Fontes e Status (Simplificada para o exemplo) ---
  List<String> _extractSources(String response) {
    if (!response.contains('[SOURCES]')) return [];
    return response.split('[SOURCES]').last.trim().split('\n').where((s) => s.length > 5).toList();
  }

  Widget _buildSourcesCard(BuildContext context, List<String> sources) {
    if (sources.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Fontes Científicas", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...sources.map((s) => Text("• $s", style: const TextStyle(color: Colors.white70, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(String text, AppLocalizations appL10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.green.withAlpha(200), borderRadius: BorderRadius.circular(20)),
      child: Text(appL10n.pet_status_healthy_simple, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _AnalysisBlock {
  final String title;
  final String content;
  final IconData icon;
  _AnalysisBlock({required this.title, required this.content, required this.icon});
}