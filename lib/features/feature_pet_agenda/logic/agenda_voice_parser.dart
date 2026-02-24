import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/parsed_agenda_intent.dart';

class AgendaVoiceParser {
  final GenerativeModel _model;

  AgendaVoiceParser(String apiKey)
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
        );

  Future<ParsedAgendaIntent> parseSpeech(String rawSpeech) async {
    if (rawSpeech.trim().isEmpty) {
      return const ParsedAgendaIntent(hasCriticalError: true);
    }

    final prompt = '''
Você é um assistente de extração de dados para agendas veterinárias.
O usuário enviou este texto falado: "$rawSpeech".

Extraia as intenções e retorne APENAS um objeto JSON num formato estrito (sem blocks de markdown ou aspas ao redor).

Formato exigido:
{
  "category": "String (Saúde, Nutrição, Passeio, Higiene, Comportamento, Outros)",
  "type": "String (Ex: Consulta, Vacina, Banho, Exame... deduza se o usuário não disser exatamente)",
  "date": "String ISO8601 YYYY-MM-DD (Tente adivinhar a data baseada em 'hoje', 'amanhã', etc. O ano atual é ${DateTime.now().year}, mês atual é ${DateTime.now().month}, dia atual é ${DateTime.now().day}. Deixe nulo se não conseguir deduzir)",
  "time": "String HH:mm (ex: 14:00). Deixe nulo se não foi falado.",
  "description": "String (O que vai fazer? Resuma a intenção)",
  "isHighConfidence": boolean (true se você tem certeza de todos os dados extraídos, false se algo ficou ambíguo ou faltou),
  "hasCriticalError": boolean (true apenas se o texto for muito confuso, vazio, ou pedir uma data no passado claramente impossível)
}

Retorne cru, apenas JSON. Nada mais.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final rawText = response.text ?? '{}';
      
      // Clean up potential markdown blocks from model output
      final cleanedText = rawText.replaceAll('```json', '').replaceAll('```', '').trim();
      
      final Map<String, dynamic> jsonMap = jsonDecode(cleanedText);
      return ParsedAgendaIntent.fromJson(jsonMap);
    } catch (e) {
      // Return a safe fallback intent indicating failure
      return const ParsedAgendaIntent(hasCriticalError: true);
    }
  }
}
