class ParsedAgendaIntent {
  final String? category;
  final String? type;
  final DateTime? date;
  final String? time;
  final String? description;
  final bool isHighConfidence;
  final bool hasCriticalError;

  const ParsedAgendaIntent({
    this.category,
    this.type,
    this.date,
    this.time,
    this.description,
    this.isHighConfidence = false,
    this.hasCriticalError = false,
  });

  /// Fabrica a intent a partir do payload JSON extraído pelo Gemini
  factory ParsedAgendaIntent.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['date'] != null && json['date'].toString().isNotEmpty) {
      try {
        parsedDate = DateTime.parse(json['date']);
      } catch (_) {
        // Fallback for unparseable dates
        parsedDate = null;
      }
    }

    return ParsedAgendaIntent(
      category: json['category'],
      type: json['type'],
      date: parsedDate,
      time: json['time'],
      description: json['description'],
      isHighConfidence: json['isHighConfidence'] ?? false,
      hasCriticalError: json['hasCriticalError'] ?? false,
    );
  }

  /// Verifica se os campos vitais estão completamente preenchidos
  bool get isReadyToSave =>
      category != null && category!.isNotEmpty && date != null;

  ParsedAgendaIntent copyWith({
    String? category,
    String? type,
    DateTime? date,
    String? time,
    String? description,
    bool? isHighConfidence,
    bool? hasCriticalError,
  }) {
    return ParsedAgendaIntent(
      category: category ?? this.category,
      type: type ?? this.type,
      date: date ?? this.date,
      time: time ?? this.time,
      description: description ?? this.description,
      isHighConfidence: isHighConfidence ?? this.isHighConfidence,
      hasCriticalError: hasCriticalError ?? this.hasCriticalError,
    );
  }
}
