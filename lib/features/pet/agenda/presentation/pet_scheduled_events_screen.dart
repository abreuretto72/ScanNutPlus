import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/pet/agenda/pet_event.dart';
import 'package:scannutplus/pet/agenda/pet_event_repository.dart';
import 'package:scannutplus/features/pet/presentation/extensions/pet_ui_extensions.dart';
import 'package:scannutplus/features/pet/agenda/logic/pet_notification_manager.dart';

class PetScheduledEventsScreen extends StatefulWidget {
  final String petId;

  final bool showAppBar;

  const PetScheduledEventsScreen({
    super.key, 
    required this.petId,
    this.showAppBar = true,
  });

  @override
  State<PetScheduledEventsScreen> createState() => _PetScheduledEventsScreenState();
}

class _PetScheduledEventsScreenState extends State<PetScheduledEventsScreen> {
  final PetEventRepository _repository = PetEventRepository();
  List<PetEvent> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
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
        final isFuture = e.startDateTime.isAfter(now);
        return isAppt && isFuture;
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.petBackgroundDark,
      appBar: widget.showAppBar ? AppBar(
        title: Text(l10n.pet_scheduled_list_title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ) : null,
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.petPrimary))
          : _appointments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                       const SizedBox(height: 16),
                       Text(l10n.pet_scheduled_empty, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _appointments.length,
                  itemBuilder: (context, index) {
                    final event = _appointments[index];
                    final rawTitle = event.metrics?['custom_title']?.toString();
                    final title = rawTitle != null 
                        ? rawTitle.toCategoryDisplay(context) 
                        : l10n.pet_appointment_tab_data; // Default: 'Appointment'
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
                          child: const Icon(Icons.calendar_month, color: AppColors.petPrimary),
                        ),
                        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm').format(event.startDateTime),
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
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _confirmDelete(context, event.id),
                        ),
                      ),
                    );
                  },
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
}
