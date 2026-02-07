import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:scannutplus/features/pet/data/models/pet_history_entry.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/data/pet_history_repository.dart';
import 'package:scannutplus/features/pet/l10n/generated/pet_localizations.dart';
import 'package:scannutplus/features/pet/presentation/history/pet_history_detail_screen.dart';

class PetProfileScreen extends StatefulWidget {
  final PetHistoryEntry latestEntry; // Determines the pet context

  const PetProfileScreen({super.key, required this.latestEntry});

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  final PetHistoryRepository _repo = PetHistoryRepository();
  List<PetHistoryEntry> _fullHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    _fullHistory = await _repo.getHistoryByPet(widget.latestEntry.petUuid!, petName: widget.latestEntry.petName);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0E17),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFFD1DC))),
      );
    }

    final l10n = PetLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   _buildStatusIndicator(),
                   const SizedBox(height: 24),
                   _buildTimelineHeader(l10n),
                   const SizedBox(height: 12),
                   _buildTimeline(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,

      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF1F3A5F),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(widget.latestEntry.petName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
            )),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(widget.latestEntry.imagePath),
              fit: BoxFit.cover,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xFF0A0E17)],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.settings),
          onPressed: () {
            // Edit Profile (Phase 2)
          },
        )
      ],
    );
  }

  Widget _buildStatusIndicator() {
     // Logic to determine status from last entry
     final isCritical = widget.latestEntry.category.contains(PetConstants.keyCritical) || 
                        _containsCriticalKeyword(widget.latestEntry);
     
     Color color = isCritical ? const Color(0xFFFF5252) : const Color(0xFF10AC84);
     String text = isCritical ? PetLocalizations.of(context)!.pet_status_attention : PetLocalizations.of(context)!.pet_status_healthy;
     IconData icon = isCritical ? LucideIcons.alertTriangle : LucideIcons.checkCircle;

     return Container(
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: color.withValues(alpha: 0.15),
         borderRadius: BorderRadius.circular(16),
         border: Border.all(color: color.withValues(alpha: 0.5)),
       ),
       child: Row(
         children: [
           Icon(icon, color: color, size: 28),
           const SizedBox(width: 16),
           Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(PetLocalizations.of(context)!.pet_label_status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
               Text(text, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
             ],
           )
         ],
       ),
     );
  }
  
  bool _containsCriticalKeyword(PetHistoryEntry entry) {
      // Simple check in content
      for(var c in entry.analysisCards) {
          if (c.values.any((v) => v.toLowerCase().contains(PetConstants.keyCritical) || v.toLowerCase().contains(PetConstants.keyAttention))) return true;
      }
      return false;
  }

  Widget _buildTimelineHeader(PetLocalizations l10n) {
    return Row(
      children: [
        const Icon(LucideIcons.activity, color: Color(0xFFFFD1DC), size: 20),
        const SizedBox(width: 12),
        Text(
          l10n.pet_tab_history, // Reusing History string as Timeline title for now
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    // 2. ValueListenble for Reactive Updates
    return ValueListenableBuilder(
      valueListenable: Hive.box<PetHistoryEntry>(PetConstants.boxPetHistory).listenable(),
      builder: (context, Box<PetHistoryEntry> box, _) {
          
          final currentPetUuid = widget.latestEntry.petUuid;
          
          // TRACE DE LEITURA (Requested by User)
          debugPrint('--- [PET_TRACE] CARREGANDO TIMELINE ---');
          debugPrint('[LOG] Buscando por UUID: $currentPetUuid');
          debugPrint('[LOG] Box Total: ${box.length}');

          final myHistory = box.values
              .where((item) => item.petUuid == currentPetUuid)
              .toList();

          debugPrint('[LOG] Itens encontrados: ${myHistory.length}');
          
          if (myHistory.isEmpty) {
             return Padding(
               padding: const EdgeInsets.symmetric(vertical: 32),
               child: Center(child: Text(PetLocalizations.of(context)!.pet_history_empty, style: const TextStyle(color: Colors.white30))),
             );
          }
          
          // Sort by timestamp desc
          myHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: myHistory.length,
            itemBuilder: (context, index) {
              final entry = myHistory[index];
              final isLast = index == myHistory.length - 1;
              
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Line Column
                    SizedBox(
                      width: 40,
                      child: Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1F3A5F),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                               child: Container(
                                 width: 6, height: 6,
                                 decoration: const BoxDecoration(color: Color(0xFFFFD1DC), shape: BoxShape.circle),
                               ),
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(width: 2, color: const Color(0xFF1F3A5F)),
                            )
                        ],
                      ),
                    ),
                    
                    // Content Column
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: _buildTimelineCard(entry),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
      },
    );
  }

  Widget _buildTimelineCard(PetHistoryEntry entry) {
      return GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PetHistoryDetailScreen(entry: entry))),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF152033),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    Text(
                      _getCategoryLabel(entry),
                      style: const TextStyle(color: Color(0xFF10AC84), fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    Text(
                      '${entry.timestamp.day}/${entry.timestamp.month} ${entry.timestamp.hour}:${entry.timestamp.minute.toString().padLeft(2,'0')}',
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                 ],
               ),
               const SizedBox(height: 8),
               Text(
                 _getSummary(entry),
                 style: const TextStyle(color: Colors.white70, fontSize: 14),
                 maxLines: 2,
                 overflow: TextOverflow.ellipsis,
               ),
            ],
          ),
        ),
      );
  }

  String _getCategoryLabel(PetHistoryEntry entry) {
     final l10n = PetLocalizations.of(context)!;
     final type = entry.category;
     
     // 1. If Clinical/Generic, try to find a better title in cards
     if (type.contains(PetConstants.typeClinical) && entry.analysisCards.isNotEmpty) {
         // Try to find a specific sub-category card title
         final firstTitle = entry.analysisCards.first[PetConstants.keyTitle];
         if (firstTitle != null && firstTitle.toLowerCase() != PetConstants.keyAnalysis.toLowerCase() && firstTitle.toLowerCase() != PetConstants.keyAnalysis.toLowerCase()) {
             return firstTitle; // Return specific card title (e.g. Skin, Ears)
         }
     }
     
     // 2. Standard Mappings
     if (type.contains(PetConstants.typeClinical)) return l10n.category_clinical;
     if (type.contains(PetConstants.categoryLab)) return l10n.category_lab;
     
     return type; // Fallback
  }

  String _getSummary(PetHistoryEntry entry) {
      if (entry.analysisCards.isEmpty) return '...';
      return entry.analysisCards.first[PetConstants.keyContent] ?? '...';
  }
}
