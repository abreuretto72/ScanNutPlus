import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/pet/agenda/pet_event.dart';
import 'package:scannutplus/pet/agenda/pet_event_repository.dart';
import 'package:scannutplus/features/pet/agenda/presentation/pet_appointment_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:scannutplus/features/pet/data/models/pet_event_type.dart';
import 'package:scannutplus/features/pet/presentation/extensions/pet_ui_extensions.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:scannutplus/features/pet/agenda/logic/pet_notification_manager.dart';

class PetScheduledEventsScreen extends StatefulWidget {
  final String petId;
  final String petName;
  final bool showAppBar;
  final DateTime? filterDate;

  const PetScheduledEventsScreen({
    super.key,
    required this.petId,
    required this.petName,
    this.showAppBar = true,
    this.filterDate,
  });

  @override
  State<PetScheduledEventsScreen> createState() =>
      _PetScheduledEventsScreenState();
}

class _PetScheduledEventsScreenState extends State<PetScheduledEventsScreen> {
  final PetEventRepository _repository = PetEventRepository();
  List<PetEvent> _appointments = [];
  final bool _isPlanCopied = false;

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _previousText = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  @override
  void didUpdateWidget(PetScheduledEventsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filterDate != oldWidget.filterDate) {
      _loadAppointments();
    }
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    final result = await _repository.getByPetId(widget.petId);

    if (result.isSuccess && result.data != null) {
      final now = DateTime.now();
      // Filter: Only appointments, only future (or recent past if desired, but user said "agendados" implies future)
      // We will show all future appointments.
      final allEvents = result.data!;

      final filtered = allEvents.where((e) {
        final isAppt = e.metrics?['is_appointment'] == true;
        final isMed = e.metrics?['is_medication'] == true;
        final isTaken = e.metrics?['status'] == 'taken';
        final isFuture = e.startDateTime.isAfter(now);
        
        bool dateMatches = true;
        if (widget.filterDate != null) {
          dateMatches = DateUtils.isSameDay(e.startDateTime, widget.filterDate);
        }
        
        // Se for compromisso normal, aplica dateMatches. Se não tiver filtro de data, deve ser futuro
        if (isAppt) return dateMatches && (widget.filterDate != null || isFuture);
        
        // Se for remédio, mostra sempre (pendente/atrasado) enquanto não for tomado, respeitando data filtro
        if (isMed) return !isTaken && dateMatches;
        
        return false;
      }).toList();

      // Sort ascending (nearest first)
      filtered.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

      if (mounted) {
        setState(() {
          _appointments = filtered;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAppointment(String id) async {
    await PetNotificationManager().cancelNotification(id);
    await _repository.delete(id);
    _loadAppointments(); // Refresh
  }

  Future<void> _markMedicationAsTaken(BuildContext context, PetEvent event) async {
    try {
      final updatedMetrics = Map<String, dynamic>.from(event.metrics ?? {});
      updatedMetrics['status'] = 'taken';

      final updatedEvent = PetEvent(
        id: event.id,
        startDateTime: DateTime.now(), // Marca a data exata da baixa
        endDateTime: event.endDateTime,
        petIds: event.petIds,
        eventTypeIndex: event.eventTypeIndex,
        notes: event.notes,
        metrics: updatedMetrics,
        mediaPaths: event.mediaPaths,
        partnerId: event.partnerId,
        hasAIAnalysis: event.hasAIAnalysis,
      );

      await _repository.saveEvent(updatedEvent);
      _loadAppointments(); // Refresh immediate view
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pet_med_taken_success), backgroundColor: Colors.green));
      }
    } catch (e) {
      debugPrint("Error marking medication as taken: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.petPrimary));
    }

    if (_appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_rounded,
                size: 60, color: Colors.black.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(l10n.pet_scheduled_empty,
                style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 80),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          itemCount: _appointments.length + 1,
          itemBuilder: (context, index) {
            if (index == _appointments.length) {
              return const SizedBox(height: 80);
            }

            final event = _appointments[index];
            final rawTitle = event.metrics?['custom_title']?.toString();
            
            final type = PetEventType.values.firstWhere(
                (e) => e.index == event.eventTypeIndex,
                orElse: () => PetEventType.activity);

            final title =
                rawTitle ?? (type == PetEventType.activity 
                    ? l10n.pet_walk_title_dynamic(widget.petName) 
                    : l10n.pet_appointment_tab_data);
            
            final professional =
                event.metrics?['professional']?.toString() ?? '';
            final leadTime =
                event.metrics?['notification_lead_time']?.toString();

            final appointmentType =
                event.metrics?['appointment_type']?.toString();
            final typeDisplay =
                appointmentType?.toAppointmentTypeDisplay(context);

            final prefix = l10n.pet_agenda_outcome_prefix;
            String whatToDo = event.notes ?? '';
            String outcomeText = '';
            
            if (whatToDo.contains('[$prefix]:')) {
               final parts = whatToDo.split('[$prefix]:');
               whatToDo = parts[0].trim();
               outcomeText = parts.length > 1 ? parts[1].trim() : '';
            }
            final rawCategory = event.metrics?['is_medication'] == true
                ? "MEDICAÇÃO"
                : event.eventTypeIndex == PetEventType.health.index
                    ? l10n.pet_appointment_cat_health
                    : event.eventTypeIndex == PetEventType.food.index
                        ? l10n.pet_appointment_cat_nutrition
                        : l10n.pet_appointment_tab_data;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PetAppointmentScreen(
                          petId: widget.petId,
                          petName: widget.petName,
                          existingEvent: event,
                        ),
                      ),
                    ).then((_) {
                      _loadAppointments();
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.petPrimary,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black, width: 3),
                      boxShadow: const [
                        BoxShadow(color: Colors.black, offset: Offset(6, 6))
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.black, width: 2),
                                      ),
                                      child: Icon(
                                          event.metrics?['is_medication'] == true ? Icons.medication_rounded : Icons.calendar_month_rounded,
                                          color: Colors.black,
                                          size: 24),
                                    ),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          rawCategory.toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 10,
                                              letterSpacing: 1.2),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Row(
                                children: [
                                  if (event.mediaPaths != null && event.mediaPaths!.isNotEmpty)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 4),
                                      child: Icon(Icons.attach_file_rounded, color: Colors.black87),
                                    ),
                                  if (event.metrics?['is_medication'] == true && event.metrics?['status'] == 'pending')
                                    Container(
                                       margin: const EdgeInsets.only(right: 4),
                                       child: IconButton(
                                         icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF10AC84), size: 28),
                                         onPressed: () => _markMedicationAsTaken(context, event),
                                       ),
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded,
                                        color: Colors.redAccent),
                                    onPressed: () =>
                                        _confirmDelete(context, event.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            title,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 16),
                          ),
                          if (typeDisplay != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              typeDisplay.toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12),
                            ),
                          ],
                          if (professional.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                               children: [
                                  const Icon(Icons.business_center_rounded, size: 14, color: Colors.black54),
                                  const SizedBox(width: 4),
                                  Text(
                                    professional.toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11),
                                  ),
                               ]
                            )
                          ],
                          if (whatToDo.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.black, width: 1.5),
                              ),
                              child: Text(
                                "${l10n.pet_field_what_to_do}: $whatToDo",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12),
                              ),
                            ),
                          ],
                          if (outcomeText.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.green.shade900, width: 1.5),
                              ),
                              child: Text(
                                "$prefix: $outcomeText",
                                style: TextStyle(
                                    color: Colors.green.shade900,
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12),
                              ),
                            ),
                          ],
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: Colors.black, height: 1, thickness: 2),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded,
                                  color: Colors.black, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  DateFormat.yMd(Localizations.localeOf(context)
                                          .toString())
                                      .add_jm()
                                      .format(event.startDateTime),
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              if (leadTime != null && leadTime != 'none')
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.black, width: 1)),
                                  child: Row(
                                    children: [
                                      const Icon(
                                          Icons.notifications_active_rounded,
                                          size: 12,
                                          color: Colors.black),
                                      const SizedBox(width: 2),
                                      Text(leadTime,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 10)),
                                    ],
                                  ),
                                ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.assignment_turned_in_rounded, color: Colors.black, size: 28),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: l10n.pet_agenda_outcome_btn,
                                onPressed: () => _showOutcomeDialog(context, event)
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    final l10n = AppLocalizations.of(context)!;
    // Simple confirmation dialog could be added here, but for now direct delete or snackbar undo
    // Let's do a simple dialog
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.petBackgroundDark,
              title: Text(l10n.pet_delete_confirmation_title,
                  style: const TextStyle(color: Colors.white)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.common_cancel,
                      style: const TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _deleteAppointment(id);
                  },
                  child: Text(l10n.common_delete,
                      style: const TextStyle(color: Colors.red)),
                ),
              ],
            ));
  }

  void _showEventActionsModal(BuildContext context, PetEvent event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.petBackgroundDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: Colors.black, width: 4),
              left: BorderSide(color: Colors.black, width: 4),
              right: BorderSide(color: Colors.black, width: 4),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 24),

                // Editar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PetAppointmentScreen(
                            petId: widget.petId,
                            petName: '',
                            existingEvent: event,
                          ),
                        ),
                      ).then((_) {
                        _loadAppointments(); // Refresh list on return
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black, width: 3),
                        boxShadow: const [
                          BoxShadow(color: Colors.black, offset: Offset(4, 4))
                        ],
                      ),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.pet_agenda_edit_btn,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Registrar Desfecho
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _showOutcomeDialog(context, event);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.petPrimary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black, width: 3),
                        boxShadow: const [
                          BoxShadow(color: Colors.black, offset: Offset(4, 4))
                        ],
                      ),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.pet_agenda_outcome_btn,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOutcomeDialog(BuildContext context, PetEvent event) {
    final l10n = AppLocalizations.of(context)!;
    final prefix = l10n.pet_agenda_outcome_prefix;
    
    String whatToDo = event.notes ?? '';
    String existingOutcome = '';
    
    if (whatToDo.contains('[$prefix]:')) {
       final parts = whatToDo.split('[$prefix]:');
       whatToDo = parts[0].trim();
       if (parts.length > 1) {
           existingOutcome = parts[1].trim();
       }
    }
    
    final controller = TextEditingController(text: existingOutcome);
    List<String> selectedMedia = List<String>.from(event.mediaPaths ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.petBackgroundDark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                top: BorderSide(color: Colors.black, width: 4),
                left: BorderSide(color: Colors.black, width: 4),
                right: BorderSide(color: Colors.black, width: 4),
              ),
            ),
            child: SafeArea(
              child: StatefulBuilder(
                builder: (BuildContext dlgCtx, StateSetter setModalState) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.pet_agenda_outcome_title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: controller,
                        maxLines: 4,
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: l10n.pet_agenda_outcome_hint,
                          hintStyle: const TextStyle(color: Colors.black54),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.black, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.black, width: 3),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: _isListening ? Colors.red : Colors.black,
                            ),
                            onPressed: () => _toggleVoiceInput(
                                controller, setModalState, l10n),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (selectedMedia.isNotEmpty) ...[
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: selectedMedia.map((path) {
                                final fileName =
                                    path.split('/').last.split('\\').last;
                                return InputChip(
                                  label: Text(fileName,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                      overflow: TextOverflow.ellipsis),
                                  backgroundColor: Colors.white,
                                  deleteIcon: const Icon(Icons.close,
                                      size: 16, color: Colors.black),
                                  onDeleted: () {
                                    setModalState(() {
                                      selectedMedia.remove(path);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: AppColors.petPrimary,
                              side: const BorderSide(
                                  color: Colors.black, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.attach_file,
                                color: Colors.black),
                            label: Text(l10n.pet_agenda_attach_document,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                            onPressed: () async {
                              final result = await FilePicker.platform
                                  .pickFiles(
                                      type: FileType.any, allowMultiple: true);
                              if (result != null) {
                                final paths = result.files
                                    .map((f) => f.path)
                                    .whereType<String>()
                                    .toList();
                                setModalState(() {
                                  selectedMedia.addAll(paths);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(
                              l10n.common_cancel,
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final outcome = controller.text.trim();
                              if (outcome.isNotEmpty ||
                                  selectedMedia.isNotEmpty ||
                                  existingOutcome.isNotEmpty) {
                                Navigator.pop(ctx);

                                String updatedNotes = whatToDo;
                                if (outcome.isNotEmpty) {
                                  updatedNotes = updatedNotes.isNotEmpty
                                      ? "$updatedNotes\n\n[$prefix]: $outcome"
                                      : "[$prefix]: $outcome";
                                }

                                final updatedEvent = event.copyWith(
                                    notes: updatedNotes.isNotEmpty
                                        ? updatedNotes
                                        : null,
                                    mediaPaths: selectedMedia);

                                await _repository.update(updatedEvent);
                                _loadAppointments();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.petPrimary,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                    color: Colors.black, width: 2),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              l10n.common_save,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        );
      },
    );
  }

  void _toggleVoiceInput(TextEditingController controller, StateSetter setModalState, AppLocalizations l10n) async {
    if (_isListening) {
      setModalState(() => _isListening = false);
      _speech.stop();
    } else {
      bool available = await _speech.initialize();
      if (available) {
        _previousText = controller.text;
        setModalState(() => _isListening = true);
        
        _speech.listen(
          onResult: (val) {
            setModalState(() {
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
             SnackBar(content: Text(l10n.pet_journal_mic_permission_denied)),
           );
         }
      }
    }
  }
}
