import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kDebugMode
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/data/models/pet_history_entry.dart';
import 'package:scannutplus/core/data/objectbox_manager.dart'; // ObjectBox
import 'package:scannutplus/objectbox.g.dart';

import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/features/pet/presentation/pet_analysis_result_view.dart';

import 'package:scannutplus/features/pet/presentation/pet_capture_view.dart';
import 'package:scannutplus/features/pet/presentation/extensions/pet_ui_extensions.dart';

class PetHistoryScreen extends StatefulWidget {
  final String? petUuid; // Filter by Pet
  const PetHistoryScreen({super.key, this.petUuid});

  @override
  State<PetHistoryScreen> createState() => _PetHistoryScreenState();
}

class _PetHistoryScreenState extends State<PetHistoryScreen> {
  late Box<PetHistoryEntry> _historyBox;
  late Stream<List<PetHistoryEntry>> _stream;

  @override
  void initState() {
    super.initState();
    _historyBox = ObjectBoxManager.currentStore.box<PetHistoryEntry>();
    
    // Construct Query
    final queryBuilder = widget.petUuid != null
        ? _historyBox.query(PetHistoryEntry_.petUuid.equals(widget.petUuid!))
        : _historyBox.query();
        
    _stream = queryBuilder
        .order(PetHistoryEntry_.timestamp, flags: Order.descending)
        .watch(triggerImmediately: true)
        .map((query) => query.find());

    if (widget.petUuid != null) {
        if (kDebugMode) debugPrint('${PetConstants.logTagPetData} [HISTORY] Inicializando tela para UUID: ${widget.petUuid}');
    } else {
        if (kDebugMode) debugPrint('${PetConstants.logTagPetData} [HISTORY] Inicializando tela para TODOS (Modo Global)');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
        // Use generic "History" title or "Analysis History" depending on context
        title: Text(AppLocalizations.of(context)!.pet_history_button, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent, // Restore to dark/transparent
        iconTheme: const IconThemeData(color: Colors.white), // Ensure back arrow is white
        centerTitle: true,
        elevation: 0,
      ),
      // Use StreamBuilder to listen to ObjectBox changes
      body: StreamBuilder<List<PetHistoryEntry>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator(color: Color(0xFF10AC84)));
          }

          if (snapshot.hasError) {
             return Center(child: Text('Error loading history: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }
          
          final entries = snapshot.data ?? [];

          if (entries.isEmpty) {
             return Center(
               child: Text(AppLocalizations.of(context)!.pet_history_empty, 
               style: const TextStyle(color: Colors.white54, fontSize: 16)),
             );
          }

          return SingleChildScrollView( 
            child: Column(
              children: entries.map((pet) { 
                return Card(
                  color: const Color(0xFFFFD1DC), // Rosa Pastel (Restored)
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: pet.imagePath.isNotEmpty 
                        ? CircleAvatar(
                            radius: 25,
                            backgroundImage: FileImage(File(pet.imagePath)),
                            onBackgroundImageError: (_, __) {},
                            child: const Icon(Icons.pets, color: Colors.transparent), // Verify if transparent works or just empty
                          )
                        : const CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.black12,
                            child: Icon(Icons.pets, color: Colors.black54),
                          ),
                    title: Text(pet.petName, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                       '${pet.category.toCategoryDisplay(context)} • ${pet.timestamp.toString().substring(0, 16)}',
                       style: const TextStyle(color: Colors.black54),
                    ),
                    trailing: IconButton(
                       icon: const Icon(Icons.delete, color: Colors.redAccent),
                       onPressed: () {
                         _historyBox.remove(pet.id);
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Entry deleted")));
                       }, 
                    ),
                   onTap: () {
                       // Extract Breed from rawJson (Logic restoration from main flow)
                       String breed = '';
                       // Try multiple patterns to catch various LLM output formats
                       final breedPatterns = [
                           RegExp(r'breed_name:\s*([^|\]\n]*)', caseSensitive: false), // Metadata format
                           RegExp(r'\[BREED\]:\s*([^\n]*)', caseSensitive: false),     // Tag format
                           RegExp(r'\*\*Breed\*\*:\s*([^\n]*)', caseSensitive: false), // Bold format
                           RegExp(r'Raça:\s*([^\n]*)', caseSensitive: false),          // Portuguese
                           RegExp(r'Race:\s*([^\n]*)', caseSensitive: false),          // English fallback
                       ];

                       for (final pattern in breedPatterns) {
                           final match = pattern.firstMatch(pet.rawJson);
                           if (match != null && match.group(1) != null) {
                               breed = match.group(1)!.trim();
                               breed = breed.replaceAll(RegExp(r'[*_\]|]'), '').trim();
                               if (breed.isNotEmpty && breed.length < 50) break; 
                           }
                       }

                       // Fallback: Deep Scan for known breeds in text (Dictionary Match)
                       if (breed.isEmpty) {
                           for (final knownBreed in PetConstants.commonBreedsList) {
                               if (pet.rawJson.contains(knownBreed)) {
                                   breed = knownBreed;
                                   break; // Found a known breed
                               }
                           }
                       }

                       Navigator.of(context).push(
                         MaterialPageRoute(
                           builder: (_) => PetAnalysisResultView(
                             imagePath: pet.imagePath,
                             analysisResult: pet.rawJson,
                             petDetails: {
                                 PetConstants.fieldName: pet.petName, // Correct Key: pet_name
                                 PetConstants.fieldBreed: breed,      // Pass Extracted Breed
                             },
                             onRetake: () => Navigator.of(context).pop(), 
                             onShare: () {
                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Share not implemented for history yet")));
                             },
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

    );
  }
}
