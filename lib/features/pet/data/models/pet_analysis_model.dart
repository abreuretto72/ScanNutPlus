import 'package:scannutplus/features/pet/data/pet_constants.dart';

class PetAnalysisModel {
  final String identifiedBreed;
  final String rawReport;

  PetAnalysisModel({
    required this.identifiedBreed,
    required this.rawReport,
  });

  factory PetAnalysisModel.fromJson(Map<String, dynamic> json) {
    return PetAnalysisModel(
      identifiedBreed: json[PetConstants.keyJsonBreed] as String? ?? PetConstants.valueUnknown,
      rawReport: json[PetConstants.keyJsonReport] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      PetConstants.keyJsonBreed: identifiedBreed,
      PetConstants.keyJsonReport: rawReport,
    };
  }
}
