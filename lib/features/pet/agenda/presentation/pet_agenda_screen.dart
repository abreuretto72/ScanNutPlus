import 'dart:io'; // Added for File
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:scannutplus/l10n/app_localizations.dart';

import 'package:scannutplus/pet/agenda/pet_event_repository.dart';
import 'package:scannutplus/pet/agenda/pet_event.dart';
// import 'package:scannutplus/features/pet/data/models/pet_event_type.dart'; // Unused
import 'package:scannutplus/features/pet/agenda/domain/pet_event_type_extension.dart';
import 'package:scannutplus/features/pet/agenda/presentation/pet_event_type_label.dart';
import 'package:scannutplus/features/pet/agenda/presentation/create_pet_event_screen.dart';
import 'package:scannutplus/features/pet/agenda/presentation/pet_event_detail_screen.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart'; // Constants

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
      if (kDebugMode) {
         debugPrint('APP_TRACE: Eventos retornados: ${result.data!.length}');
      }
      return result.data!;
    }
    if (kDebugMode) {
      debugPrint('APP_TRACE: Nenhum evento encontrado ou erro: ${result.status}');
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pet_agenda_title_dynamic(widget.petName)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddEventPressed,
        tooltip: l10n.pet_agenda_add_event,
        child: const Icon(Icons.add),
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

                    return Card(
                      color: const Color(0xFFFFD1DC), // Rosa Pastel (Pet Domain)
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
                                  cacheWidth: 150, // Optimization: Memory
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(type.icon, size: 32);
                                  },
                                ),
                              )
                            : (event.metrics != null && event.metrics![PetConstants.keyVideoPath] != null)
                                ? Icon(Icons.videocam, size: 32, color: Colors.black) // Video Analysis Icon
                            : (event.metrics != null && event.metrics![PetConstants.keyAudioPath] != null)
                                ? Icon(Icons.campaign, size: 32, color: Colors.black) // Vocal Analysis Icon
                                : Icon(type.icon, size: 32, color: Colors.black), // Default Icon
                        title: Text(type.label(l10n), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Data e Hora (Black Text)
                            Text(
                              DateFormat("dd/MM/yyyy • HH:mm").format(event.startDateTime),
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                            ),
                            
                            // Palavras-chave (Resumo)
                            if (event.notes != null && event.notes!.isNotEmpty)
                               Padding(
                                padding: const EdgeInsets.only(top: 4, bottom: 4),
                                child: Builder(
                                  builder: (context) {
                                    // Extração de palavras-chave (>= 4 letras)
                                    final keywords = event.notes!
                                        .split(RegExp(r'\s+')) // Split por espaço
                                        .map((w) => w.replaceAll(RegExp(r'[.,;!]'), '')) // Remove pontuação
                                        .where((w) => w.length >= 4) // >= 4 letras
                                        .take(3) // Top 3
                                        .join(', ');
                                    
                                    if (keywords.isEmpty) return const SizedBox.shrink();

                                    return Text(
                                      l10n.pet_agenda_summary_format(keywords),
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
                                     const Icon(Icons.location_on, size: 12, color: Colors.black),
                                     const SizedBox(width: 4),
                                     Expanded(
                                       child: Text(
                                         event.address!,
                                         style: const TextStyle(fontSize: 12, color: Colors.black),
                                         maxLines: 2, // Aumentado para 2 linhas
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
    );
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
      final id = event.id; // Capture ID before delete
      if (event.isInBox) {
        await event.delete();
        debugPrint('APP_TRACE: Evento $id removido pelo usuário');
        
        // UI Sync: Refresh list immediately
        setState(() {
          _futureEvents = _loadEvents();
        });

        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Evento removido com sucesso!'), backgroundColor: Colors.green), // TODO: l10n
           );
        }
      }
    } catch (e) {
      debugPrint('Error deleting event: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(l10n.pet_error_delete_event), backgroundColor: Colors.red),
        );
      }
    }
  }
}
