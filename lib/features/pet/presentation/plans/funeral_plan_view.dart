import 'package:flutter/material.dart';
import 'package:scannutplus/core/data/objectbox_manager.dart';
import 'package:scannutplus/features/pet/data/models/funeral_plan_entity.dart';
import 'package:scannutplus/features/pet/data/funeral_plan_constants.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/objectbox.g.dart'; 
import 'package:url_launcher/url_launcher.dart';

class FuneralPlanView extends StatefulWidget {
  final String petUuid;

  const FuneralPlanView({super.key, required this.petUuid});

  @override
  State<FuneralPlanView> createState() => _FuneralPlanViewState();
}

class _FuneralPlanViewState extends State<FuneralPlanView> {
  late Box<FuneralPlanEntity> _planBox;
  FuneralPlanEntity? _plan;
  bool _isLoading = true;

  // --- CONTROLLERS ---
  // Identity
  final _companyController = TextEditingController();
  final _planNameController = TextEditingController();
  final _contractController = TextEditingController();
  final _startDateController = TextEditingController(); // TODO: Date Picker
  String _currentStatus = FuneralPlanConstants.statusActive;

  // Rules & Values
  final _gracePeriodController = TextEditingController();
  final _maxWeightController = TextEditingController();
  final _valueController = TextEditingController();
  final _extraFeesController = TextEditingController();
  bool _is24h = false;

  // Emergency
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();

  // Services
  final Map<String, bool> _services = {
    FuneralPlanConstants.svcRemoval: false,
    FuneralPlanConstants.svcViewing: false,
    FuneralPlanConstants.svcCremationInd: false,
    FuneralPlanConstants.svcCremationCol: false,
    FuneralPlanConstants.svcBurial: false,
    FuneralPlanConstants.svcUrn: false,
    FuneralPlanConstants.svcAshes: false,
    FuneralPlanConstants.svcCertificate: false,
  };

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final store = ObjectBoxManager.currentStore;
    _planBox = store.box<FuneralPlanEntity>();
    
    final query = _planBox.query(FuneralPlanEntity_.petUuid.equals(widget.petUuid)).build();
    _plan = query.findFirst();
    query.close();

    if (_plan != null) {
       _companyController.text = _plan!.funeralCompany;
       _planNameController.text = _plan!.planName;
       _contractController.text = _plan!.contractNumber;
       _startDateController.text = _plan!.startDate != null ? _plan!.startDate!.toIso8601String().split('T')[0] : '';
       _currentStatus = _plan!.status;
       
       _gracePeriodController.text = _plan!.gracePeriodDays.toString();
       _maxWeightController.text = _plan!.maxWeightKg.toString();
       _valueController.text = _plan!.planValue.toString();
       _extraFeesController.text = _plan!.extraFees.toString();
       
       _phoneController.text = _plan!.phone24h;
       _whatsappController.text = _plan!.whatsApp;
       _is24h = _plan!.is24hService;

       if (_plan!.includedServicesJson.isNotEmpty) {
          final savedList = _plan!.includedServicesJson.split(',');
          for (var k in _services.keys) {
             if (savedList.contains(k)) _services[k] = true;
          }
       }
    } else {
       _plan = FuneralPlanEntity(petUuid: widget.petUuid);
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _savePlan() async {
      if (_plan == null) return;

      _plan!.funeralCompany = _companyController.text;
      _plan!.planName = _planNameController.text;
      _plan!.contractNumber = _contractController.text;
      // Start Date logic would go here (parsing string or keeping value from picker)
      _plan!.status = _currentStatus;
      
      _plan!.gracePeriodDays = int.tryParse(_gracePeriodController.text) ?? 0;
      _plan!.maxWeightKg = double.tryParse(_maxWeightController.text) ?? 0.0;
      _plan!.planValue = double.tryParse(_valueController.text) ?? 0.0;
      _plan!.extraFees = double.tryParse(_extraFeesController.text) ?? 0.0;
      
      _plan!.phone24h = _phoneController.text;
      _plan!.whatsApp = _whatsappController.text;
      _plan!.is24hService = _is24h;

      final selected = _services.entries.where((e) => e.value).map((e) => e.key).join(',');
      _plan!.includedServicesJson = selected;

      _planBox.put(_plan!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.funeral_save_success), backgroundColor: Colors.green)
        );
        Navigator.pop(context);
      }
  }

  void _callEmergency() async {
     final phone = _phoneController.text;
     if (phone.isEmpty) return;
     final uri = Uri.parse('tel:$phone');
     if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.black, // AppColors.backgroundDark
      appBar: AppBar(
        title: Text(l10n.funeral_plan_title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
         padding: const EdgeInsets.all(16),
         child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               _buildSectionHeader(l10n.funeral_section_identity),
               _buildIdentityCard(l10n),
               const SizedBox(height: 16),
               
               _buildSectionHeader(l10n.funeral_section_services),
               _buildServicesCard(l10n),
               const SizedBox(height: 16),
               
               _buildSectionHeader(l10n.funeral_section_rules),
               _buildRulesCard(l10n),
               const SizedBox(height: 16),
               
               _buildSectionHeader(l10n.funeral_section_emergency),
               _buildEmergencyCard(l10n),
               const SizedBox(height: 24),
               
               ElevatedButton.icon(
                  onPressed: _savePlan,
                  icon: const Icon(Icons.save),
                  label: Text(l10n.funeral_action_save),
                  style: ElevatedButton.styleFrom(
                     backgroundColor: const Color(0xFFFFD1DC), // Pet Primary
                     foregroundColor: Colors.black,
                     padding: const EdgeInsets.symmetric(vertical: 16),
                     textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
               ),
               const SizedBox(height: 32),
            ],
         ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
     return Padding(
        padding: const EdgeInsets.only(bottom: 8.0, left: 4),
        child: Text(title, style: const TextStyle(color: Color(0xFFFFD1DC), fontSize: 18, fontWeight: FontWeight.bold)),
     );
  }

  Widget _buildIdentityCard(AppLocalizations l10n) {
     return Card(
        color: Colors.grey[900],
        child: Padding(
           padding: const EdgeInsets.all(16),
           child: Column(
              children: [
                 _buildTextField(_companyController, l10n.funeral_label_company, Icons.business),
                 const SizedBox(height: 12),
                 _buildTextField(_planNameController, l10n.funeral_label_plan_name, Icons.badge),
                 const SizedBox(height: 12),
                 _buildTextField(_contractController, l10n.funeral_label_contract, Icons.description),
                 const SizedBox(height: 12),
                 // Status Dropdown
                 Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                    child: DropdownButtonHideUnderline(
                       child: DropdownButton<String>(
                          value: _currentStatus,
                          dropdownColor: Colors.grey[850],
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white),
                          items: FuneralPlanConstants.statusOptions.map((s) => DropdownMenuItem(
                             value: s,
                             child: Text(s), // Could localize status values too if needed
                          )).toList(),
                          onChanged: (v) => setState(() => _currentStatus = v!),
                       ),
                    ),
                 ),
              ],
           ),
        ),
     );
  }

  Widget _buildServicesCard(AppLocalizations l10n) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
           shrinkWrap: true,
           physics: const NeverScrollableScrollPhysics(),
           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
           ),
           itemCount: _services.length,
           itemBuilder: (context, index) {
              final key = _services.keys.elementAt(index);
              return Theme(
                 data: ThemeData.dark().copyWith(unselectedWidgetColor: Colors.grey),
                 child: CheckboxListTile(
                    title: Text(
                       _getServiceLabel(key, l10n), 
                       style: const TextStyle(fontSize: 11, color: Colors.white), 
                       maxLines: 2, 
                       overflow: TextOverflow.ellipsis
                    ),
                    value: _services[key],
                    onChanged: (v) => setState(() => _services[key] = v ?? false),
                    activeColor: const Color(0xFFFFD1DC),
                    checkColor: Colors.black,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                 ),
              );
           }
        ),
      ),
    );
  }

  String _getServiceLabel(String key, AppLocalizations l10n) {
     switch (key) {
        case FuneralPlanConstants.svcRemoval: return l10n.funeral_svc_removal;
        case FuneralPlanConstants.svcViewing: return l10n.funeral_svc_viewing;
        case FuneralPlanConstants.svcCremationInd: return l10n.funeral_svc_cremation_ind;
        case FuneralPlanConstants.svcCremationCol: return l10n.funeral_svc_cremation_col;
        case FuneralPlanConstants.svcBurial: return l10n.funeral_svc_burial;
        case FuneralPlanConstants.svcUrn: return l10n.funeral_svc_urn;
        case FuneralPlanConstants.svcAshes: return l10n.funeral_svc_ashes;
        case FuneralPlanConstants.svcCertificate: return l10n.funeral_svc_certificate;
        default: return key;
     }
  }

  Widget _buildRulesCard(AppLocalizations l10n) {
     return Card(
        color: Colors.grey[900],
        child: Padding(
           padding: const EdgeInsets.all(16),
           child: Column(
              children: [
                 _buildTextField(_gracePeriodController, l10n.funeral_label_grace_period, Icons.timer, isNumber: true),
                 const SizedBox(height: 12),
                 _buildTextField(_maxWeightController, l10n.funeral_label_max_weight, Icons.monitor_weight, isNumber: true),
                 const SizedBox(height: 12),
                 _buildTextField(_valueController, l10n.funeral_label_value, Icons.attach_money, isNumber: true),
                 const SizedBox(height: 12),
                 _buildTextField(_extraFeesController, l10n.funeral_label_extra_fees, Icons.add_circle, isNumber: true),
              ],
           ),
        ),
     );
  }

  Widget _buildEmergencyCard(AppLocalizations l10n) {
     return Card(
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5))),
        child: Padding(
           padding: const EdgeInsets.all(16),
           child: Column(
              children: [
                 _buildTextField(_phoneController, l10n.funeral_label_phone, Icons.phone, isNumber: true),
                 const SizedBox(height: 12),
                 _buildTextField(_whatsappController, l10n.funeral_label_whatsapp, Icons.chat, isNumber: true),
                 const SizedBox(height: 24),
                 SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                       onPressed: _callEmergency,
                       icon: const Icon(Icons.emergency, color: Colors.white),
                       label: Text(l10n.funeral_action_call_emergency),
                       style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                       ),
                    ),
                 )
              ],
           ),
        ),
     );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: const Color(0xFFFFD1DC)),
        filled: true,
        fillColor: Colors.black26,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }
}
