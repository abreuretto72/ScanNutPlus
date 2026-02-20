import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/features/pet/data/models/pet_event_type.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/pet/agenda/pet_event.dart';
import 'package:scannutplus/pet/agenda/pet_event_repository.dart';
import 'package:scannutplus/features/pet/agenda/logic/pet_notification_manager.dart';
import 'package:scannutplus/features/pet/agenda/presentation/pet_scheduled_events_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class PetAppointmentScreen extends StatefulWidget {
  final String petId;
  final String petName;

  const PetAppointmentScreen({
    super.key,
    required this.petId,
    required this.petName,
  });

  @override
  State<PetAppointmentScreen> createState() => _PetAppointmentScreenState();
}

class _PetAppointmentScreenState extends State<PetAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _professionalController = TextEditingController(); // Doctor or Place
  final _partnerContactController = TextEditingController();
  final _partnerPhoneController = TextEditingController();
  final _partnerWhatsappController = TextEditingController();
  final _partnerEmailController = TextEditingController();
  final _partnerNotesController = TextEditingController(); // Added per user request
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  String _selectedCategory = 'health'; // Default Category
  String _selectedType = 'consultation_general'; // Default Type
  String _selectedLeadTime = 'none'; // Default notification preference

  // Categories Keys
  final List<String> _categories = [
    'health', 'wellness', 'behavior', 'services', 'docs'
  ];

  // Map Category -> List of Types
  final Map<String, List<String>> _typesByCategory = {
    'health': [
      'consultation_general', 'consultation_return', 'consultation_specialist', 'consultation_tele',
      'vaccine_annual', 'vaccine_specific', 'vaccine_booster',
      'exam_blood', 'exam_ultrasound', 'exam_xray', 'exam_lab', 'exam_periodic',
      'procedure_castration', 'procedure_surgery', 'procedure_dental', 'procedure_dressing',
      'treatment_physio', 'treatment_acu', 'treatment_chemo', 'treatment_hemo'
    ],
    'wellness': [
      'wellness_bath', 'wellness_grooming', 'wellness_hygienic', 'wellness_hydration',
      'wellness_daycare', 'wellness_hotel'
    ],
    'behavior': [
      'behavior_training', 'behavior_evaluation', 'behavior_social'
    ],
    'nutrition': [
      'nutrition_meal', 'nutrition_food_change', 'service_nutrition', 'service_mealplan'
    ],
    'services': [
      'service_taxi', 'service_delivery'
    ],
    'docs': [
      'doc_vaccine_card', 'doc_health_cert', 'doc_microchip', 'doc_gta', 'doc_travel'
    ]
  };

  bool _isLoading = false;
  
  final stt.SpeechToText _speech = stt.SpeechToText();
  TextEditingController? _activeVoiceController;

  @override
  void dispose() {
    _titleController.dispose();
    _professionalController.dispose();
    _partnerContactController.dispose();
    _partnerPhoneController.dispose();
    _partnerWhatsappController.dispose();
    _partnerEmailController.dispose();
    _partnerNotesController.dispose();
    _notesController.dispose();
    _speech.cancel();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(), // Future appointments usually
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.petPrimary,
              onPrimary: Colors.black,
              surface: AppColors.petBackgroundDark,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.petPrimary,
              onPrimary: Colors.black,
              surface: AppColors.petBackgroundDark,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final l10n = AppLocalizations.of(context)!;
    
    try {
      final startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      
      // Determine EventType and Icon
      // Health Category -> PetEventType.health (Medical Icon)
      // Nutrition Category -> PetEventType.food (Food Icon)
      // Others -> PetEventType.appointment (Calendar Icon)
      int eventTypeIndex;
      if (_selectedCategory == 'health') {
        eventTypeIndex = PetEventType.health.index;
      } else if (_selectedCategory == 'nutrition') {
        eventTypeIndex = PetEventType.food.index;
      } else {
        eventTypeIndex = PetEventType.appointment.index;
      }

      String typeLabel = _getLabelForType(l10n, _selectedType);
      
      // If user typed a custom title, use it. Otherwise use Type + Professional
      String customTitle = _titleController.text.trim();
      if (customTitle.isEmpty) {
        customTitle = "$typeLabel (${_professionalController.text.trim()})";
      }

      final newEvent = PetEvent(
        id: const Uuid().v4(),
        startDateTime: startDateTime,
        endDateTime: startDateTime.add(const Duration(hours: 1)), // Default 1h duration
        petIds: [widget.petId],
        eventTypeIndex: eventTypeIndex,
        hasAIAnalysis: false,
        notes: _notesController.text,
        metrics: {
          'custom_title': customTitle, 
          'appointment_type': _selectedType,
          'professional': _professionalController.text.trim(),
          'partner_contact': _partnerContactController.text.trim(),
          'partner_phone': _partnerPhoneController.text.trim(),
          'partner_whatsapp': _partnerWhatsappController.text.trim(),
          'partner_email': _partnerEmailController.text.trim(),
          'partner_notes': _partnerNotesController.text.trim(), // Save the new notes field
          'is_appointment': true,
          'notification_lead_time': _selectedLeadTime,
          'source': 'appointment', // Origin: Appointment (Compromisso)
        },
        address: null, // Could add address field later if needed
      );

      final repository = PetEventRepository();
      await repository.saveEvent(newEvent);

      // Schedule Notification
      await PetNotificationManager().scheduleNotification(newEvent, _selectedLeadTime);

      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(l10n.pet_appointment_save_success), backgroundColor: Colors.green),
        );
        // Navigate to Scheduled Events List instead of popping
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PetScheduledEventsScreen(petId: widget.petId)),
        );
      }
      
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(l10n.pet_error_saving_event(e.toString())), backgroundColor: Colors.red),
         );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _previousText = '';

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.petBackgroundDark,
        appBar: AppBar(
          title: Text(l10n.pet_appointment_screen_title, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
             IconButton(
               icon: const Icon(Icons.event_available, color: AppColors.petPrimary),
               tooltip: l10n.pet_scheduled_list_title,
               onPressed: () {
                 Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => PetScheduledEventsScreen(petId: widget.petId)),
                 );
               },
             ),
          ],
          bottom: TabBar(
            indicatorColor: AppColors.petPrimary,
            labelColor: AppColors.petPrimary,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: l10n.pet_appointment_tab_data, icon: const Icon(Icons.calendar_today)),
              Tab(text: l10n.pet_appointment_tab_partner, icon: const Icon(Icons.store)),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: TabBarView(
                  children: [
                    // TAB 1: APPOINTMENT DATA
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // CATEGORY DROPDOWN
                          DropdownButtonFormField<String>(
                            // ignore: deprecated_member_use
                            value: _selectedCategory,
                            isExpanded: true,
                            decoration: _inputDecoration(l10n.pet_apt_select_category, Icons.category),
                            dropdownColor: Colors.grey[850],
                            style: const TextStyle(color: Colors.white),
                            items: [
                              DropdownMenuItem(value: 'health', child: Text(l10n.pet_appointment_cat_health)),
                              DropdownMenuItem(value: 'nutrition', child: Text(l10n.pet_appointment_cat_nutrition)),
                              DropdownMenuItem(value: 'wellness', child: Text(l10n.pet_appointment_cat_wellness)),
                              DropdownMenuItem(value: 'behavior', child: Text(l10n.pet_appointment_cat_behavior)),
                              DropdownMenuItem(value: 'services', child: Text(l10n.pet_appointment_cat_services)),
                              DropdownMenuItem(value: 'docs', child: Text(l10n.pet_appointment_cat_docs)),
                            ],
                            onChanged: (val) {
                               if (val != null && val != _selectedCategory) {
                                 setState(() {
                                   _selectedCategory = val;
                                   _selectedType = _typesByCategory[val]?.first ?? 'consultation_general'; 
                                 });
                               }
                            },
                          ),
                          const SizedBox(height: 16),

                          // SUB-TYPE DROPDOWN
                          DropdownButtonFormField<String>(
                            // ignore: deprecated_member_use
                            value: _selectedType,
                            isExpanded: true,
                            decoration: _inputDecoration(l10n.pet_apt_select_type, Icons.info_outline),
                            dropdownColor: Colors.grey[850],
                            style: const TextStyle(color: Colors.white),
                            items: _typesByCategory[_selectedCategory]?.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(_getLabelForType(l10n, type)),
                              );
                            }).toList() ?? [],
                            onChanged: (val) => setState(() => _selectedType = val!),
                          ),
                          const SizedBox(height: 16),

                          // "WHAT TO DO?" (TITLE)
                          TextFormField(
                            controller: _titleController,
                            decoration: _inputDecoration(l10n.pet_field_what_to_do, Icons.edit).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _activeVoiceController == _titleController ? Icons.mic : Icons.mic_none,
                                  color: _activeVoiceController == _titleController ? Colors.redAccent : Colors.grey,
                                ),
                                onPressed: () => _toggleVoiceInput(_titleController),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 16),

                          // DATE & TIME
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectDate(context),
                                  child: InputDecorator(
                                    decoration: _inputDecoration(l10n.pet_agenda_event_date, Icons.calendar_today),
                                    child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: const TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectTime(context),
                                  child: InputDecorator(
                                    decoration: _inputDecoration(l10n.pet_field_time, Icons.access_time),
                                    child: Text(_selectedTime.format(context), style: const TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // NOTIFICATION
                          DropdownButtonFormField<String>(
                            value: _selectedLeadTime,
                            decoration: _inputDecoration(l10n.pet_notification_label, Icons.notifications),
                            dropdownColor: Colors.grey[850],
                            style: const TextStyle(color: Colors.white),
                            items: [
                               DropdownMenuItem(value: 'none', child: Text(l10n.pet_notification_none)),
                               DropdownMenuItem(value: '1h', child: Text(l10n.pet_notification_1h)),
                               DropdownMenuItem(value: '2h', child: Text(l10n.pet_notification_2h)),
                               DropdownMenuItem(value: '1d', child: Text(l10n.pet_notification_1d)),
                               DropdownMenuItem(value: '1w', child: Text(l10n.pet_notification_1w)),
                            ],
                            onChanged: (val) => setState(() => _selectedLeadTime = val!),
                          ),
                          const SizedBox(height: 16),

                          // "WHAT WAS DONE?" (NOTES)
                          TextFormField(
                            controller: _notesController,
                            decoration: _inputDecoration(l10n.pet_field_what_was_done, Icons.assignment_turned_in).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _activeVoiceController == _notesController ? Icons.mic : Icons.mic_none,
                                  color: _activeVoiceController == _notesController ? Colors.redAccent : Colors.grey,
                                ),
                                onPressed: () => _toggleVoiceInput(_notesController),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),

                    // TAB 2: PARTNER DATA
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                         crossAxisAlignment: CrossAxisAlignment.stretch,
                         children: [
                            TextFormField(
                              controller: _professionalController,
                              decoration: _inputDecoration(l10n.pet_field_partner_name, Icons.business),
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _partnerContactController,
                              decoration: _inputDecoration(l10n.pet_field_contact_person, Icons.person),
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _partnerPhoneController,
                              decoration: _inputDecoration(l10n.pet_field_phone, Icons.phone),
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _partnerWhatsappController,
                              decoration: _inputDecoration(l10n.pet_field_whatsapp, Icons.chat),
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _partnerEmailController,
                              decoration: _inputDecoration(l10n.pet_field_email, Icons.email),
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _partnerNotesController,
                              decoration: _inputDecoration(l10n.pet_field_what_was_done, Icons.notes).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _activeVoiceController == _partnerNotesController ? Icons.mic : Icons.mic_none,
                                    color: _activeVoiceController == _partnerNotesController ? Colors.redAccent : Colors.grey,
                                  ),
                                  onPressed: () => _toggleVoiceInput(_partnerNotesController),
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                              maxLines: 3,
                            ),
                         ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // BOTTOM SAVING BAR (STANDARD APP STYLE)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.petBackgroundDark,
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.petPrimary,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _isLoading ? null : _saveAppointment,
                    icon: _isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) 
                        : const Icon(Icons.check, color: Colors.black),
                    label: Text(
                      l10n.common_save, 
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLabelForType(AppLocalizations l10n, String type) {
    switch(type) {
      // Health
      case 'consultation_general': return l10n.pet_apt_consultation_general;
      case 'consultation_return': return l10n.pet_apt_consultation_return;
      case 'consultation_specialist': return l10n.pet_apt_consultation_specialist;
      case 'consultation_tele': return l10n.pet_apt_consultation_tele;
      case 'vaccine_annual': return l10n.pet_apt_vaccine_annual;
      case 'vaccine_specific': return l10n.pet_apt_vaccine_specific;
      case 'vaccine_booster': return l10n.pet_apt_vaccine_booster;
      case 'exam_blood': return l10n.pet_apt_exam_blood;
      case 'exam_ultrasound': return l10n.pet_apt_exam_ultrasound;
      case 'exam_xray': return l10n.pet_apt_exam_xray;
      case 'exam_lab': return l10n.pet_apt_exam_lab;
      case 'exam_periodic': return l10n.pet_apt_exam_periodic;
      case 'procedure_castration': return l10n.pet_apt_procedure_castration;
      case 'procedure_surgery': return l10n.pet_apt_procedure_surgery;
      case 'procedure_dental': return l10n.pet_apt_procedure_dental;
      case 'procedure_dressing': return l10n.pet_apt_procedure_dressing;
      case 'treatment_physio': return l10n.pet_apt_treatment_physio;
      case 'treatment_acu': return l10n.pet_apt_treatment_acu;
      case 'treatment_chemo': return l10n.pet_apt_treatment_chemo;
      case 'treatment_hemo': return l10n.pet_apt_treatment_hemo;
      
      // Wellness
      case 'wellness_bath': return l10n.pet_apt_wellness_bath;
      case 'wellness_grooming': return l10n.pet_apt_wellness_grooming;
      case 'wellness_hygienic': return l10n.pet_apt_wellness_hygienic;
      case 'wellness_hydration': return l10n.pet_apt_wellness_hydration;
      case 'wellness_daycare': return l10n.pet_apt_wellness_daycare;
      case 'wellness_hotel': return l10n.pet_apt_wellness_hotel;

      // Behavior
      case 'behavior_training': return l10n.pet_apt_behavior_training;
      case 'behavior_evaluation': return l10n.pet_apt_behavior_evaluation;
      case 'behavior_social': return l10n.pet_apt_behavior_social;

      // Nutrition
      case 'nutrition_meal': return l10n.pet_apt_nutrition_meal;
      case 'nutrition_food_change': return l10n.pet_apt_nutrition_food_change;

      // Services
      case 'service_taxi': return l10n.pet_apt_service_taxi;
      case 'service_delivery': return l10n.pet_apt_service_delivery;
      case 'service_nutrition': return l10n.pet_apt_service_nutrition;
      case 'service_mealplan': return l10n.pet_apt_service_mealplan;

      // Docs
      case 'doc_vaccine_card': return l10n.pet_apt_doc_vaccine_card;
      case 'doc_health_cert': return l10n.pet_apt_doc_health_cert;
      case 'doc_microchip': return l10n.pet_apt_doc_microchip;
      case 'doc_gta': return l10n.pet_apt_doc_gta;
      case 'doc_travel': return l10n.pet_apt_doc_travel;

      default: return l10n.pet_apt_consultation_general;
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: AppColors.petPrimary),
      filled: true,
      fillColor: Colors.black26,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.petPrimary)),
    );
  }
}
