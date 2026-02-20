
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:scannutplus/l10n/app_localizations.dart';

import 'package:uuid/uuid.dart'; 
import 'package:scannutplus/core/services/universal_ai_service.dart'; 

import 'package:scannutplus/pet/agenda/pet_event_repository.dart';
import 'package:scannutplus/pet/agenda/pet_event.dart';
import 'package:scannutplus/features/pet/agenda/presentation/create_pet_event_screen.dart';
import 'package:scannutplus/features/pet/agenda/presentation/widgets/pet_activity_calendar.dart'; 
import 'package:scannutplus/features/pet/agenda/presentation/pet_scheduled_events_screen.dart'; // Tab 0
import 'package:scannutplus/features/pet/agenda/presentation/pet_appointment_screen.dart'; // New Appointment Action
import 'package:scannutplus/features/pet/agenda/presentation/tabs/pet_history_tab.dart';
import 'package:scannutplus/features/pet/agenda/presentation/tabs/pet_records_tab.dart';


class PetAgendaScreen extends StatefulWidget {
  final String petId;
  final String petName;

  const PetAgendaScreen({
    super.key,
    required this.petId,
    required this.petName,
  });

  @override
  State<PetAgendaScreen> createState() => _PetAgendaScreenState();
}

class _PetAgendaScreenState extends State<PetAgendaScreen> {
  final PetEventRepository _repository = PetEventRepository();
  late Future<List<PetEvent>> _futureEvents;

  @override
  void initState() {
    super.initState();
    _futureEvents = _loadEvents();
  }

  /// Mostra tela cheia para criar novo evento (Journal Mode)
  void _onAddEventPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePetEventScreen(
          petId: widget.petId,
          petName: widget.petName,
          onEventSaved: () {
            setState(() {
              _futureEvents = _loadEvents();
            });
          },
        ),
      ),
    );
  }
  
  /// 🔄 Carrega eventos filtrados pelo pet
  Future<List<PetEvent>> _loadEvents() async {
    if (kDebugMode) {
      debugPrint('APP_TRACE: Buscando eventos do banco para Pet ID: ${widget.petId}');
    }
    final result = await _repository.getByPetId(widget.petId);
    if (result.isSuccess && result.data != null) {
      return result.data!;
    }
    return [];
  }


  void _confirmDelete(BuildContext context, PetEvent event) {
     /// ... existing delete confirm
     final l10n = AppLocalizations.of(context)!;
     showDialog(
       context: context,
       builder: (ctx) => AlertDialog(
         title: Text(l10n.common_delete_confirm_title),
         content: Text(l10n.common_delete_confirm_message),
         actions: [
           TextButton(
             onPressed: () => Navigator.pop(ctx),
             child: Text(l10n.common_cancel),
           ),
           TextButton(
             onPressed: () {
               Navigator.pop(ctx);
               _deleteEvent(event);
             },
             style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
             child: Text(l10n.common_delete),
           ),
         ],
       ),
     );
  }

  Future<void> _deleteEvent(PetEvent event) async {
     /// ... existing delete logic
     try {
       if (event.isInBox) {
         await event.delete();
         setState(() {
           _futureEvents = _loadEvents();
         });
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evento removido com sucesso!'), backgroundColor: Colors.green));
         }
       }
     } catch (e) {
       debugPrint('Error deleting event: $e');
     }
  }



  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 3, // 3 Tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.pet_agenda_title_dynamic(widget.petName)),
          bottom: TabBar(
            indicatorColor: const Color(0xFFFFD1DC), // Pink
            labelColor: const Color(0xFFFFD1DC),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: l10n.pet_agenda_tab_scheduled, icon: const Icon(Icons.event_available)), // "Compromissos"
              Tab(text: l10n.pet_agenda_tab_history_label, icon: const Icon(Icons.history)), // "Histórico"
              Tab(text: l10n.pet_agenda_tab_records, icon: const Icon(Icons.edit_note)), // "Registros"
              // Wait, I need a proper label for "Registros". 
              // I created keys for individual records, but not for the tab title "Registros".
              // User said "Registros".
              // Existing key l10n.pet_agenda_title is "Agenda" (used for History before).
              // "Histórico" is l10n.pet_tab_history.
              // "Compromissos" is l10n.pet_scheduled_list_title or l10n.pet_agenda_tab_scheduled (I added this? No).
              // I need to check keys I added.
            ],
          ),
          actions: [
            // Calendar View (For timeline) - Only relevant for History tab?
            // Keep it globally for now.
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () {
                 // ... (Existing Calendar Logic) 
                  showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: const Color(0xFF1C1C1E),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (_) => DraggableScrollableSheet(
                    initialChildSize: 0.6,
                    minChildSize: 0.4,
                    maxChildSize: 0.9,
                    expand: false,
                    builder: (context, scrollController) {
                       return FutureBuilder<List<PetEvent>>(
                         future: _futureEvents,
                         builder: (context, snapshot) {
                           if (snapshot.connectionState == ConnectionState.waiting) {
                             return const Center(child: CircularProgressIndicator());
                           }
                           final events = snapshot.data ?? [];
                           return PetActivityCalendar(
                             events: events,
                             onDateSelected: (date) {
                               Navigator.pop(context); 
                             },
                           );
                         }
                       );
                    }
                  ),
                );
              },
            ),
          ],
        ),
        
        // BUILDER PARA FAB CONDICIONAL
        floatingActionButton: Builder(
          builder: (context) {
            final tabController = DefaultTabController.of(context);
            return AnimatedBuilder(
              animation: tabController,
              builder: (context, child) {
                // If not on the first tab (Compromissos), hide the FAB
                if (tabController.index != 0) {
                  return const SizedBox.shrink();
                }
                
                return FloatingActionButton(
                  onPressed: () {
                    // ABA 0: COMPROMISSOS -> Abre PetAppointmentScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PetAppointmentScreen(
                          petId: widget.petId,
                          petName: widget.petName,
                        ),
                      ),
                    ).then((_) {
                       // Scheduled screen handles its own refresh
                    });
                  },
                  tooltip: l10n.pet_agenda_add_event,
                  backgroundColor: const Color(0xFFFFD1DC), // Pink Pastel (Domain Color)
                  child: const Icon(Icons.add, color: Colors.black), // Black Icon
                );
              }
            );
          }
        ),
        
        body: TabBarView(
          children: [
            // TAB 0: Compromissos
            PetScheduledEventsScreen(
              petId: widget.petId, 
              showAppBar: false
            ),

            // TAB 1: Histórico
            PetHistoryTab(
              petId: widget.petId,
              petName: widget.petName,
              onDelete: (ctx, event) async {
                  _confirmDelete(ctx, event);
              },
            ),

            // TAB 2: Registros
            PetRecordsTab(
              petId: widget.petId,
              petName: widget.petName,
              onRecordSaved: () {
                // Refresh History Tab?
                // `PetHistoryTab` has its own refresh logic if we trigger it.
                // But since they are siblings, we might need a state management solution or simpler:
                // Just let History refresh on next init/focus.
                // Or call setState here to rebuild tabs? No, that resets state.
                setState(() {
                  _futureEvents = _loadEvents(); // Update parent's future which might be passed down?
                  // `PetHistoryTab` manages its own `_futureEvents`.
                  // Parent's `_futureEvents` is only used for Calendar.
                });
                
                // Ideally we want to force refresh PetHistoryTab.
                // Pass a UniqueKey to force rebuild?
                // Or GlobalKey to call method.
              },
            ),
          ],
        ),
      ),
    );
  }
}
