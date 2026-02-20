
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
  Key _scheduledTabKey = UniqueKey();
  Key _historyTabKey = UniqueKey();

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
       await _repository.delete(event.id);
       setState(() {
         _futureEvents = _loadEvents();
         _scheduledTabKey = UniqueKey();
         _historyTabKey = UniqueKey();
       });
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evento removido com sucesso!'), backgroundColor: Colors.green));
       }
     } catch (e) {
       debugPrint('Error deleting event: $e');
     }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 3, 
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          title: Text(l10n.pet_agenda_title_dynamic(widget.petName),
             style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5, fontSize: 22, color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: TabBar(
            indicator: BoxDecoration(
              color: const Color(0xFFFFD1DC), // Rosa Pastel 
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 2),
              // shadow isn't natively supported easy inside tabbar indicator without custom painters, but we can fake weight via border
            ),
            indicatorPadding: const EdgeInsets.symmetric(horizontal: -8, vertical: 6),
            labelColor: Colors.black,
            labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
            unselectedLabelColor: Colors.white54,
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: l10n.pet_agenda_tab_scheduled), // Compromissos
              Tab(text: l10n.pet_agenda_tab_history_label), // Histórico
              Tab(text: 'Registros'), // Registros
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24, width: 1.5)
              ),
              child: IconButton(
                icon: const Icon(Icons.calendar_month_rounded, color: Color(0xFFFFD1DC), size: 22),
                tooltip: 'Ver Calendário',
                onPressed: () {
                    showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: const Color(0xFF121212),
                    shape: const RoundedRectangleBorder(
                       borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    builder: (_) => DraggableScrollableSheet(
                      initialChildSize: 0.7,
                      minChildSize: 0.5,
                      maxChildSize: 0.95,
                      expand: false,
                      builder: (context, scrollController) {
                         return Column(
                           children: [
                             Container(
                               margin: const EdgeInsets.only(top: 12, bottom: 24),
                               width: 48, height: 6,
                               decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                             ),
                             Expanded(
                               child: FutureBuilder<List<PetEvent>>(
                                 future: _futureEvents,
                                 builder: (context, snapshot) {
                                   if (snapshot.connectionState == ConnectionState.waiting) {
                                     return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD1DC), strokeWidth: 4));
                                   }
                                   final events = snapshot.data ?? [];
                                   return PetActivityCalendar(
                                     events: events,
                                     onDateSelected: (date) {
                                       Navigator.pop(context); 
                                     },
                                   );
                                 }
                               ),
                             ),
                           ],
                         );
                      }
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        
        floatingActionButton: Builder(
          builder: (context) {
            final tabController = DefaultTabController.of(context);
            return AnimatedBuilder(
              animation: tabController,
              builder: (context, child) {
                if (tabController.index != 0) {
                  return const SizedBox.shrink();
                }
                
                return Container(
                  decoration: BoxDecoration(
                    boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PetAppointmentScreen(
                            petId: widget.petId,
                            petName: widget.petName,
                          ),
                        ),
                      ).then((_) {
                         setState(() {
                           _scheduledTabKey = UniqueKey();
                           _futureEvents = _loadEvents();
                         });
                      });
                    },
                    tooltip: l10n.pet_agenda_add_event,
                    elevation: 0,
                    backgroundColor: const Color(0xFFFFD1DC), // Pink Pastel
                    shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(20), 
                       side: const BorderSide(color: Colors.black, width: 3)
                    ),
                    icon: const Icon(Icons.add_rounded, color: Colors.black, size: 28),
                    label: const Text('NOVO', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5)),
                  ),
                );
              }
            );
          }
        ),
        
        body: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: TabBarView(
            children: [
              PetScheduledEventsScreen(
                key: _scheduledTabKey,
                petId: widget.petId, 
                showAppBar: false
              ),
              PetHistoryTab(
                key: _historyTabKey,
                petId: widget.petId,
                petName: widget.petName,
                onDelete: (ctx, event) async {
                    _confirmDelete(ctx, event);
                },
              ),
              PetRecordsTab(
                petId: widget.petId,
                petName: widget.petName,
                onRecordSaved: () {
                  setState(() {
                    _futureEvents = _loadEvents(); 
                    _historyTabKey = UniqueKey();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
