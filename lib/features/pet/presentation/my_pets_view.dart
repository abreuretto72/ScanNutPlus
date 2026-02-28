import 'package:scannutplus/core/theme/app_colors.dart'; // Import AppColors
import 'package:flutter/material.dart';
// import 'package:lucide_icons/lucide_icons.dart'; // Removed

import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:flutter/foundation.dart'; // Added for kDebugMode
import 'package:scannutplus/features/pet/data/pet_repository.dart';
 // Or AppLocalizations if central
import 'package:scannutplus/l10n/app_localizations.dart';
import 'dart:io';
import 'package:scannutplus/features/pet/presentation/widgets/pet_card_actions/pet_analysis_button.dart';
import 'package:scannutplus/features/pet/presentation/widgets/pet_card_actions/pet_profile_button.dart';
import 'package:scannutplus/features/pet/presentation/widgets/pet_card_actions/pet_nutrition_button.dart';
import 'package:scannutplus/features/pet/presentation/widgets/pet_card_actions/pet_agenda_button.dart';
import 'package:scannutplus/features/pet/presentation/widgets/pet_card_actions/pet_walk_button.dart';
import 'package:scannutplus/features/pet/agenda/presentation/pet_agenda_screen.dart';
import 'package:scannutplus/features/pet/agenda/presentation/pet_walk_events_screen.dart'; // Correct Import Placement


import 'package:scannutplus/features/pet/presentation/pet_profile_view.dart';
import 'package:scannutplus/features/pet/presentation/health/pet_health_screen.dart';
import 'package:scannutplus/features/pet/presentation/pet_ai_chat_view.dart'; // Import AI View
import 'package:scannutplus/features/pet/presentation/history/pet_history_screen.dart'; // Import History Screen
import 'package:scannutplus/features/home/presentation/widgets/app_drawer.dart'; // Menu Drawer
import 'package:scannutplus/features/pet/presentation/widgets/pet_card_widget.dart'; // The New Card


class MyPetsView extends StatefulWidget {
  const MyPetsView({super.key});

  @override
  State<MyPetsView> createState() => _MyPetsViewState();
}

class _MyPetsViewState extends State<MyPetsView> {
  final PetRepository _repository = PetRepository();
  
  // NOVA IDENTIDADE VISUAL via AppColors (Pilar 0)
  // Rosa Pastel (#FFD1DC) com Contraste Preto

  // Helper for Brazilian Date Format (dd/MM/yyyy HH:mm)
  String _formatDate(String? isoString) {
    if (isoString == null) return '';
    try {
      final date = DateTime.parse(isoString).toLocal();
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$day/$month/$year $hour:$minute';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Assuming AppLocalizations has the keys we just added
    final appL10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.petBackgroundDark,
      // 1. ADD DRAWER (Menu Requirements)
      drawer: const AppDrawer(),
      appBar: AppBar(
        // 2. MENU ICON: Uses Builder to get Scaffod context
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.notes_rounded, color: Colors.blue), // Menu Icon
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          appL10n.pet_my_pets_title, 
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // ERGONOMIA SM A256E: Remoção de SingleChildScrollView aninhada para resgatar o Lazy Rendering
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _repository.getAllRegisteredPets(), // Método blindado no repository
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.petPrimary));
          }

          // UI FILTER: Double protection against ghost cards
          final allPets = snapshot.data ?? [];
          final pets = allPets.where((p) => p[PetConstants.fieldName] != null && p[PetConstants.fieldName].toString().isNotEmpty && p[PetConstants.fieldName].toString() != PetConstants.valNull).toList();
          
          if (kDebugMode) {
            debugPrint('${PetConstants.logUiBuild}${pets.length}');
            for (var p in pets) {
              debugPrint('${PetConstants.logUiItem}UUID: ${p[PetConstants.fieldUuid]}, Name: ${p[PetConstants.fieldName]}');
            }
          }

          if (pets.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Column(
                  children: [
                     const Icon(Icons.pets, size: 64, color: Colors.white24),
                     const SizedBox(height: 16),
                     Text(
                       appL10n.pet_no_pets_registered, 
                       style: const TextStyle(color: Colors.white54, fontSize: 16)
                     ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            itemCount: pets.length + 1, // +1 para o espaçador
            itemBuilder: (context, index) {
              if (index == pets.length) {
                return const SizedBox(height: 80); // Espaçador para o FAB não cobrir card
              }
              final pet = pets[index];
              return PetCardWidget(
                pet: pet,
                onRefresh: () {
                  if (mounted) setState(() {});
                },
              );
            },
          );
        },
      ),
      // Botão Flutuante (FAB) - Rosa Pastel com Ícone Azul Médio (Sem borda/sombra)
      floatingActionButton: Container(
        child: FloatingActionButton(
          backgroundColor: AppColors.petPrimary, 
          foregroundColor: AppColors.petIconAction,
          shape: const CircleBorder(),
          elevation: 0,
          onPressed: () async {
            // STEP 0: Request Name BEFORE Camera (Protocol 2026)
            final String? petName = await _showNameInputDialog(context);
          
          if (petName != null && petName.isNotEmpty) {
             // Generates UUID here to bind identity immediately
             final newUuid = 'pet_${DateTime.now().millisecondsSinceEpoch}';
             
             if (!context.mounted) return;

             Navigator.pushNamed(
              context, 
              '/pet_capture', 
              arguments: {
                PetConstants.argUuid: newUuid,
                PetConstants.argType: PetImageType.newProfile,
                PetConstants.argName: petName, // Passed from Step 0
                PetConstants.argIsAddingNewPet: true, // Explicit State: New Pet Mode
              },
            ).then((_) => setState(() {})); // Reload list on return
          }
        },
        child: const Icon(Icons.add, size: 32),
        ),
      ),
    );
  }

  Future<String?> _showNameInputDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    TextEditingController controller = TextEditingController();

    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true, // Allow full keyboard interaction
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SingleChildScrollView( // Ergonomia SM A256E: Avoid Overflow
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.petBackgroundDark, // Dark Theme Modal
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: AppColors.petPrimary, width: 2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(Icons.pets, color: AppColors.petPrimary),
                      const SizedBox(width: 12),
                      Text(
                        l10n.pet_dialog_new_title, // "Novo Perfil"
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Input
                  Text(
                    l10n.pet_input_name_hint, // "Qual o nome do pet?"
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    cursorColor: AppColors.petPrimary,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                       filled: true,
                       fillColor: Colors.white.withValues(alpha: 0.1),
                       border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(12),
                         borderSide: BorderSide.none,
                       ),
                       focusedBorder: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(12),
                         borderSide: const BorderSide(color: AppColors.petPrimary),
                       ),
                    ),
                    onChanged: (val) {
                       // Optional: If we wanted to validate live
                    },
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) Navigator.pop(context, val.trim());
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Action Button - Rosa Pastel (Go) com Borda Preta
                  ElevatedButton(
                    onPressed: () {
                      final text = controller.text.trim();
                      if (text.isNotEmpty) {
                         Navigator.pop(context, text);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.petPrimary, // #FFD1DC
                      foregroundColor: AppColors.petText,    // Black
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.petText, width: 1.0), // Black Border
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.btn_go, // "Ir" / "Go"
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Safe Area for Keyboard
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}
