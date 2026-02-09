import 'package:scannutplus/core/theme/app_colors.dart'; // AppColors
import 'package:flutter/material.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/l10n/app_localizations.dart';

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


}
