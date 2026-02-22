import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/data/pet_repository.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
// import 'package:scannutplus/features/pet/presentation/pet_generic_result_view.dart'; // Deprecated Protocol 2026

class PetHistoryTimelineView extends StatefulWidget {
  final String petUuid;
  final String petName;
  final String? petImage; // Main Profile Image for Header

  const PetHistoryTimelineView({
    super.key,
    required this.petUuid,
    required this.petName,
    this.petImage,
  });

  @override
  State<PetHistoryTimelineView> createState() => _PetHistoryTimelineViewState();
}

class _PetHistoryTimelineViewState extends State<PetHistoryTimelineView> {
  final PetRepository _repository = PetRepository();
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  void _refreshHistory() {
    setState(() {
      _historyFuture = _repository.getPetHistory(widget.petUuid);
    });
  }

  String _getModuleTitle(BuildContext context, String type) {
    // Map internal type string to L10n
    final l10n = AppLocalizations.of(context)!;
    switch (type.toLowerCase()) {
      case PetConstants.valMouth: return l10n.pet_module_dentistry;
      case PetConstants.valSkin:
      case PetConstants.valWound: return l10n.pet_module_dermatology;
      case PetConstants.valStool: return l10n.pet_module_gastro;
      case PetConstants.valLab: return l10n.pet_module_lab;
      case PetConstants.valLabel: return l10n.pet_module_nutrition;
      case PetConstants.valEyes: return l10n.pet_module_ophthalmology;
      case PetConstants.valPosture:
      case PetConstants.valProfile: return l10n.pet_module_physique;
      case PetConstants.typeNewProfile: return l10n.pet_initial_assessment; // Mapped Title
      default: return l10n.pet_section_general; // Fallback "Análise Geral"
    }
  }

  IconData _getModuleIcon(String type) {
    switch (type.toLowerCase()) {
      case PetConstants.valMouth: return Icons.health_and_safety;
      case PetConstants.valSkin:
      case PetConstants.valWound: return Icons.healing;
      case PetConstants.valStool: return Icons.medical_services;
      case PetConstants.valLab: return Icons.description;
      case PetConstants.valLabel: return Icons.label;
      case PetConstants.valEyes: return Icons.remove_red_eye;
      case PetConstants.valPosture:
      case PetConstants.valProfile: return Icons.accessibility;
      case PetConstants.typeNewProfile: return Icons.pets; // Paw Icon for Birth Certificate
      default: return Icons.pets;
    }
  }

  void _openResult(Map<String, dynamic> entry) {
    final type = entry[PetConstants.fieldAnalysisType] as String? ?? PetConstants.valGeneral;
    final result = entry[PetConstants.keyPetAnalysisResult] as String? ?? '';
    final imagePath = entry[PetConstants.fieldImagePath] as String? ?? '';
    
    // Safety check for image
    if (imagePath.isEmpty || !File(imagePath).existsSync()) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(AppLocalizations.of(context)!.pet_error_image_not_found)),
       );
       return;
    }

    // Parse Friend metadata seamlessly from Analysis Result block
    String? tutorName;
    String? myPetName;
    bool isFriend = false;
    
    if (result.contains('[METADATA]')) {
      isFriend = true;
      final tutorMatch = RegExp(r'tutor_name:\s*(.*?)(?=\n|$)').firstMatch(result);
      if (tutorMatch != null) tutorName = tutorMatch.group(1)?.trim();
      
      final myPetMatch = RegExp(r'my_pet_name:\s*(.*?)(?=\n|$)').firstMatch(result);
      if (myPetMatch != null) myPetName = myPetMatch.group(1)?.trim();
    }

    // Unified Routing (Protocol 2026 - Golden Standard)
    Navigator.of(context).pushNamed(
      '/pet_analysis_result',
      arguments: <String, dynamic>{
         PetConstants.argUuid: widget.petUuid,
         PetConstants.argType: type,
         PetConstants.argImagePath: imagePath,
         PetConstants.argResult: result,
         PetConstants.argName: widget.petName,
         PetConstants.argBreed: (entry[PetConstants.fieldBreed] ?? '').toString(),
         
         // Fix: Ensure explicitly Map<String, String> (Restoring Friend Flags for view & PDF)
         PetConstants.argPetDetails: <String, String>{
            PetConstants.fieldName: widget.petName,
            PetConstants.fieldBreed: (entry[PetConstants.fieldBreed] ?? '').toString(),
            if (isFriend) 'is_friend': 'true',
            if (tutorName != null && tutorName.isNotEmpty) 'tutor_name': tutorName,
            if (myPetName != null && myPetName.isNotEmpty) 'my_pet_name': myPetName,
         }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.petBackgroundDark,
      appBar: AppBar(
        title: Text('${l10n.pet_history_title}: ${widget.petName}'),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.petPrimary));
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.history, size: 64, color: Colors.white24),
                   const SizedBox(height: 16),
                   Text(l10n.pet_no_history, style: const TextStyle(color: Colors.white54)),
                ],
              ),
            );
          }
          
          final history = snapshot.data!;
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
               final entry = history[index];
               final timestampStr = entry[PetConstants.fieldTimestamp] as String? ?? '';
               
               // Manual Formatting (YYYY-MM-DDTHH:MM...)
               String dateStr = l10n.val_unknown_date;
               if (timestampStr.isNotEmpty) {
                  try {
                    final parts = timestampStr.split('T');
                    final datePart = parts[0].split('-'); // [YYYY, MM, DD]
                    final timePart = parts.length > 1 ? parts[1].split(':') : ['00', '00'];
                    
                    if (datePart.length == 3) {
                       dateStr = '${datePart[2]}/${datePart[1]}/${datePart[0]} ${timePart[0]}:${timePart[1]}';
                    }
                  } catch (e) {
                    dateStr = timestampStr;
                  }
               }

               final type = entry[PetConstants.fieldAnalysisType] as String? ?? PetConstants.valGeneral;
               
               return GestureDetector(
                 onTap: () => _openResult(entry),
                 child: Container(
                   margin: const EdgeInsets.only(bottom: 12),
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                     color: AppColors.petPrimary, // Pink Background
                     borderRadius: BorderRadius.circular(12),
                     border: Border.all(color: Colors.black, width: 2), // Black Border (Pilar 0)
                     boxShadow: const [
                        BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 4),
                     ],
                   ),
                   child: Row(
                     children: [
                       // Icon Badge
                       Container(
                         padding: const EdgeInsets.all(10),
                         decoration: BoxDecoration(
                           color: Colors.black,
                           shape: BoxShape.circle,
                           border: Border.all(color: Colors.white, width: 1),
                         ),
                         child: Icon(_getModuleIcon(type), color: AppColors.petPrimary, size: 24),
                       ),
                       const SizedBox(width: 16),
                       
                       // Content
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               _getModuleTitle(context, type),
                               style: const TextStyle(
                                 color: Colors.black,
                                 fontWeight: FontWeight.bold,
                                 fontSize: 16,
                               ),
                             ),
                             const SizedBox(height: 4),
                             Text(
                               dateStr,
                               style: const TextStyle(
                                 color: Colors.black87,
                                 fontSize: 12,
                                 fontStyle: FontStyle.italic,
                               ),
                             ),
                           ],
                         ),
                       ),
                       
                       // Arrow
                       const Icon(Icons.chevron_right, color: Colors.black),
                     ],
                   ),
                 ),
               );
            },
          );
        },
      ),
    );
  }
}
