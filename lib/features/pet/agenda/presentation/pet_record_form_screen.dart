import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/pet/agenda/pet_event.dart';
import 'package:scannutplus/pet/agenda/pet_event_repository.dart';
import 'package:scannutplus/features/pet/data/models/pet_event_type.dart';
import 'package:uuid/uuid.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:gal/gal.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

enum PetRecordType {
  medication, // 💊 Medicação
  weight,     // ⚖️ Peso
  energy,     // ⚡ Energia
  appetite,   // 🍽️ Apetite
  incident,   // ⚠️ Incidentes
  other,      // 📝 Outros
}

class PetRecordFormScreen extends StatefulWidget {
  final String petId;
  final String petName;
  final PetRecordType recordType;

  const PetRecordFormScreen({
    super.key,
    required this.petId,
    required this.petName,
    required this.recordType,
  });

  @override
  State<PetRecordFormScreen> createState() => _PetRecordFormScreenState();
}

class _PetRecordFormScreenState extends State<PetRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final PetEventRepository _repository = PetEventRepository();
  bool _isLoading = false;

  // Controllers
  final _nameController = TextEditingController(); // Drug Name, Title
  final _amountController = TextEditingController(); // Dosage, Mass
  final _unitController = TextEditingController(); // Unit
  final _contextController = TextEditingController(); // Context, Description, Details
  final _symptomsController = TextEditingController(); // Symptoms
  final _actionController = TextEditingController(); // Action Taken
  final _observationController = TextEditingController(); // Observation
  final _variationController = TextEditingController(); // Diet Variation
  final _locationController = TextEditingController(); // Location

  // State
  String? _category;
  String? _level;
  String? _period;
  String? _consumption;
  String? _thirst;
  String? _severity;
  String? _otherType;
  
  final DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  File? _selectedImage;

  final stt.SpeechToText _speech = stt.SpeechToText();
  TextEditingController? _activeVoiceController;
  String _previousText = '';

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _unitController.dispose();
    _contextController.dispose();
    _symptomsController.dispose();
    _actionController.dispose();
    _observationController.dispose();
    _variationController.dispose();
    _locationController.dispose();
    _speech.cancel();
    super.dispose();
  }

  // --- UI BUILDERS ---

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.petBackgroundDark,
      appBar: AppBar(
        title: Text(_getTitle(l10n), style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : _saveRecord,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.petPrimary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDynamicFields(l10n),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveRecord,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.petPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(l10n.pet_agenda_save, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _getTitle(AppLocalizations l10n) {
    switch (widget.recordType) {
      case PetRecordType.medication: return l10n.pet_record_medication;
      case PetRecordType.weight: return l10n.pet_record_weight;
      case PetRecordType.energy: return l10n.pet_record_energy;
      case PetRecordType.appetite: return l10n.pet_record_appetite;
      case PetRecordType.incident: return l10n.pet_record_incident;
      case PetRecordType.other: return l10n.pet_record_other;
    }
  }

  Widget _buildDynamicFields(AppLocalizations l10n) {
    switch (widget.recordType) {
      case PetRecordType.medication: return _buildMedicationFields(l10n);
      case PetRecordType.weight: return _buildWeightFields(l10n);
      case PetRecordType.energy: return _buildEnergyFields(l10n);
      case PetRecordType.appetite: return _buildAppetiteFields(l10n);
      case PetRecordType.incident: return _buildIncidentFields(l10n);
      case PetRecordType.other: return _buildOtherFields(l10n);
    }
  }

  // 1. Medication
  Widget _buildMedicationFields(AppLocalizations l10n) {
    return Column(
      children: [
        _buildTextField(l10n.pet_field_drug_name, _nameController, required: true),
        const SizedBox(height: 12),
        _buildDropdown(
          label: l10n.pet_field_category,
          items: [
            l10n.pet_opt_continuous,
            l10n.pet_opt_wormer,
            l10n.pet_opt_flea,
            l10n.pet_opt_antibiotic,
          ],
          value: _category,
          onChanged: (v) => setState(() => _category = v),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTextField(l10n.pet_field_dosage, _amountController, keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField(l10n.pet_field_unit, _unitController, hint: 'mg, ml...')),
          ],
        ),
        const SizedBox(height: 12),
        _buildTimePicker(l10n),
        const SizedBox(height: 12),
        _buildTextField(l10n.pet_field_observation, _observationController, maxLines: 3),
      ],
    );
  }

  // 2. Weight
  Widget _buildWeightFields(AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTextField(l10n.pet_field_mass, _amountController, keyboardType: TextInputType.number, required: true)), // Reuse amount
            const SizedBox(width: 12),
            Expanded(child: _buildTextField(l10n.pet_field_unit, _unitController, hint: 'kg, g', required: true)),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(l10n.pet_field_location, _locationController, hint: 'Vet, Home...'),
        const SizedBox(height: 12),
        _buildImagePicker(l10n),
      ],
    );
  }

  // 3. Energy
  Widget _buildEnergyFields(AppLocalizations l10n) {
    return Column(
      children: [
        _buildDropdown(
          label: l10n.pet_field_energy_level,
          items: [
            l10n.pet_opt_low,
            l10n.pet_opt_normal,
            l10n.pet_opt_active,
            l10n.pet_opt_hyper,
          ],
          value: _level,
          onChanged: (v) => setState(() => _level = v),
        ),
        const SizedBox(height: 12),
        _buildDropdown(
          label: l10n.pet_field_period,
          items: [
            l10n.pet_opt_morning,
            l10n.pet_opt_afternoon,
            l10n.pet_opt_night,
            l10n.pet_opt_all_day,
          ],
          value: _period,
          onChanged: (v) => setState(() => _period = v),
        ),
        const SizedBox(height: 12),
        _buildTextField(l10n.pet_field_context, _contextController, maxLines: 2),
      ],
    );
  }

  // 4. Appetite
  Widget _buildAppetiteFields(AppLocalizations l10n) {
    return Column(
      children: [
        _buildDropdown(
          label: l10n.pet_field_consumption,
          items: [
            l10n.pet_opt_none,
            l10n.pet_opt_half,
            l10n.pet_opt_all,
          ],
          value: _consumption,
          onChanged: (v) => setState(() => _consumption = v),
        ),
        const SizedBox(height: 12),
        _buildDropdown(
          label: l10n.pet_field_thirst,
          items: [
            l10n.pet_opt_normal,
            l10n.pet_opt_reduced,
            l10n.pet_opt_excessive,
          ],
          value: _thirst,
          onChanged: (v) => setState(() => _thirst = v),
        ),
        const SizedBox(height: 12),
        _buildTextField(l10n.pet_field_diet_variation, _variationController),
      ],
    );
  }

  // 5. Incident
  Widget _buildIncidentFields(AppLocalizations l10n) {
    return Column(
      children: [
        _buildDropdown(
          label: l10n.pet_field_severity,
          items: [
            l10n.pet_opt_mild,
            l10n.pet_opt_moderate,
            l10n.pet_opt_urgent,
          ],
          value: _severity,
          onChanged: (v) => setState(() => _severity = v),
        ),
        const SizedBox(height: 12),
        _buildTextField(l10n.pet_field_description, _contextController, maxLines: 2, required: true),
        const SizedBox(height: 12),
        _buildTextField(l10n.pet_field_symptoms, _symptomsController, maxLines: 2),
        const SizedBox(height: 12),
        _buildTextField(l10n.pet_field_action_taken, _actionController),
      ],
    );
  }

  // 6. Other
  Widget _buildOtherFields(AppLocalizations l10n) {
    return Column(
      children: [
        _buildDropdown(
          label: l10n.pet_field_type,
          items: [
            l10n.pet_opt_hygiene,
            l10n.pet_opt_estrus,
            l10n.pet_opt_social,
          ],
          value: _otherType,
          onChanged: (v) => setState(() => _otherType = v),
        ),
        const SizedBox(height: 12),
        _buildTextField(l10n.pet_field_details, _contextController, maxLines: 3),
      ],
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, TextInputType? keyboardType, bool required = false, String? hint}) {
    final hasMic = maxLines > 1;
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: AppColors.petCardBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        suffixIcon: hasMic ? IconButton(
          icon: Icon(
            _activeVoiceController == controller ? Icons.mic : Icons.mic_none,
            color: _activeVoiceController == controller ? Colors.redAccent : Colors.grey,
          ),
          onPressed: () => _toggleVoiceInput(controller),
        ) : null,
      ),
      validator: required ? (v) => (v == null || v.isEmpty) ? '$label Required' : null : null,
    );
  }

  void _toggleVoiceInput(TextEditingController controller) async {
    if (_activeVoiceController == controller) {
      setState(() => _activeVoiceController = null);
      _speech.stop();
    } else {
      bool available = await _speech.initialize();
      if (available) {
        _previousText = controller.text;
        setState(() => _activeVoiceController = controller);
        
        _speech.listen(
          onResult: (val) {
            setState(() {
              final newText = val.recognizedWords;
              if (_previousText.isEmpty) {
                 controller.text = newText;
              } else {
                 controller.text = "$_previousText $newText";
              }
            });
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 5),
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.dictation,
        );
      } else {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(AppLocalizations.of(context)!.pet_journal_mic_permission_denied)),
           );
         }
      }
    }
  }

  Widget _buildDropdown({required String label, required List<String> items, required String? value, required ValueChanged<String?> onChanged}) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
      onChanged: onChanged,
      dropdownColor: AppColors.petBackgroundDark,
      selectedItemBuilder: (context) {
        return items.map((e) => Text(e, style: const TextStyle(color: Colors.white))).toList();
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: AppColors.petCardBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildTimePicker(AppLocalizations l10n) {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(context: context, initialTime: _selectedTime);
        if (time != null) setState(() => _selectedTime = time);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.pet_field_time,
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: AppColors.petCardBackground,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          suffixIcon: const Icon(Icons.access_time, color: Colors.white70),
        ),
        child: Text(_selectedTime.format(context), style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildImagePicker(AppLocalizations l10n) {
    return Column(
      children: [
        if (_selectedImage != null)
          Stack(
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_selectedImage!, height: 150, width: double.infinity, fit: BoxFit.cover)),
              Positioned(top: 8, right: 8, child: CircleAvatar(backgroundColor: Colors.black54, child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => setState(() => _selectedImage = null)))),
            ],
          ),
        if (_selectedImage != null) const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () async {
            final picker = ImagePicker();
            final xFile = await picker.pickImage(source: ImageSource.camera);
            if (xFile != null) {
              try {
                 await Gal.putImage(xFile.path);
                 if (kDebugMode) debugPrint('[GAL] Saved photo to gallery: ${xFile.path}');
              } catch (e) {
                 if (kDebugMode) debugPrint('[GAL_ERROR] Failed to save photo to gallery: $e');
              }
              setState(() => _selectedImage = File(xFile.path));
            }
          },
          icon: const Icon(Icons.camera_alt),
          label: Text(l10n.action_take_photo),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800], foregroundColor: Colors.white),
        ),
      ],
    );
  }

  // --- SAVE LOGIC ---

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final l10n = AppLocalizations.of(context)!;
      final now = DateTime.now();
      final eventDateTime = DateTime(
        now.year, now.month, now.day, 
        _selectedTime.hour, _selectedTime.minute
      );
      
      final metrics = <String, dynamic>{
        'source': 'journal',
      };
      
      PetEventType eventType = PetEventType.other;
      String title = '';
      String notes = '';

      switch (widget.recordType) {
        case PetRecordType.medication:
          eventType = PetEventType.health;
          title = '${l10n.pet_record_medication}: ${_nameController.text}';
          metrics['subtype'] = 'medication';
          metrics['drug_name'] = _nameController.text;
          metrics['category'] = _category;
          metrics['dosage'] = '${_amountController.text} ${_unitController.text}';
          metrics['observation'] = _observationController.text;
          notes = '${metrics['dosage']} - $_category\n${metrics['observation']}';
          break;
        case PetRecordType.weight:
          eventType = PetEventType.weight;
          title = '${l10n.pet_record_weight}: ${_amountController.text} ${_unitController.text}';
          metrics['subtype'] = 'weight';
          metrics['mass'] = double.tryParse(_amountController.text) ?? 0.0;
          metrics['unit'] = _unitController.text;
          metrics['location'] = _locationController.text;
          notes = '${metrics['location']}';
          break;
        case PetRecordType.energy:
          eventType = PetEventType.behavior;
          title = '${l10n.pet_record_energy}: $_level';
          metrics['subtype'] = 'energy';
          metrics['level'] = _level;
          metrics['period'] = _period;
          metrics['context'] = _contextController.text;
          notes = '$_period - ${_contextController.text}';
          break;
        case PetRecordType.appetite:
          eventType = PetEventType.food;
          title = '${l10n.pet_record_appetite}: $_consumption';
          metrics['subtype'] = 'appetite';
          metrics['consumption'] = _consumption;
          metrics['thirst'] = _thirst;
          metrics['diet_variation'] = _variationController.text;
          notes = 'Sede: $_thirst\nVar: ${_variationController.text}';
          break;
        case PetRecordType.incident:
          eventType = PetEventType.health;
          title = '${l10n.pet_record_incident}: $_severity';
          metrics['subtype'] = 'incident';
          metrics['severity'] = _severity;
          metrics['description'] = _contextController.text;
          metrics['symptoms'] = _symptomsController.text;
          metrics['action_taken'] = _actionController.text;
          notes = '${_contextController.text}\nSintomas: ${_symptomsController.text}\nAção: ${_actionController.text}';
          break;
        case PetRecordType.other:
          eventType = _otherType == l10n.pet_opt_hygiene 
              ? PetEventType.hygiene 
              : (_otherType == l10n.pet_opt_estrus ? PetEventType.health : PetEventType.behavior);
          title = _otherType ?? l10n.pet_record_other;
          metrics['subtype'] = 'other_${_otherType?.toLowerCase()}';
          notes = _contextController.text;
          break;
      }
      
      metrics['custom_title'] = title; // For display in timeline

      final event = PetEvent(
        id: const Uuid().v4(),
        petIds: [widget.petId],
        startDateTime: eventDateTime,
        endDateTime: eventDateTime,
        eventTypeIndex: eventType.index, // Using index from enum
        hasAIAnalysis: false,
        notes: notes,
        metrics: metrics,
        mediaPaths: _selectedImage != null ? [_selectedImage!.path] : null,
      );

      final result = await _repository.saveEvent(event);
      
      setState(() => _isLoading = false);
      
      if (result.isSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pet_record_save_success), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pet_record_save_error), backgroundColor: Colors.red));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }
}
