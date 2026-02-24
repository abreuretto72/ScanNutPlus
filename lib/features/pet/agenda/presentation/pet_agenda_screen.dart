
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:scannutplus/l10n/app_localizations.dart';


import 'package:scannutplus/pet/agenda/pet_event_repository.dart';
import 'package:scannutplus/pet/agenda/pet_event.dart';
import 'package:scannutplus/features/pet/agenda/presentation/create_pet_event_screen.dart';
import 'package:scannutplus/features/pet/agenda/presentation/widgets/pet_activity_calendar.dart'; 
import 'package:scannutplus/features/pet/agenda/presentation/pet_scheduled_events_screen.dart'; // Tab 0
import 'package:scannutplus/features/pet/agenda/presentation/pet_appointment_screen.dart'; // New Appointment Action
import 'package:scannutplus/features/pet/agenda/presentation/tabs/pet_history_tab.dart';
import 'package:scannutplus/features/pet/agenda/presentation/tabs/pet_records_tab.dart';
import 'package:scannutplus/features/feature_pet_agenda/models/parsed_agenda_intent.dart';
import 'package:scannutplus/features/feature_pet_agenda/presentation/agenda_voice_form_screen.dart';
import 'package:uuid/uuid.dart';

import 'package:scannutplus/features/pet/data/models/pet_event_type.dart';


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
  DateTime? _selectedDate;

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

  Future<void> _saveVoiceIntentToEvent(ParsedAgendaIntent intent) async {
    final startDateTime = intent.date ?? DateTime.now();
    
    DateTime finalStart = startDateTime;
    if (intent.time != null && intent.time!.contains(':')) {
      final parts = intent.time!.split(':');
      if (parts.length == 2) {
        final hours = int.tryParse(parts[0]) ?? startDateTime.hour;
        final mins = int.tryParse(parts[1]) ?? startDateTime.minute;
        finalStart = DateTime(startDateTime.year, startDateTime.month, startDateTime.day, hours, mins);
      }
    }

    final newEvent = PetEvent(
      id: const Uuid().v4(),
      startDateTime: finalStart,
      endDateTime: finalStart.add(const Duration(hours: 1)),
      petIds: [widget.petId],
      eventTypeIndex: PetEventType.appointment.index,
      hasAIAnalysis: false,
      notes: '',
      metrics: {
        'custom_title': intent.description ?? intent.type ?? 'Compromisso',
        'appointment_type': intent.type?.toLowerCase() ?? 'consultation_general',
        'is_appointment': true,
        'source': 'voice_agenda', 
      },
    );

    await _repository.saveEvent(newEvent);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Compromisso agendado!'), backgroundColor: Color(0xFF10AC84)),
      );
      setState(() {
        _scheduledTabKey = UniqueKey();
        _futureEvents = _loadEvents();
      });
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
            indicatorWeight: 4,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: const Color(0xFFFFD1DC), // Rosa Pastel
            labelColor: Colors.white,
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
                                       setState(() {
                                          _selectedDate = date;
                                       });
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
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD1DC), // Pink Pastel
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 3),
                      boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () async {
                          final intent = await Navigator.push<ParsedAgendaIntent>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AgendaVoiceFormScreen(
                                petName: widget.petName,
                              ),
                            ),
                          );

                          if (intent != null && mounted) {
                             await _saveVoiceIntentToEvent(intent);
                          }
                        },
                        child: Tooltip(
                          message: l10n.pet_agenda_add_event,
                          child: const Icon(Icons.add, color: Colors.black, size: 32),
                        ),
                      ),
                    ),
                  );
              }
            );
          }
        ),
        
        body: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               if (_selectedDate != null)
                 Padding(
                   padding: const EdgeInsets.only(bottom: 16.0, left: 16, right: 16),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                         decoration: BoxDecoration(
                           color: const Color(0xFFFFD1DC),
                           borderRadius: BorderRadius.circular(20),
                           border: Border.all(color: Colors.black, width: 2),
                         ),
                         child: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Text(
                               "Filtro: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}",
                               style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14),
                             ),
                             const SizedBox(width: 8),
                             InkWell(
                               onTap: () => setState(() => _selectedDate = null),
                               child: const Icon(Icons.close, color: Colors.black, size: 20),
                             ),
                           ],
                         ),
                       ),
                     ],
                   ),
                 ),
               Expanded(
                 child: TabBarView(
                   children: [
                     PetScheduledEventsScreen(
                       key: _scheduledTabKey,
                       petId: widget.petId, 
                       petName: widget.petName,
                       showAppBar: false,
                       filterDate: _selectedDate,
                     ),
                     PetHistoryTab(
                       key: _historyTabKey,
                       petId: widget.petId,
                       petName: widget.petName,
                       filterDate: _selectedDate,
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
            ],
          ),
        ),
      ),
    );
  }
}
