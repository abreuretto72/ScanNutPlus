import 'package:scannutplus/core/theme/app_colors.dart'; // AppColors
import 'package:flutter/material.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/features/pet/data/pet_repository.dart';
import 'package:scannutplus/features/pet/presentation/pet_history_timeline_view.dart';

class PetDashboardView extends StatefulWidget {
  const PetDashboardView({super.key});

  @override
  State<PetDashboardView> createState() => _PetDashboardViewState();
}

class _PetDashboardViewState extends State<PetDashboardView> {
  // Default to null to force selection (UX Requirement)
  PetImageType? _selectedType;

  @override
  Widget build(BuildContext context) {
    // DECLARAÇÃO ANTES DO USO (Pilar de Tipagem Forte)
    final l10n = AppLocalizations.of(context)!;
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String uuid = args?[PetConstants.argUuid] ?? '';
    final String name = args?[PetConstants.argName] ?? l10n.pet_label_pet;
    final String breed = args?[PetConstants.argBreed] ?? '';
    final String imagePath = args?[PetConstants.argImagePath] ?? '';

    return Scaffold(
      backgroundColor: AppColors.petBackgroundDark, // Dark Theme
      appBar: AppBar(title: Text(name), backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(), // Ergonomia SM A256E
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.pet_select_context, 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            
            // --- SELETOR DE ESPECIALIDADES (Dropdown) ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.petPrimary, // Pink Background (Protocol 2026)
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black), // Black Border
              ),
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<PetImageType>(
                    value: _selectedType,
                    hint: Text(
                      l10n.pet_hint_select_type, 
                      style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)
                    ),
                    isExpanded: true,
                    dropdownColor: AppColors.petPrimary, // Pink Menu Background
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.black), // Black Icon
                    style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold), // Black Text
                    items: [
                       _buildDropdownItem(context, PetImageType.mouth, l10n.pet_module_dentistry, Icons.health_and_safety),
                       _buildDropdownItem(context, PetImageType.skin, l10n.pet_module_dermatology, Icons.healing),
                       _buildDropdownItem(context, PetImageType.stool, l10n.pet_module_gastro, Icons.medical_services),
                       _buildDropdownItem(context, PetImageType.lab, l10n.pet_module_lab, Icons.description),
                       _buildDropdownItem(context, PetImageType.label, l10n.pet_module_nutrition, Icons.label),
                       _buildDropdownItem(context, PetImageType.eyes, l10n.pet_module_ophthalmology, Icons.remove_red_eye),
                       _buildDropdownItem(context, PetImageType.posture, l10n.pet_module_physique, Icons.accessibility),
                    ], 
                    onChanged: (PetImageType? newValue) {
                      setState(() => _selectedType = newValue);
                    },
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            // --- BOTÃO DE AÇÃO (Scan / Analyze) ---
            // Visual Identity: Pink Button, Black Text, Black Border
            ElevatedButton.icon(
              onPressed: () {
                // VALIDATION (Pilar 0: Zero erros de fluxo)
                if (_selectedType == null) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                       content: Text(l10n.pet_hint_select_type), // Show hint as error
                       backgroundColor: Colors.red,
                     )
                   );
                   return;
                }

                Navigator.pushNamed(context, '/pet_capture', arguments: {
                  PetConstants.argUuid: uuid,
                  PetConstants.argType: _selectedType, // Guaranteed not null here
                  PetConstants.argName: name,
                  PetConstants.argBreed: breed,
                  PetConstants.argImagePath: imagePath,
                }).then((_) => setState(() {})); // Refresh history on return
              },
              icon: const Icon(Icons.camera_alt, color: AppColors.petText),
              label: Text(l10n.btn_scan_image.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)), // "SCAN IMAGE"
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.petPrimary, // #FFD1DC
                foregroundColor: AppColors.petText,    // Black
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.petText, width: 1.0), // Black Border
                ),
                elevation: 4,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // --- BOTÃO DE PRONTUÁRIO (History Timeline) ---
            OutlinedButton.icon(
               onPressed: () {
                 Navigator.push(
                   context,
                   MaterialPageRoute(
                     builder: (_) => PetHistoryTimelineView(
                       petUuid: uuid,
                       petName: name,
                       petImage: imagePath,
                     ),
                   ),
                 ).then((_) => setState(() {}));
               },
               icon: const Icon(Icons.history, color: Colors.white),
               label: Text(l10n.pet_action_history.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
               style: OutlinedButton.styleFrom(
                 side: const BorderSide(color: Colors.white54, width: 1),
                 padding: const EdgeInsets.symmetric(vertical: 16),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
               ),
            ),

            const SizedBox(height: 24),
            
            // HISTORY SECTION
            _buildHistorySection(context, uuid, l10n, {
              PetConstants.fieldName: name,
              PetConstants.fieldBreed: breed.isNotEmpty ? breed : l10n.pet_breed_unknown,
              PetConstants.fieldImagePath: imagePath,
            }),
          ],
        ),
      ),
    );
  }

  DropdownMenuItem<PetImageType> _buildDropdownItem(BuildContext context, PetImageType type, String label, IconData icon) {
    return DropdownMenuItem<PetImageType>(
      value: type,
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 20), // Black Icon
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.black, fontSize: 16), // Black Text
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context, String uuid, AppLocalizations l10n, Map<String, dynamic> petDetails) {
    final repo = PetRepository(); // Simple instantiation for now, ideally DI
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            l10n.pet_recent_analyses,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: repo.getAnalyses(uuid), // Assuming getAnalyses sorts by date desc? We should check or sort here.
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.petPrimary));
            }
            
            final analyses = snapshot.data ?? [];
            
            if (analyses.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: Text(l10n.pet_no_history, style: const TextStyle(color: Colors.grey))),
              );
            }

            // Sort by date descending (assuming standard ISO format in keyPetTimestamp)
            analyses.sort((a, b) {
              final dateA = DateTime.tryParse(a[PetConstants.keyPetTimestamp] ?? '') ?? DateTime(2000);
              final dateB = DateTime.tryParse(b[PetConstants.keyPetTimestamp] ?? '') ?? DateTime(2000);
              return dateB.compareTo(dateA);
            });

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: analyses.length,
              separatorBuilder: (context, index) => const Divider(color: Colors.white10),
              itemBuilder: (context, index) {
                final analysis = analyses[index];
                final dateStr = analysis[PetConstants.keyPetTimestamp] ?? '';
                final dateDisplay = dateStr.isNotEmpty 
                    ? dateStr.split('T').first.split('-').reversed.join('/') // Simple formatter: YYYY-MM-DD -> DD/MM/YYYY
                    : l10n.val_unknown_date;
                final type = analysis[PetConstants.fieldAnalysisType] ?? PetConstants.valGeneral;

                // VISUAL FILTER: Show 'newProfile' as 'Initial Assessment'
                // if (type == PetConstants.typeNewProfile) return const SizedBox.shrink(); // REMOVED FILTER

                String displayType = type;
                if (type == PetConstants.typeNewProfile) {
                   displayType = l10n.pet_initial_assessment;
                } else if (type == PetConstants.typeClinical) {
                   displayType = l10n.category_clinical;
                }
                // Add other mappings if needed, or use capitalized type

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                     padding: const EdgeInsets.all(8),
                     // Icon Background: Pink
                     decoration: BoxDecoration(
                        color: AppColors.petPrimary, // Pastel Pink 
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 1) // Black Border
                     ),
                     // Icon Color: Black
                     child: const Icon(Icons.pets, color: Colors.black, size: 20), // Paw Icon for History
                  ), 
                  title: Text(
                     displayType, 
                     style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white) // White Text for contrast on Dark Background
                  ), 
                  subtitle: Text(dateDisplay, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
                  onTap: () {
                    // Navigate to Result View with this data
                    Navigator.pushNamed(
                      context, 
                      '/pet_analysis_result', 
                      arguments: <String, dynamic>{
                         PetConstants.argUuid: uuid,
                         PetConstants.argType: type,
                         PetConstants.argImagePath: (analysis[PetConstants.fieldImagePath] ?? petDetails[PetConstants.fieldImagePath]).toString(),
                         PetConstants.argResult: (analysis[PetConstants.keyPetAnalysisResult] ?? '').toString(),
                         PetConstants.argName: (petDetails[PetConstants.fieldName] ?? '').toString(),
                         PetConstants.argBreed: (analysis[PetConstants.fieldBreed] ?? petDetails[PetConstants.fieldBreed] ?? '').toString(),
                         
                         // Fix: Ensure this is explicitly a Map<String, String>
                         PetConstants.argPetDetails: <String, String>{
                           PetConstants.fieldName: (petDetails[PetConstants.fieldName] ?? '').toString(),
                           PetConstants.fieldBreed: (analysis[PetConstants.fieldBreed] ?? petDetails[PetConstants.fieldBreed] ?? '').toString(),
                           PetConstants.fieldImagePath: (analysis[PetConstants.fieldImagePath] ?? petDetails[PetConstants.fieldImagePath] ?? '').toString(),
                         },
                      }
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
