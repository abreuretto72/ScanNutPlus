// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'pet_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class PetLocalizationsPt extends PetLocalizations {
  PetLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get pet_capture_title => 'Captura Pet';

  @override
  String get pet_capture_instructions => 'A IA analisa imagens do pet, da ferida, das fezes, da boca, dos olhos e da pele. Uma de cada vez.';

  @override
  String get pet_saved_success => 'Pet salvo com sucesso';

  @override
  String get pet_analysis_error => 'Falha na análise';

  @override
  String get pet_history_empty => 'Nenhum histórico encontrado';

  @override
  String get pet_tab_history => 'Histórico';

  @override
  String get pet_tab_capture => 'Capturar';

  @override
  String get pet_label_species => 'Espécie';

  @override
  String get pet_label_dog => 'Cão';

  @override
  String get pet_label_cat => 'Gato';

  @override
  String get pet_result_title => 'Resultado da Análise';

  @override
  String get pet_section_observations => 'Observações Visuais';

  @override
  String get pet_section_sources => 'Fontes Consultadas';

  @override
  String get pet_disclaimer => 'A análise é apenas visual e não substitui avaliação veterinária.';

  @override
  String get pet_action_share => 'Compartilhar com Vet';

  @override
  String get pet_action_new_analysis => 'Nova Análise';

  @override
  String get pet_footer_text => 'Página de Resultado | © 2026 Multiverso Digital';

  @override
  String get pet_action_analyze => 'Analisar Agora';

  @override
  String get pet_status_analyzing => 'Analisando...';

  @override
  String get pet_voice_title => 'Identificação Vocal';

  @override
  String get pet_voice_instruction => 'Novo amigo detectado! Qual o nome, sexo, peso e idade?';

  @override
  String get pet_voice_hint => 'Ex: Thor, Macho, 12kg, 4 anos';

  @override
  String get pet_voice_action => 'Enviar Voz';

  @override
  String get pet_voice_retry => 'Tentar Novamente';

  @override
  String pet_rag_new_identity(Object name) {
    return 'Identidade salva: $name';
  }

  @override
  String pet_analysis_for(Object name) {
    return 'Análise: $name';
  }

  @override
  String get pet_voice_who_is_this => 'Quem é este pet?';
}
