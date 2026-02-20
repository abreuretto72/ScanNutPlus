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
  final Future<void> Function(BuildContext, PetEvent) onDelete;

  const PetHistoryTab({
    super.key,
    required this.petId,
    required this.petName,
    required this.onDelete,
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
      // case 'appointment': return (l10n.source_appointment, Icons.calendar_today, Colors.blue); // Usually in Scheduled tab
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
           
           // Filter Future Appointments (they are in Tab 1)
           final isAppointment = e.metrics?['is_appointment'] == true;
           final isFuture = e.startDateTime.isAfter(DateTime.now());
           if (isAppointment && isFuture) return false;

           return true; 
        }).toList();

        if (events.isEmpty) {
          return Center(
            child: Text(l10n.pet_agenda_empty, style: const TextStyle(color: Colors.white70)),
          );
        }

        final grouped = _groupByDay(events);
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
                                    ? (event.metrics!['custom_title'] as String).toCategoryDisplay(context)
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
                            
                            // Source Badge
                            Builder(
                              builder: (context) {
                                final sourceKey = event.metrics?['source'];
                                final sourceInfo = _getSourceInfo(sourceKey, l10n);
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4, bottom: 2),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(sourceInfo.$2, size: 12, color: sourceInfo.$3),
                                      const SizedBox(width: 4),
                                      Text(sourceInfo.$1.toUpperCase(), style: TextStyle(fontSize: 10, color: sourceInfo.$3, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                );
                              }
                            ),
                            
                             if (isFriend && event.metrics?['guest_tutor_name'] != null && event.metrics!['guest_tutor_name'].toString().isNotEmpty)
                                Text("${l10n.pet_label_tutor}: ${event.metrics!['guest_tutor_name']}", style: TextStyle(fontSize: 12, color: Colors.grey[800], fontStyle: FontStyle.italic)),

                            // Palavras-chave (Resumo)
                            if (event.notes != null && 
                                event.notes!.isNotEmpty && 
                                !event.notes!.contains('pet_title_') && 
                                !event.notes!.contains('Pet_title_') &&
                                !event.notes!.contains('Lab_result') &&
                                !event.notes!.contains('lab_result'))
                               Padding(
                                padding: const EdgeInsets.only(top: 4, bottom: 4),
                                child: Builder(
                                  builder: (context) {
                                    // Full text for structured data might be better than keywords
                                    // For now, keep logic but allow full text if short
                                    if (event.notes!.length < 50) {
                                       return Text(
                                         event.notes!,
                                         style: TextStyle(fontSize: 12, color: Colors.black87),
                                       );
                                    }

                                    // Extração de palavras-chave (>= 4 letras) for normal events
                                    final keywords = event.notes!
                                        .split(RegExp(r'\s+')) // Split por espaço
                                        .map((w) => w.replaceAll(RegExp(r'[.,;!]'), '')) // Remove pontuação
                                        .where((w) => w.length >= 4) // >= 4 letras
                                        .take(5) // Top 5
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
                          onPressed: () => widget.onDelete(context, event),
                        ),
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
                              refresh(); // Refresh on return
                          });
                        },
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
