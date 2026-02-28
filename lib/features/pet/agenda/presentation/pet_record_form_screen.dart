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
import 'package:scannutplus/features/pet/services/pet_ai_service.dart';
import 'dart:convert';
import 'package:scannutplus/features/pet/agenda/presentation/pet_expense_history_screen.dart';
import 'package:scannutplus/features/pet/agenda/presentation/pet_expense_dashboard_screen.dart';
enum PetRecordType {
  medication, // 💊 Medicação
  weight,     // ⚖️ Peso
  energy,     // ⚡ Energia
  appetite,   // 🍽️ Apetite
  incident,   // ⚠️ Incidentes
  expense,    // 💰 Despesas
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
  
  DateTime _selectedDate = DateTime.now();
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
          if (widget.recordType == PetRecordType.expense)
            IconButton(
              icon: const Icon(Icons.history, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PetExpenseHistoryScreen(
                      petId: widget.petId,
                      petName: widget.petName,
                    ),
                  ),
                );
              },
            ),
          if (widget.recordType == PetRecordType.expense)
            IconButton(
              icon: const Icon(Icons.bar_chart, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PetExpenseDashboardScreen(
                      petId: widget.petId,
                      petName: widget.petName,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.petPrimary))
          : SingleChildScrollView(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
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
      case PetRecordType.expense: return l10n.pet_record_expense;
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
      case PetRecordType.expense: return _buildExpenseFields(l10n);
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
          hint: l10n.pet_field_category,
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
        _buildFieldWithTitle(l10n.pet_field_time, _buildTimePicker(l10n)),
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildFieldWithTitle(l10n.pet_record_date_label, _buildDatePicker(l10n))),
            const SizedBox(width: 12),
            Expanded(child: _buildFieldWithTitle(l10n.pet_field_time, _buildTimePicker(l10n))),
          ],
        ),
        _buildFieldWithTitle(
          l10n.pet_field_energy_level,
          _buildDropdown(
            hint: l10n.pet_field_energy_level,
            items: [
              l10n.pet_opt_low,
              l10n.pet_opt_normal,
              l10n.pet_opt_active,
              l10n.pet_opt_hyper,
            ],
            value: _level,
            onChanged: (v) => setState(() => _level = v),
          ),
        ),
        _buildFieldWithTitle(
          l10n.pet_field_period,
          _buildDropdown(
            hint: l10n.pet_field_period,
            items: [
              l10n.pet_opt_morning,
              l10n.pet_opt_afternoon,
              l10n.pet_opt_night,
              l10n.pet_opt_all_day,
            ],
            value: _period,
            onChanged: (v) => setState(() => _period = v),
          ),
        ),
        _buildFieldWithTitle(
          l10n.pet_field_context,
          _buildTextField("", _contextController, maxLines: 2, hint: l10n.pet_field_context),
        ),
      ],
    );
  }

  // 4. Appetite
  Widget _buildAppetiteFields(AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildFieldWithTitle(l10n.pet_record_date_label, _buildDatePicker(l10n))),
            const SizedBox(width: 12),
            Expanded(child: _buildFieldWithTitle(l10n.pet_field_time, _buildTimePicker(l10n))),
          ],
        ),
        _buildFieldWithTitle(
          l10n.pet_field_consumption,
          _buildDropdown(
            hint: l10n.pet_field_consumption,
            items: [
              l10n.pet_opt_none,
              l10n.pet_opt_half,
              l10n.pet_opt_all,
            ],
            value: _consumption,
            onChanged: (v) => setState(() => _consumption = v),
          ),
        ),
        _buildFieldWithTitle(
          l10n.pet_field_thirst,
          _buildDropdown(
            hint: l10n.pet_field_thirst,
            items: [
              l10n.pet_opt_normal,
              l10n.pet_opt_reduced,
              l10n.pet_opt_excessive,
            ],
            value: _thirst,
            onChanged: (v) => setState(() => _thirst = v),
          ),
        ),
        _buildFieldWithTitle(
          l10n.pet_field_diet_variation,
          _buildTextField("", _variationController, hint: l10n.pet_field_diet_variation),
        ),
      ],
    );
  }

  // 5. Incident
  Widget _buildIncidentFields(AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildFieldWithTitle(l10n.pet_record_date_label, _buildDatePicker(l10n))),
            const SizedBox(width: 12),
            Expanded(child: _buildFieldWithTitle(l10n.pet_field_time, _buildTimePicker(l10n))),
          ],
        ),
        _buildFieldWithTitle(
          l10n.pet_field_severity,
          _buildDropdown(
            hint: l10n.pet_field_severity,
            items: [
              l10n.pet_opt_mild,
              l10n.pet_opt_moderate,
              l10n.pet_opt_urgent,
            ],
            value: _severity,
            onChanged: (v) => setState(() => _severity = v),
          ),
        ),
        _buildFieldWithTitle(
          l10n.pet_field_description,
          _buildTextField("", _contextController, maxLines: 2, required: true, hint: l10n.pet_field_description),
        ),
        _buildFieldWithTitle(
          l10n.pet_field_symptoms,
          _buildTextField("", _symptomsController, maxLines: 2, hint: l10n.pet_field_symptoms),
        ),
        _buildFieldWithTitle(
          l10n.pet_field_action_taken,
          _buildTextField("", _actionController, hint: l10n.pet_field_action_taken),
        ),
      ],
    );
  }

  Widget _buildOtherFields(AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildFieldWithTitle(l10n.pet_record_date_label, _buildDatePicker(l10n))),
            const SizedBox(width: 12),
            Expanded(child: _buildFieldWithTitle(l10n.pet_field_time, _buildTimePicker(l10n))),
          ],
        ),
        _buildFieldWithTitle(
          l10n.pet_field_type,
          _buildDropdown(
            hint: l10n.pet_field_type,
            items: [
              l10n.pet_opt_hygiene,
              l10n.pet_opt_estrus,
              l10n.pet_opt_social,
            ],
            value: _otherType,
            onChanged: (v) => setState(() => _otherType = v),
          ),
        ),
        _buildFieldWithTitle(
          l10n.pet_field_details,
          _buildTextField("", _contextController, maxLines: 3, hint: l10n.pet_field_details),
        ),
      ],
    );
  }

  // 7. Expenses
  File? _expenseReceiptImage;
  bool _isAnalyzingExpense = false;

  Widget _buildFieldWithTitle(String title, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        field,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildExpenseFields(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. RECEIPT SCANNER (Replacing camera)
        if (_expenseReceiptImage != null) ...[
          Container(
             decoration: BoxDecoration(
               color: AppColors.petBackgroundDark,
               borderRadius: BorderRadius.circular(12),
               border: Border.all(color: AppColors.petPrimary, width: 2),
             ),
             child: ClipRRect(
               borderRadius: BorderRadius.circular(10),
               child: Stack(
                 alignment: Alignment.center,
                 children: [
                    Image.file(_expenseReceiptImage!, height: 180, width: double.infinity, fit: BoxFit.cover),
                    if (_isAnalyzingExpense)
                       Container(
                          color: AppColors.petBackgroundDark.withOpacity(0.7),
                          height: 180,
                          width: double.infinity,
                          child: const Center(
                             child: CircularProgressIndicator(color: AppColors.petPrimary)
                          )
                       ),
                 ]
               )
             )
          ),
          const SizedBox(height: 12),
        ] else ...[
           ElevatedButton.icon(
              onPressed: _isAnalyzingExpense ? null : () => _captureExpenseReceipt(l10n),
              icon: _isAnalyzingExpense ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 2)) : const Icon(Icons.qr_code_scanner, color: Colors.blue),
              label: Text(_isAnalyzingExpense ? "Analisando..." : "Escanear Recibo"),
              style: ElevatedButton.styleFrom(
                 backgroundColor: AppColors.petPrimary,
                 foregroundColor: Colors.black, // Enforce black text
                 padding: const EdgeInsets.symmetric(vertical: 16),
              )
           ),
           const SizedBox(height: 24),
        ],
        // 2. DATA
        _buildFieldWithTitle(
           l10n.pet_record_date_label, 
           _buildDatePicker(l10n, required: true)
        ),
        Row(
           children: [
              Expanded(flex: 3, child: _buildFieldWithTitle(l10n.pet_field_amount_money, _buildTextField("", _amountController, keyboardType: TextInputType.number, required: true, hint: l10n.pet_field_amount_money))), // Used for Amount
              const SizedBox(width: 12),
              Expanded(flex: 1, child: _buildFieldWithTitle(l10n.pet_field_currency, _buildTextField("", _unitController, required: true, hint: l10n.pet_field_currency))), // Used for Currency
           ],
        ),
        _buildFieldWithTitle(
           l10n.pet_field_description, 
           _buildTextField("", _contextController, maxLines: 2, required: true, hint: l10n.pet_field_description)
        ),
        _buildFieldWithTitle(
           l10n.pet_field_category,
           _buildDropdown(
             hint: l10n.pet_field_category, // Using category as hint
             items: [
               l10n.pet_expense_cat_food,
               l10n.pet_expense_cat_health,
               l10n.pet_expense_cat_hygiene,
               l10n.pet_expense_cat_meds,
               l10n.pet_expense_cat_treats,
               l10n.pet_expense_cat_services,
             ],
             value: _category,
             required: true, // Category is mandatory
             onChanged: (v) => setState(() => _category = v),
           )
        ),
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
        labelText: label.isEmpty ? null : label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.grey),
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: AppColors.petCardBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        suffixIcon: hasMic ? IconButton(
          icon: Icon(
            _activeVoiceController == controller ? Icons.mic : Icons.mic_none,
            color: _activeVoiceController == controller ? Colors.redAccent : Colors.blue,
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

  Widget _buildDropdown({required String hint, required List<String> items, required String? value, required ValueChanged<String?> onChanged, bool required = false}) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
      onChanged: onChanged,
      dropdownColor: AppColors.petBackgroundDark,
      icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
      selectedItemBuilder: (context) {
        return items.map((e) => Text(e, style: const TextStyle(color: Colors.white))).toList();
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: AppColors.petCardBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: required ? (v) => (v == null || v.isEmpty) ? 'Required' : null : null,
    );
  }

  Widget _buildDatePicker(AppLocalizations l10n, {bool required = false}) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context, 
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100)
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: FormField<DateTime>(
        initialValue: _selectedDate,
        validator: required ? (v) => v == null ? 'Required' : null : null,
        builder: (state) {
          return InputDecorator(
            decoration: InputDecoration(
              hintText: l10n.pet_record_date_label,
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: AppColors.petCardBackground,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              suffixIcon: const Icon(Icons.calendar_today, color: Colors.blue),
              errorText: state.hasError ? state.errorText : null,
            ),
            child: Text("${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}", style: const TextStyle(color: Colors.white)),
          );
        }
      ),
    );
  }

  Widget _buildTimePicker(AppLocalizations l10n, {bool required = false}) {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(context: context, initialTime: _selectedTime);
        if (time != null) setState(() => _selectedTime = time);
      },
      child: FormField<TimeOfDay>(
        initialValue: _selectedTime,
        validator: required ? (v) => v == null ? 'Required' : null : null,
        builder: (state) {
          return InputDecorator(
            decoration: InputDecoration(
              hintText: l10n.pet_field_time,
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: AppColors.petCardBackground,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              suffixIcon: const Icon(Icons.access_time, color: Colors.blue),
              errorText: state.hasError ? state.errorText : null,
            ),
            child: Text(_selectedTime.format(context), style: const TextStyle(color: Colors.white)),
          );
        }
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
      final eventDateTime = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day, 
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
        case PetRecordType.expense:
          eventType = PetEventType.other; 
          title = '${l10n.pet_record_expense}: ${_amountController.text} ${_unitController.text}';
          metrics['subtype'] = 'expense';
          metrics['amount'] = double.tryParse(_amountController.text) ?? 0.0;
          metrics['currency'] = _unitController.text;
          metrics['category'] = _category;
          metrics['description'] = _contextController.text;
          notes = '${metrics['currency']} ${metrics['amount']} - $_category\n${_contextController.text}';
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

  // --- GEMINI OCR LOGIC ---
  Future<void> _captureExpenseReceipt(AppLocalizations l10n) async {
     try {
        final picker = ImagePicker();
        final xFile = await picker.pickImage(source: ImageSource.camera);
        if (xFile == null) return;
        
        setState(() {
           _expenseReceiptImage = File(xFile.path);
           _isAnalyzingExpense = true;
        });

        // Delegate to AI service for generic document extraction (simulated context)
        final promptContext = '''
SCANNUT MASTER PROTOCOL 2026 - FINANCIAL OCR
OBJECTIVE: Extract expense data from receipt.
OUTPUT FORMAT: JSON ONLY
{
  "amount": 0.00,
  "currency": "R\$",
  "description": "Short summary",
  "category": "Saude"
}
Extract the total amount paid, currency symbol, summarize the items or service in description, and guess the category perfectly matching ONE of these (Alimentacao, Saude, Higiene, Medicamentos, Mimos, Servicos).
        ''';

        final petAiService = PetAiService();
        final resultOutput = await petAiService.analyzePetImageBase(
            imagePath: xFile.path, 
            petName: widget.petName,
            petUuid: widget.petId,
            languageCode: l10n.localeName, 
            context: promptContext, 
            imageBytes: await File(xFile.path).readAsBytes(),
            analysisType: "OCR Financeiro"
        );

        if (kDebugMode) debugPrint('[SCAN_NUT_EXP_OCR] Raw Output: $resultOutput');

        try {
           final cleanJson = resultOutput.replaceAll(RegExp(r'```(?:json)?|```'), '').trim();
           final Map<String, dynamic> data = jsonDecode(cleanJson);
           if (kDebugMode) debugPrint('[SCAN_NUT_EXP_OCR] Parsed JSON: $data');
           
           if (data.containsKey('amount') && data['amount'] != null) {
              _amountController.text = data['amount'].toString().replaceAll(',', '.');
           }
           if (data.containsKey('currency') && data['currency'] != null) {
              _unitController.text = data['currency'].toString();
           }
           if (data.containsKey('description') && data['description'] != null) {
              _contextController.text = data['description'].toString();
           }
           if (data.containsKey('category') && data['category'] != null) {
              final extractedCat = data['category'].toString();
              final validCategories = [
                 l10n.pet_expense_cat_food,
                 l10n.pet_expense_cat_health,
                 l10n.pet_expense_cat_hygiene,
                 l10n.pet_expense_cat_meds,
                 l10n.pet_expense_cat_treats,
                 l10n.pet_expense_cat_services,
              ];
              // Map AI guess to our strict subset
              if (validCategories.contains(extractedCat)) {
                 setState(() => _category = extractedCat);
              } else {
                 final catLower = extractedCat.toLowerCase();
                 setState(() {
                    if (catLower.contains("alimenta") || catLower.contains("food")) { _category = l10n.pet_expense_cat_food; }
                    else if (catLower.contains("saude") || catLower.contains("saúde") || catLower.contains("health") || catLower.contains("consulta")) { _category = l10n.pet_expense_cat_health; }
                    else if (catLower.contains("higiene") || catLower.contains("banho") || catLower.contains("estetica")) { _category = l10n.pet_expense_cat_hygiene; }
                    else if (catLower.contains("medicamento") || catLower.contains("remedio") || catLower.contains("meds")) { _category = l10n.pet_expense_cat_meds; }
                    else if (catLower.contains("mimo") || catLower.contains("brinquedo") || catLower.contains("treat")) { _category = l10n.pet_expense_cat_treats; }
                    else { _category = l10n.pet_expense_cat_services; } // Default fallback
                 });
              }
           }
           
           if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                 content: Text('Sucesso (JSON): ${_amountController.text} | $_category'), 
                 backgroundColor: Colors.green
              ));
           }

        } catch (e) {
           if (kDebugMode) debugPrint('[SCAN_NUT_EXP_OCR] JSON Parse Error: $e');
           
           // Fallback to tolerant regex if JSON fails
           final amtMatch = RegExp(r'"amount"\s*:\s*"?([\d.,]+)"?').firstMatch(resultOutput);
           final curMatch = RegExp(r'"currency"\s*:\s*"([^"]+)"').firstMatch(resultOutput);
           final descMatch = RegExp(r'"description"\s*:\s*"([^"]+)"').firstMatch(resultOutput);
           final catMatch = RegExp(r'"category"\s*:\s*"([^"]+)"').firstMatch(resultOutput);

           if (amtMatch != null) _amountController.text = amtMatch.group(1)?.replaceAll(',', '.') ?? '';
           if (curMatch != null) _unitController.text = curMatch.group(1) ?? '';
           if (descMatch != null) _contextController.text = descMatch.group(1) ?? '';
           
           final extractedCat = catMatch?.group(1) ?? '';
           final validCategories = [
              l10n.pet_expense_cat_food,
              l10n.pet_expense_cat_health,
              l10n.pet_expense_cat_hygiene,
              l10n.pet_expense_cat_meds,
              l10n.pet_expense_cat_treats,
              l10n.pet_expense_cat_services,
           ];
           
           if (validCategories.contains(extractedCat)) {
              setState(() => _category = extractedCat);
           } else {
              final catLower = extractedCat.toLowerCase();
              setState(() {
                 if (catLower.contains("alimenta") || catLower.contains("food")) { _category = l10n.pet_expense_cat_food; }
                 else if (catLower.contains("saude") || catLower.contains("saúde") || catLower.contains("health") || catLower.contains("consulta")) { _category = l10n.pet_expense_cat_health; }
                 else if (catLower.contains("higiene") || catLower.contains("banho") || catLower.contains("estetica")) { _category = l10n.pet_expense_cat_hygiene; }
                 else if (catLower.contains("medicamento") || catLower.contains("remedio") || catLower.contains("meds")) { _category = l10n.pet_expense_cat_meds; }
                 else if (catLower.contains("mimo") || catLower.contains("brinquedo") || catLower.contains("treat")) { _category = l10n.pet_expense_cat_treats; }
                 else { _category = l10n.pet_expense_cat_services; } // Default fallback
              });
           }

           if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                 content: Text('Aviso (Regex): Falha JSON. Dados: ${_amountController.text}'), 
                 backgroundColor: Colors.orange
              ));
           }
        }

     } catch (e) {
         if (kDebugMode) debugPrint('[SCAN_NUT_EXP_OCR] Error: $e');
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Falha ao analisar: $e"), backgroundColor: Colors.red));
         }
     } finally {
         if (mounted) setState(() => _isAnalyzingExpense = false);
     }
  }

}
