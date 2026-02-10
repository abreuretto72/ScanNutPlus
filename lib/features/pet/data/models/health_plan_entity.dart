import 'package:objectbox/objectbox.dart';

@Entity()
class HealthPlanEntity {
  @Id()
  int id = 0;

  @Index()
  String petUuid; // Link to Pet

  // --- 1. Identify ---
  String? operatorName;
  String? planName;
  String? cardNumber;
  String? holderName;
  String? holderCpf;

  @Property(type: PropertyType.date)
  DateTime? startDate;
  
  @Property(type: PropertyType.date)
  DateTime? renewalDate;

  String? status; // Active, Suspended, Canceled

  // --- 2. Coverages (Stored as CSV or JSON string list) ---
  // List<String> coverages; // ObjectBox doesn't support List<String> directly yet without converter
  String? coveragesJson; // "consultas,vacinas,exames,..."

  // --- 3. Limits & Rules ---
  int? gracePeriodDays; 
  double? annualLimit;
  double? copayPercent; 
  double? reimbursementPercent; 
  double? deductible; // Franquia

  // --- 4. Network & Support ---
  String? mainClinicName;
  String? supportCity;
  String? supportPhone;
  String? supportWhatsapp;
  String? supportEmail;
  bool is24hService;

  // --- Attachments (Paths) ---
  String? policyPath;
  String? cardImagePath;

  HealthPlanEntity({
    this.id = 0,
    required this.petUuid,
    this.operatorName,
    this.planName,
    this.cardNumber,
    this.holderName,
    this.holderCpf,
    this.startDate,
    this.renewalDate,
    this.status,
    this.coveragesJson,
    this.gracePeriodDays,
    this.annualLimit,
    this.copayPercent,
    this.reimbursementPercent,
    this.deductible,
    this.mainClinicName,
    this.supportCity,
    this.supportPhone,
    this.supportWhatsapp,
    this.supportEmail,
    this.is24hService = false,
    this.policyPath,
    this.cardImagePath,
  });
}
