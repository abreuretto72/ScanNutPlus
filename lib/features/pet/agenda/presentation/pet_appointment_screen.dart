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
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  // Appointment Types
  // We will map these to PetEventType and custom metrics
  /*
    Vaccine -> Health (1)
    Consultation -> Health (1)
    Grooming -> Hygiene (3)
    Exam -> Health (1)
  */
  String _selectedType = 'consultation'; // Default key
  String _selectedLeadTime = 'none'; // Default notification preference

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _professionalController.dispose();
    _notesController.dispose();
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
    
    try {
      final l10n = AppLocalizations.of(context)!;
      final startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      
      // Determine EventType and Custom Title
      // Using PetEventType enum for safer typing
      int eventTypeIndex = PetEventType.health.index; // Default Health
      String typeLabel = l10n.pet_appointment_type_consultation;
      
      switch(_selectedType) {
        case 'vaccine':
          eventTypeIndex = PetEventType.health.index; // Health
          typeLabel = l10n.pet_appointment_type_vaccine;
          break;
        case 'grooming':
          eventTypeIndex = PetEventType.hygiene.index; // Hygiene
          typeLabel = l10n.pet_appointment_type_grooming;
          break;
        case 'exam':
          eventTypeIndex = PetEventType.health.index; // Health
          typeLabel = l10n.pet_appointment_type_exam;
          break;
        case 'consultation':
        default:
          eventTypeIndex = PetEventType.health.index; // Health
          typeLabel = l10n.pet_appointment_type_consultation;
          break;
      }
      
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
          'is_appointment': true,
          'notification_lead_time': _selectedLeadTime,
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
           SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
         );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        body: Form(
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
                    // TYPE DROPDOWN
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: _selectedType,
                      decoration: _inputDecoration(l10n.pet_agenda_select_type, Icons.category),
                      dropdownColor: Colors.grey[850],
                      style: const TextStyle(color: Colors.white),
                      items: [
                        DropdownMenuItem(value: 'consultation', child: Text(l10n.pet_appointment_type_consultation)),
                        DropdownMenuItem(value: 'vaccine', child: Text(l10n.pet_appointment_type_vaccine)),
                        DropdownMenuItem(value: 'grooming', child: Text(l10n.pet_appointment_type_grooming)),
                        DropdownMenuItem(value: 'exam', child: Text(l10n.pet_appointment_type_exam)),
                      ],
                      onChanged: (val) => setState(() => _selectedType = val!),
                    ),
                    const SizedBox(height: 16),
                    
                    // NOTIFICATION DROPDOWN
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: _selectedLeadTime,
                      decoration: _inputDecoration(l10n.pet_notification_label, Icons.notifications),
                      dropdownColor: Colors.grey[850],
                      style: const TextStyle(color: Colors.white),
                      items: [
                        DropdownMenuItem(value: 'none', child: Text(l10n.pet_notification_none)),
                        DropdownMenuItem(value: '1h', child: Text(l10n.pet_notification_1h)),
                        DropdownMenuItem(value: '2h', child: Text(l10n.pet_notification_2h)),
                        DropdownMenuItem(value: '1d', child: Text(l10n.pet_notification_1d)),
                        DropdownMenuItem(value: '2d', child: Text(l10n.pet_notification_2d)),
                        DropdownMenuItem(value: '1w', child: Text(l10n.pet_notification_1w)),
                      ],
                      onChanged: (val) => setState(() => _selectedLeadTime = val!),
                    ),
                    const SizedBox(height: 16),

                    // OPTIONAL TITLE
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("${l10n.pet_journal_question} (Opcional)", Icons.title),
                    ),
                    const SizedBox(height: 16),
                    
                    // DATE & TIME ROW
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            borderRadius: BorderRadius.circular(12),
                            child: InputDecorator(
                              decoration: _inputDecoration(l10n.pet_agenda_event_date, Icons.calendar_today),
                              child: Text(
                                DateFormat('dd/MM/yyyy').format(_selectedDate),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(context),
                            borderRadius: BorderRadius.circular(12),
                            child: InputDecorator(
                              decoration: _inputDecoration(l10n.pet_agenda_event_time, Icons.access_time),
                              child: Text(
                                _selectedTime.format(context),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // NOTES
                    TextFormField(
                      controller: _notesController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 4,
                      decoration: _inputDecoration(l10n.pet_agenda_notes_hint, Icons.notes),
                    ),
                    const SizedBox(height: 24),

                    // SAVE BUTTON (Here or Floating? Let's keep it here for now, or move to float)
                    // Better to have a Save button on the scaffold or bottom, but since we have tabs, 
                    // a FloatingActionButton is better for global "Save".
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
                    // PROFESSIONAL / PLACE
                    TextFormField(
                      controller: _professionalController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(l10n.pet_appointment_label_professional, Icons.person_pin),
                      validator: (value) {
                         // Validation will only show if this tab is visible when validate is called 
                         // or we need to handle tab switching.
                        if (value == null || value.trim().isEmpty) return l10n.pet_error_fill_friend_fields; 
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Future: Address, Phone, Website
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _isLoading ? null : _saveAppointment,
          backgroundColor: AppColors.petPrimary,
          label: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
            : Text(l10n.common_save, style: const TextStyle(color: Colors.black)),
          icon: _isLoading ? null : const Icon(Icons.check, color: Colors.black),
        ),
      ),
    );
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
