import 'package:scannutplus/core/theme/app_colors.dart'; // AppColors
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/features/pet/presentation/history/pet_history_screen.dart';
import 'package:scannutplus/features/pet/data/pet_repository.dart';
import 'package:scannutplus/features/pet/data/models/pet_entity.dart';




class PetDashboardView extends StatefulWidget {
  const PetDashboardView({super.key});

  @override
  State<PetDashboardView> createState() => _PetDashboardViewState();
}

class _PetDashboardViewState extends State<PetDashboardView> {
  // Default to null to force selection (UX Requirement)
  PetImageType? _selectedType;
  
  // Friend Logic (Module 2026)
  final PetRepository _repository = PetRepository();
  bool _isFriendMode = false;
  List<PetEntity> _friendPets = [];
  String? _selectedFriendUuid;
  final _tutorNameController = TextEditingController();
  final _friendNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final friends = _repository.getFriendPets();
    setState(() {
      _friendPets = friends;
    });
  }

  @override
  void dispose() {
    _tutorNameController.dispose();
    _friendNameController.dispose();
    super.dispose();
  }

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
      appBar: AppBar(title: Text(l10n.pet_analyses_title(name)), backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(), // Ergonomia SM A256E
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- CARD 1: NEW ANALYSIS ---
            _buildAnalysisCard(context, l10n, uuid, name, breed, imagePath),
            

          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(BuildContext context, AppLocalizations l10n, String uuid, String name, String breed, String imagePath) {
    bool isNewFriend = _selectedFriendUuid == PetConstants.valNewFriend;

    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- SWITCH: MEU PET vs PET AMIGO ---
            Container(
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: SwitchListTile(
                 title: Text(
                   _isFriendMode ? l10n.pet_mode_friend : l10n.pet_mode_my_pet,
                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                 ),
                 subtitle: Text(
                   _isFriendMode ? l10n.pet_friend_list_label : name,
                   style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                 ),
                 secondary: Icon(_isFriendMode ? Icons.group : Icons.pets, color: AppColors.petPrimary),
                 value: _isFriendMode,
                 activeColor: AppColors.petPrimary,
                 onChanged: (val) {
                   setState(() {
                     _isFriendMode = val;
                     _selectedFriendUuid = null; // Reset friend selection
                     _isFriendMode ? _loadFriends() : null; // Refresh list explicitly
                   });
                 },
              ),
            ),
            const SizedBox(height: 16),

            // --- FRIEND SELECTOR (Conditional) ---
            if (_isFriendMode) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.petPrimary, // Pink Pastel
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.petText), // Black Border for contrast
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedFriendUuid,
                      hint: Text(l10n.pet_hint_select_friend, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, shadows: [])), // Bold as requested
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.normal, shadows: [], fontSize: 14), // Strict Style for Selected Item
                      isExpanded: true,
                      dropdownColor: AppColors.petPrimary, 
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                      items: [
                        // New Friend Option
                        DropdownMenuItem<String>(
                          value: PetConstants.valNewFriend,
                          child: Row(
                            children: [
                              const Icon(Icons.add_circle, color: Colors.black), 
                              const SizedBox(width: 8),
                              Text(l10n.pet_new_friend_option, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.normal, shadows: [])), 
                            ],
                          ),
                        ),
                        // Friend List Loop
                         ..._friendPets.map((p) => DropdownMenuItem<String>(
                           value: p.uuid,
                           child: Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space
                             children: [
                               Expanded(
                                 child: Text(
                                   '${p.name} (${l10n.pet_label_tutor}: ${p.tutorName ?? '?'})', 
                                   style: const TextStyle(color: Colors.black, shadows: []),
                                   overflow: TextOverflow.ellipsis,
                                 ),
                               ),
                               if (_selectedFriendUuid == p.uuid) // Show actions only if selected (or always?) - UX Decision: better next to dropdown, but inside item works for selection
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Edit Button
                                      InkWell(
                                        onTap: () {
                                           Navigator.of(context).pop(); // Close dropdown if open (trick) part 1
                                           _showEditFriendDialog(context, p);
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                                          child: Icon(Icons.edit, color: Colors.black54, size: 20),
                                        ),
                                      ),
                                      // Delete Button
                                      InkWell(
                                         onTap: () {
                                            Navigator.of(context).pop();
                                            _showDeleteFriendDialog(context, p);
                                         },
                                         child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                                          child: Icon(Icons.delete, color: Colors.red, size: 20),
                                        ),
                                      )
                                    ],
                                  )
                             ],
                           ),
                        )),
                      ],

                      onChanged: (val) => setState(() => _selectedFriendUuid = val),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // --- NEW FRIEND INPUTS ---
                if (isNewFriend) ...[
                   TextField(
                     controller: _friendNameController,
                     style: const TextStyle(color: Colors.white),
                     decoration: InputDecoration(
                        labelText: l10n.label_friend_name,
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.pets, color: Colors.white70),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white24)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.petPrimary)),
                     ),
                   ),
                   const SizedBox(height: 12),
                   TextField(
                     controller: _tutorNameController,
                     style: const TextStyle(color: Colors.white),
                     decoration: InputDecoration(
                        labelText: l10n.pet_label_tutor,
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.person, color: Colors.white70),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white24)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.petPrimary)),
                     ),
                   ),
                   const SizedBox(height: 16),
                ],
                const Divider(color: Colors.white24),
                const SizedBox(height: 16),
            ],

            Text(l10n.pet_select_context, 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            
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
                       _buildDropdownItem(context, PetImageType.mouth, l10n.pet_module_dentistry, Icons.health_and_safety, subtitle: l10n.pet_module_dentistry_programs),
                       _buildDropdownItem(context, PetImageType.skin, l10n.pet_module_dermatology, Icons.bug_report, subtitle: l10n.pet_module_dermatology_programs),
                       _buildDropdownItem(context, PetImageType.stool, l10n.pet_module_gastro, Icons.medical_services, subtitle: l10n.pet_module_gastro_programs),
                       _buildDropdownItem(context, PetImageType.eyes, l10n.pet_module_ophthalmology, Icons.visibility, subtitle: l10n.pet_module_ophthalmology_programs),
                       _buildDropdownItem(context, PetImageType.ears, l10n.pet_module_ears, Icons.hearing, subtitle: l10n.pet_module_otology_programs),
                       _buildDropdownItem(context, PetImageType.posture, l10n.pet_module_physique, Icons.accessibility, subtitle: l10n.pet_module_physique_programs),
                       _buildDropdownItem(context, PetImageType.lab, l10n.pet_module_lab, Icons.science, subtitle: l10n.pet_module_lab_programs),
                       _buildDropdownItem(context, PetImageType.label, l10n.pet_module_nutrition, Icons.restaurant_menu, subtitle: l10n.pet_module_nutrition_programs),
                       _buildDropdownItem(context, PetImageType.vocal, l10n.pet_module_vocal, Icons.mic, subtitle: l10n.pet_module_vocal_programs),
                       _buildDropdownItem(context, PetImageType.behavior, l10n.pet_module_behavior, Icons.psychology, subtitle: l10n.pet_module_behavior_programs),
                       _buildDropdownItem(context, PetImageType.plantCheck, l10n.pet_module_plant, Icons.local_florist, subtitle: l10n.pet_module_plant_programs),
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
            ElevatedButton.icon(
              onPressed: () {
                // VALIDATION (Pilar 0: Zero erros de fluxo)
                if (_selectedType == null) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text(l10n.pet_hint_select_type), backgroundColor: Colors.red)
                   );
                   return;
                }

                String finalUuid = uuid;
                String finalName = name;
                // Friend Validation
                if (_isFriendMode) {
                   if (_selectedFriendUuid == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pet_hint_select_friend), backgroundColor: Colors.red));
                      return;
                   }
                   if (_selectedFriendUuid == PetConstants.valNewFriend) {
                      if (_friendNameController.text.isEmpty || _tutorNameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pet_error_fill_friend_fields), backgroundColor: Colors.red));
                          return;
                      }
                      // For New Friend, Generate a NEW UUID
                      // This ensures a new entity is created in saveAnalysis
                      finalUuid = const Uuid().v4(); 
                      finalName = _friendNameController.text;
                   } else {
                      // Existing Friend
                      final friend = _friendPets.firstWhere((p) => p.uuid == _selectedFriendUuid);
                      finalUuid = friend.uuid;
                      finalName = friend.name ?? l10n.pet_unknown;
                   }
                }

                Navigator.pushNamed(context, '/pet_capture', arguments: {
                  PetConstants.argUuid: finalUuid,
                  PetConstants.argType: _selectedType,
                  PetConstants.argName: finalName,
                  PetConstants.argBreed: breed, // Keep original breed or update if friend loaded
                  PetConstants.argImagePath: imagePath,
                  // New Arguments for Friend Logic
                  'is_friend': _isFriendMode,
                  'tutor_name': _isFriendMode ? (_selectedFriendUuid == PetConstants.valNewFriend ? _tutorNameController.text : _friendPets.firstWhere((p) => p.uuid == _selectedFriendUuid).tutorName) : null,
                  'is_new_friend': _isFriendMode && _selectedFriendUuid == PetConstants.valNewFriend,
                }).then((_) {
                   setState(() {
                      _selectedType = null; // Optional: reset selection on return
                      // If we added a new friend, refresh list
                      if (_isFriendMode) _loadFriends(); 
                   });
                }); 
              },
              icon: const Icon(Icons.camera_alt, color: AppColors.petText),
              label: Text(l10n.btn_scan_image.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
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
            
            // --- BOTÃO DE HISTÓRICO (Restaurado) ---
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PetHistoryScreen(petUuid: uuid, petName: name)),
                );
                if (kDebugMode) {
                  debugPrint('${PetConstants.logNavHistory}$uuid');
                }
              },
              icon: const Icon(Icons.history, color: Colors.white70),
              label: Text(
                l10n.pet_history_button, 
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }






  DropdownMenuItem<PetImageType> _buildDropdownItem(BuildContext context, PetImageType type, String label, IconData icon, {String? subtitle}) {
    return DropdownMenuItem<PetImageType>(
      value: type,
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 20), // Black Icon
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.black, fontSize: 16), // Black Text
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.black.withValues(alpha: 0.6), fontSize: 12, fontStyle: FontStyle.italic),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- FRIEND MANAGEMENT DIALOGS ---

  void _showEditFriendDialog(BuildContext context, PetEntity friend) {
     final TextEditingController nameController = TextEditingController(text: friend.name);
     final TextEditingController tutorController = TextEditingController(text: friend.tutorName);
     final l10n = AppLocalizations.of(context)!;

     showDialog(
       context: context,
       builder: (ctx) => AlertDialog(
         title: Text(l10n.pet_dialog_edit_title),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             TextField(
               controller: nameController,
               decoration: InputDecoration(labelText: l10n.label_friend_name),
             ),
             TextField(
               controller: tutorController,
               decoration: InputDecoration(labelText: l10n.label_tutor_name),
             ),
           ],
         ),
         actions: [
           TextButton(
             onPressed: () => Navigator.of(ctx).pop(),
             child: Text(l10n.common_cancel),
           ),
           TextButton(
             onPressed: () async {
               if (nameController.text.isNotEmpty) {
                  friend.name = nameController.text;
                  friend.tutorName = tutorController.text;
                  await _repository.updateFriend(friend);
                  Navigator.of(ctx).pop();
                  _loadFriends(); // Refresh UI
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pet_msg_friend_updated)));
               }
             },
             child: const Text('Salvar'), 
           ),
         ],
       ),
     );
  }

  void _showDeleteFriendDialog(BuildContext context, PetEntity friend) {
      final l10n = AppLocalizations.of(context)!;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.pet_delete_title),
          content: Text(l10n.pet_msg_confirm_delete_friend),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.common_cancel),
            ),
            TextButton(
              onPressed: () async {
                  await _repository.deleteFriend(friend.uuid);
                  Navigator.of(ctx).pop();
                  
                  // Reset selection if deleted
                  if (_selectedFriendUuid == friend.uuid) {
                     setState(() {
                       _selectedFriendUuid = null;
                     });
                  }
                  
                  _loadFriends();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pet_msg_friend_deleted)));
              },
              child: Text(l10n.common_delete, style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
  }
} // End Class
