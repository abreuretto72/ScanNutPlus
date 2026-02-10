import 'package:objectbox/objectbox.dart';

@Entity()
class FuneralPlanEntity {
  @Id()
  int id = 0;

  @Index()
  String petUuid;

  String funeralCompany;
  String planName;
  String contractNumber;
  DateTime? startDate;
  
  // Status handled as String from Constants
  String status; 

  // Stored as JSON string identifying enabled services
  String includedServicesJson; 

  // Rules
  int gracePeriodDays;
  double maxWeightKg;
  bool is24hService;

  // Emergency Contact
  String phone24h;
  String whatsApp;

  // Costs
  double planValue;
  double extraFees;

  // Documents
  String? contractPath;
  String? certificatePath;

  FuneralPlanEntity({
    required this.petUuid,
    this.funeralCompany = '',
    this.planName = '',
    this.contractNumber = '',
    this.startDate,
    this.status = 'Active',
    this.includedServicesJson = '{}',
    this.gracePeriodDays = 0,
    this.maxWeightKg = 0.0,
    this.is24hService = false,
    this.phone24h = '',
    this.whatsApp = '',
    this.planValue = 0.0,
    this.extraFees = 0.0,
    this.contractPath,
    this.certificatePath,
  });
}
