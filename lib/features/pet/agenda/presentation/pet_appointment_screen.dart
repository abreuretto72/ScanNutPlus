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
import 'dart:io';
import 'dart:typed_data';
import 'package:open_filex/open_filex.dart';
import 'package:scannutplus/features/pet/presentation/universal_pdf_preview_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:scannutplus/core/services/universal_ai_service.dart';
import 'package:scannutplus/core/services/universal_pdf_service.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
import 'package:scannutplus/features/pet/data/models/pet_entity.dart';
import 'package:scannutplus/objectbox.g.dart';
import 'package:scannutplus/core/data/objectbox_manager.dart';

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

  List<String> _mediaPaths = [];
  bool _isGeneratingPdf = false;

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
      _notesController.text = ev.notes ?? '';
      _partnerPhoneController.text = ev.metrics?['partner_phone'] ?? '';
      _selectedCategory = ev.metrics?['category'] ?? 'health';
      _selectedType = ev.metrics?['appointment_type'] ?? 'consultation_general';
      _selectedLeadTime = ev.metrics?['notification_lead_time'] ?? '2 horas antes';
      _mediaPaths = List<String>.from(ev.mediaPaths ?? []);
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
          
          if (widget.existingEvent != null) {
              final ev = widget.existingEvent!;
              final prof = ev.metrics?['professional']?.toString() ?? '';
              final isNew = ev.metrics?['is_new_partner'] == true;
              
              if (prof.isNotEmpty) {
                 if (!isNew && _existingPartners.contains(prof)) {
                     _selectedPartner = prof;
                 } else {
                     _selectedPartner = 'NEW_PARTNER';
                     _isNewPartner = true;
                     _professionalController.text = prof;
                 }
              }
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
        mediaPaths: _mediaPaths.isNotEmpty ? _mediaPaths : null,
        metrics: {
          'custom_title': customTitle, 
          'appointment_type': _selectedType,
          'category': _selectedCategory,
          'is_new_partner': _isNewPartner,
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
      
      PetEventRepoResult<void> result;
      if (widget.existingEvent != null) {
         result = await repository.update(newEvent);
      } else {
         result = await repository.saveEvent(newEvent);
      }

      if (!result.isSuccess) {
         throw Exception("Database storage failure: ${result.status}");
      }

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

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _mediaPaths.add(result.files.single.path!);
        });
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(AppLocalizations.of(context)!.pet_agenda_file_attached), backgroundColor: Colors.green),
           );
        }
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }




  Future<void> _generateAISummaryPDF() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isGeneratingPdf = true);

    debugPrint("[AI_SUMMARY_RAG] Starting comprehensive AI Summary Generation for Pet: ${widget.petId}");

    try {
      // Ensure bindings are initialized before calling PDF service or accessing assets
      WidgetsFlutterBinding.ensureInitialized();

      // 1. Fetch Pet Profile Data (ObjectBox)
      debugPrint("[AI_SUMMARY_RAG] Fetching Pet Profile from ObjectBox...");
      final petBox = ObjectBoxManager.currentStore.box<PetEntity>();
      final petProfileResult = petBox.query(PetEntity_.uuid.equals(widget.petId)).build().findFirst();
      
      String petProfileContext = "Nome: ${widget.petName}\n";
      if (petProfileResult != null) {
         debugPrint("[AI_SUMMARY_RAG] Pet Profile Found: ${petProfileResult.name}");
         if (petProfileResult.breed != null) petProfileContext += "Raça: ${petProfileResult.breed}\n";
         if (petProfileResult.estimatedWeight != null) petProfileContext += "Peso: ${petProfileResult.estimatedWeight} kg\n";
         if (petProfileResult.birthDate != null) {
            final ageDays = DateTime.now().difference(petProfileResult.birthDate!).inDays;
            final ageYears = ageDays ~/ 365;
            petProfileContext += "Idade: $ageYears anos\n";
         }
         if (petProfileResult.chronicConditions != null && petProfileResult.chronicConditions!.isNotEmpty) {
            petProfileContext += "Condições Crônicas: ${petProfileResult.chronicConditions}\n";
         }
         if (petProfileResult.allergies != null && petProfileResult.allergies!.isNotEmpty) {
            petProfileContext += "Alergias: ${petProfileResult.allergies}\n";
         }
         if (petProfileResult.clinicalNotes != null && petProfileResult.clinicalNotes!.isNotEmpty) {
            petProfileContext += "Notas Clínicas: ${petProfileResult.clinicalNotes}\n";
         }
         debugPrint("[AI_SUMMARY_RAG] Constructed Profile Context:\n$petProfileContext");
      } else {
         debugPrint("[AI_SUMMARY_RAG] WARNING: Pet Profile NOT FOUND in ObjectBox!");
      }

      // 2. Fetch Events (Hive)
      debugPrint("[AI_SUMMARY_RAG] Fetching Recent Events from Hive...");
      final repo = PetEventRepository();
      final result = await repo.getByPetId(widget.petId);
      
      String medicationsText = "Nenhuma medicação recente.";
      String activitiesText = "Nenhuma atividade recente.";
      String nutritionText = "Nenhum registro nutricional recente.";
      String appointmentsText = "Nenhum compromisso recente.";
      String analysesText = "Nenhuma análise de IA recente.";

      if (result.isSuccess && result.data != null) {
         // Strict RAG Filter: Exclusively Primary Pet events. Do NOT use friend events.
         final events = result.data!.where((e) {
             final isFriend = e.metrics?[PetConstants.keyIsFriend]?.toString() == 'true';
             return !isFriend;
         }).toList();
         
         debugPrint("[AI_SUMMARY_RAG] Found ${events.length} strict PRIMARY events for this pet.");
         
         // Helper to format date
         String fd(DateTime d) => DateFormat.yMd(l10n.localeName).format(d);
         
         // Filter & Format Medications
         final meds = events.where((e) => e.metrics?['is_medication'] == true || e.metrics?['subtype'] == 'medication').take(10).toList();
         debugPrint("[AI_SUMMARY_RAG] Filtered ${meds.length} medications.");
         if (meds.isNotEmpty) {
             medicationsText = meds.map((e) => "- ${fd(e.startDateTime)} [${e.metrics?['custom_title'] ?? 'Medicação'}]: ${e.notes ?? ''}").join("\n");
         }

         // Filter & Format Activities
         final acts = events.where((e) => e.eventTypeIndex == PetEventType.activity.index).take(10).toList();
         debugPrint("[AI_SUMMARY_RAG] Filtered ${acts.length} activities (walks/energy).");
         if (acts.isNotEmpty) {
             activitiesText = acts.map((e) => "- ${fd(e.startDateTime)} [${e.metrics?['custom_title'] ?? 'Passeio'}]: ${e.notes ?? ''}").join("\n");
         }

         // Filter & Format Nutrition
         final foods = events.where((e) => e.eventTypeIndex == PetEventType.food.index && e.hasAIAnalysis != true && e.metrics?.containsKey(PetConstants.keyAiSummary) != true).take(10).toList();
         debugPrint("[AI_SUMMARY_RAG] Filtered ${foods.length} nutrition/food events.");
         if (foods.isNotEmpty) {
             nutritionText = foods.map((e) => "- ${fd(e.startDateTime)} [${e.metrics?['custom_title'] ?? 'Nutrição'}]: ${e.notes ?? ''}").join("\n");
         }

         // Filter & Format Appointments (excluding acts, meds, and foods)
         final apts = events.where((e) => e.eventTypeIndex == PetEventType.health.index && e.metrics?['is_medication'] != true && e.metrics?['subtype'] != 'medication').take(10).toList();
         debugPrint("[AI_SUMMARY_RAG] Filtered ${apts.length} appointments/incidents.");
         if (apts.isNotEmpty) {
             appointmentsText = apts.map((e) => "- ${fd(e.startDateTime)} [${e.metrics?['custom_title'] ?? 'Compromisso'}]: ${e.notes ?? ''}").join("\n");
         }
         
         // Filter & Format AI Analyses (These usually have hasAIAnalysis = true or contain an 'ai_summary' metric)
         final analyses = events.where((e) => e.hasAIAnalysis == true || e.metrics?.containsKey(PetConstants.keyAiSummary) == true).take(5).toList();
         debugPrint("[AI_SUMMARY_RAG] Filtered ${analyses.length} AI analyses.");
         if (analyses.isNotEmpty) {
             analysesText = analyses.map((e) {
                 String summary = e.metrics?[PetConstants.keyAiSummary]?.toString() ?? '';
                 // Truncate long JSON/Text to avoid blowing up prompt size
                 if (summary.length > 300) summary = "${summary.substring(0, 300)}...";
                 return "- ${fd(e.startDateTime)} [${e.metrics?['custom_title'] ?? 'Análise IA'}]: $summary";
             }).join("\n\n");
         }
      } else {
         debugPrint("[AI_SUMMARY_RAG] No events found or error fetching events.");
      }

      final promptText = '''
        ROLE: Veterinary Pathologist and Analyst.
        TASK: Generate a concise Clinical Summary (Resumo Clínico) for the pet's upcoming appointment based on its profile and recent history. 
        LANGUAGE: ${l10n.localeName == 'pt' ? 'Portuguese' : 'English'}.
        
        INPUT DATA:
        --- PET PROFILE ---
        $petProfileContext
        
        --- RECENT MEDICATIONS ---
        $medicationsText
        
        --- RECENT ACTIVITIES/WALKS ---
        $activitiesText
        
        --- RECENT NUTRITION/DIET ---
        $nutritionText
        
        --- RECENT APPOINTMENTS/INCIDENTS ---
        $appointmentsText
        
        --- RECENT AI ANALYSES (Summarized) ---
        $analysesText
        
        OUTPUT FORMAT: Must follow the STRICT syntax below. Synthesize the data intelligently into a well-structured text.
        CRITICAL RULE: DO NOT use any emojis, emoticons, or special decorative icons in your response. ONLY use plain text, punctuation, and standard Portuguese characters. Emojis will crash the PDF generator system. DO NOT use the [CARD_START] block syntax.
        
        1. [VISUAL_SUMMARY] A clear paragraph summarizing the pet's current health state based on the profile, recent medications, activities, and analyses. Mention specific details to aid the veterinarian. [END_SUMMARY]
        2. Write the rest of the clinical report dynamically, using standard paragraphs and dashes for bullet points. Include insights on nutrition, weight, and general health history.
        3. [SOURCES]
        - Histórico Clínico do ScanNut+
        - Perfil de Saúde Cadastrado
        [END_SOURCES]
        
        DO NOT include [URGENCY] tags.
      ''';

      debugPrint("[AI_SUMMARY_RAG] Calling UniversalAiService...");
      final summary = await UniversalAiService().analyzeText(
        systemPrompt: promptText,
        userPrompt: l10n.localeName == 'pt' ? "Gere um resumo clínico completo com base no histórico fornecido." : "Generate a comprehensive clinical summary based on the provided history.",
        l10n: l10n,
      );

      debugPrint("[AI_SUMMARY_RAG] AI Service replied successfully. Stripping Emojis for PDF generation...");

      // Normalize common fancy characters and strictly whitelist standard ASCII & Latin-1
      // This guarantees dart_pdf default fonts won't throw 'Glyph not found' for emojis or weird symbols
      final normalizedSummary = summary
          .replaceAll('•', '-')
          .replaceAll('“', '"')
          .replaceAll('”', '"')
          .replaceAll('‘', "'")
          .replaceAll('’', "'")
          .replaceAll('–', '-') // en dash
          .replaceAll('—', '-') // em dash
          .replaceAll(RegExp(r'[\xA0\u202F\u2007\u2060]'), ' '); // Non-breaking spaces
          
      // STRICT LOCAL FONT RENDER SAFETY: Strip any unicode not in standard ASCII or Latin-1
      final safeSummary = normalizedSummary.replaceAll(RegExp(r'[^\x00-\x7F\xA0-\xFF]'), '');

      final pdfPayload = {
        PetConstants.fieldName: widget.petName,
        PetConstants.fieldBreed: petProfileResult?.breed ?? l10n.pdf_unknown_breed,
        PetConstants.keyPageTitle: l10n.pet_title_clinical_summary,
      };

      // Ensure directory exists for background saving
      final dir = await getApplicationDocumentsDirectory();
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final safePetName = widget.petName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final formattedDateTime = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final fileName = '${safePetName}_$formattedDateTime.pdf';
      final file = File('${dir.path}/$fileName');
      
      // We still save the background bytes so the "Chip" can hold it as an attachment
      var pdfBytes = await UniversalPdfService.generatePdf(
         PdfPageFormat.a4,
         null,
         safeSummary,
         pdfPayload,
         l10n: l10n,
         colorValue: AppColors.petPrimary.value, // It's generated here for the attachment
      );
      await file.writeAsBytes(pdfBytes);
      pdfBytes = Uint8List(0); // GC

      setState(() {
        _mediaPaths.add(file.path);
      });

      if (mounted) {
         // Force Navigation to the Universal Previewer instantly (Domain Rule)
         Navigator.push(context, MaterialPageRoute(builder: (_) => UniversalPdfPreviewScreen(
             analysisResult: safeSummary,
             petDetails: pdfPayload,
             title: l10n.pet_title_clinical_summary,
         )));
      }
    } catch (e, stackTrace) {
      debugPrint("[AI_SUMMARY_RAG] ERROR generating summary: ${e.toString()}");
      debugPrint("[AI_SUMMARY_RAG] StackTrace: $stackTrace");
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(l10n.pet_error_summary), backgroundColor: Colors.red),
         );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
      debugPrint("[AI_SUMMARY_RAG] Process finished.");
    }
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

  Widget _buildLabeledField(String labelText, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            labelText,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        child,
      ],
    );
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
               icon: const Icon(Icons.event_available, color: Colors.blue),
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
              Tab(text: l10n.pet_appointment_tab_data.toUpperCase(), icon: const Icon(Icons.calendar_today, color: Colors.blue, size: 20)),
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
                          _buildLabeledField(l10n.pet_apt_select_category, DropdownButtonFormField<String>(
                            // ignore: deprecated_member_use
                            value: _selectedCategory,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
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
                          )),
                          const SizedBox(height: 16),

                          // SUB-TYPE DROPDOWN
                          _buildLabeledField(l10n.pet_apt_select_type, DropdownButtonFormField<String>(
                            // ignore: deprecated_member_use
                            value: _selectedType,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
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
                          )),
                          const SizedBox(height: 16),

                          // "WHAT TO DO?" (TITLE)
                          _buildLabeledField(l10n.pet_field_what_to_do, TextFormField(
                            controller: _titleController,
                            minLines: 1,
                            maxLines: 4,
                            keyboardType: TextInputType.multiline,
                            style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                            decoration: _inputDecoration(l10n.pet_field_what_to_do, Icons.edit).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _activeVoiceController == _titleController ? Icons.mic : Icons.mic_none,
                                  color: _activeVoiceController == _titleController ? Colors.redAccent : Colors.blue,
                                  size: 20,
                                ),
                                onPressed: () => _toggleVoiceInput(_titleController),
                              ),
                            ),
                          )),
                          const SizedBox(height: 16),

                          // NOTIFICATION
                          _buildLabeledField(l10n.pet_notification_label, DropdownButtonFormField<String>(
                            initialValue: _selectedLeadTime,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
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
                          )),
                          const SizedBox(height: 16),

                          // DATE & TIME
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectDate(context),
                                  child: _buildLabeledField(l10n.pet_agenda_event_date, InputDecorator(
                                    decoration: _inputDecoration(l10n.pet_agenda_event_date, Icons.calendar_today),
                                    child: Text(DateFormat.yMd(Localizations.localeOf(context).languageCode).format(_selectedDate), style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                                  )),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectTime(context),
                                  child: _buildLabeledField(l10n.pet_field_time, InputDecorator(
                                    decoration: _inputDecoration(l10n.pet_field_time, Icons.access_time).copyWith(
                                      prefixIcon: const Icon(Icons.access_time, color: Colors.blue),
                                    ),
                                    child: Text(_selectedTime.format(context), style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                                  )),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // NOTES / OUTCOME
                          _buildLabeledField("${l10n.pet_field_what_to_do} / ${l10n.pet_agenda_outcome_title}", TextFormField(
                            controller: _notesController,
                            minLines: 3,
                            maxLines: 8,
                            keyboardType: TextInputType.multiline,
                            style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                            decoration: _inputDecoration("${l10n.pet_field_what_to_do} / ${l10n.pet_agenda_outcome_title}", Icons.description).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _activeVoiceController == _notesController ? Icons.mic : Icons.mic_none,
                                  color: _activeVoiceController == _notesController ? Colors.redAccent : Colors.blue,
                                  size: 20,
                                ),
                                onPressed: () => _toggleVoiceInput(_notesController),
                              ),
                            ),
                          )),
                          const SizedBox(height: 16),

                          // ATTACHMENTS UI Row
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _pickFile,
                                  icon: const Icon(Icons.attach_file, color: Colors.black),
                                  label: Text(l10n.pet_agenda_attach_document, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: AppColors.petPrimary, // FIXED CONTRAST vs DARK BACKGROUND
                                    side: const BorderSide(color: Colors.black, width: 2),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _isGeneratingPdf
                                  ? const Center(child: CircularProgressIndicator(color: AppColors.petPrimary))
                                  : OutlinedButton.icon(
                                      onPressed: _generateAISummaryPDF,
                                      icon: const Icon(Icons.auto_awesome, color: Colors.black),
                                      label: Text(l10n.pet_agenda_ai_summary, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: const Color(0xFFE0BBE4), // Lilac
                                        side: const BorderSide(color: Colors.black, width: 2),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                              ),
                            ],
                          ),
                          if (_mediaPaths.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _mediaPaths.map((path) {
                                final fileName = path.split('/').last.split('\\\\').last;
                                return InputChip(
                                  label: Text(fileName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black), overflow: TextOverflow.ellipsis),
                                  backgroundColor: Colors.white,
                                  deleteIcon: const Icon(Icons.close, size: 16, color: Colors.black),
                                  onPressed: () {
                                    OpenFilex.open(path);
                                  },
                                  onDeleted: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        backgroundColor: AppColors.petBackgroundDark,
                                        title: Text(l10n.pet_agenda_delete_attachment_title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                        content: Text(l10n.pet_agenda_delete_attachment_msg, style: const TextStyle(color: Colors.white70)),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, false),
                                            child: Text(l10n.common_cancel, style: const TextStyle(color: Colors.grey)),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, true),
                                            child: Text(l10n.pet_agenda_delete_attachment_confirm, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      )
                                    );
                                    if (confirm == true) {
                                      setState(() {
                                        _mediaPaths.remove(path);
                                      });
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                          ],
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
                            _buildLabeledField(l10n.pet_field_partner_name, DropdownButtonFormField<String>(
                              initialValue: _selectedPartner,
                              isExpanded: true,
                              itemHeight: 60, // Aumentando a altura
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
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
                            )),
                            
                            // CONDITIONAL NEW PARTNER LOGIC
                            if (_isNewPartner) ...[
                               const SizedBox(height: 16),
                               _buildLabeledField("${l10n.pet_appointment_new_partner} *", TextFormField(
                                  controller: _professionalController,
                                  decoration: _inputDecoration("${l10n.pet_appointment_new_partner} *", Icons.edit),
                                  style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                               )),
                            ],

                            const SizedBox(height: 16),
                            _buildLabeledField(l10n.pet_field_contact_person, TextFormField(
                              controller: _partnerContactController,
                              decoration: _inputDecoration(l10n.pet_field_contact_person, Icons.person),
                              style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                            )),
                            const SizedBox(height: 16),
                            _buildLabeledField(l10n.pet_field_phone, TextFormField(
                              controller: _partnerPhoneController,
                              decoration: _inputDecoration(l10n.pet_field_phone, Icons.phone),
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                            )),
                            const SizedBox(height: 16),
                            _buildLabeledField(l10n.pet_field_whatsapp, TextFormField(
                              controller: _partnerWhatsappController,
                              decoration: _inputDecoration(l10n.pet_field_whatsapp, Icons.chat),
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                            )),
                            const SizedBox(height: 16),
                            _buildLabeledField(l10n.pet_field_email, TextFormField(
                              controller: _partnerEmailController,
                              decoration: _inputDecoration(l10n.pet_field_email, Icons.email),
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                            )),

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
      hintText: "",
      hintStyle: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.w900,
        fontSize: 12,
        letterSpacing: 0.5,
      ),
      prefixIcon: Icon(icon, color: (icon == Icons.calendar_today || icon == Icons.date_range || icon == Icons.event) ? Colors.blue : Colors.black87, size: 20),
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
