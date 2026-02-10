import 'package:flutter/material.dart';
import 'package:scannutplus/core/data/objectbox_manager.dart';
import 'package:scannutplus/features/pet/data/models/health_plan_entity.dart';
import 'package:scannutplus/features/pet/data/health_plan_constants.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:scannutplus/objectbox.g.dart'; // Ensure build_runner runs 

class HealthPlanView extends StatefulWidget {
  final String petUuid;

  const HealthPlanView({super.key, required this.petUuid});

  @override
  State<HealthPlanView> createState() => _HealthPlanViewState();
}

class _HealthPlanViewState extends State<HealthPlanView> {
  late Box<HealthPlanEntity> _planBox;
  HealthPlanEntity? _plan;
  bool _isLoading = true;

  // --- CONTROLLERS ---
  // 1. ID
  final _operatorController = TextEditingController();
  final _planNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _holderNameController = TextEditingController();
  
  // 3. Limits
  final _gracePeriodController = TextEditingController();
  final _annualLimitController = TextEditingController();
  final _copayController = TextEditingController();
  final _reimbursementController = TextEditingController();
  final _deductibleController = TextEditingController();

  // 4. Support
  final _clinicController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();
  bool _is24h = false;

  // 2. Coverages
  final Map<String, bool> _coverages = {
    HealthPlanConstants.covConsultations: false,
    HealthPlanConstants.covVaccines: false,
    HealthPlanConstants.covLabExams: false,
    HealthPlanConstants.covImaging: false,
    HealthPlanConstants.covSurgery: false,
    HealthPlanConstants.covHospitalization: false,
    HealthPlanConstants.covEmergency: false,
    HealthPlanConstants.covPreExisting: false,
    HealthPlanConstants.covDentistry: false,
    HealthPlanConstants.covPhysiotherapy: false,
  };

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final store = ObjectBoxManager.currentStore;
    _planBox = store.box<HealthPlanEntity>();
    
    // Find existing plan for this Pet UUID
    final query = _planBox.query(HealthPlanEntity_.petUuid.equals(widget.petUuid)).build();
    _plan = query.findFirst();
    query.close();

    if (_plan != null) {
       _operatorController.text = _plan!.operatorName ?? '';
       _planNameController.text = _plan!.planName ?? '';
       _cardNumberController.text = _plan!.cardNumber ?? '';
       _holderNameController.text = _plan!.holderName ?? '';
       
       _gracePeriodController.text = _plan!.gracePeriodDays?.toString() ?? '';
       _annualLimitController.text = _plan!.annualLimit?.toString() ?? '';
       _copayController.text = _plan!.copayPercent?.toString() ?? '';
       _reimbursementController.text = _plan!.reimbursementPercent?.toString() ?? '';
       _deductibleController.text = _plan!.deductible?.toString() ?? '';
       
       _clinicController.text = _plan!.mainClinicName ?? '';
       _cityController.text = _plan!.supportCity ?? '';
       _phoneController.text = _plan!.supportPhone ?? '';
       _whatsappController.text = _plan!.supportWhatsapp ?? '';
       _emailController.text = _plan!.supportEmail ?? '';
       _is24h = _plan!.is24hService;

       // Load Coverages
       if (_plan!.coveragesJson != null && _plan!.coveragesJson!.isNotEmpty) {
          final savedList = _plan!.coveragesJson!.split(',');
          for (var k in _coverages.keys) {
             if (savedList.contains(k)) {
                _coverages[k] = true;
             }
          }
       }
    } else {
       // Initialize empty
       _plan = HealthPlanEntity(petUuid: widget.petUuid);
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _savePlan() async {
      if (_plan == null) return;

      // Update Entity
      _plan!.operatorName = _operatorController.text;
      _plan!.planName = _planNameController.text;
      _plan!.cardNumber = _cardNumberController.text;
      _plan!.holderName = _holderNameController.text;
      
      _plan!.gracePeriodDays = int.tryParse(_gracePeriodController.text);
      _plan!.annualLimit = double.tryParse(_annualLimitController.text);
      _plan!.copayPercent = double.tryParse(_copayController.text);
      _plan!.reimbursementPercent = double.tryParse(_reimbursementController.text);
      _plan!.deductible = double.tryParse(_deductibleController.text);
      
      _plan!.mainClinicName = _clinicController.text;
      _plan!.supportCity = _cityController.text;
      _plan!.supportPhone = _phoneController.text;
      _plan!.supportWhatsapp = _whatsappController.text;
      _plan!.supportEmail = _emailController.text;
      _plan!.is24hService = _is24h;

      // Save Coverages
      final selected = _coverages.entries.where((e) => e.value).map((e) => e.key).join(',');
      _plan!.coveragesJson = selected;

      _planBox.put(_plan!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.health_plan_saved_success), backgroundColor: Colors.green)
        );
        Navigator.pop(context); // Optional: return to profile?
      }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
       return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final l10n = AppLocalizations.of(context)!;
    
    // Using explicit colors or AppColors if available globally
    // Fallback to dark theme based
    
    return Scaffold(
      backgroundColor: Colors.black, // AppColors.backgroundDark
      appBar: AppBar(
        title: Text(l10n.health_plan_title),
        backgroundColor: Colors.black, // AppColors.backgroundDark
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
         padding: const EdgeInsets.all(16),
         child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               _buildSectionHeader(l10n.health_plan_section_identification),
               _buildIdentificationCard(l10n),
               const SizedBox(height: 16),
               
               _buildSectionHeader(l10n.health_plan_section_coverages),
               _buildCoveragesCard(l10n),
               const SizedBox(height: 16),
               
               _buildSectionHeader(l10n.health_plan_section_limits),
               _buildLimitsCard(l10n),
               const SizedBox(height: 16),
               
               _buildSectionHeader(l10n.health_plan_section_support),
               _buildSupportCard(l10n),
               const SizedBox(height: 24),
               
               // --- SAVE BUTTON ---
               ElevatedButton.icon(
                  onPressed: _savePlan,
                  icon: const Icon(Icons.save),
                  label: Text(l10n.health_plan_action_save),
                  style: ElevatedButton.styleFrom(
                     backgroundColor: const Color(0xFFFFD1DC), // AppColors.petPrimary
                     foregroundColor: Colors.black, // AppColors.petText
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
        child: Text(title, style: const TextStyle(color: Color(0xFFFFD1DC), fontSize: 18, fontWeight: FontWeight.bold)), // Pet Primary
     );
  }

  Widget _buildIdentificationCard(AppLocalizations l10n) {
     return Card(
        color: Colors.grey[900],
        child: Padding(
           padding: const EdgeInsets.all(16),
           child: Column(
              children: [
                 _buildTextField(_operatorController, l10n.health_plan_label_operator, Icons.business),
                 const SizedBox(height: 12),
                 _buildTextField(_planNameController, l10n.health_plan_label_plan_name, Icons.badge),
                 const SizedBox(height: 12),
                 _buildTextField(_cardNumberController, l10n.health_plan_label_card_number, Icons.credit_card),
                 const SizedBox(height: 12),
                 _buildTextField(_holderNameController, l10n.health_plan_label_holder_name, Icons.person),
              ],
           ),
        ),
     );
  }

  Widget _buildCoveragesCard(AppLocalizations l10n) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
           shrinkWrap: true,
           physics: const NeverScrollableScrollPhysics(),
           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.8, // Taller items to prevent text overflow
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
           ),
           itemCount: _coverages.length,
           itemBuilder: (context, index) {
              final key = _coverages.keys.elementAt(index);
              return Theme(
                 data: ThemeData.dark().copyWith(
                    unselectedWidgetColor: Colors.grey,
                 ),
                 child: CheckboxListTile(
                    title: Text(
                       _getCoverageLabel(key, l10n), 
                       style: const TextStyle(fontSize: 11, color: Colors.white), 
                       maxLines: 2, 
                       overflow: TextOverflow.ellipsis
                    ),
                    value: _coverages[key],
                    onChanged: (v) => setState(() => _coverages[key] = v ?? false),
                    activeColor: const Color(0xFFFFD1DC), // Pet Primary
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

  String _getCoverageLabel(String key, AppLocalizations l10n) {
    switch (key) {
      case HealthPlanConstants.covConsultations: return l10n.health_cov_consultations;
      case HealthPlanConstants.covVaccines: return l10n.health_cov_vaccines;
      case HealthPlanConstants.covLabExams: return l10n.health_cov_lab_exams;
      case HealthPlanConstants.covImaging: return l10n.health_cov_imaging;
      case HealthPlanConstants.covSurgery: return l10n.health_cov_surgery;
      case HealthPlanConstants.covHospitalization: return l10n.health_cov_hospitalization;
      case HealthPlanConstants.covEmergency: return l10n.health_cov_emergency;
      case HealthPlanConstants.covPreExisting: return l10n.health_cov_pre_existing;
      case HealthPlanConstants.covDentistry: return l10n.health_cov_dentistry;
      case HealthPlanConstants.covPhysiotherapy: return l10n.health_cov_physiotherapy;
      default: return key;
    }
  }

  Widget _buildLimitsCard(AppLocalizations l10n) {
     return Card(
        color: Colors.grey[900],
        child: Padding(
           padding: const EdgeInsets.all(16),
           child: Column(
              children: [
                 _buildTextField(_gracePeriodController, l10n.health_plan_label_grace_period, Icons.timer, isNumber: true),
                 const SizedBox(height: 12),
                 _buildTextField(_annualLimitController, l10n.health_plan_label_annual_limit, Icons.attach_money, isNumber: true),
                 const SizedBox(height: 12),
                 _buildTextField(_copayController, l10n.health_plan_label_copay, Icons.percent, isNumber: true),
                 const SizedBox(height: 12),
                 _buildTextField(_reimbursementController, l10n.health_plan_label_reimburse, Icons.monetization_on, isNumber: true),
                 const SizedBox(height: 12),
                 _buildTextField(_deductibleController, l10n.health_plan_label_deductible, Icons.money_off, isNumber: true),
              ],
           ),
        ),
     );
  }
  
  Widget _buildSupportCard(AppLocalizations l10n) {
     return Card(
        color: Colors.grey[900],
        child: Padding(
           padding: const EdgeInsets.all(16),
           child: Column(
              children: [
                 _buildTextField(_clinicController, l10n.health_plan_label_main_clinic, Icons.local_hospital),
                 const SizedBox(height: 12),
                 _buildTextField(_cityController, l10n.health_plan_label_city, Icons.location_city),
                 const SizedBox(height: 12),
                 Container(
                    decoration: BoxDecoration(
                       color: Colors.black26, 
                       borderRadius: BorderRadius.circular(8)
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                          Text(l10n.health_plan_label_24h, style: const TextStyle(color: Colors.white)),
                          Switch(
                             value: _is24h, 
                             onChanged: (v) => setState(() => _is24h = v),
                             thumbColor: WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                   return const Color(0xFFFFD1DC);
                                }
                                return Colors.grey;
                             }),
                             trackColor: WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                   return const Color(0xFFFFD1DC).withValues(alpha: 0.5);
                                }
                                return null;
                             }),
                          )
                       ],
                    ),
                 ),
                 const SizedBox(height: 12),
                 _buildTextField(_phoneController, l10n.health_plan_label_phone, Icons.phone, isNumber: true),
                 const SizedBox(height: 12),
                 _buildTextField(_whatsappController, l10n.health_plan_label_whatsapp, Icons.chat, isNumber: true),
                 const SizedBox(height: 12),
                 _buildTextField(_emailController, l10n.health_plan_label_email, Icons.email),
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
        prefixIcon: Icon(icon, color: const Color(0xFFFFD1DC)), // Pet Primary
        filled: true,
        fillColor: Colors.black26,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }
}
