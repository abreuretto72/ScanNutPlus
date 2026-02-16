import 'package:flutter_test/flutter_test.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';

void main() {
  group('Pet Parsing Logic Tests', () {
    // 1. Standard English Response (Ideal Case)
    test('Should parse standard English keys correctly', () {
      const raw = '''
      [CARD_START]
      TITLE: Nutritional Profile
      ICON: scale
      CONTENT: High protein content suitable for active pets.
      [CARD_END]
      ''';

      final titleMatch = RegExp(PetConstants.regexTitle).firstMatch(raw);
      final contentMatch = RegExp(PetConstants.regexContent, dotAll: true).firstMatch(raw);
      final iconMatch = RegExp(PetConstants.regexIcon).firstMatch(raw);

      expect(titleMatch?.group(1)?.trim(), 'Nutritional Profile');
      expect(contentMatch?.group(1)?.trim(), 'High protein content suitable for active pets.');
      expect(iconMatch?.group(1)?.trim(), 'scale');
    });

    // 2. Portuguese Translated Keys (The Failure Case) - Simulate View Logic
    test('Should parse Portuguese translated keys correctly (Polyglot)', () {
      const raw = '''
      [CARD_START]
      TÍTULO: Perfil Nutricional
      ÍCONE: scale
      CONTEÚDO: Alto teor de proteína.
      [CARD_END]
      ''';

      // Step 1: Extract Body (View Logic)
      final bodyMatch = RegExp(PetConstants.regexCardStart, dotAll: true).firstMatch(raw);
      final body = bodyMatch?.group(1) ?? '';
      
      // Step 2: Parse Fields (Case Insensitive)
      final titleMatch = RegExp(PetConstants.regexTitle, caseSensitive: false).firstMatch(body);
      final contentMatch = RegExp(PetConstants.regexContent, dotAll: true, caseSensitive: false).firstMatch(body);
      final iconMatch = RegExp(PetConstants.regexIcon, caseSensitive: false).firstMatch(body);

      expect(titleMatch?.group(1)?.trim(), 'Perfil Nutricional');
      expect(contentMatch?.group(1)?.trim(), 'Alto teor de proteína.');
      expect(iconMatch?.group(1)?.trim(), 'scale');
    });

    // 3. Mixed/Messy Response (Robustness)
    test('Should handle mixed Case and messy spacing', () {
      const raw = '''
      [CARD_START]
      Titulo:   Análise Garantida  
      Icone: file_text
      Conteudo: 
      Umidade 10%, Proteína 25%.
      [CARD_END]
      ''';

      final bodyMatch = RegExp(PetConstants.regexCardStart, dotAll: true).firstMatch(raw);
      final body = bodyMatch?.group(1) ?? '';

      final titleMatch = RegExp(PetConstants.regexTitle, caseSensitive: false).firstMatch(body);
      final contentMatch = RegExp(PetConstants.regexContent, dotAll: true, caseSensitive: false).firstMatch(body);

      expect(titleMatch?.group(1)?.trim(), 'Análise Garantida');
      expect(contentMatch?.group(1)?.trim(), 'Umidade 10%, Proteína 25%.');
    });
  });
}
