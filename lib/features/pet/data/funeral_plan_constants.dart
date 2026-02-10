class FuneralPlanConstants {
  // --- SERVICE KEYS (PERSISTENCE) ---
  static const String svcRemoval = 'Removal';
  static const String svcViewing = 'Viewing';
  static const String svcCremationInd = 'CremationInd';
  static const String svcCremationCol = 'CremationCol';
  static const String svcBurial = 'Burial';
  static const String svcUrn = 'Urn';
  static const String svcAshes = 'Ashes';
  static const String svcCertificate = 'Certificate';

  // --- LIST FOR ITERATION ---
  static const List<String> serviceKeys = [
    svcRemoval,
    svcViewing,
    svcCremationInd,
    svcCremationCol,
    svcBurial,
    svcUrn,
    svcAshes,
    svcCertificate,
  ];

  // --- STATUS VALUES ---
  static const String statusActive = 'Active';
  static const String statusUsed = 'Used';
  static const String statusCanceled = 'Canceled';
  static const String statusPending = 'Pending';
  
  static const List<String> statusOptions = [
    statusActive,
    statusPending,
    statusUsed,
    statusCanceled
  ];
}
