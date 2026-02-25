import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/pet/agenda/pet_event.dart';
import 'package:scannutplus/pet/agenda/pet_event_repository.dart';
import 'package:scannutplus/features/pet/agenda/logic/pet_notification_manager.dart';
import 'package:scannutplus/features/pet/agenda/presentation/pet_appointment_screen.dart';

class PetScheduledEventsTab extends StatefulWidget {
  final String petId;
  final VoidCallback? onEventDeleted;

  const PetScheduledEventsTab({
    super.key, 
    required this.petId,
    this.onEventDeleted,
  });

  @override
  State<PetScheduledEventsTab> createState() => _PetScheduledEventsTabState();
}

class _PetScheduledEventsTabState extends State<PetScheduledEventsTab> {
  final PetEventRepository _repository = PetEventRepository();
  List<PetEvent> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  // Allow parent to refresh this list
  void refresh() {
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    final result = await _repository.getByPetId(widget.petId);
    
    if (result.isSuccess && result.data != null) {
      final now = DateTime.now();
      final allEvents = result.data!;
      debugPrint("APP_TRACE: PetScheduledEventsTab recebeu ${allEvents.length} eventos do banco.");
      
      final filtered = allEvents.where((e) {
        final isAppt = e.metrics?['is_appointment'] == true;
        final isMed = e.metrics?['is_medication'] == true;
        final isTaken = e.metrics?['status'] == 'taken';
        final isFuture = e.startDateTime.isAfter(now);
        
        debugPrint("APP_TRACE: Evento ID ${e.id} | Title: ${e.metrics?['custom_title']} | isAppt: $isAppt | isMed: $isMed | isTaken: $isTaken | isFuture: $isFuture (${e.startDateTime}) | metrics: ${e.metrics}");
        
        // Se for compromisso normal, mostra apenas futuros
        if (isAppt) return isFuture;
        // Se for remédio, mostra se não foi tomado (mesmo atrasado no passado)
        if (isMed) return !isTaken;
        
        return false;
      }).toList();
      
      debugPrint("APP_TRACE: PetScheduledEventsTab filtrou para ${filtered.length} eventos visíveis.");

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
    _loadAppointments(); // Refresh list
    widget.onEventDeleted?.call();
  }

  Future<void> _markMedicationAsTaken(BuildContext context, PetEvent event) async {
    try {
      final updatedMetrics = Map<String, dynamic>.from(event.metrics ?? {});
      updatedMetrics['status'] = 'taken';

      final updatedEvent = PetEvent(
        id: event.id,
        startDateTime: DateTime.now(), // Log exact moment
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
      refresh();
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
      return const Center(child: CircularProgressIndicator(color: AppColors.petPrimary));
    }

    if (_appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             const Icon(Icons.event_busy, size: 64, color: Colors.grey),
             const SizedBox(height: 16),
             Text(l10n.pet_scheduled_empty, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Bottom padding for FAB
      itemCount: _appointments.length,
      itemBuilder: (context, index) {
        final event = _appointments[index];
        final title = event.metrics?['custom_title'] ?? 'Compromisso';
        final professional = event.metrics?['professional'] ?? '';
        final leadTime = event.metrics?['notification_lead_time'] as String?;
        
        return Card(
          color: AppColors.petCardBackground,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(12),
             side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.petPrimary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                event.metrics?['is_medication'] == true ? Icons.medication : Icons.calendar_month, 
                color: AppColors.petPrimary
              ),
            ),
            title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${DateFormat.yMd(l10n.localeName).format(event.startDateTime)} ${DateFormat.Hm(l10n.localeName).format(event.startDateTime)}",
                  style: const TextStyle(color: Colors.white70),
                ),
                if (professional.isNotEmpty)
                  Text(professional, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                 if (leadTime != null && leadTime != 'none')
                  Row(
                    children: [
                      const Icon(Icons.notifications_active, size: 12, color: AppColors.petSecondary),
                      const SizedBox(width: 4),
                      Text(leadTime, style: const TextStyle(color: AppColors.petSecondary, fontSize: 10)),
                    ],
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (event.mediaPaths != null && event.mediaPaths!.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.attach_file_rounded, color: Colors.white70),
                  ),
                if (event.metrics?['is_medication'] == true && event.metrics?['status'] == 'pending')
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline, color: Color(0xFF10AC84)),
                    onPressed: () => _markMedicationAsTaken(context, event),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _confirmDelete(context, event.id),
                ),
              ],
            ),
            onTap: () => _showActionOptions(context, event),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String id) {
     final l10n = AppLocalizations.of(context)!;
     showDialog(
       context: context, 
       builder: (ctx) => AlertDialog(
         backgroundColor: AppColors.petBackgroundDark,
         title: Text(l10n.pet_delete_confirmation_title, style: const TextStyle(color: Colors.white)),
         actions: [
           TextButton(
             onPressed: () => Navigator.pop(ctx), 
             child: Text(l10n.common_cancel, style: const TextStyle(color: Colors.grey)),
           ),
           TextButton(
             onPressed: () {
               Navigator.pop(ctx);
               _deleteAppointment(id);
             }, 
             child: Text(l10n.common_delete, style: const TextStyle(color: Colors.red)),
           ),
         ],
       )
     );
  }

  void _showActionOptions(BuildContext context, PetEvent event) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.petPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, color: Colors.black),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.black),
                title: Text(l10n.pet_appointment_edit, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PetAppointmentScreen(
                        petId: widget.petId,
                        petName: "Pet", // Ideally passed down, but "Pet" fallback is okay for now or we can get it from state. Using generic 'Pet' since screen requires it.
                        existingEvent: event,
                      ),
                    ),
                  ).then((_) => _loadAppointments());
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_outline, color: Colors.black),
                title: Text(l10n.pet_appointment_outcome, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showOutcomeDialog(context, event);
                },
              ),
              const SizedBox(height: 24),
            ],
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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.black, width: 3),
        ),
        title: Text(l10n.pet_appointment_outcome_title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
        content: TextField(
          controller: controller,
          maxLines: 4,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: l10n.pet_appointment_outcome_hint,
            hintStyle: const TextStyle(color: Colors.black54),
            filled: true,
            fillColor: AppColors.petPrimary,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black, width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black, width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.petPrimary, width: 2)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.common_cancel, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _registerOutcome(event, whatToDo, controller.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.petSecondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.black, width: 2)),
              elevation: 0,
            ),
            child: Text(l10n.pet_appointment_outcome_save, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Future<void> _registerOutcome(PetEvent event, String originalNotes, String outcome) async {
    final l10n = AppLocalizations.of(context)!;
    final prefix = l10n.pet_agenda_outcome_prefix;
    
    String updatedNotes = originalNotes;
    if (outcome.isNotEmpty) {
        updatedNotes = updatedNotes.isNotEmpty 
          ? "$updatedNotes\n\n[$prefix]: $outcome"
          : "[$prefix]: $outcome";
    }

    final updatedEvent = PetEvent(
      id: event.id,
      startDateTime: event.startDateTime,
      endDateTime: event.endDateTime,
      petIds: event.petIds,
      eventTypeIndex: event.eventTypeIndex,
      eventSubTypeIndex: event.eventSubTypeIndex,
      notes: updatedNotes.isNotEmpty ? updatedNotes : null,
      metrics: event.metrics,
      mediaPaths: event.mediaPaths,
      partnerId: event.partnerId,
      hasAIAnalysis: event.hasAIAnalysis,
      address: event.address,
    );

    await _repository.update(updatedEvent);
    _loadAppointments();
    widget.onEventDeleted?.call(); // Refresh parent view if necessary to show summary update
  }
}
