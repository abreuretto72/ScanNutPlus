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
  
  // Controllers for Variable Data (New Metric)
  final _weightController = TextEditingController();
  final _sizeController = TextEditingController();
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
    
    // 2. Diagnóstico de Emergência
    final allInBox = _petBox.getAll();
    print('SCAN_NUT_TRACE: [DB_CHECK] Itens na Box de Pets: ${allInBox.length}');
    if (allInBox.isNotEmpty) {
       print('SCAN_NUT_TRACE: [DB_CHECK] Exemplo de UUID no banco: ${allInBox.first.uuid}');
    } else {
       if (mounted) {
          // 4. Tratamento de Erro Visual
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(AppLocalizations.of(context)!.pet_db_sync_error), backgroundColor: Colors.red)
          );
       }
    }

    // 3. Busca por Correspondência Parcial (Strings limpas)
    try {
      _pet = allInBox.cast<PetEntity?>().firstWhere(
        (p) => p?.uuid.trim() == widget.petUuid.trim(),
        orElse: () => null,
      );
      
      if (_pet != null) {
        print('SCAN_NUT_TRACE: [SUCESSO] Pet localizado via Trim Match.');
      } else {
        print('SCAN_NUT_TRACE: [ERRO FATAL] UUID ${widget.petUuid} não encontrado mesmo com Trim Check.');
      }
    } catch (e) {
      print('SCAN_NUT_TRACE: [EXCEPTION] Erro na busca: $e');
    }

    if (_pet != null) {
      print('SCAN_NUT_TRACE: [SPECIES_CHECK] Espécie recuperada do banco: "${_pet!.species}" (Raw)');
      
      _healthPlanController.text = _pet!.healthPlan ?? '';
      
      // Load Birth Date
      if (_pet!.birthDate != null) {
         _birthDate = _pet!.birthDate;
         _birthDateController.text = "${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}";
      }

      // Load latest metric for initial UI state if needed, though we show list
      if (_pet!.metrics.isNotEmpty) {
        // Sort explicitly if needed, but we used insertion order usually
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
    _pet!.birthDate = _birthDate;
    // _pet!.birthDate is not editable in this simplified view yet, as per requirements focus
    
    _petBox.put(_pet!);

    // 2. Add New Metric if data is present
    if (_weightController.text.isNotEmpty || _sizeController.text.isNotEmpty) {
       final newMetric = PetMetrics(
         petUuid: _pet!.uuid,
         weight: double.tryParse(_weightController.text.replaceAll(',', '.')),
         size: _sizeController.text,
         isNeutered: _isNeutered,
         timestamp: DateTime.now(),
       );
       
       // Relation update
       newMetric.pet.target = _pet;
       _metricsBox.put(newMetric);
       
       // Clear metric inputs after save
       _weightController.clear();
       _sizeController.clear();
    }
    
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
        title: Text(l10n.pet_profile_title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- READ ONLY SECTION ---
            _buildReadOnlyCard(l10n),
            const SizedBox(height: 16),
            
            // --- EDITABLE FIXED DATA ---
            _buildFixedDataCard(l10n),
            const SizedBox(height: 16),
            
            // --- NEW METRIC SECTION ---
            _buildNewMetricCard(l10n),
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
             const SizedBox(height: 24),
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
             _buildReadOnlyRow("Breed", _pet!.breed ?? l10n.pet_breed_unknown, isExpanded: true),
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
            OutlinedButton.icon(
               onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => HealthPlanView(petUuid: widget.petUuid)));
               },
               icon: const Icon(Icons.shield_outlined, color: Colors.white), 
               label: Text(l10n.pet_action_manage_health_plan, style: const TextStyle(color: Colors.white)),
               style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.centerLeft,
               ),
            ),

            const SizedBox(height: 12),
            const SizedBox(height: 12),
            // --- FUNERAL PLAN BUTTON ---
            OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => FuneralPlanView(petUuid: widget.petUuid)));
                },
                icon: const Icon(Icons.church, color: Colors.white),
                label: Text(l10n.pet_action_manage_funeral_plan, style: const TextStyle(color: Colors.white)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.centerLeft,
                ),
            ),
            const SizedBox(height: 12),
            
            // --- DATE OF BIRTH FIELD ---
             GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: _buildTextField(_birthDateController, l10n.pet_label_birth_date, Icons.cake),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewMetricCard(AppLocalizations l10n) {
    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.pet_btn_add_metric, style: TextStyle(color: AppColors.petPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildTextField(_weightController, l10n.pet_label_weight, Icons.monitor_weight, isNumber: true)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(_sizeController, l10n.pet_label_size, Icons.height)),
              ],
            ),
            const SizedBox(height: 12),
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
}
