// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get app_title => 'ScanNut+';

  @override
  String get login_title => 'Login';

  @override
  String get login_title_plus => 'ScanNut+';

  @override
  String get login_subtitle => 'Acesse seu universo digital de bem-estar';

  @override
  String get login_email_label => 'E-mail';

  @override
  String get login_email_hint => 'E-mail';

  @override
  String get login_password_label => 'Senha';

  @override
  String get login_password_hint => 'Senha';

  @override
  String get login_confirm_password_hint => 'Confirmar Senha';

  @override
  String get login_button_enter => 'Entrar';

  @override
  String get login_button_biometrics => 'Entrar com Biometria';

  @override
  String get login_keep_me => 'Manter conectado';

  @override
  String get login_no_account => 'Não tem uma conta?';

  @override
  String get login_sign_up => 'Cadastre-se';

  @override
  String get biometric_success => 'Biometria verificada com sucesso';

  @override
  String get login_error_credentials => 'Credenciais inválidas';

  @override
  String get error_password_short => 'A senha deve ter pelo menos 8 caracteres';

  @override
  String get error_password_weak =>
      'Requer maiúscula, número e caractere especial';

  @override
  String get error_password_mismatch => 'As senhas não coincidem';

  @override
  String get pwd_help_title => 'Regras de Senha';

  @override
  String get pwd_rule_length => 'Mínimo de 8 caracteres';

  @override
  String get pwd_rule_uppercase => 'Pelo menos uma letra maiúscula';

  @override
  String get pwd_rule_number => 'Pelo menos um número';

  @override
  String get pwd_rule_special => 'Pelo menos um caractere especial';

  @override
  String get biometric_error => 'Falha na autenticação biométrica';

  @override
  String get biometric_reason => 'Escaneie para autenticar';

  @override
  String get biometric_tooltip => 'Biometria';

  @override
  String get common_copyright => 'ScanNut+ © 2026 Multiverso Digital';

  @override
  String get tabFood => 'Food';

  @override
  String get tabPlants => 'Plants';

  @override
  String get tabPets => 'Pets';

  @override
  String get splashPoweredBy => 'Powered by AI Vision';

  @override
  String get home_title => 'Início';

  @override
  String get home_welcome => 'Bem-vindo';

  @override
  String get onboarding_title => 'Bem-vindo ao ScanNut+';

  @override
  String get onboarding_welcome =>
      'Seu companheiro de IA para alimentos, plantas e pets.';

  @override
  String get onboarding_button_start => 'Começar';

  @override
  String get debug_nav_login_forced => 'NAVIGATE_TO_LOGIN_DEBUG';

  @override
  String get debug_nav_onboarding => 'NAVIGATE_TO_ONBOARDING';

  @override
  String get debug_nav_login_no_session => 'NAVIGATE_TO_LOGIN_NO_SESSION';

  @override
  String get debug_nav_home_bio_success => 'NAVIGATE_TO_HOME_BIO_SUCCESS';

  @override
  String get debug_nav_login_bio_fail => 'NAVIGATE_TO_LOGIN_BIO_FAIL';

  @override
  String get debug_nav_home_session_active => 'NAVIGATE_TO_HOME_SESSION_ACTIVE';

  @override
  String get auth_required_fallback => 'Autenticação Obrigatória';

  @override
  String get login_success => 'Login realizado com sucesso';

  @override
  String get signup_success => 'Cadastro realizado com sucesso';

  @override
  String home_welcome_user(Object name) {
    return 'Olá, $name';
  }

  @override
  String get tab_food => 'Food';

  @override
  String get tab_plant => 'Plants';

  @override
  String get tab_pet => 'Pets';

  @override
  String get common_logout => 'Sair';

  @override
  String get logout_success => 'Desconectado com sucesso';

  @override
  String get food_scan_title => 'Scanner de Alimentos';

  @override
  String get food_analyzing => 'Analisando informações nutricionais...';

  @override
  String get food_analysis_success => 'Análise Concluída';

  @override
  String get food_calories => 'Calorias';

  @override
  String get food_protein => 'Proteínas';

  @override
  String get food_carbs => 'Carboidratos';

  @override
  String get food_fat => 'Gorduras';

  @override
  String get food_btn_scan => 'Escanear';

  @override
  String get food_btn_gallery => 'Galeria';

  @override
  String get food_empty_history => 'Nenhum registro ainda.';

  @override
  String get domain_pets_navigation => 'Navegação Pet';

  @override
  String get pets_navigation_subtitle => 'Assistente de Direção Pet';

  @override
  String get menu_profile => 'Perfil';

  @override
  String get menu_settings => 'Configurações';

  @override
  String get menu_help => 'Ajuda';

  @override
  String get stub_map_module => 'Módulo de Mapa em Breve';

  @override
  String get user_demo_name => 'Usuário Demo';

  @override
  String get user_default_name => 'Usuário';

  @override
  String get food_mock_grilled_chicken => 'Salada de Frango Grelhado';

  @override
  String get food_key_calories => 'calorias';

  @override
  String get food_key_protein => 'proteínas';

  @override
  String get food_key_carbs => 'carboidratos';

  @override
  String get food_key_fat => 'gorduras';

  @override
  String get food_key_name => 'nome';

  @override
  String get test_food => 'Teste: Food';

  @override
  String get test_plants => 'Teste: Plants';

  @override
  String get test_pets => 'Teste: Pets';

  @override
  String get test_navigation => 'Teste: Navigation';

  @override
  String get debug_gallery_title => 'Galeria de Cores';

  @override
  String get auth_biometric_reason => 'Escaneie para verificar sua identidade';

  @override
  String get app_name_plus => 'ScanNut+';

  @override
  String get pdf_copyright => '© 2026 ScanNut+ Multiverso Digital';

  @override
  String get pdf_page => 'Página';

  @override
  String get dev_name => 'Multiverso Digital';

  @override
  String get dev_email => 'contato@multiversodigital.com.br';

  @override
  String get about_title => 'Sobre';

  @override
  String get version_label => 'Versão';

  @override
  String get contact_label => 'Contato';

  @override
  String get copyright_label => '© 2026 Multiverso Digital';

  @override
  String get profile_title => 'Perfil';

  @override
  String get profile_email_label => 'E-mail';

  @override
  String get profile_biometric_enable => 'Habilitar Biometria';

  @override
  String get common_confirm_exit => 'Deseja realmente sair?';

  @override
  String get profile_change_password => 'Alterar Senha';

  @override
  String get password_current => 'Senha Atual';

  @override
  String get password_new => 'Nova Senha';

  @override
  String get password_confirm => 'Confirmar Senha';

  @override
  String get password_save => 'Salvar Nova Senha';

  @override
  String get password_match_error => 'As senhas não conferem';

  @override
  String get password_success => 'Senha alterada com sucesso';

  @override
  String get default_user_name => 'Usuário';

  @override
  String get pet_capture_title => 'Captura Pet';

  @override
  String get action_take_photo => 'Tirar Foto';

  @override
  String get action_upload_gallery => 'Upload da Galeria';

  @override
  String get species_label => 'Espécie';

  @override
  String get species_dog => 'Cão';

  @override
  String get species_cat => 'Gato';

  @override
  String get image_type_label => 'Tipo de Imagem';

  @override
  String get type_pet => 'Animal';

  @override
  String get type_label => 'Rótulo';

  @override
  String get pet_saved_success => 'Pet salvo com sucesso';

  @override
  String get label_analysis_pending => 'Análise de rótulo em breve';

  @override
  String get action_retake => 'Tentar Novamente';

  @override
  String get label_name => 'Nome';

  @override
  String get label_email => 'E-mail';

  @override
  String get hint_user_name => 'Digite seu nome';

  @override
  String get section_account_data => 'Dados da Conta';

  @override
  String get help_title => 'Ajuda e Suporte';

  @override
  String get help_how_to_use => 'Como Usar';

  @override
  String get help_pet_scan_tip =>
      'Escaneie seu pet ou rótulos de alimentos para análise nutricional.';

  @override
  String get help_privacy_policy => 'Política de Privacidade';

  @override
  String get help_contact_support => 'Contatar Suporte';

  @override
  String get help_dev_info => 'Desenvolvido por Multiverso Digital';

  @override
  String get help_privacy_content =>
      'Seus dados são processados localmente sempre que possível. Respeitamos sua privacidade.';

  @override
  String get help_email_subject => 'Suporte ScanNut+';

  @override
  String get help_story_title => 'Nossa História';

  @override
  String get help_origin_story =>
      'O nome deste app é uma homenagem ao meu pet, o Nut. Minha ideia era criar uma ferramenta que fizesse a gestão completa da vida dele, partindo de organização de rotina até a criação de cardápios saudáveis. No dia a dia, o ScanNut me ajuda a registrar qualquer intercorrência. Em exames de fezes, urina e sangue, uso a IA para ter insights iniciais através da análise de imagem — um suporte tecnológico que sempre compartilho com o veterinário. Além disso, incluí um guia de plantas para identificar espécies tóxicas e garantir a segurança dele. Pensando na minha saúde, adicionei o Food Scan para controlar calorias, vitaminas e gerar planos alimentares com listas de compras. Sinto que, agora, o app está completo para nós dois.';

  @override
  String get help_analysis_guide_title => 'Guia de Análise IA';

  @override
  String get help_disclaimer =>
      'A análise é apenas visual e não substitui avaliação veterinária.';

  @override
  String get help_section_pet_title => 'Análise Geral do Pet';

  @override
  String get help_section_pet_desc =>
      'Analisa espécie, porte estimado, postura corporal (sinais de dor/conforto) e segurança do ambiente.';

  @override
  String get help_section_wound_title => 'Feridas e Lesões';

  @override
  String get help_section_wound_desc =>
      'Avalia tamanho, aspecto visual (pus/sangue), vermelhidão e sinais inflamatórios.';

  @override
  String get help_section_stool_title => 'Análise de Fezes';

  @override
  String get help_section_stool_desc =>
      'Verifica consistência (Escala de Bristol), alterações de cor e presença visível de muco ou vermes.';

  @override
  String get help_section_mouth_title => 'Boca e Dentes';

  @override
  String get help_section_mouth_desc =>
      'Inspeciona cor da gengiva (pálida/vermelha), acúmulo de tártaro e dentes quebrados.';

  @override
  String get help_section_eyes_title => 'Saúde dos Olhos';

  @override
  String get help_section_eyes_desc =>
      'Detecta secreção, vermelhidão, opacidade (nuvens) e sinais de irritação.';

  @override
  String get help_section_skin_title => 'Pele e Pelagem';

  @override
  String get help_section_skin_desc =>
      'Identifica falhas no pelo (alopecia), vermelhidão, descamação e manchas suspeitas.';

  @override
  String get help_can_do => 'O que a IA detecta';

  @override
  String get help_cannot_do => 'Limite: Requer confirmação vet';

  @override
  String get pet_capture_instructions =>
      'A IA analisa imagens do pet, da ferida, das fezes, da boca, dos olhos e da pele. Uma de cada vez.';

  @override
  String get help_domain_pet_title => 'Domínio Pet';

  @override
  String get help_domain_pet_desc =>
      'Gestão completa para Cães e Gatos: IA para análises visuais, rotinas de saúde e segurança com guia de plantas.';

  @override
  String get help_domain_food_title => 'Domínio Food';

  @override
  String get help_domain_food_desc =>
      'Gestão da sua saúde: Scan de alimentos, contagem de nutrientes e criação de cardápios saudáveis.';

  @override
  String get help_domain_plant_title => 'Domínio Plant';

  @override
  String get help_domain_plant_desc =>
      'Guia de Plantas: Identifique espécies no seu jardim ou casa e saiba instantaneamente se são tóxicas para o seu pet, com base em dados botânicos reais.';

  @override
  String get pet_capture_info_title => 'Recursos IA ScanNut+';

  @override
  String get pet_capture_capability_labels =>
      'Análise de Rótulos e Ingredientes';

  @override
  String get pet_capture_capability_exams => 'Laudos Clínicos e Exames';

  @override
  String get pet_capture_capability_biometrics =>
      'Monitoramento de Postura e Biometria';

  @override
  String get pet_capture_capability_visual => 'Visual Health Inspection';

  @override
  String get pet_input_name_hint => 'What is the pet\'s name?';

  @override
  String get pet_result_status_stable => 'Status: Stable';

  @override
  String get pet_result_summary_title => 'Analysis Summary';

  @override
  String get pet_result_visual_empty => 'No visual anomalies detected';

  @override
  String pet_analysis_error_generic(Object error) {
    return 'Analysis Error: $error';
  }

  @override
  String get pet_urgency_red => 'urgency: red';

  @override
  String get pet_urgency_immediate => 'immediate attention';

  @override
  String get pet_urgency_critical => 'critical';

  @override
  String get pet_urgency_yellow => 'urgency: yellow';

  @override
  String get pet_urgency_monitor => 'monitor';

  @override
  String get pet_status_critical => 'Status: Critical Attention';

  @override
  String get pet_status_monitor => 'Status: Monitor';

  @override
  String get pet_mock_visual_confirm => 'Visual analysis confirms structure...';

  @override
  String get pet_label_pet => 'Pet';

  @override
  String get pet_section_species => 'Species Identification';

  @override
  String get pet_section_health => 'General Health & Behavior';

  @override
  String get pet_section_coat => 'General Coat Condition';

  @override
  String get pet_section_skin => 'Skin Appearance';

  @override
  String get pet_action_share => 'Compartilhar';

  @override
  String get source_merck => 'Manual Veterinário Merck (MSD Digital 2026)';

  @override
  String get source_scannut => 'Protocolo de Biometria e Fenotipagem ScanNut+';

  @override
  String get source_aaha => 'Diretrizes de Exame Físico AAHA/WSAVA';

  @override
  String get pet_section_ears => 'Ear Health';

  @override
  String get pet_section_nose => 'Nose';

  @override
  String get pet_section_eyes => 'Olhos';

  @override
  String get pet_section_body => 'Corpo';

  @override
  String get pet_section_issues => 'Potential Issues';

  @override
  String get pet_status_healthy => 'HEALTHY STATUS';

  @override
  String get pet_status_attention => 'ATTENTION REQUIRED';

  @override
  String get key_green => 'Monitorar';

  @override
  String get key_yellow => 'Atenção';

  @override
  String get key_red => 'Crítico';

  @override
  String get value_unknown => 'Desconhecido';

  @override
  String error_database_load(String error) {
    return 'Erro ao carregar banco de dados: $error';
  }

  @override
  String get pet_section_mouth => 'Boca';

  @override
  String get pet_section_posture => 'Postura';

  @override
  String get pet_section_exams => 'Exames';

  @override
  String get category_feces => 'Fezes';

  @override
  String get category_food_label => 'Rótulo';

  @override
  String get pet_type_general => 'Geral';

  @override
  String get category_wound => 'Ferida';

  @override
  String get pet_dialog_new_title => 'Novo Perfil';

  @override
  String get category_clinical => 'Clínico';

  @override
  String get category_lab => 'Laboratório';

  @override
  String get pet_section_general => 'Análise Geral';

  @override
  String get pet_section_biometrics => 'Biometria';

  @override
  String get pet_section_weight => 'Peso';

  @override
  String get pet_ui_my_pets => 'Meus Pets';

  @override
  String get pet_my_pets_title => 'Meus Pets';

  @override
  String get pet_no_pets_registered => 'Nenhum pet registrado ainda.';

  @override
  String get pet_dashboard_title => 'Painel do Pet';

  @override
  String get pet_action_biometrics => 'Biometria';

  @override
  String get pet_action_history => 'Prontuário';

  @override
  String get pet_type_label => 'Rótulo';

  @override
  String get pet_type_wound => 'Ferida';

  @override
  String get pet_type_stool => 'Fezes';

  @override
  String get pet_type_mouth => 'Boca/Dentes';

  @override
  String get pet_type_eyes => 'Olhos';

  @override
  String get pet_type_skin => 'Pele/Pelo';

  @override
  String get pet_type_lab => 'Exame Lab';

  @override
  String get pet_select_context => 'Selecione o tipo de análise:';

  @override
  String get pet_unknown => 'Desconhecido';

  @override
  String pet_analyzing_x(String name) {
    return 'Analisando: $name';
  }

  @override
  String pet_id_format(String id) {
    return 'ID: $id...';
  }

  @override
  String get pet_section_visual => 'Inspeção Visual';

  @override
  String get pet_type_safety => 'Segurança';

  @override
  String get pet_type_new_profile => 'Novo Perfil';

  @override
  String get pet_waze_title => 'Waze Pet';

  @override
  String get pet_waze_desc => 'Alertas da comunidade próximos a você';

  @override
  String get pet_partners_title => 'Parceiros';

  @override
  String get pet_partners_desc => 'Descontos e serviços';

  @override
  String get pet_tab_history => 'Histórico';

  @override
  String get pet_history_empty => 'Nenhum histórico disponível';

  @override
  String get pet_analysis_result_title => 'Resultado da Análise';

  @override
  String get pet_status_healthy_simple => 'Saudável';

  @override
  String get pet_status_critical_simple => 'Crítico';

  @override
  String get pet_status_attention_simple => 'Atenção';

  @override
  String get pet_section_sources => 'Referências e Protocolo';

  @override
  String get pet_action_new_analysis => 'Nova Análise';

  @override
  String get source_scannut_db => 'Banco de Dados ScanNut+';

  @override
  String get pet_unknown_name => 'Nome Desconhecido';

  @override
  String get pet_footer_brand => 'Inteligência Pet ScanNut+';

  @override
  String get pet_label_status => 'Status';

  @override
  String get pet_history_title => 'Histórico de Análises';

  @override
  String get pet_breed_unknown => 'Raça não informada';

  @override
  String get pet_delete_title => 'Excluir Pet';

  @override
  String get pet_delete_content =>
      'Tem certeza que deseja excluir este pet e todo o histórico?';

  @override
  String get pet_delete_confirm => 'Excluir';

  @override
  String get pet_delete_cancel => 'Cancelar';

  @override
  String get pet_delete_success => 'Pet excluído com sucesso';

  @override
  String get pet_recent_analyses => 'Últimas Análises';

  @override
  String get pet_no_history => 'Nenhuma análise recente.';

  @override
  String get pet_new_pet => 'Novo Pet';

  @override
  String get val_unknown_date => 'Data Desconhecida';

  @override
  String get report_generated_on => 'Gerado em';

  @override
  String get pet_analysis_skin => 'Pele e Pelagem';

  @override
  String get pet_analysis_mouth => 'Saúde Bucal';

  @override
  String get pet_analysis_stool => 'Triagem de Excrementos';

  @override
  String get pet_analysis_lab => 'Leitura de Exames';

  @override
  String get pet_analysis_label => 'Nutricional e Rótulos';

  @override
  String get pet_analysis_posture => 'Condição Corporal';

  @override
  String get ai_feedback_no_oral_layout =>
      'Nenhuma estrutura oral visível para análise.';

  @override
  String get ai_feedback_no_derm_abnormalities =>
      'Nenhuma anormalidade dermatológica detectada com base na evidência visual.';

  @override
  String get ai_feedback_invalid_gastro =>
      'CONTEXTO_INVÁLIDO: A imagem não parece ser conteúdo gastrointestinal.';

  @override
  String get ai_feedback_invalid_lab =>
      'CONTEXTO_INVÁLIDO: A imagem não é um exame laboratorial.';

  @override
  String get ai_feedback_lab_disclaimer =>
      'Interpretação baseada em texto visível. Verifique com o documento original.';

  @override
  String get ai_feedback_eyes_not_visible => 'Olhos não totalmente visíveis.';

  @override
  String get ai_feedback_inconclusive_angle => 'Ângulo visual inconclusivo.';

  @override
  String get pet_module_dentistry => 'Saúde Bucal (Dentes e Gengivas)';

  @override
  String get pet_module_dermatology => 'Pele, Pelagem e Feridas';

  @override
  String get pet_module_gastro => 'Análise de Fezes e Digestão';

  @override
  String get pet_module_lab => 'Leitura de Exames Laboratoriais';

  @override
  String get pet_module_nutrition => 'Análise de Rótulos e Alimentos';

  @override
  String get pet_module_ophthalmology => 'Análise de Olhos e Ouvidos';

  @override
  String get pet_module_physique => 'Condição Corporal e Peso (ECC)';

  @override
  String get btn_scan_image => 'Escanear Imagem';

  @override
  String get generic_analyzing => 'Analisando imagem...';

  @override
  String get pet_error_image_not_found =>
      'Erro: Imagem original não encontrada.';

  @override
  String get btn_go => 'Ir';

  @override
  String get pet_created_at_label => 'Criado em:';

  @override
  String get pet_initial_assessment => 'Avaliação Inicial';

  @override
  String get pet_hint_select_type => '<Selecione o tipo>';

  @override
  String get pet_label_info => 'Informação';

  @override
  String get pet_type_profile => 'Análise de Perfil';

  @override
  String get pet_type_posture => 'Análise de Postura';
}
