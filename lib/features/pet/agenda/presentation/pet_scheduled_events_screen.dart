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
  State<PetScheduledEventsScreen> createState() =>
      _PetScheduledEventsScreenState();
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

    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.petPrimary));
    }

    if (_appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_rounded,
                size: 60, color: Colors.black.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(l10n.pet_scheduled_empty,
                style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 80),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          itemCount: _appointments.length + 1,
          itemBuilder: (context, index) {
            if (index == _appointments.length) {
              return const SizedBox(height: 80);
            }

            final event = _appointments[index];
            final rawTitle = event.metrics?['custom_title']?.toString();
            final title =
                rawTitle != null ? rawTitle : l10n.pet_appointment_tab_data;
            final professional =
                event.metrics?['professional']?.toString() ?? '';
            final leadTime =
                event.metrics?['notification_lead_time']?.toString();

            final appointmentType =
                event.metrics?['appointment_type']?.toString();
            final typeDisplay =
                appointmentType != null ? appointmentType : null;

            final whatToDo = event.notes ?? '';

            final rawCategory =
                event.eventTypeIndex == PetEventType.health.index
                    ? l10n.pet_appointment_cat_health
                    : event.eventTypeIndex == PetEventType.food.index
                        ? l10n.pet_appointment_cat_nutrition
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
                      color: AppColors.petPrimary,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black, width: 3),
                      boxShadow: const [
                        BoxShadow(color: Colors.black, offset: Offset(6, 6))
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                      border: Border.all(
                                          color: Colors.black, width: 2),
                                    ),
                                    child: const Icon(
                                        Icons.calendar_month_rounded,
                                        color: Colors.black,
                                        size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      rawCategory.toUpperCase(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 10,
                                          letterSpacing: 1.2),
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    color: Colors.black54),
                                onPressed: () =>
                                    _confirmDelete(context, event.id),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            title,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 20),
                          ),
                          if (typeDisplay != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              typeDisplay.toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14),
                            ),
                          ],
                          if (whatToDo.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.black, width: 1.5),
                              ),
                              child: Text(
                                "${l10n.pet_field_what_to_do}: $whatToDo",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 13),
                              ),
                            ),
                          ],
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Divider(
                                color: Colors.black, height: 1, thickness: 3),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded,
                                  color: Colors.black, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  DateFormat.yMd(Localizations.localeOf(context)
                                          .toString())
                                      .add_jm()
                                      .format(event.startDateTime),
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (leadTime != null && leadTime != 'none')
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.black, width: 1.5)),
                                  child: Row(
                                    children: [
                                      const Icon(
                                          Icons.notifications_active_rounded,
                                          size: 14,
                                          color: Colors.black),
                                      const SizedBox(width: 4),
                                      Text(leadTime,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          if (professional.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.storefront_rounded,
                                    color: Colors.black, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "${l10n.pet_appointment_tab_partner}: $professional",
                                    style: const TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14),
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
              title: Text(l10n.pet_delete_confirmation_title,
                  style: const TextStyle(color: Colors.white)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.common_cancel,
                      style: const TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _deleteAppointment(id);
                  },
                  child: Text(l10n.common_delete,
                      style: const TextStyle(color: Colors.red)),
                ),
              ],
            ));
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
                Container(
                  width: 40,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 24),

                // Editar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to Edit
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black, width: 3),
                        boxShadow: const [
                          BoxShadow(color: Colors.black, offset: Offset(4, 4))
                        ],
                      ),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.pet_agenda_edit_btn,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w900),
                        ),
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
                        boxShadow: const [
                          BoxShadow(color: Colors.black, offset: Offset(4, 4))
                        ],
                      ),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.pet_agenda_outcome_btn,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOutcomeDialog(BuildContext context, PetEvent event) {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.pet_agenda_outcome_title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: controller,
                        maxLines: 4,
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: l10n.pet_agenda_outcome_hint,
                          hintStyle: const TextStyle(color: Colors.black54),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.black, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.black, width: 3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(
                              l10n.common_cancel,
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () async {
                              final outcome = controller.text.trim();
                              if (outcome.isNotEmpty) {
                                Navigator.pop(ctx);

                                final prefix = l10n.pet_agenda_outcome_prefix;
                                final updatedNotes = event.notes != null &&
                                        event.notes!.isNotEmpty
                                    ? "${event.notes}\n\n[$prefix]: $outcome"
                                    : "[$prefix]: $outcome";

                                final updatedEvent =
                                    event.copyWith(notes: updatedNotes);

                                await _repository.update(updatedEvent);
                                _loadAppointments();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.petPrimary,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                    color: Colors.black, width: 2),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              l10n.common_save,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
