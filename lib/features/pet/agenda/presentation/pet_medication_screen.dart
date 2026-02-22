import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/pet/agenda/pet_event_repository.dart';
import 'package:scannutplus/features/pet/agenda/logic/pet_medication_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class PetMedicationScreen extends StatefulWidget {
  final String petId;
  final String petName;
  
  const PetMedicationScreen({
    super.key,
    required this.petId,
    required this.petName,
  });

  @override
  State<PetMedicationScreen> createState() => _PetMedicationScreenState();
}

class _PetMedicationScreenState extends State<PetMedicationScreen> {
  final _drugNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _durationController = TextEditingController(text: '7');
  final _intervalController = TextEditingController(text: '12');
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  String _selectedRoute = ''; // Defined later via l10n
  String _selectedUnit = 'mg';
  
  bool _isLoading = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _previousText = '';

  @override
  void dispose() {
    _drugNameController.dispose();
    _dosageController.dispose();
    _durationController.dispose();
    _intervalController.dispose();
    _notesController.dispose();
    _speech.cancel();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  void _showActionSheet(String title, List<String> options, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.petBackgroundDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ...options.map((option) => ListTile(
                title: Text(option, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                onTap: () {
                  onSelect(option);
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: 16),
            ],
          ),
        );
      }
    );
  }

  void _toggleVoiceInput() async {
    if (_isListening) {
      setState(() => _isListening = false);
      _speech.stop();
    } else {
      bool available = await _speech.initialize();
      if (available) {
        _previousText = _notesController.text;
        setState(() => _isListening = true);
        
        _speech.listen(
          onResult: (val) {
            setState(() {
              final newText = val.recognizedWords;
              if (_previousText.isEmpty) {
                 _notesController.text = newText;
              } else {
                 _notesController.text = "$_previousText $newText";
              }
            });
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 5),
          partialResults: true,
          // ignore: deprecated_member_use
          cancelOnError: true,
          // ignore: deprecated_member_use
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

  Future<void> _saveMedication() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (_drugNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pet_med_empty_error), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final service = PetMedicationService(PetEventRepository());
      
      await service.scheduleTreatment(
        petId: widget.petId,
        drugName: _drugNameController.text.trim(),
        dosage: _dosageController.text.trim(),
        unit: _selectedUnit,
        route: _selectedRoute.isEmpty ? l10n.pet_med_oral : _selectedRoute,
        observation: _notesController.text.trim(),
        durationDays: int.tryParse(_durationController.text) ?? 1,
        intervalHours: int.tryParse(_intervalController.text) ?? 24,
        startDate: startDateTime,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.pet_med_success), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildLabeledField(String labelText, Widget child) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(padding: const EdgeInsets.only(top: 10), child: child),
        Positioned(
          left: 24, top: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
            child: Text(labelText.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.0)),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      hintText: labelText,
      hintStyle: const TextStyle(color: Colors.black54),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      prefixIcon: Icon(icon, color: Colors.black),
      filled: true,
      fillColor: const Color(0xFFFFD1DC), // Pet domain color (#FFD1DC)
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black, width: 3)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black, width: 3)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black, width: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedRoute.isEmpty) _selectedRoute = l10n.pet_med_oral;

    return Scaffold(
      backgroundColor: AppColors.petBackgroundDark,
      appBar: AppBar(
        title: Text(l10n.pet_med_drug_name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFFFFD1DC),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLabeledField(l10n.pet_med_drug_name, TextFormField(
                    controller: _drugNameController,
                    style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: _inputDecoration(l10n.pet_med_drug_name, Icons.medication),
                  )),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildLabeledField(l10n.pet_med_dosage, TextFormField(
                          controller: _dosageController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                          decoration: _inputDecoration(l10n.pet_med_dosage, Icons.science),
                        )),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () => _showActionSheet(l10n.pet_med_unit, ['mg', 'ml', 'gotas', 'comp', 'cp', 'UI'], (val) => setState(() => _selectedUnit = val)),
                          child: _buildLabeledField(l10n.pet_med_unit, InputDecorator(
                            decoration: _inputDecoration(l10n.pet_med_unit, Icons.scale),
                            child: Text(_selectedUnit, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                          )),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  InkWell(
                    onTap: () => _showActionSheet(l10n.pet_med_route, [l10n.pet_med_oral, l10n.pet_med_injectable, l10n.pet_med_topical, l10n.pet_med_drops], (val) => setState(() => _selectedRoute = val)),
                    child: _buildLabeledField(l10n.pet_med_route, InputDecorator(
                      decoration: _inputDecoration(l10n.pet_med_route, Icons.route),
                      child: Text(_selectedRoute, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                    )),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildLabeledField(l10n.pet_med_duration, TextFormField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                          decoration: _inputDecoration(l10n.pet_med_duration, Icons.date_range),
                        )),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildLabeledField(l10n.pet_med_interval, TextFormField(
                          controller: _intervalController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                          decoration: _inputDecoration(l10n.pet_med_interval, Icons.timer),
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context),
                          child: _buildLabeledField(l10n.pet_agenda_event_date, InputDecorator(
                            decoration: _inputDecoration(l10n.pet_agenda_event_date, Icons.calendar_today),
                            child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: const TextStyle(color: Colors.black, fontSize: 16)),
                          )),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectTime(context),
                          child: _buildLabeledField(l10n.pet_field_time, InputDecorator(
                            decoration: _inputDecoration(l10n.pet_field_time, Icons.access_time),
                            child: Text(_selectedTime.format(context), style: const TextStyle(color: Colors.black, fontSize: 16)),
                          )),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildLabeledField(l10n.pet_field_observation, TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    decoration: _inputDecoration(l10n.pet_field_observation, Icons.edit).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening ? Colors.redAccent : Colors.black,
                        ),
                        onPressed: _toggleVoiceInput,
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
          
          // BOTTOM SAVING BAR 
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.petBackgroundDark,
              border: Border(top: BorderSide(color: Colors.black, width: 3)),
            ),
            child: SafeArea(
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF10AC84), // Requested standard green
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _isLoading ? null : _saveMedication,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isLoading)
                          const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                        else
                          const Icon(Icons.check_circle_outline, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          l10n.pet_med_save.toUpperCase(), 
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
