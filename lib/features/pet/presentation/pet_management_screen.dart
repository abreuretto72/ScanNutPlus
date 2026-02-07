import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:scannutplus/features/pet/data/models/pet_profile.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/data/models/pet_history_entry.dart';
import 'package:scannutplus/features/pet/l10n/generated/pet_localizations.dart';
import 'package:scannutplus/features/pet/presentation/pet_capture_view.dart';
import 'package:scannutplus/features/pet/presentation/history/pet_profile_screen.dart';
import 'package:scannutplus/features/pet/presentation/extensions/pet_ui_extensions.dart';

class PetManagementScreen extends StatefulWidget {
  final PetProfile pet;

  const PetManagementScreen({super.key, required this.pet});

  @override
  State<PetManagementScreen> createState() => _PetManagementScreenState();
}

class _PetManagementScreenState extends State<PetManagementScreen> {

  @override
  void initState() {
    super.initState();
    _ensureBoxesOpen();
  }

  Future<void> _ensureBoxesOpen() async {
     if (!Hive.isBoxOpen(PetConstants.boxPetAnalyses)) {
        await Hive.openBox<PetHistoryEntry>(PetConstants.boxPetAnalyses);
     }
     // Force rebuild to show data if it was waiting
     if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
       debugPrint('[PET_TRACE] Opening Management for UUID: ${widget.pet.uuid}');
    }

    final l10n = PetLocalizations.of(context)!;
    
    // Safety Check for Box (Loading State)
    if (!Hive.isBoxOpen(PetConstants.boxPetAnalyses)) {
       return const Scaffold(
          backgroundColor: Color(0xFF0A0E17),
          body: Center(child: CircularProgressIndicator(color: Color(0xFF10AC84))),
       );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
        title: Text(widget.pet.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1F3A5F),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<PetHistoryEntry>(PetConstants.boxPetAnalyses).listenable(),
        builder: (context, Box<PetHistoryEntry> box, _) {
          // Filter history for THIS pet UUID
          final petHistory = box.values
              .where((entry) => entry.petUuid == widget.pet.uuid)
              .toList();

          // Sort by timestamp descending (newest first)
          petHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          final latestAnalysis = petHistory.isNotEmpty ? petHistory.first : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 160), // Space for FAB/Dock if needed
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPetHeader(context, latestAnalysis),
                
                // --- ECOSYSTEM WIDGETS ---
                // Only show warning if status is critical/attention
                if (latestAnalysis != null && 
                   (latestAnalysis.category.toLowerCase().contains(PetConstants.keyCritical) || 
                    latestAnalysis.category.toLowerCase().contains(PetConstants.keyAttention)))
                   _buildEcosystemWarning(context),
                   
                _buildActionMenu(context),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(color: Color(0xFF22304A), thickness: 1),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.pet_tab_history, 
                    style: const TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                ),

                if (petHistory.isEmpty)
                   _buildEmptyHistory(context, l10n)
                else
                   ...petHistory.map((entry) => _buildHistoryItem(context, entry)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPetHeader(BuildContext context, PetHistoryEntry? latest) {
    Color statusColor = const Color(0xFF10AC84); // Green
    String statusText = PetLocalizations.of(context)!.pet_status_healthy;

    if (latest != null) {
       if (latest.category.toLowerCase().contains(PetConstants.keyCritical)) {
          statusColor = const Color(0xFFFF5252);
          statusText = PetLocalizations.of(context)!.pet_status_critical;
       } else if (latest.category.toLowerCase().contains(PetConstants.keyAttention)) {
          statusColor = const Color(0xFFFFD700);
          statusText = PetLocalizations.of(context)!.pet_status_attention;
       }
    }

    return Container(
      height: 220,
      decoration: BoxDecoration(
        image: DecorationImage(
           image: FileImage(File(widget.pet.profileImagePath)),
           fit: BoxFit.cover,
        ),
      ),
      child: Container(
         decoration: BoxDecoration(
           gradient: LinearGradient(
             begin: Alignment.bottomCenter,
             end: Alignment.topCenter,
             colors: [
                const Color(0xFF0A0E17), 
                const Color(0xFF0A0E17).withValues(alpha: 0.0)
             ],
           ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
                children: [
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                     decoration: BoxDecoration(
                       color: statusColor,
                       borderRadius: BorderRadius.circular(20),
                     ),
                     child: Text(
                       statusText.toUpperCase(),
                       style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                     ),
                   ),
                ],
             ),
             const SizedBox(height: 8),
             Text(
               widget.pet.name,
               style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
             ),
             Text(
               '${widget.pet.breed} • ${widget.pet.age}',
               style: const TextStyle(color: Colors.white70, fontSize: 16),
             ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEcosystemWarning(BuildContext context) {
     return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
           color: const Color(0xFF1F3A5F),
           borderRadius: BorderRadius.circular(16),
           border: Border.all(color: const Color(0xFFFF9800)),
        ),
        child: Column(
           children: [
              Row(
                 children: [
                    const Icon(LucideIcons.mapPin, color: Color(0xFFFF9800)),
                    const SizedBox(width: 12),
                    Expanded(
                       child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(PetLocalizations.of(context)!.pet_waze_title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text(PetLocalizations.of(context)!.pet_waze_desc, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(LucideIcons.chevronRight, color: Colors.white24),
                 ],
              ),
              const Divider(color: Colors.white12, height: 24),
              Row(
                 children: [
                    const Icon(LucideIcons.badgePercent, color: Color(0xFF10AC84)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(PetLocalizations.of(context)!.pet_partners_title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text(PetLocalizations.of(context)!.pet_partners_desc, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(LucideIcons.chevronRight, color: Colors.white24),
                 ],
              ),
           ],
        ),
     );
  }

  Widget _buildActionMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3, // Ergonomic 3 columns
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
        children: [
           _buildMenuButton(context, LucideIcons.stethoscope, PetLocalizations.of(context)!.pet_cat_health, PetImageType.general, const Color(0xFF6C5CE7)),
           _buildMenuButton(context, LucideIcons.eye, PetLocalizations.of(context)!.pet_cat_eyes, PetImageType.eyes, const Color(0xFF0984E3)),
           _buildMenuButton(context, LucideIcons.smile, PetLocalizations.of(context)!.pet_cat_mouth, PetImageType.mouth, const Color(0xFFE17055)),
           _buildMenuButton(context, LucideIcons.search, PetLocalizations.of(context)!.pet_cat_skin, PetImageType.skin, const Color(0xFFFD79A8)),
           _buildMenuButton(context, LucideIcons.activity, PetLocalizations.of(context)!.pet_cat_posture, PetImageType.posture, const Color(0xFF00B894)),
           _buildMenuButton(context, LucideIcons.fileText, PetLocalizations.of(context)!.pet_cat_labs, PetImageType.lab, const Color(0xFF636E72)), 
           _buildMenuButton(context, LucideIcons.alertCircle, PetLocalizations.of(context)!.pet_cat_stool, PetImageType.stool, const Color(0xFFA29BFE)),
           _buildMenuButton(context, LucideIcons.shieldAlert, PetLocalizations.of(context)!.pet_cat_safety, PetImageType.safety, const Color(0xFFFF7675)),
           _buildMenuButton(context, LucideIcons.tag, PetLocalizations.of(context)!.pet_cat_label, PetImageType.label, const Color(0xFFFDCB6E)),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, IconData icon, String label, PetImageType type, Color color) {
    return InkWell(
      onTap: () {
         Navigator.push(
           context,
           MaterialPageRoute(
             builder: (_) => PetCaptureView(
               initialMode: type,
               existingPetUuid: widget.pet.uuid, // ✅ CORRECTLY PASSING UUID
               existingPetName: widget.pet.name, // ✅ CORRECTLY PASSING NAME
             ),
           ),
         );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF152033),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF22304A)),
          boxShadow: [
             BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))
          ]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Container(
               padding: const EdgeInsets.all(10),
               decoration: BoxDecoration(
                 color: color.withValues(alpha: 0.2),
                 shape: BoxShape.circle,
               ),
               child: Icon(icon, color: color, size: 24),
             ),
             const SizedBox(height: 8),
             Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }


  Widget _buildHistoryItem(BuildContext context, PetHistoryEntry entry) {
    return ListTile(
       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
       leading: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(8),
             // Fallback color if image fails
             color: const Color(0xFF22304A),
             image: File(entry.imagePath).existsSync() 
                ? DecorationImage(image: FileImage(File(entry.imagePath)), fit: BoxFit.cover)
                : null,
          ),
          child: !File(entry.imagePath).existsSync() ? const Icon(Icons.broken_image, color: Colors.white24) : null,
       ),
        title: Text(entry.category.toCategoryDisplay(context), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
       subtitle: Text('${_formatDate(entry.timestamp)}  •  RAG Idx: ${entry.severityIndex}', style: const TextStyle(color: Colors.white54)),
       trailing: const Icon(LucideIcons.chevronRight, color: Colors.white24),
       onTap: () => _openDetail(context, entry),
    );
  }

  Widget _buildEmptyHistory(BuildContext context, PetLocalizations l10n) {
     return Padding(
       padding: const EdgeInsets.all(32.0),
       child: Column(
          children: [
             const Icon(LucideIcons.clipboardList, size: 48, color: Colors.white12),
             const SizedBox(height: 16),
             Text(l10n.pet_history_empty, style: const TextStyle(color: Colors.white38)),
          ],
       ),
     );
  }

  void _openDetail(BuildContext context, PetHistoryEntry entry) {
     Navigator.push(
       context,
       MaterialPageRoute(
         builder: (_) => PetProfileScreen(latestEntry: entry),
       ),
     );
  }
  
  String _formatDate(DateTime dt) {
     return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
  }
}
