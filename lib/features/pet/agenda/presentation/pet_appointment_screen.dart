import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/features/pet/data/models/pet_event_type.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/pet/agenda/pet_event.dart';
import 'package:scannutplus/pet/agenda/pet_event_repository.dart';
import 'package:scannutplus/features/pet/agenda/logic/pet_notification_manager.dart';
import 'package:scannutplus/features/pet/agenda/presentation/pet_scheduled_events_screen.dart';
import 'package:scannutplus/features/pet/agenda/presentation/pet_partner_selection_screen.dart';
import 'package:scannutplus/features/pet/agenda/data/models/partner_model.dart';
import 'package:uuid/uuid.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class PetAppointmentScreen extends StatefulWidget {
  final String petId;
  final String petName;
  final PetEvent? existingEvent; // Allows passing an old event to edit it

  const PetAppointmentScreen({
    super.key,
    required this.petId,
    required this.petName,
    this.existingEvent,
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

  List<String> _existingPartners = [];
  String? _selectedPartner; // Initially null, will be set in initState if list isn't empty
  bool _isNewPartner = false;


  bool _isLoading = false;
  
  final stt.SpeechToText _speech = stt.SpeechToText();
  TextEditingController? _activeVoiceController;

  @override
  void initState() {
    super.initState();
    _loadExistingPartners();
    
    // Popula dados se for edição
    if (widget.existingEvent != null) {
      final ev = widget.existingEvent!;
      _selectedDate = ev.startDateTime;
      _selectedTime = TimeOfDay.fromDateTime(ev.startDateTime);
      _titleController.text = ev.metrics?['custom_title'] ?? '';
      _professionalController.text = ev.metrics?['professional'] ?? '';
      _notesController.text = ev.notes ?? '';
      _partnerPhoneController.text = ev.metrics?['partner_phone'] ?? '';
      _selectedCategory = ev.metrics?['category'] ?? 'health';
      _selectedType = ev.metrics?['type'] ?? 'consultation_general';
      _isNewPartner = (ev.metrics?['is_new_partner'] == true);
      _selectedLeadTime = ev.metrics?['notification_lead_time'] ?? '2 horas antes';
    }
  }

  Future<void> _loadExistingPartners() async {
    final repo = PetEventRepository();
    final result = await repo.getByPetId(widget.petId);
    
    final Set<String> partnersSet = {};
    if (result.isSuccess && result.data != null) {
      for (var ev in result.data!) {
         final prof = ev.metrics?['professional']?.toString().trim();
         if (prof != null && prof.isNotEmpty) {
             partnersSet.add(prof);
         }
      }
    }
    
    if (mounted) {
       setState(() {
          _existingPartners = partnersSet.toList()..sort();
          if (_existingPartners.isNotEmpty) {
             // We do NOT set _selectedPartner automatically to avoid saving wrong partner by accident.
             // It will default to null (hint: "Select").
          }
       });
    }
  }

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
    
    final l10n = AppLocalizations.of(context)!;
    
    final finalPartnerName = _isNewPartner ? _professionalController.text.trim() : (_selectedPartner ?? '');
    
    if (finalPartnerName.isEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.petBackgroundDark,
          title: Text(l10n.pet_appointment_no_partner_title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          content: Text(l10n.pet_appointment_no_partner_msg, style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.common_cancel, style: const TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.pet_appointment_no_partner_confirm, style: const TextStyle(color: AppColors.petPrimary)),
            ),
          ],
        )
      );
      if (confirm != true) return;
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
        id: widget.existingEvent?.id ?? const Uuid().v4(),
        startDateTime: startDateTime,
        endDateTime: startDateTime.add(const Duration(hours: 1)), // Default 1h duration
        petIds: [widget.petId],
        eventTypeIndex: eventTypeIndex,
        hasAIAnalysis: false,
        notes: _notesController.text,
        metrics: {
          'custom_title': customTitle, 
          'appointment_type': _selectedType,
          'professional': finalPartnerName,
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
        Navigator.pop(context, true);
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
          title: Text(l10n.pet_appointment_screen_title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
             IconButton(
               icon: const Icon(Icons.event_available, color: AppColors.petPrimary),
               tooltip: l10n.pet_scheduled_list_title,
               onPressed: () {
                 Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => PetScheduledEventsScreen(petId: widget.petId, petName: widget.petName)),
                 );
               },
             ),
          ],
          bottom: TabBar(
            indicatorWeight: 4,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: AppColors.petPrimary, // Rosa Pastel
            labelColor: Colors.white,
            labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
            unselectedLabelColor: Colors.white54,
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: l10n.pet_appointment_tab_data.toUpperCase(), icon: const Icon(Icons.calendar_today, size: 20)),
              Tab(text: l10n.pet_appointment_tab_partner.toUpperCase(), icon: const Icon(Icons.store, size: 20)),
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
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                            decoration: _inputDecoration(l10n.pet_apt_select_category, Icons.category),
                            dropdownColor: AppColors.petPrimary,
                            style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                            items: [
                              DropdownMenuItem(value: 'health', child: Text(l10n.pet_appointment_cat_health, style: const TextStyle(color: Colors.black))),
                              DropdownMenuItem(value: 'nutrition', child: Text(l10n.pet_appointment_cat_nutrition, style: const TextStyle(color: Colors.black))),
                              DropdownMenuItem(value: 'wellness', child: Text(l10n.pet_appointment_cat_wellness, style: const TextStyle(color: Colors.black))),
                              DropdownMenuItem(value: 'behavior', child: Text(l10n.pet_appointment_cat_behavior, style: const TextStyle(color: Colors.black))),
                              DropdownMenuItem(value: 'services', child: Text(l10n.pet_appointment_cat_services, style: const TextStyle(color: Colors.black))),
                              DropdownMenuItem(value: 'docs', child: Text(l10n.pet_appointment_cat_docs, style: const TextStyle(color: Colors.black))),
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
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                            decoration: _inputDecoration(l10n.pet_apt_select_type, Icons.info_outline),
                            dropdownColor: AppColors.petPrimary,
                            style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                            items: _typesByCategory[_selectedCategory]?.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(_getLabelForType(l10n, type), style: const TextStyle(color: Colors.black)),
                              );
                            }).toList() ?? [],
                            onChanged: (val) => setState(() => _selectedType = val!),
                          ),
                          const SizedBox(height: 16),

                          // "WHAT TO DO?" (TITLE)
                          TextFormField(
                            controller: _titleController,
                            style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                            decoration: _inputDecoration(l10n.pet_field_what_to_do, Icons.edit).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _activeVoiceController == _titleController ? Icons.mic : Icons.mic_none,
                                  color: _activeVoiceController == _titleController ? Colors.redAccent : Colors.black87,
                                  size: 20,
                                ),
                                onPressed: () => _toggleVoiceInput(_titleController),
                              ),
                            ),
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
                                    child: Text(DateFormat.yMd(Localizations.localeOf(context).languageCode).format(_selectedDate), style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectTime(context),
                                  child: InputDecorator(
                                    decoration: _inputDecoration(l10n.pet_field_time, Icons.access_time),
                                    child: Text(_selectedTime.format(context), style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // NOTIFICATION
                          DropdownButtonFormField<String>(
                            initialValue: _selectedLeadTime,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                            decoration: _inputDecoration(l10n.pet_notification_label, Icons.notifications),
                            dropdownColor: AppColors.petPrimary,
                            style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                            items: [
                               DropdownMenuItem(value: 'none', child: Text(l10n.pet_notification_none, style: const TextStyle(color: Colors.black))),
                               DropdownMenuItem(value: '1h', child: Text(l10n.pet_notification_1h, style: const TextStyle(color: Colors.black))),
                               DropdownMenuItem(value: '2h', child: Text(l10n.pet_notification_2h, style: const TextStyle(color: Colors.black))),
                               DropdownMenuItem(value: '1d', child: Text(l10n.pet_notification_1d, style: const TextStyle(color: Colors.black))),
                               DropdownMenuItem(value: '1w', child: Text(l10n.pet_notification_1w, style: const TextStyle(color: Colors.black))),
                            ],
                            onChanged: (val) => setState(() => _selectedLeadTime = val!),
                          ),
                          const SizedBox(height: 16),
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
                            // PARTNER DROPDOWN
                            DropdownButtonFormField<String>(
                              initialValue: _selectedPartner,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                              decoration: _inputDecoration(l10n.pet_field_partner_name, Icons.business),
                              dropdownColor: AppColors.petPrimary,
                              style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                              hint: Text(l10n.pet_field_partner_name, style: const TextStyle(color: Colors.black54)),
                              items: [
                                DropdownMenuItem(
                                  value: 'NEW_PARTNER',
                                  child: Text(
                                    l10n.pet_appointment_new_partner,
                                    style: const TextStyle(color: Color(0xFFC2185B), fontWeight: FontWeight.w900), // Dark Pink (50% darker)
                                  ),
                                ),
                                ..._existingPartners.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(color: Colors.black)))),
                              ],
                              validator: (val) {
                                if (val == null || val.isEmpty) return null; // We prompt with dialog if empty
                                return null;
                              },
                              onChanged: (val) {
                                setState(() {
                                   _selectedPartner = val;
                                   _isNewPartner = (val == 'NEW_PARTNER');
                                   if (!_isNewPartner) {
                                      _professionalController.text = val ?? ''; 
                                   } else {
                                      _professionalController.clear();
                                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                                        final Partner? result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const PetPartnerSelectionScreen()),
                                        );
                                        if (result != null && mounted) {
                                           setState(() {
                                              _professionalController.text = result.name;
                                              if (result.address.isNotEmpty) _partnerContactController.text = result.address;
                                              if (result.phoneNumber != null) _partnerPhoneController.text = result.phoneNumber!;
                                           });
                                        }
                                      });
                                   }
                                });
                              },
                            ),
                            
                            // CONDITIONAL NEW PARTNER LOGIC
                            if (_isNewPartner) ...[
                               const SizedBox(height: 16),
                               TextFormField(
                                  controller: _professionalController,
                                  decoration: _inputDecoration("${l10n.pet_appointment_new_partner} *", Icons.edit),
                                  style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                               ),
                            ],

                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _partnerContactController,
                              decoration: _inputDecoration(l10n.pet_field_contact_person, Icons.person),
                              style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _partnerPhoneController,
                              decoration: _inputDecoration(l10n.pet_field_phone, Icons.phone),
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _partnerWhatsappController,
                              decoration: _inputDecoration(l10n.pet_field_whatsapp, Icons.chat),
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _partnerEmailController,
                              decoration: _inputDecoration(l10n.pet_field_email, Icons.email),
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                            ),

                         ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // BOTTOM SAVING BAR (NEO-BRUTALIST STYLE)
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
                    color: AppColors.petPrimary,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: const [
                       BoxShadow(color: Colors.black, offset: Offset(4, 4))
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _isLoading ? null : _saveAppointment,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isLoading)
                            const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                          else
                            const Icon(Icons.check_circle_outline, color: Colors.black, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            l10n.common_save.toUpperCase(), 
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1),
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

  InputDecoration _inputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      hintText: labelText.toUpperCase(),
      hintStyle: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.w900,
        fontSize: 12,
        letterSpacing: 0.5,
      ),
      prefixIcon: Icon(icon, color: Colors.black87, size: 20),
      filled: true,
      fillColor: AppColors.petPrimary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black, width: 2)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black, width: 2)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black, width: 3)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 2)),
    );
  }
}
