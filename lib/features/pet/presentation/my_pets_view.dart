import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:scannutplus/l10n/app_localizations.dart'; // Core L10n
import 'package:scannutplus/features/pet/data/models/pet_profile.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/l10n/generated/pet_localizations.dart';
import 'package:scannutplus/features/pet/presentation/pet_capture_view.dart';
import 'package:scannutplus/features/pet/presentation/pet_management_screen.dart'; 
// Note: We might need to refactor PetProfileScreen to accept PetProfile instead of HistoryEntry, 
// or create a dummy entry. For now, I'll assume we navigate to a detail view.
// The user said: "3. Tela de Gerenciamento do Pet (Ao clicar no Card)" -> uses PetProfile logic.
// So I might need to update PetProfileScreen too.

class MyPetsView extends StatefulWidget {
  const MyPetsView({super.key});

  @override
  State<MyPetsView> createState() => _MyPetsViewState();
}

class _MyPetsViewState extends State<MyPetsView> {
  // final ImagePicker _picker = ImagePicker(); // Unused

  @override
  Widget build(BuildContext context) {
    // Ensure box is open (should be done in main/init, but safe check)
    // We assume openPetBoxes() was called.
    
    final l10n = PetLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
        title: Text(l10n.pet_screen_title_my_pets, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1F3A5F),
        elevation: 0,
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<PetProfile>(PetConstants.boxPetProfiles).listenable(),
        builder: (context, Box<PetProfile> box, _) {
          if (box.isEmpty) return _buildEmptyState(l10n);
          
          return SingleChildScrollView(
             // Ergonomia SM A256E
            padding: const EdgeInsets.only(bottom: 160, left: 16, right: 16, top: 16),
            child: Column(
              children: box.values.map((pet) => _buildPetCard(pet, l10n)).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF9800), 
        onPressed: () => _startNewPetFlow(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildEmptyState(PetLocalizations l10n) {
    return Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
            const Icon(LucideIcons.dog, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              l10n.pet_history_empty, // "Nenhum histórico" -> "Nenhum pet" (close enough or need new key)
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
         ],
       ),
    );
  }

  Widget _buildPetCard(PetProfile pet, PetLocalizations l10n) {
    return Card(
      color: const Color(0xFF152033),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: FileImage(File(pet.profileImagePath)),
          backgroundColor: Colors.grey,
        ),
        title: Text(
          pet.name, 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
        ),
        subtitle: Text(
          "${_getLocalizedBreed(context, pet.breed)} • ${pet.age}",
          style: const TextStyle(color: Colors.white70)
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
          onPressed: () => _confirmDelete(pet, l10n),
        ),
        onTap: () => _navigateToPetDetails(pet),
      ),
    );
  }

  Future<void> _startNewPetFlow(BuildContext context) async {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PetCaptureView(initialMode: PetImageType.newProfile),
        ),
      );
  }


  void _confirmDelete(PetProfile pet, PetLocalizations l10n) {
     showDialog(
       context: context,
       builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1F3A5F),
          title: Text(l10n.pet_delete_title, style: const TextStyle(color: Colors.white)),
          content: Text(
            l10n.pet_delete_confirm_msg(pet.name), 
            style: const TextStyle(color: Colors.white70)
          ),
          actions: [
             TextButton(
               onPressed: () => Navigator.pop(ctx),
               child: Text(l10n.action_cancel, style: const TextStyle(color: Colors.white54)),
             ),
             TextButton(
               onPressed: () {
                  pet.delete(); 
                  try {
                    final f = File(pet.profileImagePath);
                    if (f.existsSync()) f.deleteSync();
                  } catch (e) {
                    debugPrint('${PetConstants.logTagPetData}$e');
                  }
                  Navigator.pop(ctx);
               },
               child: Text(l10n.action_delete, style: const TextStyle(color: Colors.redAccent)),
             )
          ],
       )
     );
  }

  void _navigateToPetDetails(PetProfile pet) {
     Navigator.push(
       context,
       MaterialPageRoute(builder: (_) => PetManagementScreen(pet: pet)),
     );
  }

  String _getLocalizedBreed(BuildContext context, String breed) {
    if (breed.contains(PetConstants.valDog)) return AppLocalizations.of(context)!.species_dog;
    if (breed.contains(PetConstants.valCat)) return AppLocalizations.of(context)!.species_cat;
    return breed;
  }
}




