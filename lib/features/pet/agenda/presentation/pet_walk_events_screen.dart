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

class PetWalkEventsScreen extends StatefulWidget {
  final String petId;
  final String petName;

  const PetWalkEventsScreen({
    super.key,
    required this.petId,
    required this.petName,
  });

  @override
  State<PetWalkEventsScreen> createState() => _PetWalkEventsScreenState();
}

class _PetWalkEventsScreenState extends State<PetWalkEventsScreen> {
  final PetEventRepository _repository = PetEventRepository();
  late Future<List<PetEvent>> _futureEvents;

  @override
  void initState() {
    super.initState();
    _futureEvents = _loadEvents();
  }

  /// Mostra tela cheia para criar novo evento (Journal Mode - Walk specific context)
  void _onAddEventPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePetEventScreen(
          petId: widget.petId,
          petName: widget.petName,
          // Could pre-select 'Activity' type if possible, but strict separation is done via filtering
          onEventSaved: () {
            setState(() {
              _futureEvents = _loadEvents();
            });
          },
        ),
      ),
    );
  }

  /// 🔄 Carrega eventos filtrados para PASSEIO
  Future<List<PetEvent>> _loadEvents() async {
    final result = await _repository.getByPetId(widget.petId);
    if (result.isSuccess && result.data != null) {
      // FILTER FOR WALKS
      return result.data!.where((e) {
          final isActivity = e.eventTypeIndex == PetEventType.activity.index;
          final isGoogle = e.metrics != null && e.metrics!['is_google_event'] == true;
          final isSummary = e.metrics != null && e.metrics!['is_summary'] == true;
          // Also include if the user manually selected Activity type
          return isActivity || isGoogle || isSummary;
      }).toList();
    }
    return [];
  }

  DateTime _onlyDate(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  Map<DateTime, List<PetEvent>> _groupByDay(List<PetEvent> events) {
    final Map<DateTime, List<PetEvent>> grouped = {};

    for (final event in events) {
      final dayKey = _onlyDate(event.startDateTime);
      grouped.putIfAbsent(dayKey, () => []);
      grouped[dayKey]!.add(event);
    }
    return grouped;
  }

  String _dayLabel(DateTime day, AppLocalizations l10n) {
    final today = _onlyDate(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    if (day == today) return l10n.pet_agenda_today;
    if (day == yesterday) return l10n.pet_agenda_yesterday;

    return '${day.day}/${day.month}/${day.year}';
  }

  // --- FEATURE: Walk Summary ---
  
  Future<void> _showSummaryDialog() async {
    final l10n = AppLocalizations.of(context)!;
    DateTime selectedDate = DateTime.now();
    TimeOfDay startTime = TimeOfDay.fromDateTime(DateTime.now().subtract(const Duration(hours: 1)));
    TimeOfDay endTime = TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Resumo do Passeio 🐾", style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Selecione o intervalo do passeio para gerar o resumo com IA."),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setDialogState(() => selectedDate = date);
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text("Início"),
                          subtitle: Text(startTime.format(context)),
                          onTap: () async {
                            final time = await showTimePicker(context: context, initialTime: startTime);
                            if (time != null) setDialogState(() => startTime = time);
                          },
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text("Fim"),
                          subtitle: Text(endTime.format(context)),
                          onTap: () async {
                            final time = await showTimePicker(context: context, initialTime: endTime);
                            if (time != null) setDialogState(() => endTime = time);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(child: Text(l10n.common_cancel), onPressed: () => Navigator.pop(ctx)),
                ElevatedButton.icon(
                  icon: const Icon(Icons.auto_awesome, color: Colors.white),
                  label: const Text("Gerar Resumo", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10AC84)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _generateWalkSummary(selectedDate, startTime, endTime);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _generateWalkSummary(DateTime date, TimeOfDay start, TimeOfDay end) async {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFF10AC84))),
    );

    try {
      final startDateTime = DateTime(date.year, date.month, date.day, start.hour, start.minute);
      final endDateTime = DateTime(date.year, date.month, date.day, end.hour, end.minute);

      final eventsResult = await _repository.getByPetId(widget.petId);
      if (!eventsResult.isSuccess || eventsResult.data == null) throw Exception("Erro ao buscar eventos.");

      final walkEvents = eventsResult.data!.where((e) {
        return e.startDateTime.isAfter(startDateTime) && e.startDateTime.isBefore(endDateTime);
      }).toList();

      if (walkEvents.isEmpty) {
        if (mounted) {
           Navigator.pop(context); 
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nenhum evento encontrado neste período.")));
        }
        return;
      }

      final eventsText = walkEvents.map((e) {
        final time = DateFormat('HH:mm').format(e.startDateTime);
        final notes = e.notes ?? "Sem notas";
        final typeStr = e.eventTypeIndex == 0 ? "Food" : 
                        e.eventTypeIndex == 3 ? "Hygiene/Stool/Urine" : 
                        e.eventTypeIndex == 4 ? "Activity" : "Other"; 
        return "- $time [$typeStr]: $notes";
      }).join("\n");

      final prompt = "${PetPrompts.promptWalkSummary}\n\nCONTEXT: Pet Name: ${widget.petName}\n\nEVENTS LOG:\n$eventsText";

      final summary = await UniversalAiService().analyzeText(
        systemPrompt: prompt,
        userPrompt: "Generate the Walk Summary now.",
      );

      final summaryTitle = "Resumo do Passeio ${DateFormat('HH:mm').format(startDateTime)} - ${DateFormat('HH:mm').format(endDateTime)}";
      
      final newEvent = PetEvent(
        id: const Uuid().v4(),
        startDateTime: endDateTime, 
        petIds: [widget.petId],
        eventTypeIndex: 5, // Other (Summary)
        hasAIAnalysis: true,
        notes: summary,
        metrics: {
          'custom_title': summaryTitle, 
          'is_summary': true,
          PetConstants.keyAiSummary: summary, 
        },
      );

      await _repository.saveEvent(newEvent);

      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Resumo gerado e salvo com sucesso! 🐾")));
        setState(() {
          _futureEvents = _loadEvents();
        });
      }

    } catch (e) {
      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
      }
    }
  }

  // --- DEBUG: SIMULATION ---
  Future<void> _simulateGoogleWalk() async {
    final now = DateTime.now();
    
    // 1. Context (Place)
    await _repository.saveEvent(PetEvent(
      id: const Uuid().v4(),
      startDateTime: now.subtract(const Duration(minutes: 40)),
      petIds: [widget.petId],
      eventTypeIndex: 5, 
      notes: "Local: Parque Ibirapuera (Parque Urbano). Área segura e dog-friendly.",
      metrics: {
        'custom_title': 'Google Places: Contexto', 
        'is_google_event': true,
        'google_type': 'context'
      },
      hasAIAnalysis: false,
    ));

    // 2. Weather
    await _repository.saveEvent(PetEvent(
      id: const Uuid().v4(),
      startDateTime: now.subtract(const Duration(minutes: 38)),
      petIds: [widget.petId],
      eventTypeIndex: 5,
      notes: "Temperatura: 24°C, Umidade: 60%, UV: Moderado (4). Asfalto: Aquecido.",
      metrics: {
        'custom_title': 'Google Weather: Clima', 
        'is_google_event': true,
        'google_type': 'weather'
      },
      hasAIAnalysis: false,
    ));

    // 3. Telemetry (Roads)
    await _repository.saveEvent(PetEvent(
      id: const Uuid().v4(),
      startDateTime: now.subtract(const Duration(minutes: 5)),
      petIds: [widget.petId],
      eventTypeIndex: 5,
      notes: "Distância: 3.2km (Snap-to-Roads), Ritmo: 12min/km (Lento/Farejando).",
      metrics: {
        'custom_title': 'Google Roads: Telemetria', 
        'is_google_event': true,
        'google_type': 'telemetry'
      },
      hasAIAnalysis: false,
    ));

    // 4. Altimetry (Elevation)
    await _repository.saveEvent(PetEvent(
      id: const Uuid().v4(),
      startDateTime: now.subtract(const Duration(minutes: 2)),
      petIds: [widget.petId],
      eventTypeIndex: 5,
      notes: "Ganho de Elevação: +45m. Terreno: Inclinado (Alto esforço calórico).",
      metrics: {
        'custom_title': 'Google Elevation: Altimetria', 
        'is_google_event': true,
        'google_type': 'altimetry'
      },
      hasAIAnalysis: false,
    ));

    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dados do Google (Simulados) adicionados!")));
       setState(() {
         _futureEvents = _loadEvents();
       });
    }
  }

  void _confirmDelete(BuildContext context, PetEvent event) {
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
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao deletar'), backgroundColor: Colors.red));
       }
     }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pet_walk_title_dynamic(widget.petName)), // "Passeio: {name}"
        actions: [
          // SIMULATE BUTTON (DEBUG)
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.bug_report, color: Colors.orange),
              tooltip: "Simular Google Walk",
              onPressed: _simulateGoogleWalk,
            ),
            
          // WALK SUMMARY ACTION
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Color(0xFF10AC84)), // Green Star
            tooltip: "Resumo com IA",
            onPressed: _showSummaryDialog,
          ),
          
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
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
      
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddEventPressed,
        tooltip: l10n.pet_agenda_add_event,
        backgroundColor: const Color(0xFFFFD1DC), // Pink Pastel (Domain Color)
        child: const Icon(Icons.add, color: Colors.black), // Black Icon
      ),
      
      body: FutureBuilder<List<PetEvent>>(
        future: _futureEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data ?? [];

          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.directions_walk, size: 64, color: Colors.grey),
                   const SizedBox(height: 16),
                   Text("Nenhum passeio registrado.", style: TextStyle(color: Colors.grey)), // TODO: Localize "No walks"
                ],
              ),
            );
          }

          final grouped = _groupByDay(events);
          final days = grouped.keys.toList()
            ..sort((a, b) => b.compareTo(a)); 

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
                    // Google Event Logic
                    final isSummary = event.metrics != null && event.metrics!['is_summary'] == true;
                    final isGoogleEvent = event.metrics != null && event.metrics!['is_google_event'] == true;
                    
                    // Card Color
                    final cardColor = isSummary ? const Color(0xFFFFF9C4) // Light Yellow/Gold for Summary
                                    : isGoogleEvent ? const Color(0xFFE3F2FD) // Light Blue for Google
                                    : const Color(0xFFFFD1DC); 
                    final textColor = Colors.black;

                    return Card(
                      color: cardColor, 
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: isSummary 
                                ? Icon(Icons.auto_awesome, size: 32, color: Colors.amber[800]) // Summary Icon
                            : isGoogleEvent
                                ? const Icon(Icons.map, size: 32, color: Color(0xFF4285F4)) // Google Maps Icon (Blue)
                                : Icon(Icons.directions_walk, size: 32, color: textColor), // Walk Icon

                        title: Text(
                           (event.metrics != null && event.metrics!.containsKey('custom_title'))
                              ? event.metrics!['custom_title']
                              : "Passeio", 
                           style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                           overflow: TextOverflow.ellipsis,
                        ),
                        
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Data e Hora (Black Text)
                            Text(
                              DateFormat("dd/MM/yyyy • HH:mm").format(event.startDateTime),
                              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                            ),
                         
                            // Palavras-chave (Resumo)
                            if (event.notes != null && event.notes!.isNotEmpty)
                               Padding(
                                padding: const EdgeInsets.only(top: 4, bottom: 4),
                                child: Text(
                                  event.notes!,
                                  style: TextStyle(
                                    fontSize: 12, 
                                    color: Colors.black87,
                                  ),
                                  maxLines: 4, 
                                  overflow: TextOverflow.ellipsis,
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
    );
  }
}
