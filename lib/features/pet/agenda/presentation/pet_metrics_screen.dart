import 'package:flutter/material.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/pet/agenda/pet_event.dart';
import 'package:scannutplus/pet/agenda/pet_event_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:scannutplus/features/pet/data/models/pet_event_type.dart';
import 'package:scannutplus/features/pet/agenda/services/pet_metrics_pdf_service.dart';
import 'package:scannutplus/features/pet/presentation/universal_pdf_preview_screen.dart';

class PetMetricsScreen extends StatefulWidget {
  final String petId;
  final String petName;

  const PetMetricsScreen({
    super.key,
    required this.petId,
    required this.petName,
  });

  @override
  State<PetMetricsScreen> createState() => _PetMetricsScreenState();
}

class _PetMetricsScreenState extends State<PetMetricsScreen> {
  final PetEventRepository _repository = PetEventRepository();
  Map<String, String> _lastMetrics = {};
  List<PetEvent> _allMetricsEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLastMetrics();
  }

  Future<void> _loadLastMetrics() async {
    final result = await _repository.getByPetId(widget.petId);
    if (result.isSuccess && result.data != null) {
      final metricsEvents = result.data!.where((e) => e.metrics?['is_metric_record'] == true).toList();
      metricsEvents.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
      
      final Map<String, String> latest = {};
      for (final ev in metricsEvents) {
        final m = ev.metrics ?? {};
        for (final key in m.keys) {
          if (key != 'is_metric_record' && key != 'custom_title' && m[key] != null) {
            latest[key] = m[key].toString();
          }
        }
      }
      if (mounted) {
        setState(() {
          _allMetricsEvents = metricsEvents;
          _lastMetrics = latest;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveMetric(String key, String value, String label, DateTime selectedDate, TimeOfDay selectedTime) async {
    if (value.trim().isEmpty) return;
    
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    
    final metricsData = {
      'is_metric_record': true,
      'custom_title': label,
      'source': 'health_metrics', // Origin flag
      key: value.trim(),
    };

    final event = PetEvent(
      id: const Uuid().v4(),
      startDateTime: now,
      endDateTime: now,
      petIds: [widget.petId],
      eventTypeIndex: PetEventType.health.index, 
      hasAIAnalysis: false,
      notes: '$label: ${value.trim()}\n\n${l10n.pet_metric_source_clinical}', // Explicit requested text
      metrics: metricsData,
    );

    await _repository.saveEvent(event);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pet_metric_save_success), backgroundColor: const Color(0xFF10AC84)),
      );
      _loadLastMetrics();
    }
  }

  void _showMetricBottomSheet(BuildContext context, String key, String label, IconData icon, bool isInteger, bool isText) {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.petBackgroundDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 24, right: 24, top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: AppColors.petPrimary, size: 28),
                        const SizedBox(width: 12),
                        Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                        IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: ctx,
                                initialDate: selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) setModalState(() => selectedDate = pickedDate);
                            },
                            child: _buildPickerContainer(
                              Icons.calendar_today,
                              "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}",
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final pickedTime = await showTimePicker(context: ctx, initialTime: selectedTime);
                              if (pickedTime != null) setModalState(() => selectedTime = pickedTime);
                            },
                            child: _buildPickerContainer(
                              Icons.access_time,
                              "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
                              overrideIconColor: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: ctrl,
                      autofocus: true,
                      keyboardType: isText ? TextInputType.text : TextInputType.numberWithOptions(decimal: !isInteger),
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      decoration: InputDecoration(
                        labelText: label,
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD1DC), // Domain Pink
                        foregroundColor: Colors.black, // Black text/icon
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        if (ctrl.text.trim().isNotEmpty) {
                          _saveMetric(key, ctrl.text, label, selectedDate, selectedTime);
                          Navigator.pop(ctx);
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: Text(l10n.pet_metric_save_quick(label)),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildPickerContainer(IconData icon, String text, {Color? overrideIconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.petCardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: overrideIconColor ?? Colors.black54, size: 20),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showMetricChart(BuildContext context, String key, String label) {
    final l10n = AppLocalizations.of(context)!;
    if (_allMetricsEvents.isEmpty) return;
    final eventsWithKey = _allMetricsEvents.where((e) {
      final val = e.metrics?[key];
      return val != null && double.tryParse(val.toString().replaceAll(',', '.')) != null;
    }).toList();

    if (eventsWithKey.isEmpty) return;

    final spots = <FlSpot>[];
    double minVal = double.infinity;
    double maxVal = double.negativeInfinity;

    for (int i = 0; i < eventsWithKey.length; i++) {
      final val = double.parse(eventsWithKey[i].metrics![key].toString().replaceAll(',', '.'));
      if (val < minVal) minVal = val;
      if (val > maxVal) maxVal = val;
      spots.add(FlSpot(i.toDouble(), val));
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.petBackgroundDark,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.pet_metric_evolution_title(label), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: AppColors.petPrimary,
                        belowBarData: BarAreaData(show: true, color: AppColors.petPrimary.withValues(alpha: 0.2)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.petBackgroundDark,
        body: const Center(child: CircularProgressIndicator(color: AppColors.petPrimary)),
      );
    }

    // LISTAS DE MÉTRICAS (A-D)
    final vitals = [
      {'key': 'weight', 'label': l10n.pet_metric_weight, 'icon': Icons.monitor_weight, 'isInt': false, 'isText': false},
      {'key': 'bpm', 'label': l10n.pet_metric_bpm, 'icon': Icons.favorite, 'isInt': true, 'isText': false},
      {'key': 'mpm', 'label': l10n.pet_metric_mpm, 'icon': Icons.air, 'isInt': true, 'isText': false},
      {'key': 'temperature', 'label': l10n.pet_metric_temp, 'icon': Icons.thermostat, 'isInt': false, 'isText': false},
      {'key': 'glycemia', 'label': l10n.pet_metric_glycemia, 'icon': Icons.water_drop, 'isInt': false, 'isText': false},
      {'key': 'capillary_refill_time', 'label': l10n.pet_metric_tpc, 'icon': Icons.timer, 'isInt': false, 'isText': true},
    ];

    final structure = [
      {'key': 'body_condition_score', 'label': l10n.pet_metric_ecc, 'icon': Icons.straighten, 'isInt': true, 'isText': false},
      {'key': 'abdominal_circ', 'label': l10n.pet_metric_abd_circ, 'icon': Icons.architecture, 'isInt': false, 'isText': false},
      {'key': 'neck_circ', 'label': l10n.pet_metric_neck_circ, 'icon': Icons.checkroom, 'isInt': false, 'isText': false},
      {'key': 'height_withers', 'label': l10n.pet_metric_height, 'icon': Icons.height, 'isInt': false, 'isText': false},
    ];

    final hydration = [
      {'key': 'water_intake', 'label': l10n.pet_metric_water, 'icon': Icons.local_drink, 'isInt': true, 'isText': false},
      {'key': 'urine_volume', 'label': l10n.pet_metric_urine_vol, 'icon': Icons.opacity, 'isInt': false, 'isText': true},
      {'key': 'urine_density', 'label': l10n.pet_metric_urine_dens, 'icon': Icons.science, 'isInt': false, 'isText': false},
    ];

    final activity = [
      {'key': 'distance_traveled', 'label': l10n.pet_metric_distance, 'icon': Icons.directions_run, 'isInt': false, 'isText': false},
      {'key': 'average_speed', 'label': l10n.pet_metric_speed, 'icon': Icons.speed, 'isInt': false, 'isText': false},
      {'key': 'sleep_time', 'label': l10n.pet_metric_sleep, 'icon': Icons.nightlight_round, 'isInt': false, 'isText': false},
      {'key': 'stand_latency', 'label': l10n.pet_metric_stand_latency, 'icon': Icons.timer_off, 'isInt': false, 'isText': false},
    ];

    return Scaffold(
      backgroundColor: AppColors.petBackgroundDark,
      appBar: AppBar(
        title: Text(l10n.pet_metric_quick_action_title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.blue),
            tooltip: 'Gerar Relatório PDF',
            onPressed: () async {
               if (_allMetricsEvents.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.pet_metric_pdf_empty_data), backgroundColor: Colors.orange),
                  );
                  return;
               }

               // 1. Mostrar Filtro de Datas Customizado
               final DateTimeRange? selectedRange = await _showPdfFilterBottomSheet(context, l10n);

               if (selectedRange == null) return; // Usuário cancelou

               // 2. Filtrar os eventos pelo período selecionado (inclusive)
               final filteredEvents = _allMetricsEvents.where((e) {
                 final eDate = e.startDateTime;
                 // Reseta hora para garantir que o limite englobe o dia inteiro
                 final start = DateTime(selectedRange.start.year, selectedRange.start.month, selectedRange.start.day);
                 final end = DateTime(selectedRange.end.year, selectedRange.end.month, selectedRange.end.day, 23, 59, 59);
                 return eDate.isAfter(start.subtract(const Duration(seconds: 1))) && eDate.isBefore(end.add(const Duration(seconds: 1)));
               }).toList();

               if (filteredEvents.isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.pet_metric_pdf_empty_data), backgroundColor: Colors.orange),
                    );
                  }
                  return;
               }
               
               // 3. Enviar a função Builder para o Preview
               if (context.mounted) {
                 Navigator.push(
                   context,
                   MaterialPageRoute(
                     builder: (_) => UniversalPdfPreviewScreen(
                       title: '${l10n.pet_metric_title}: ${widget.petName}',
                       customBuilder: (format) async {
                           return await PetMetricsPdfService.generateMetricsPdf(
                             petName: widget.petName,
                             breed: l10n.pet_breed_unknown,
                             metricsEvents: filteredEvents,
                             l10n: l10n,
                           );
                       },
                     ),
                   ),
                 );
               }
            },
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSectionHeader(l10n.pet_metric_section_vitals),
          _buildGrid(vitals),
          _buildSectionHeader(l10n.pet_metric_section_structure),
          _buildGrid(structure),
          _buildSectionHeader(l10n.pet_metric_section_hydration),
          _buildGrid(hydration),
          _buildSectionHeader(l10n.pet_metric_section_activity),
          _buildGrid(activity),
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Container(width: 4, height: 20, color: AppColors.petPrimary),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: AppColors.petPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<Map<String, dynamic>> items) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.3,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            final key = item['key'] as String;
            final label = item['label'] as String;
            final icon = item['icon'] as IconData;
            final lastValue = _lastMetrics[key];

            return InkWell(
              onTap: () => _showMetricBottomSheet(context, key, label, icon, item['isInt'], item['isText']),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.petPrimary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                padding: const EdgeInsets.all(12),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon, color: Colors.black),
                        const Spacer(),
                        Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(lastValue ?? '--', style: TextStyle(color: Colors.black.withValues(alpha: 0.6), fontSize: 11)),
                      ],
                    ),
                    if (lastValue != null && !item['isText'])
                      Positioned(
                        right: -10, top: -10,
                        child: IconButton(
                          icon: const Icon(Icons.bar_chart_rounded, color: AppColors.petIconAction, size: 20),
                          onPressed: () => _showMetricChart(context, key, label),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  Future<DateTimeRange?> _showPdfFilterBottomSheet(BuildContext context, AppLocalizations l10n) async {
    DateTime? startDate;
    DateTime? endDate;
    int selectedOption = 1; // Default: 30 days => index 1

    return showModalBottomSheet<DateTimeRange>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.petBackgroundDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            Widget buildOption(int index, String title, IconData icon) {
              final isSelected = selectedOption == index;
              return InkWell(
                onTap: () {
                  setModalState(() {
                    selectedOption = index;
                    if (index != 4) {
                      endDate = DateTime.now();
                      if (index == 0) { startDate = endDate!.subtract(const Duration(days: 7)); }
                      if (index == 1) { startDate = endDate!.subtract(const Duration(days: 30)); }
                      if (index == 2) { startDate = endDate!.subtract(const Duration(days: 90)); }
                      if (index == 3) {
                        startDate = DateTime(2000);
                      }
                    } else {
                      startDate ??= DateTime.now().subtract(const Duration(days: 30));
                      endDate ??= DateTime.now();
                    }
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFD1DC).withValues(alpha: 0.15) : Colors.black26,
                    border: Border.all(color: isSelected ? const Color(0xFFFFD1DC) : Colors.transparent, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: isSelected ? const Color(0xFFFFD1DC) : Colors.white70, size: 24),
                      const SizedBox(width: 16),
                      Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      const Spacer(),
                      if (isSelected) const Icon(Icons.check_circle, color: Color(0xFFFFD1DC)),
                    ],
                  ),
                ),
              );
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  left: 24, right: 24, top: 24,
                ),
                child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                   Row(
                      children: [
                        const Icon(Icons.picture_as_pdf, color: Color(0xFFFFD1DC), size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.pet_metric_pdf_filter_title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                              Text(l10n.pet_metric_pdf_filter_subtitle, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                            ],
                          )
                        ),
                        IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    buildOption(0, l10n.pet_metric_pdf_filter_last_7_days, Icons.calendar_view_week),
                    buildOption(1, l10n.pet_metric_pdf_filter_last_30_days, Icons.calendar_month),
                    buildOption(2, l10n.pet_metric_pdf_filter_last_3_months, Icons.date_range),
                    buildOption(3, l10n.pet_metric_pdf_filter_all_time, Icons.all_inclusive),
                    buildOption(4, l10n.pet_metric_pdf_filter_custom, Icons.edit_calendar),
                    
                    if (selectedOption == 4) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: ctx, initialDate: startDate ?? DateTime.now().subtract(const Duration(days: 30)),
                                  firstDate: DateTime(2000), lastDate: endDate ?? DateTime.now(),
                                  builder: _buildCalendarTheme,
                                );
                                if (picked != null) setModalState(() => startDate = picked);
                              },
                              child: _buildDateButton(l10n.pet_metric_pdf_filter_start_date, startDate),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: ctx, initialDate: endDate ?? DateTime.now(),
                                  firstDate: startDate ?? DateTime(2000), lastDate: DateTime.now().add(const Duration(days: 1)),
                                  builder: _buildCalendarTheme,
                                );
                                if (picked != null) setModalState(() => endDate = picked);
                              },
                              child: _buildDateButton(l10n.pet_metric_pdf_filter_end_date, endDate),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD1DC),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        if (selectedOption != 4) {
                           endDate = DateTime.now();
                           if (selectedOption == 0) { startDate = endDate!.subtract(const Duration(days: 7)); }
                           else if (selectedOption == 1) { startDate = endDate!.subtract(const Duration(days: 30)); }
                           else if (selectedOption == 2) { startDate = endDate!.subtract(const Duration(days: 90)); }
                           else if (selectedOption == 3) { startDate = DateTime(2000); }
                        }
                        if (startDate != null && endDate != null) {
                           Navigator.pop(ctx, DateTimeRange(start: startDate!, end: endDate!));
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: Text(l10n.pet_metric_pdf_filter_generate),
                    ),
                    const SizedBox(height: 48), // Adjusted for hardware safety
                  ],
                ),
              ),
            )); // Closed SafeArea
          }
        );
      },
    );
  }

  Widget _buildDateButton(String label, DateTime? date) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          Text(date != null ? DateFormat('dd/MM/yyyy').format(date) : '--/--/----', style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildCalendarTheme(BuildContext context, Widget? child) {
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFFFD1DC), // Domain Pink (Circles/Highlights)
          onPrimary: Colors.black, // Text inside primary color
          surface: AppColors.petBackgroundDark, // Calendar Background
          onSurface: Colors.white, // Days text
        ),
        dialogTheme: const DialogThemeData(backgroundColor: AppColors.petBackgroundDark),
      ),
      child: child!,
    );
  }
}