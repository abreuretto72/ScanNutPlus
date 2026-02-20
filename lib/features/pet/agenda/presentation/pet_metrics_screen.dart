import 'package:flutter/material.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/pet/agenda/pet_event.dart';
import 'package:scannutplus/pet/agenda/pet_event_repository.dart';
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
  final _formKey = GlobalKey<FormState>();

  // A. Sinais Vitais
  final _weightCtrl = TextEditingController();
  final _bpmCtrl = TextEditingController();
  final _mpmCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _tpcCtrl = TextEditingController();
  final _glycemiaCtrl = TextEditingController();

  // B. Estrutura
  final _eccCtrl = TextEditingController();
  final _abdCircCtrl = TextEditingController();
  final _neckCircCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();

  // C. Hidratação e Excreção
  final _waterCtrl = TextEditingController();
  final _urineVolCtrl = TextEditingController();
  final _urineDensCtrl = TextEditingController();

  // D. Atividade e Biometria
  final _distanceCtrl = TextEditingController();
  final _speedCtrl = TextEditingController();
  final _sleepCtrl = TextEditingController();
  final _latencyCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _weightCtrl.dispose();
    _bpmCtrl.dispose();
    _mpmCtrl.dispose();
    _tempCtrl.dispose();
    _tpcCtrl.dispose();
    _glycemiaCtrl.dispose();
    _eccCtrl.dispose();
    _abdCircCtrl.dispose();
    _neckCircCtrl.dispose();
    _heightCtrl.dispose();
    _waterCtrl.dispose();
    _urineVolCtrl.dispose();
    _urineDensCtrl.dispose();
    _distanceCtrl.dispose();
    _speedCtrl.dispose();
    _sleepCtrl.dispose();
    _latencyCtrl.dispose();
    super.dispose();
  }

  bool _hasAnyData() {
    return _weightCtrl.text.isNotEmpty ||
        _bpmCtrl.text.isNotEmpty ||
        _mpmCtrl.text.isNotEmpty ||
        _tempCtrl.text.isNotEmpty ||
        _tpcCtrl.text.isNotEmpty ||
        _glycemiaCtrl.text.isNotEmpty ||
        _eccCtrl.text.isNotEmpty ||
        _abdCircCtrl.text.isNotEmpty ||
        _neckCircCtrl.text.isNotEmpty ||
        _heightCtrl.text.isNotEmpty ||
        _waterCtrl.text.isNotEmpty ||
        _urineVolCtrl.text.isNotEmpty ||
        _urineDensCtrl.text.isNotEmpty ||
        _distanceCtrl.text.isNotEmpty ||
        _speedCtrl.text.isNotEmpty ||
        _sleepCtrl.text.isNotEmpty ||
        _latencyCtrl.text.isNotEmpty;
  }

  Future<void> _saveMetrics() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (!_formKey.currentState!.validate()) return;
    
    if (!_hasAnyData()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pet_metric_empty_fields), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final now = DateTime.now();
      
      final metricsData = {
        'is_metric_record': true,
        // Vitals
        if (_weightCtrl.text.isNotEmpty) 'weight': _weightCtrl.text.trim(),
        if (_bpmCtrl.text.isNotEmpty) 'bpm': _bpmCtrl.text.trim(),
        if (_mpmCtrl.text.isNotEmpty) 'mpm': _mpmCtrl.text.trim(),
        if (_tempCtrl.text.isNotEmpty) 'temperature': _tempCtrl.text.trim(),
        if (_tpcCtrl.text.isNotEmpty) 'capillary_refill_time': _tpcCtrl.text.trim(),
        if (_glycemiaCtrl.text.isNotEmpty) 'glycemia': _glycemiaCtrl.text.trim(),
        // Structure
        if (_eccCtrl.text.isNotEmpty) 'body_condition_score': _eccCtrl.text.trim(),
        if (_abdCircCtrl.text.isNotEmpty) 'abdominal_circ': _abdCircCtrl.text.trim(),
        if (_neckCircCtrl.text.isNotEmpty) 'neck_circ': _neckCircCtrl.text.trim(),
        if (_heightCtrl.text.isNotEmpty) 'height_withers': _heightCtrl.text.trim(),
        // Hydration
        if (_waterCtrl.text.isNotEmpty) 'water_intake': _waterCtrl.text.trim(),
        if (_urineVolCtrl.text.isNotEmpty) 'urine_volume': _urineVolCtrl.text.trim(),
        if (_urineDensCtrl.text.isNotEmpty) 'urine_density': _urineDensCtrl.text.trim(),
        // Activity
        if (_distanceCtrl.text.isNotEmpty) 'distance_traveled': _distanceCtrl.text.trim(),
        if (_speedCtrl.text.isNotEmpty) 'average_speed': _speedCtrl.text.trim(),
        if (_sleepCtrl.text.isNotEmpty) 'sleep_time': _sleepCtrl.text.trim(),
        if (_latencyCtrl.text.isNotEmpty) 'stand_latency': _latencyCtrl.text.trim(),
      };

      final event = PetEvent(
        id: const Uuid().v4(),
        startDateTime: now,
        endDateTime: now,
        petIds: [widget.petId],
        eventTypeIndex: PetEventType.health.index, 
        hasAIAnalysis: false,
        notes: l10n.metrics_registered_clinical,
        metrics: metricsData,
      );

      final repo = PetEventRepository();
      await repo.saveEvent(event);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(l10n.pet_metric_save_success), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(l10n.pet_error_saving_event(e.toString())), backgroundColor: Colors.red),
         );
       }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.petPrimary, size: 20),
      filled: true,
      fillColor: Colors.black26,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.petPrimary)),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 4),
      child: Row(
        children: [
          Container(width: 4, height: 20, color: AppColors.petPrimary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(title, style: const TextStyle(color: AppColors.petPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField(TextEditingController ctrl, String label, IconData icon, {bool isInteger = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.numberWithOptions(decimal: !isInteger),
        decoration: _inputDeco(label, icon),
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
    );
  }
  
  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        decoration: _inputDeco(label, icon),
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.petBackgroundDark,
      appBar: AppBar(
        title: Text(l10n.pet_metric_title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // A. SINAIS VITAIS
                    _buildSectionHeader(l10n.pet_metric_section_vitals),
                    _buildNumberField(_weightCtrl, l10n.pet_metric_weight, Icons.monitor_weight),
                    Row(
                      children: [
                        Expanded(child: _buildNumberField(_bpmCtrl, l10n.pet_metric_bpm, Icons.favorite, isInteger: true)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildNumberField(_mpmCtrl, l10n.pet_metric_mpm, Icons.air, isInteger: true)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildNumberField(_tempCtrl, l10n.pet_metric_temp, Icons.thermostat)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildNumberField(_glycemiaCtrl, l10n.pet_metric_glycemia, Icons.water_drop)),
                      ],
                    ),
                    _buildTextField(_tpcCtrl, l10n.pet_metric_tpc, Icons.timer),

                    // B. ESTRUTURA E COMPOSIÇÃO
                    _buildSectionHeader(l10n.pet_metric_section_structure),
                    _buildNumberField(_eccCtrl, l10n.pet_metric_ecc, Icons.straighten, isInteger: true),
                    Row(
                      children: [
                        Expanded(child: _buildNumberField(_abdCircCtrl, l10n.pet_metric_abd_circ, Icons.architecture)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildNumberField(_neckCircCtrl, l10n.pet_metric_neck_circ, Icons.checkroom)),
                      ],
                    ),
                    _buildNumberField(_heightCtrl, l10n.pet_metric_height, Icons.height),

                    // C. HIDRATAÇÃO E EXCREÇÃO
                    _buildSectionHeader(l10n.pet_metric_section_hydration),
                    _buildNumberField(_waterCtrl, l10n.pet_metric_water, Icons.local_drink, isInteger: true),
                    _buildTextField(_urineVolCtrl, l10n.pet_metric_urine_vol, Icons.opacity),
                    _buildNumberField(_urineDensCtrl, l10n.pet_metric_urine_dens, Icons.science),

                    // D. ATIVIDADE E BIOMETRIA
                    _buildSectionHeader(l10n.pet_metric_section_activity),
                    Row(
                      children: [
                        Expanded(child: _buildNumberField(_distanceCtrl, l10n.pet_metric_distance, Icons.directions_run)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildNumberField(_speedCtrl, l10n.pet_metric_speed, Icons.speed)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildNumberField(_sleepCtrl, l10n.pet_metric_sleep, Icons.nightlight_round)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildNumberField(_latencyCtrl, l10n.pet_metric_stand_latency, Icons.timer_off)),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          
          // SAVING BAR
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.petBackgroundDark,
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.petPrimary,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isLoading ? null : _saveMetrics,
                  icon: _isLoading 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) 
                      : const Icon(Icons.check, color: Colors.black),
                  label: Text(
                    l10n.common_save, 
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
