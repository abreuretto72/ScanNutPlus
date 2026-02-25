import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/pet/agenda/pet_event_repository.dart';
import 'package:scannutplus/pet/agenda/pet_event.dart';
import 'package:scannutplus/features/pet/data/models/pet_event_type.dart';
import 'package:scannutplus/features/pet/agenda/domain/pet_event_type_extension.dart';
import 'package:scannutplus/features/pet/presentation/extensions/pet_ui_extensions.dart';
import 'package:scannutplus/features/pet/agenda/presentation/pet_event_detail_screen.dart';
import 'package:scannutplus/features/pet/agenda/presentation/pet_event_type_label.dart';

class PetHistoryTab extends StatefulWidget {
  final String petId;
  final String petName;
  final DateTime? filterDate;
  final Future<void> Function(BuildContext, PetEvent) onDelete;

  const PetHistoryTab({
    super.key,
    required this.petId,
    required this.petName,
    required this.onDelete,
    this.filterDate,
  });

  @override
  State<PetHistoryTab> createState() => _PetHistoryTabState();
}

class _PetHistoryTabState extends State<PetHistoryTab> {
  final PetEventRepository _repository = PetEventRepository();
  late Future<List<PetEvent>> _futureEvents;

  @override
  void initState() {
    super.initState();
    _futureEvents = _loadEvents();
  }

  void refresh() {
    setState(() {
      _futureEvents = _loadEvents();
    });
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

  // --- FEATURE: SMART MEDICATION (DAR DOSE) ---
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

  // --- HELPER: Source Info ---
  (String, IconData, Color) _getSourceInfo(String? source, AppLocalizations l10n) {
    if (source == null) return (l10n.source_analysis, Icons.analytics, Colors.pink);
    switch (source) {
      case 'walk': return (l10n.source_walk, Icons.directions_walk, Colors.green);
      case 'appointment': return (l10n.source_appointment, Icons.calendar_today, Colors.blue); 
      case 'nutrition': return (l10n.source_nutrition, Icons.restaurant, Colors.orange);
      case 'health_summary': return (l10n.source_health, Icons.medical_services, Colors.red);
      case 'profile': return (l10n.source_profile, Icons.badge, Colors.purple);
      case 'journal': return (l10n.source_journal, Icons.edit_note, Colors.grey);
      case 'walk_journal': return (l10n.source_walk, Icons.directions_walk, Colors.green);
      case 'friend': return (l10n.source_friend, Icons.people, Colors.teal);
      case 'analysis': 
      default: return (l10n.source_analysis, Icons.analytics, Colors.pink);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<List<PetEvent>>(
      future: _futureEvents,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD1DC)));
        }

        // FILTER LOGIC
        // Exclude 'Activity' (Walks) IF we want to separate them.
        // The user previously said: "Na agenda só tem a aba de histórico que não tem os registros de passeios"
        // implying they WANTED to see walks in history or they were missing.
        // But we have `PetWalkEventsScreen`.
        // Let's INCLUDE everything here for a full history timeline, except maybe future appointments?
        // Let's mirror the previous logic but keep it robust.
        // Logic from previous file:
        // final events = (snapshot.data ?? []).where((e) {
        //     final isActivity = e.eventTypeIndex == PetEventType.activity.index;
        //     final isGoogle = e.metrics != null && e.metrics!['is_google_event'] == true;
        //     final isSummary = e.metrics != null && e.metrics!['is_summary'] == true;
        //     return !isActivity && !isGoogle && !isSummary;
        // }).toList();
        
        // I will RELEASE restrictions to show ALL history here as "Timeline".
        // "Histórico (Agenda)" usually means everything.
        // If users want specific walks, they go to Walk section.
        // Let's keep the filter for now to avoid regression if the user wanted them separate.
        // Wait, the prompt says "Na agenda vamos ter 3 abas... Histórico(Agenda)".
        // I'll default to showing EVERYTHING except strictly 'future' appointments which are in Tab 1?
        // Actually, let's keep the previous filter for "Walks" to not clutter if that was the design.
        // But "Registros" (Weight, Meds) MUST appear here.
        
        final events = (snapshot.data ?? []).where((e) {
           // We filter out Walks/Google/Summary as they have their own specialized view?
           // Or should we show them?
           // "Histórico" usually implies ALL past events.
           // I will comment out the filter to show EVERYTHING, effectively making it a true Global Timeline.
           // Only separate "Scheduled" (Future).
           
           // Filter Future Appointments and pending Medications (they are in Tab 1)
           final isAppointment = e.metrics?['is_appointment'] == true;
           final isMedication = e.metrics?['is_medication'] == true;
           final isTaken = e.metrics?['status'] == 'taken';
           final isFuture = e.startDateTime.isAfter(DateTime.now());
           
           // Esconde compromissos normais que ainda vão acontecer
           if (isAppointment && isFuture) return false;
           // Esconde medicações que ainda não foram tomadas (pendentes, atrasadas ou futuras)
           if (isMedication && !isTaken) return false;

           // Selected Date Filter
           if (widget.filterDate != null) {
             if (!DateUtils.isSameDay(e.startDateTime, widget.filterDate)) return false;
           }

           return true; 
        }).toList();

        // EXCLUIR EVENTOS DE AMIGOS (E LEGADOS) DA AGENDA
        final myPetsEvents = events.where((event) {
           final type = event.eventTypeIndex.toPetEventType();
           final isFriendByType = type == PetEventType.friend || (event.metrics != null && event.metrics!['event_type'] == 'FRIEND');
           final isFriendByNotes = (event.notes != null && event.notes!.contains('[${l10n.pet_friend_prefix}:'));
           final isFriend = isFriendByType || isFriendByNotes;
           return !isFriend;
        }).toList();

        // Return a clean single timeline view
        return _buildEventList(myPetsEvents, l10n);
      },
    );
  }

  Widget _buildEventList(List<PetEvent> eventsList, AppLocalizations l10n) {
     if (eventsList.isEmpty) {
        return Center(
          child: Text(l10n.pet_agenda_empty, style: const TextStyle(color: Colors.white70)),
        );
     }

     final grouped = _groupByDay(eventsList);
     final days = grouped.keys.toList()
        ..sort((a, b) => b.compareTo(a)); // Reset to most recent first

     return RefreshIndicator(
        onRefresh: () async {
          refresh();
        },
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 80, top: 10),
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
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white70),
                  ),
                ),

                // 📋 Eventos do dia
                ...dayEvents.map((event) {
                  final type = event.eventTypeIndex.toPetEventType();
                  // Custom Logic for FRIEND type
                  final isFriend = type == PetEventType.friend || (event.metrics != null && event.metrics!['event_type'] == 'FRIEND');
     
                  // Card Color: Lilac for Friend, Pink for Normal
                  final cardColor = isFriend ? const Color(0xFFE0BBE4) // Domain Color Lilac
                                  : const Color(0xFFFFD1DC); 
                  final textColor = Colors.black;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: cardColor, 
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black, width: 3),
                      boxShadow: const [
                        BoxShadow(color: Colors.black, offset: Offset(5, 5))
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PetEventDetailScreen(
                                event: event,
                                petName: widget.petName,
                              ),
                            ),
                          ).then((_) {
                              refresh();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // TRACE LOG PARA DEBUGAR A IMAGEM DO PASSEIO
                              if (kDebugMode && type == PetEventType.activity)
                                Builder(builder: (context) {
                                  debugPrint('APP_TRACE_PASSEIO_ID: ${event.id} | MEDIAPATHS: ${event.mediaPaths}');
                                  return const SizedBox.shrink();
                                }),
                              // Icon or Image (Chunky)
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.black, width: 2),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: (event.mediaPaths != null && event.mediaPaths!.isNotEmpty)
                                    ? Image.file(
                                        File(event.mediaPaths!.first),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Icon(isFriend ? Icons.pets_rounded : type.icon, size: 32, color: Colors.black),
                                      )
                                    : Icon(isFriend ? Icons.pets_rounded : type.icon, size: 32, color: Colors.black),
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title Row
                                    Row(
                                      children: [
                                         Expanded(
                                            child: Text(
                                              (event.metrics != null && event.metrics!['is_metric_record'] == true)
                                                 ? "Métricas Clínicas: ${event.metrics!['custom_title'] ?? type.label(l10n)}"
                                              : (event.metrics != null && event.metrics!.containsKey('custom_title'))
                                                 ? (event.metrics!['custom_title'] as String).toCategoryDisplay(context)
                                                 : (type == PetEventType.activity)
                                                    ? (isFriend ? l10n.pet_friend_walk_title_dynamic(event.metrics?['guest_pet_name'] ?? l10n.pet_unknown_name) : l10n.pet_walk_title_dynamic(widget.petName))
                                                    : (isFriend ? (event.metrics?['guest_pet_name'] ?? l10n.history_guest) : type.label(l10n)), 
                                             style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 18, letterSpacing: -0.3),
                                             overflow: TextOverflow.ellipsis,
                                             maxLines: 2,
                                           ),
                                         ),
                                         if (isFriend)
                                            Container(
                                              margin: const EdgeInsets.only(left: 8),
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
                                              child: Text(l10n.source_friend.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                                            )
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                     Text(
                                       "${DateFormat.yMd(l10n.localeName).format(event.startDateTime)} • ${DateFormat.Hm(l10n.localeName).format(event.startDateTime)}",
                                       style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 13),
                                     ),
                                    const SizedBox(height: 6),
                                    
                                    // Source Badge
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Builder(
                                              builder: (context) {
                                                final sourceKey = event.metrics?['source'];
                                                final sourceInfo = _getSourceInfo(sourceKey, l10n);
                                                return Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black, width: 1.5)),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(sourceInfo.$2, size: 12, color: Colors.black),
                                                      const SizedBox(width: 4),
                                                      Flexible(
                                                        child: Text(
                                                          sourceInfo.$1.toUpperCase(), 
                                                          style: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    if (isFriend && event.metrics?['guest_tutor_name'] != null && event.metrics!['guest_tutor_name'].toString().isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text("${l10n.pet_label_tutor}: ${event.metrics!['guest_tutor_name']}", style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w700)),
                                    ],
        
                                    // Address or specific details
                                    if (event.address != null && event.address!.isNotEmpty) ...[
                                       const SizedBox(height: 8),
                                       Row(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                            const Icon(Icons.location_on_rounded, size: 14, color: Colors.black),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                event.address!,
                                                style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w600),
                                                maxLines: 2, 
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                         ],
                                       ),
                                    ],
                                      
                                      if (event.metrics != null && event.metrics!['is_medication'] == true && event.metrics!['status'] == 'pending')
                                          Container(
                                            margin: const EdgeInsets.only(top: 8),
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              onPressed: () => _markMedicationAsTaken(context, event),
                                              icon: const Icon(Icons.check, color: Colors.white, size: 18),
                                              label: Text(l10n.pet_med_take_dose, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF10AC84), // Plant Green
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.black, width: 2)),
                                                elevation: 0,
                                              ),
                                            ),
                                          ),

                                   ],
                                 ),
                               ),
                              
                              // Actions Column (Attachment Indicator + Delete)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (event.mediaPaths != null && event.mediaPaths!.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(left: 8, bottom: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.black, width: 2),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(6),
                                        child: Icon(Icons.attach_file_rounded, color: Colors.black87, size: 20),
                                      ),
                                    ),
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.black, width: 2),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.delete_rounded, color: Colors.redAccent, size: 20),
                                      padding: const EdgeInsets.all(6),
                                      constraints: const BoxConstraints(),
                                      onPressed: () => widget.onDelete(context, event),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
     );
  }
}
