import 'package:flutter/material.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/features/pet/data/models/pet_entity.dart';
import 'package:scannutplus/features/pet/data/models/pet_metrics.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/presentation/plans/health_plan_view.dart';
import 'package:scannutplus/features/pet/presentation/plans/funeral_plan_view.dart';
import 'package:scannutplus/core/data/objectbox_manager.dart';
import 'package:scannutplus/objectbox.g.dart'; // Generated file

class PetProfileView extends StatefulWidget {
  final String petUuid;
  
  const PetProfileView({super.key, required this.petUuid});

  @override
  State<PetProfileView> createState() => _PetProfileViewState();
}

class _PetProfileViewState extends State<PetProfileView> {
  late Box<PetEntity> _petBox;
  late Box<PetMetrics> _metricsBox;
  PetEntity? _pet;
  
  // Controllers for Fixed Data
  final _healthPlanController = TextEditingController();
  final _birthDateController = TextEditingController(); // Date of Birth
  

  final _estimatedWeightController = TextEditingController(); // New Profile Weight
  
  // Clinical Conditions Controllers
  final _allergiesController = TextEditingController();
  final _chronicController = TextEditingController();
  final _disabilitiesController = TextEditingController();
  final _notesController = TextEditingController();
  
  // External ID Controllers
  final _microchipController = TextEditingController();
  final _registryController = TextEditingController();
  String? _selectedSex; 
  String? _selectedSize; // New state for Size Category (Small/Medium/Large)
  bool _isNeutered = false;
  
  bool _isLoading = true;
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final store = ObjectBoxManager.currentStore;
    _petBox = store.box<PetEntity>();
    _metricsBox = store.box<PetMetrics>();
    
    // Find pet by UUID - Diagnostic & Robust Implementation
    final allInBox = _petBox.getAll();
    
    // 3. Busca por Correspondência Parcial (Strings limpas)
    try {
      _pet = allInBox.cast<PetEntity?>().firstWhere(
        (p) => p?.uuid.trim() == widget.petUuid.trim(),
        orElse: () => null,
      );
    } catch (e) {
      // Error finding pet
    }

    if (_pet == null) {
       // 4. Tratamento de Erro Visual
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(AppLocalizations.of(context)!.pet_db_sync_error), backgroundColor: Colors.red)
          );
       }
    } else {
       // Load data
       // _nameController and _breedController are not used in ReadOnly UI
       _healthPlanController.text = _pet!.healthPlan ?? '';
       
       // Load Estimated Weight -- NEW
       if (_pet!.estimatedWeight != null) {
         _estimatedWeightController.text = _pet!.estimatedWeight.toString();
       }
       
       // Load Clinical Conditions
       _allergiesController.text = _pet!.allergies ?? '';
       _chronicController.text = _pet!.chronicConditions ?? '';
       _disabilitiesController.text = _pet!.disabilities ?? '';
       _notesController.text = _pet!.clinicalNotes ?? '';
       
       // Load External ID
       _microchipController.text = _pet!.microchip ?? '';
       _registryController.text = _pet!.registryId ?? '';
       
       // Load Birth Date
       if (_pet!.birthDate != null) {
         _birthDate = _pet!.birthDate;
         _birthDateController.text = "${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}";
       }
       
       // Load Sex -- NEW
       _selectedSex = _pet!.gender;
       
       // Load Size Category -- NEW
       _selectedSize = _pet!.sizeCategory;

       // Load latest metric for initial UI state if needed
       if (_pet!.metrics.isNotEmpty) {
         final latest = _pet!.metrics.last; 

         _isNeutered = latest.isNeutered ?? false;
       }
    }
    
    if (mounted) setState(() => _isLoading = false);
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.petPrimary,
              onPrimary: Colors.black,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
        _birthDateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }
  
  Future<void> _saveProfile() async {
    if (_pet == null) return;
    
    // 1. Update Fixed Data
    _pet!.healthPlan = _healthPlanController.text;
    _pet!.healthPlan = _healthPlanController.text;
    _pet!.birthDate = _birthDate;
    _pet!.gender = _selectedSex; // Save Sex
    _pet!.sizeCategory = _selectedSize; // Save Size Category
    
    // Save Estimated Weight
    if (_estimatedWeightController.text.isNotEmpty) {
      _pet!.estimatedWeight = double.tryParse(_estimatedWeightController.text.replaceAll(',', '.'));
    } else {
      _pet!.estimatedWeight = null;
    }
    
    // Save Clinical Conditions
    _pet!.allergies = _allergiesController.text;
    _pet!.chronicConditions = _chronicController.text;
    _pet!.disabilities = _disabilitiesController.text;
    _pet!.clinicalNotes = _notesController.text;
    
    // Save External ID
    _pet!.microchip = _microchipController.text;
    _pet!.registryId = _registryController.text;
    // _pet!.birthDate is not editable in this simplified view yet, as per requirements focus
    
    _petBox.put(_pet!);


    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pet_profile_save_success), backgroundColor: Colors.green),
      );
      setState(() {}); // Refresh list
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_pet == null) return Scaffold(appBar: AppBar(), body: Center(child: Text(l10n.pet_not_found)));

    return Scaffold(
      backgroundColor: AppColors.petBackgroundDark,
      appBar: AppBar(
        title: Text(l10n.pet_profile_title_dynamic(_pet?.name ?? l10n.pet_unknown)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- READ ONLY SECTION ---
            // --- READ ONLY SECTION ---
            _buildReadOnlyCard(l10n),
            const SizedBox(height: 16),
            
            // --- CLINICAL CONDITIONS ---
            _buildClinicalDataCard(l10n),
            const SizedBox(height: 16),
            
            // --- EXTERNAL IDENTIFICATION ---
            _buildExternalIdCard(l10n),
            const SizedBox(height: 16),
            
            // --- EDITABLE FIXED DATA ---
            _buildFixedDataCard(l10n),
            const SizedBox(height: 16),
            

            
            // --- SAVE BUTTON ---
            ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save),
              label: Text(l10n.pet_action_save_profile),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.petPrimary,
                foregroundColor: AppColors.petText,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
             const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyCard(AppLocalizations l10n) {
    String displaySpecies = _pet!.species;
    // Map known codes to localized labels
    if (_pet!.species.toLowerCase().contains(PetConstants.speciesDog) || _pet!.species.toLowerCase().contains(PetConstants.speciesDogPt)) {
       displaySpecies = l10n.species_dog;
    } else if (_pet!.species.toLowerCase().contains(PetConstants.speciesCat) || _pet!.species.toLowerCase().contains(PetConstants.speciesCatPt)) {
       displaySpecies = l10n.species_cat;
    }

    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReadOnlyRow(l10n.label_name, _pet!.name ?? l10n.pet_unknown_name),
            const Divider(color: Colors.grey),
            _buildReadOnlyRow(l10n.species_label, displaySpecies), // Keeps existing species logic
            const Divider(color: Colors.grey),
            // Fix Overflow for Breed
             _buildReadOnlyRow(l10n.pet_label_breed, _pet!.breed ?? l10n.pet_breed_unknown, isExpanded: true),
             const Divider(color: Colors.grey),
             // --- DATE OF BIRTH FIELD (Moved here) ---
             GestureDetector(
               onTap: () => _selectDate(context),
               child: AbsorbPointer(
                 child: _buildTextField(_birthDateController, l10n.pet_label_birth_date, Icons.cake),
               ),
             ),
             if (_birthDate != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 4, bottom: 8),
                  child: Text(
                    _getFormattedAge(_birthDate!, l10n),
                    style: TextStyle(color: AppColors.petPrimary, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
             const SizedBox(height: 12),
             
             // --- SEX DROPDOWN ---
             DropdownButtonFormField<String>(
               key: ValueKey('sex_$_selectedSex'), // Distinct Key
               initialValue: _selectedSex,
               decoration: InputDecoration(
                 labelText: l10n.pet_label_sex,
                 labelStyle: const TextStyle(color: Colors.grey),
                 prefixIcon: const Icon(Icons.male, color: AppColors.petPrimary), // Using male/male-female icon generic
                 filled: true,
                 fillColor: Colors.black26,
                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
               ),
               dropdownColor: Colors.grey[850],
               style: const TextStyle(color: Colors.white),
               items: [
                 DropdownMenuItem(value: 'Male', child: Text(l10n.pet_sex_male)),
                 DropdownMenuItem(value: 'Female', child: Text(l10n.pet_sex_female)),
               ],
               onChanged: (val) => setState(() => _selectedSex = val),
             ),
             const SizedBox(height: 12),

             // --- SIZE DROPDOWN (PORTE) ---
             DropdownButtonFormField<String>(
               key: ValueKey('size_$_selectedSize'), // Distinct Key
               initialValue: _selectedSize,
               decoration: InputDecoration(
                 labelText: l10n.pet_label_size,
                 labelStyle: const TextStyle(color: Colors.grey),
                 prefixIcon: const Icon(Icons.fitness_center, color: AppColors.petPrimary),
                 filled: true,
                 fillColor: Colors.black26,
                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
               ),
               dropdownColor: Colors.grey[850],
               style: const TextStyle(color: Colors.white),
               items: [
                 DropdownMenuItem(value: 'Small', child: Text(l10n.pet_size_small)),
                 DropdownMenuItem(value: 'Medium', child: Text(l10n.pet_size_medium)),
                 DropdownMenuItem(value: 'Large', child: Text(l10n.pet_size_large)),
               ],
               onChanged: (val) => setState(() => _selectedSize = val),
             ),
             const SizedBox(height: 12),

             const SizedBox(height: 12),

             // --- ESTIMATED WEIGHT INPUT ---
             _buildTextField(
               _estimatedWeightController,
               "${l10n.pet_label_estimated_weight} (${l10n.pet_weight_unit})",
               Icons.monitor_weight,
               isNumber: true,
             ),
             const SizedBox(height: 12),
             
             // --- NEUTERED SWITCH (Moved here) ---
             SwitchListTile(
               title: Text(l10n.pet_label_neutered, style: const TextStyle(color: Colors.white)),
               value: _isNeutered,
               onChanged: (v) => setState(() => _isNeutered = v),
               thumbColor: WidgetStateProperty.resolveWith((states) {
                 if (states.contains(WidgetState.selected)) {
                   return AppColors.petPrimary;
                 }
                 return Colors.grey; 
               }),
               trackColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.petPrimary.withValues(alpha: 0.5);
                  }
                  return null;
               }),
               contentPadding: EdgeInsets.zero,
             ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildClinicalDataCard(AppLocalizations l10n) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.pet_clinical_title, style: TextStyle(color: AppColors.petPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            _buildTextField(_allergiesController, l10n.pet_label_allergies, Icons.no_food),
            const SizedBox(height: 12),
            
            _buildTextField(_chronicController, l10n.pet_label_chronic, Icons.healing),
            const SizedBox(height: 12),
            
            _buildTextField(_disabilitiesController, l10n.pet_label_disabilities, Icons.accessible),
             const SizedBox(height: 12),
            
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: l10n.pet_label_observations,
                labelStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.note, color: AppColors.petPrimary),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildExternalIdCard(AppLocalizations l10n) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.pet_id_external_title, style: TextStyle(color: AppColors.petPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            _buildTextField(_microchipController, l10n.pet_label_microchip, Icons.memory),
            const SizedBox(height: 12),
            
            _buildTextField(_registryController, l10n.pet_label_registry, Icons.app_registration),
            const SizedBox(height: 16),
            
            // Placeholder QR Code
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black26, // Distinct background
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code_2, size: 48, color: Colors.grey),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.pet_label_qrcode, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text(l10n.pet_qrcode_future, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedDataCard(AppLocalizations l10n) {
    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.pet_plans_title, style: TextStyle(color: AppColors.petPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // --- HEALTH PLAN BUTTON ---
            _buildPlanButton(
              icon: Icons.shield_outlined,
              label: l10n.pet_action_manage_health_plan,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HealthPlanView(petUuid: widget.petUuid, petName: _pet?.name ?? l10n.pet_unknown))),
            ),

            const SizedBox(height: 12),
            
            // --- FUNERAL PLAN BUTTON ---
            _buildPlanButton(
              icon: Icons.church,
              label: l10n.pet_action_manage_funeral_plan,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FuneralPlanView(petUuid: widget.petUuid, petName: _pet?.name ?? l10n.pet_unknown))),
            ),
            
          ],
        ),
      ),
    );
  }

  Widget _buildPlanButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.petPrimary, // Pink Background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: Colors.black), // Black Icon
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black), // Black Chevron
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildReadOnlyRow(String label, String value, {bool isExpanded = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(width: 8),
        isExpanded 
          ? Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.end, overflow: TextOverflow.ellipsis))
          : Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: AppColors.petPrimary),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }
  String _getFormattedAge(DateTime birthDate, AppLocalizations l10n) {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;

    if (months < 0 || (months == 0 && days < 0)) {
      years--;
      months += 12;
    }
    
    if (days < 0) {
      months--;
    }
    
    if (years < 0) years = 0;
    if (months < 0) months = 0;
    
    final yearsStr = l10n.pet_age_years(years);
    final monthsStr = l10n.pet_age_months(months);
    
    String ageParts = [yearsStr, monthsStr].where((s) => s.isNotEmpty).join(' ');
    
    if (ageParts.isEmpty) {
       return "${l10n.pet_age_estimate_label} < 1 ${l10n.pet_age_months(1).replaceAll('1 ', '')}";
    }
    
    return "${l10n.pet_age_estimate_label}$ageParts";
  }
}
