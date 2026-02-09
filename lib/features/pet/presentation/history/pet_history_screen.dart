import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/data/models/pet_history_entry.dart';

import 'package:scannutplus/l10n/app_localizations.dart';
// import 'package:scannutplus/features/pet/l10n/generated/pet_localizations.dart'; // Removed
import 'package:scannutplus/features/pet/presentation/history/pet_profile_screen.dart';
import 'package:scannutplus/features/pet/presentation/pet_capture_view.dart';
import 'package:scannutplus/features/pet/presentation/extensions/pet_ui_extensions.dart';

class PetHistoryScreen extends StatefulWidget {
  const PetHistoryScreen({super.key});

  @override
  State<PetHistoryScreen> createState() => _PetHistoryScreenState();
}

class _PetHistoryScreenState extends State<PetHistoryScreen> {

  @override
  Widget build(BuildContext context) {
    // Ensure box is open (Safety First)
    return FutureBuilder(
      future: Hive.isBoxOpen(PetConstants.boxPetHistory)
          ? Future.value(Hive.box<PetHistoryEntry>(PetConstants.boxPetHistory))
          : Hive.openBox<PetHistoryEntry>(PetConstants.boxPetHistory),
      builder: (context, snapshot) {
        // Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const Scaffold(
             backgroundColor: Color(0xFF0A0E17),
             body: Center(child: CircularProgressIndicator(color: Color(0xFF10AC84))),
           );
        }

        // Error State
        if (snapshot.hasError) {
           return Scaffold(
             backgroundColor: const Color(0xFF0A0E17),
             body: Center(child: Text(AppLocalizations.of(context)!.error_database_load(snapshot.error.toString()), style: const TextStyle(color: Colors.red))),
           );
        }
        
        // Success State - Build the List
        return Scaffold(
          backgroundColor: const Color(0xFF0A0E17),
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.pet_ui_my_pets, style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFFFFD1DC), // Rosa Pastel
            centerTitle: true,
            elevation: 0,
          ),
          body: ValueListenableBuilder<Box<PetHistoryEntry>>(
            valueListenable: Hive.box<PetHistoryEntry>(PetConstants.boxPetHistory).listenable(),
            builder: (context, box, _) {
              if (box.isEmpty) {
                 return Center(
                   child: Text(AppLocalizations.of(context)!.pet_history_empty, 
                   style: const TextStyle(color: Colors.white54, fontSize: 16)),
                 );
              }

              return SingleChildScrollView( 
                child: Column(
                  children: box.values.toList().reversed.map((pet) { // Newest first
                    return Card(
                      color: const Color(0xFF152033),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: pet.imagePath.isNotEmpty 
                            ? Image.file(File(pet.imagePath), width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.pets, color: Colors.white54)) 
                            : const Icon(Icons.pets, color: Colors.white54),
                        title: Text(pet.petName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                           '${pet.category.toCategoryDisplay(context)} • ${pet.timestamp.toString().substring(0, 16)}',
                           style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: IconButton(
                           icon: const Icon(Icons.delete, color: Colors.redAccent),
                           onPressed: () => pet.delete(), // Quick delete
                        ),
                       onTap: () {
                           Navigator.of(context).push(
                             MaterialPageRoute(
                               builder: (_) => PetProfileScreen(
                                 uuid: pet.petUuid,
                                 name: pet.petName,
                               ),
                             ),
                           );
                        },
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF1F3A5F),
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const PetCaptureView(),
                        settings: const RouteSettings(
                           arguments: {
                              PetConstants.argType: PetImageType.newProfile
                           }
                        )
                    )
                );
            },
          ),
        );
      },
    );
  }
}
