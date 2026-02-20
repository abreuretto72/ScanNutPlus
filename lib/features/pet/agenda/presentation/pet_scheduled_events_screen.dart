import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/pet/agenda/pet_event.dart';
import 'package:scannutplus/pet/agenda/pet_event_repository.dart';
import 'package:scannutplus/features/pet/presentation/extensions/pet_ui_extensions.dart';
import 'package:scannutplus/features/pet/agenda/logic/pet_notification_manager.dart';
import 'package:scannutplus/features/pet/data/models/pet_event_type.dart';

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
        return isAppt;
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
                    
                    final appointmentType = event.metrics?['appointment_type'] as String?;
                    final typeDisplay = appointmentType != null ? appointmentType.toAppointmentTypeDisplay(context) : null;

                    final categoryLabel = event.metrics?['source'] == 'appointment' 
                        ? title // fallback if source is basic
                        : title;
                    
                    // We need a helper to translate the type, or we just display the raw text if translation isn't available here.
                    // Actually, the 'custom_title' already contains the translated type by default in `pet_appointment_screen.dart`!
                    // E.g.: "Consulta Geral (Dr. João)" or just "Consulta Geral ()".
                    // But if the user typed something custom, 'custom_title' has that.
                    // Let's use the explicit fields from metrics.
                    
                    final whatToDo = event.notes ?? ''; // Notes might contain 'What to do' or we just show the title
                    
                    final rawCategory = event.eventTypeIndex == PetEventType.health.index ? l10n.pet_appointment_cat_health 
                        : event.eventTypeIndex == PetEventType.food.index ? l10n.pet_appointment_cat_nutrition 
                        : l10n.pet_appointment_tab_data;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showEventActionsModal(context, event),
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.petPrimary, // Rosa Pastel
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.black, width: 3),
                              boxShadow: const [
                                 BoxShadow(color: Colors.black, offset: Offset(6, 6)) // Hard Shadow
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // CABEÇALHO: Ícone, Categoria e Lixeira
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.black, width: 2),
                                            ),
                                            child: const Icon(Icons.calendar_month_rounded, color: Colors.black, size: 24),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              rawCategory.toUpperCase(), 
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.2),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white, 
                                          shape: BoxShape.circle, 
                                          border: Border.all(color: Colors.black, width: 2)
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.delete_rounded, color: Colors.redAccent, size: 22),
                                          padding: const EdgeInsets.all(6),
                                          constraints: const BoxConstraints(),
                                          onPressed: () => _confirmDelete(context, event.id),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // O QUE VAI FAZER (Título / Tipo)
                                  Text(
                                    title, 
                                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 22, height: 1.1, letterSpacing: -0.5),
                                  ),
                                  
                                  if (typeDisplay != null) ...[
                                     const SizedBox(height: 4),
                                     Text(
                                       typeDisplay.toUpperCase(),
                                       style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 14),
                                     ),
                                  ],
                                  
                                  if (whatToDo.isNotEmpty) ...[
                                     const SizedBox(height: 8),
                                     Container(
                                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                       decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.5),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.black, width: 1.5),
                                       ),
                                       child: Text(
                                         "${l10n.pet_field_what_to_do}: $whatToDo",
                                         style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontStyle: FontStyle.italic, fontSize: 13),
                                       ),
                                     ),
                                  ],
                                  
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Divider(color: Colors.black, height: 1, thickness: 3),
                                  ),
                                  
                                  // DATA E HORA
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time_rounded, color: Colors.black, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          DateFormat('dd/MM/yyyy • HH:mm').format(event.startDateTime),
                                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 15),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (leadTime != null && leadTime != 'none')
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black, width: 1.5)),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.notifications_active_rounded, size: 14, color: Colors.black),
                                              const SizedBox(width: 4),
                                              Text(leadTime, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  
                                  // PARCEIRO / PROFISSIONAL
                                  if (professional.isNotEmpty) ...[
                                     const SizedBox(height: 12),
                                     Row(
                                       children: [
                                         const Icon(Icons.storefront_rounded, color: Colors.black, size: 20),
                                         const SizedBox(width: 8),
                                         Expanded(
                                           child: Text(
                                             "${l10n.pet_appointment_tab_partner}: $professional", 
                                             style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 14),
                                             overflow: TextOverflow.ellipsis,
                                           ),
                                         ),
                                       ],
                                     ),
                                  ],
                                ],
                              ),
                            ),
                          ),
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
                Container(width: 40, height: 6, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 24),
                
                // Editar Agendamento
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to Edit (Requires creating navigation logic next)
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black, width: 3),
                        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                      ),
                      child: const Center(
                        child: Text("Editar Agendamento", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900)),
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
                        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                      ),
                      child: const Center(
                        child: Text("Registrar Desfecho", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }
    );
  }

  void _showOutcomeDialog(BuildContext context, PetEvent event) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: AppColors.petBackgroundDark,
          shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(24),
             side: const BorderSide(color: Colors.black, width: 4),
          ),
          title: const Text("Registrar Desfecho", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          content: TextField(
            controller: controller,
            maxLines: 4,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: "Como foi o atendimento?",
              hintStyle: const TextStyle(color: Colors.black54),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 3),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () async {
                final outcome = controller.text.trim();
                if (outcome.isNotEmpty) {
                   Navigator.pop(ctx);
                   
                   final updatedNotes = event.notes != null && event.notes!.isNotEmpty 
                       ? "${event.notes}\n\n[Desfecho]: $outcome" 
                       : "[Desfecho]: $outcome";
                       
                   final updatedEvent = event.copyWith(notes: updatedNotes);
                   
                   await _repository.update(updatedEvent);
                   _loadAppointments();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.petPrimary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.black, width: 2),
                ),
                elevation: 0,
              ),
              child: const Text("Salvar", style: TextStyle(fontWeight: FontWeight.w900)),
            )
          ],
        );
      }
    );
  }
}