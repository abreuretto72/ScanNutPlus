import 'package:flutter/material.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/pet/agenda/pet_event.dart';
import 'package:scannutplus/pet/agenda/pet_event_repository.dart';
import 'package:scannutplus/features/pet/agenda/presentation/pet_medication_screen.dart'; // Added Medication Screen imports
import 'package:uuid/uuid.dart';
import 'package:scannutplus/features/pet/data/models/pet_event_type.dart';

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
               _lastMetrics = latest;
               _isLoading = false;
           });
        }
    } else {
        if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveMetric(String key, String value, String label) async {
    if (value.trim().isEmpty) return;
    
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    
    final metricsData = {
      'is_metric_record': true,
      'custom_title': label,
      key: value.trim(),
    };

    final event = PetEvent(
      id: const Uuid().v4(),
      startDateTime: now,
      endDateTime: now,
      petIds: [widget.petId],
      eventTypeIndex: PetEventType.health.index, 
      hasAIAnalysis: false,
      notes: '$label: ${value.trim()}',
      metrics: metricsData,
    );

    await _repository.saveEvent(event);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(l10n.pet_metric_save_success), backgroundColor: Colors.green),
      );
      _loadLastMetrics(); // refresh
    }
  }

  void _showMetricBottomSheet(BuildContext context, String key, String label, IconData icon, bool isInteger, bool isText) {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.petBackgroundDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24, right: 24, top: 24,
          ),
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
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.petPrimary, width: 2)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10AC84), // SUCCESS GREEN
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  if (ctrl.text.trim().isNotEmpty) {
                    _saveMetric(key, ctrl.text, label);
                    Navigator.pop(ctx);
                  }
                },
                icon: const Icon(Icons.check),
                label: Text(l10n.pet_metric_save_quick(label), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
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
            Expanded(
              child: Text(title, style: const TextStyle(color: AppColors.petPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
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
           crossAxisCount: 2,
           mainAxisSpacing: 12,
           crossAxisSpacing: 12,
           childAspectRatio: 1.3,
         ),
         delegate: SliverChildBuilderDelegate(
           (context, index) {
             final item = items[index];
             final key = item['key'] as String;
             final label = item['label'] as String;
             final icon = item['icon'] as IconData;
             final isInt = item['isInt'] as bool;
             final isText = item['isText'] as bool;

             final lastValue = _lastMetrics[key];
             final l10n = AppLocalizations.of(context)!;

             return InkWell(
               onTap: () => _showMetricBottomSheet(context, key, label, icon, isInt, isText),
               borderRadius: BorderRadius.circular(16),
               child: Container(
                 decoration: BoxDecoration(
                   color: AppColors.petPrimary,
                   borderRadius: BorderRadius.circular(16),
                   border: Border.all(color: Colors.black, width: 2),
                   boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
                 ),
                 padding: const EdgeInsets.all(12),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Icon(icon, color: Colors.black, size: 28),
                     const Spacer(),
                     Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                     const SizedBox(height: 4),
                     Text(
                       lastValue != null ? l10n.pet_metric_last_recorded(lastValue) : l10n.pet_metric_empty_state, 
                       style: TextStyle(color: Colors.black.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.bold),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.petBackgroundDark,
        appBar: AppBar(title: Text(l10n.pet_metric_quick_action_title, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
        body: const Center(child: CircularProgressIndicator(color: AppColors.petPrimary)),
      );
    }

    // A. SINAIS VITAIS
    // 'weight', 'bpm', 'mpm', 'temperature', 'glycemia', 'capillary_refill_time'
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
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // MEDICATION ACTION BUTTON
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PetMedicationScreen(petId: widget.petId, petName: widget.petName)));
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.petPrimary,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.medication, color: Colors.black, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.pet_med_save, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text("Agendar e gerenciar tratamentos", style: TextStyle(color: Colors.black.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          _buildSectionHeader(l10n.pet_metric_section_vitals), _buildGrid(vitals),
          _buildSectionHeader(l10n.pet_metric_section_structure), _buildGrid(structure),
          _buildSectionHeader(l10n.pet_metric_section_hydration), _buildGrid(hydration),
          _buildSectionHeader(l10n.pet_metric_section_activity), _buildGrid(activity),
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ]
      )
    );
  }
}
