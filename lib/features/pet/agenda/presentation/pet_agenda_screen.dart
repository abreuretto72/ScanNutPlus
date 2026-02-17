import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:scannutplus/l10n/app_localizations.dart';

import 'package:uuid/uuid.dart'; 
import 'package:scannutplus/core/services/universal_ai_service.dart'; 

import 'package:scannutplus/pet/agenda/pet_event_repository.dart';
import 'package:scannutplus/pet/agenda/pet_event.dart';
import 'package:scannutplus/features/pet/data/models/pet_event_type.dart'; 
import 'package:scannutplus/features/pet/agenda/domain/pet_event_type_extension.dart';
import 'package:scannutplus/features/pet/agenda/presentation/pet_event_type_label.dart';
import 'package:scannutplus/features/pet/agenda/presentation/create_pet_event_screen.dart';
import 'package:scannutplus/features/pet/agenda/presentation/pet_event_detail_screen.dart';
import 'package:scannutplus/features/pet/agenda/presentation/widgets/pet_activity_calendar.dart'; 
import 'package:scannutplus/features/pet/data/pet_constants.dart'; 
import 'package:scannutplus/features/pet/agenda/presentation/pet_scheduled_events_screen.dart'; // Tab 0
import 'package:scannutplus/features/pet/agenda/presentation/pet_appointment_screen.dart'; // New Appointment Action


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

  /// Normaliza data (yyyy-mm-dd)
  DateTime _onlyDate(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Agrupa eventos por dia
  Map<DateTime, List<PetEvent>> _groupByDay(List<PetEvent> events) {
    final Map<DateTime, List<PetEvent>> grouped = {};

    for (final event in events) {
      final dayKey = _onlyDate(event.startDateTime);
      grouped.putIfAbsent(dayKey, () => []);
      grouped[dayKey]!.add(event);
    }

    return grouped;
  }

  /// Label inteligente do dia
  String _dayLabel(DateTime day, AppLocalizations l10n) {
    final today = _onlyDate(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    if (day == today) return l10n.pet_agenda_today;
    if (day == yesterday) return l10n.pet_agenda_yesterday;

    return '${day.day}/${day.month}/${day.year}';
  }

  // --- FEATURE: Walk Summary ---
  // MOVED TO PetWalkEventsScreen
  
  // --- DEBUG: SIMULATION ---
  // MOVED TO PetWalkEventsScreen
  
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
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.pet_agenda_title_dynamic(widget.petName)),
          bottom: TabBar(
            indicatorColor: const Color(0xFFFFD1DC), // Pink
            labelColor: const Color(0xFFFFD1DC),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: l10n.pet_appointment_screen_title, icon: const Icon(Icons.event_available)), // "Agendamentos" / "Scheduled"
              Tab(text: l10n.pet_agenda_title, icon: const Icon(Icons.history)), // "Histórico" / "History"
            ],
          ),
          actions: [
            // Calendar View (For timeline)
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
            return FloatingActionButton(
              onPressed: () {
                // Lógica Condicional baseada na aba ativa
                final tabIndex = DefaultTabController.of(context).index;
                
                if (tabIndex == 0) {
                  // ABA 0: AGENDAMENTOS -> Abre PetAppointmentScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PetAppointmentScreen(
                        petId: widget.petId,
                        petName: widget.petName,
                      ),
                    ),
                  ).then((_) {
                     // No callback needed for Scheduled screen as it manages its own state, 
                     // but good practice to refresh any shared state if needed.
                  });
                } else {
                  // ABA 1: HISTÓRICO -> Abre CreatePetEventScreen (Journal)
                  _onAddEventPressed();
                }
              },
              tooltip: l10n.pet_agenda_add_event,
              backgroundColor: const Color(0xFFFFD1DC), // Pink Pastel (Domain Color)
              child: const Icon(Icons.add, color: Colors.black), // Black Icon
            );
          }
        ),
        
        body: TabBarView(
          children: [
            // TAB 0: Agendamentos (Scheduled)
            PetScheduledEventsScreen(petId: widget.petId),

            // TAB 1: Histórico (Timeline)
            FutureBuilder<List<PetEvent>>(
              future: _futureEvents,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
      
                // FILTER OUT WALKS
                // "Na agenda só tem a aba de histórico que não tem os registros de passeios"
                final events = (snapshot.data ?? []).where((e) {
                    final isActivity = e.eventTypeIndex == PetEventType.activity.index;
                    final isGoogle = e.metrics != null && e.metrics!['is_google_event'] == true;
                    final isSummary = e.metrics != null && e.metrics!['is_summary'] == true;
                    
                    // Also EXCLUDE 'is_appointment' future events IF we strictly want history?
                    // The user said "aba de histórico". Typically history = past + logs.
                    // But without the "Scheduled" tab, users might want to see scheduled items here too?
                    // The request was specifically "não tem os registros de passeios".
                    // So I will keep other events (including scheduled ones if they are treated as events in the backend, 
                    // but typically scheduled events have 'is_appointment' flag).
                    
                    // Let's keep it safe: Exclude ONLY Walks/Google/Summary as requested.
                    return !isActivity && !isGoogle && !isSummary;
                }).toList();
      
                if (events.isEmpty) {
                  return Center(
                    child: Text(l10n.pet_agenda_empty),
                  );
                }
      
                final grouped = _groupByDay(events);
                final days = grouped.keys.toList()
                  ..sort((a, b) => b.compareTo(a)); // mais recente primeiro
      
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: days.length,
                  itemBuilder: (context, index) {
                    final day = days[index];
                    final dayEvents = grouped[day]!;
      
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 📅 Cabeçalho do dia
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            _dayLabel(day, l10n),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
      
                        // 📋 Eventos do dia
                        ...dayEvents.map((event) {
                          final type = event.eventTypeIndex.toPetEventType();
                          // Custom Logic for FRIEND type
                          final isFriend = type == PetEventType.friend || (event.metrics != null && event.metrics!['event_type'] == 'FRIEND');
             
                          // Card Color: Green for Friend, Pink for Normal
                          final cardColor = isFriend ? const Color(0xFFE0F2F1) 
                                          : const Color(0xFFFFD1DC); 
                          final textColor = Colors.black;
      
                          return Card(
                            color: cardColor, 
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: (event.mediaPaths != null && event.mediaPaths!.isNotEmpty)
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(event.mediaPaths!.first),
                                        width: 48,
                                        height: 48,
                                        cacheWidth: 150, 
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(isFriend ? Icons.pets : type.icon, size: 32);
                                        },
                                      ),
                                    )
                                  : Icon(isFriend ? Icons.pets : type.icon, size: 32, color: textColor), // Default Icon
      
                              title: Row(
                                children: [
                                   Expanded(
                                     child: Text(
                                       isFriend ? (event.metrics?['guest_pet_name'] ?? 'Visitante') 
                                       : (event.metrics != null && event.metrics!.containsKey('custom_title'))
                                          ? event.metrics!['custom_title']
                                          : type.label(l10n), 
                                       style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                                       overflow: TextOverflow.ellipsis,
                                     ),
                                   ),
                                   if (isFriend) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)),
                                        child: const Text("FRIEND", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                      )
                                   ]
                                ],
                              ),
                              
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Data e Hora (Black Text)
                                  Text(
                                    DateFormat("dd/MM/yyyy • HH:mm").format(event.startDateTime),
                                    style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                                  ),
                                  
                                  // Tutor Name (if Friend)
                                  if (isFriend && event.metrics?['guest_tutor_name'] != null && event.metrics!['guest_tutor_name'].toString().isNotEmpty)
                                     Text("Tutor: ${event.metrics!['guest_tutor_name']}", style: TextStyle(fontSize: 12, color: Colors.grey[800], fontStyle: FontStyle.italic)),
      
                                  // Palavras-chave (Resumo)
                                  if (event.notes != null && event.notes!.isNotEmpty)
                                     Padding(
                                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                                      child: Builder(
                                        builder: (context) {
                                          // Extração de palavras-chave (>= 4 letras) for normal events
                                          final keywords = event.notes!
                                              .split(RegExp(r'\s+')) // Split por espaço
                                              .map((w) => w.replaceAll(RegExp(r'[.,;!]'), '')) // Remove pontuação
                                              .where((w) => w.length >= 4) // >= 4 letras
                                              .take(3) // Top 3
                                              .join(', ');
                                          
                                          if (keywords.isEmpty) return const SizedBox.shrink();
      
                                          return Text(
                                            keywords,
                                            style: TextStyle(
                                              fontSize: 12, 
                                              color: Colors.orange[800], 
                                              fontWeight: FontWeight.w600
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          );
                                        }
                                      ),
                                    ),
      
                                  // Endereço (se houver)
                                  if (event.address != null && event.address!.isNotEmpty)
                                     Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                           Icon(Icons.location_on, size: 12, color: textColor),
                                           const SizedBox(width: 4),
                                           Expanded(
                                             child: Text(
                                               event.address!,
                                               style: TextStyle(fontSize: 12, color: textColor),
                                               maxLines: 2, 
                                               overflow: TextOverflow.ellipsis,
                                             ),
                                           ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _confirmDelete(context, event),
                              ),
                              onTap: () {
                                debugPrint('[PET_AGENDA] Evento ${event.id} selecionado');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PetEventDetailScreen(
                                      event: event,
                                      petName: widget.petName,
                                    ),
                                  ),
                                ).then((_) {
                                   setState(() {
                                     _futureEvents = _loadEvents(); // Refresh on return
                                   });
                                });
                              },
                            ),
                          );
                        }),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
