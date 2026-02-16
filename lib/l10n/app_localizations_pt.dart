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
  String get tabFood => 'Alimentos';

  @override
  String get tabPlants => 'Plantas';

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
  String get auth_required_fallback => 'Authentication Required';

  @override
  String get login_success => 'Login successful';

  @override
  String get signup_success => 'Registration successful';

  @override
  String home_welcome_user(Object name) {
    return 'Olá, $name';
  }

  @override
  String get tab_food => 'Alimentos';

  @override
  String get tab_plant => 'Plantas';

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
  String get food_key_calories => 'calories';

  @override
  String get food_key_protein => 'protein';

  @override
  String get food_key_carbs => 'carbs';

  @override
  String get food_key_fat => 'fat';

  @override
  String get food_key_name => 'name';

  @override
  String get test_food => 'Test: Food';

  @override
  String get test_plants => 'Test: Plants';

  @override
  String get test_pets => 'Test: Pets';

  @override
  String get test_navigation => 'Test: Navigation';

  @override
  String get debug_gallery_title => 'Color Gallery';

  @override
  String get auth_biometric_reason => 'Scan to verify your identity';

  @override
  String get app_name_plus => 'ScanNut+';

  @override
  String get pdf_copyright => '© 2026 ScanNut+ Multiverso Digital';

  @override
  String get pdf_page => 'Page';

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
  String get type_label => 'Alimentos';

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
      'Seus dados são processados localmente sempre que possível.';

  @override
  String get help_email_subject => 'ScanNut+ Support';

  @override
  String get help_story_title => 'Nossa História';

  @override
  String get help_origin_story =>
      'O nome deste app é uma homenagem ao meu pet, o Nut.';

  @override
  String get help_analysis_guide_title => 'Guia de Análise IA';

  @override
  String get help_disclaimer =>
      'A análise é apenas visual e não substitui avaliação veterinária.';

  @override
  String get help_section_pet_title => 'Análise Geral do Pet';

  @override
  String get help_section_pet_desc => 'Analisa espécie, porte e postura.';

  @override
  String get help_section_wound_title => 'Feridas e Lesões';

  @override
  String get help_section_wound_desc => 'Avalia aspectos visuais de lesões.';

  @override
  String get help_section_stool_title => 'Análise de Fezes';

  @override
  String get help_section_stool_desc => 'Verifica consistência e cor.';

  @override
  String get help_section_mouth_title => 'Boca e Dentes';

  @override
  String get help_section_mouth_desc => 'Inspeciona dentes e gengiva.';

  @override
  String get help_section_eyes_title => 'Saúde dos Olhos';

  @override
  String get help_section_eyes_desc => 'Detecta secreção e vermelhidão.';

  @override
  String get help_section_skin_title => 'Pele e Pelagem';

  @override
  String get help_section_skin_desc => 'Identifica falhas e descamação.';

  @override
  String get help_can_do => 'O que a IA detecta';

  @override
  String get help_cannot_do => 'Limite: Requer confirmação vet';

  @override
  String get pet_capture_instructions =>
      'A IA analisa imagens do pet individualmente.';

  @override
  String get help_domain_pet_title => 'Domínio Pet';

  @override
  String get help_domain_pet_desc => 'Gestão completa para Cães e Gatos.';

  @override
  String get help_domain_food_title => 'Domínio Food';

  @override
  String get help_domain_food_desc => 'Gestão da sua saúde nutricional.';

  @override
  String get help_domain_plant_title => 'Domínio Plant';

  @override
  String get help_domain_plant_desc => 'Identifique plantas tóxicas.';

  @override
  String get pet_capture_info_title => 'Recursos IA ScanNut+';

  @override
  String get pet_capture_capability_labels => 'Análise de Rótulos';

  @override
  String get pet_capture_capability_exams => 'Laudos Clínicos';

  @override
  String get pet_capture_capability_biometrics => 'Monitoramento Postura';

  @override
  String get pet_capture_capability_visual => 'Visual Health Inspection';

  @override
  String get pet_input_name_hint => 'Qual o nome do pet?';

  @override
  String get pet_result_status_stable => 'Status: Estável';

  @override
  String get pet_result_summary_title => 'Resumo da Análise';

  @override
  String get pet_result_visual_empty => 'Sem anomalias visuais detectadas';

  @override
  String pet_analysis_error_generic(Object error) {
    return 'Erro de Análise: $error';
  }

  @override
  String get pet_urgency_red => 'Urgência: Crítico';

  @override
  String get pet_urgency_immediate => 'Atenção Imediata';

  @override
  String get pet_urgency_critical => 'Crítico';

  @override
  String get pet_urgency_yellow => 'Urgência: Atenção';

  @override
  String get pet_urgency_monitor => 'Monitorar';

  @override
  String get pet_status_critical => 'Status: Atenção Crítica';

  @override
  String get pet_status_monitor => 'Status: Monitorar';

  @override
  String get pet_mock_visual_confirm => 'Análise visual confirmada.';

  @override
  String get pet_label_pet => 'Pet';

  @override
  String get pet_section_species => 'Espécie';

  @override
  String get pet_section_health => 'Saúde Geral';

  @override
  String get pet_section_coat => 'Pelagem';

  @override
  String get pet_section_skin => 'Pele';

  @override
  String get pet_action_share => 'Compartilhar';

  @override
  String get source_merck => 'Manual Veterinário Merck 2026';

  @override
  String get source_scannut => 'Protocolo ScanNut+';

  @override
  String get source_aaha => 'Diretrizes AAHA/WSAVA';

  @override
  String get pet_section_ears => 'Ouvidos';

  @override
  String get pet_section_nose => 'Nariz';

  @override
  String get pet_section_eyes => 'Olhos';

  @override
  String get pet_section_body => 'Corpo';

  @override
  String get pet_section_issues => 'Alertas';

  @override
  String get pet_status_healthy => 'SAUDÁVEL';

  @override
  String get pet_status_attention => 'ATENÇÃO';

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
    return 'Erro ao carregar banco: $error';
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
  String get category_food_label => 'Alimentos';

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
  String get pet_no_pets_registered => 'Nenhum pet registrado.';

  @override
  String get pet_dashboard_title => 'Painel do Pet';

  @override
  String get pet_action_biometrics => 'Biometria';

  @override
  String get pet_action_history => 'Prontuário';

  @override
  String get pet_type_label => 'Alimentos';

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
    return 'ID: $id';
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
  String get pet_waze_desc => 'Alertas da comunidade';

  @override
  String get pet_partners_title => 'Parceiros';

  @override
  String get pet_partners_desc => 'Descontos e serviços';

  @override
  String get pet_tab_history => 'Histórico';

  @override
  String get pet_history_empty => 'Histórico vazio';

  @override
  String get pet_analysis_result_title => 'Resultado';

  @override
  String get pet_status_healthy_simple => 'Saudável';

  @override
  String get pet_status_critical_simple => 'Crítico';

  @override
  String get pet_status_attention_simple => 'Atenção';

  @override
  String get pet_section_sources => 'Referências';

  @override
  String get pet_action_new_analysis => 'Nova Análise';

  @override
  String get source_scannut_db => 'Banco ScanNut+';

  @override
  String get pet_unknown_name => 'Sem Nome';

  @override
  String get pet_footer_brand => 'Inteligência Pet ScanNut+';

  @override
  String get pet_label_status => 'Status';

  @override
  String get pet_history_title => 'Histórico de Análises';

  @override
  String get pet_breed_unknown => 'Raça não informada';

  @override
  String get pet_label_breed => 'Raça';

  @override
  String get pet_label_sex => 'Sexo';

  @override
  String get pet_sex_male => 'Macho';

  @override
  String get pet_sex_female => 'Fêmea';

  @override
  String get pet_delete_title => 'Excluir Pet';

  @override
  String get pet_delete_content => 'Deseja realmente excluir?';

  @override
  String get pet_delete_confirm => 'Excluir';

  @override
  String get pet_delete_cancel => 'Cancelar';

  @override
  String get pet_history_delete_success => 'Histórico excluído';

  @override
  String get pet_ai_overloaded_message => 'IA sobrecarregada!';

  @override
  String get pet_delete_success => 'Pet excluído';

  @override
  String get pet_recent_analyses => 'Últimas Análises';

  @override
  String get pet_no_history => 'Sem análises.';

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
  String get pet_analysis_stool => 'Fezes';

  @override
  String get pet_analysis_lab => 'Exames';

  @override
  String get pet_analysis_label => 'Nutricional';

  @override
  String get pet_analysis_posture => 'Condição Corporal';

  @override
  String get ai_feedback_no_oral_layout => 'Sem estrutura oral visível.';

  @override
  String get ai_feedback_no_derm_abnormalities => 'Sem anormalidades de pele.';

  @override
  String get ai_feedback_invalid_gastro =>
      'Imagem não é conteúdo gastrointestinal.';

  @override
  String get ai_feedback_invalid_lab => 'Imagem não é exame laboratorial.';

  @override
  String get ai_feedback_lab_disclaimer => 'Verifique o documento original.';

  @override
  String get ai_feedback_eyes_not_visible => 'Olhos não visíveis.';

  @override
  String get ai_feedback_inconclusive_angle => 'Ângulo inconclusivo.';

  @override
  String get pet_module_dentistry => 'Saúde Bucal';

  @override
  String get pet_module_dermatology => 'Pele e Pelagem';

  @override
  String get pet_module_gastro => 'Digestão';

  @override
  String get pet_module_lab => 'Laboratório';

  @override
  String get pet_module_nutrition => 'Rótulos';

  @override
  String get pet_module_ophthalmology => 'Oftalmologia';

  @override
  String get pet_module_physique => 'Condição Corporal';

  @override
  String get pet_module_nutrition_programs =>
      'Análise de Rótulos, Tabela Nutricional';

  @override
  String get pet_module_vocal => 'Vocalização';

  @override
  String get pet_module_vocal_programs => 'Latidos, Miados, Tosse, Respiração';

  @override
  String get pet_module_behavior => 'Comportamento';

  @override
  String get pet_module_behavior_programs =>
      'Raça, Postura, Ansiedade, Tremores';

  @override
  String get pet_module_plant => 'Plantas';

  @override
  String get pet_module_plant_programs => 'Identificação de Plantas Tóxicas';

  @override
  String get pet_module_food_bowl => 'Alimentação';

  @override
  String get action_record_video_audio => 'Gravar';

  @override
  String get action_select_audio => 'Escolher Áudio';

  @override
  String get action_upload_video_audio => 'Carregar';

  @override
  String get pet_mode_my_pet => 'Meu Pet';

  @override
  String get pet_mode_friend => 'Pet Amigo';

  @override
  String get pet_label_tutor => 'Tutor';

  @override
  String get pet_hint_select_friend => 'Selecione';

  @override
  String get pet_new_friend_option => 'Novo Amigo';

  @override
  String get pet_friend_list_label => 'Amigos';

  @override
  String get pet_error_fill_friend_fields => 'Preencha tudo.';

  @override
  String pet_result_title_my_pet(Object name) {
    return 'Meu Pet: $name';
  }

  @override
  String pet_result_title_friend_pet(Object name, Object tutor) {
    return 'Amigo: $name';
  }

  @override
  String get pet_action_edit_friend => 'Editar';

  @override
  String get pet_action_delete_friend => 'Excluir';

  @override
  String get pet_msg_confirm_delete_friend => 'Excluir amigo?';

  @override
  String get pet_msg_friend_updated => 'Atualizado!';

  @override
  String get pet_msg_friend_deleted => 'Excluído!';

  @override
  String get pet_dialog_edit_title => 'Editar Amigo';

  @override
  String get pet_plant_toxic => 'TÓXICA ⚠️';

  @override
  String get pet_plant_safe => 'SEGURA ✅';

  @override
  String get pet_msg_confirm_delete_entry => 'Excluir análise?';

  @override
  String get pet_event_type_activity => 'Atividade';

  @override
  String get health_plan_label_card_number => 'Carteirinha';

  @override
  String get pet_analysis_visual_title => 'Análise Visual';

  @override
  String get pet_label_whatsapp => 'WhatsApp';

  @override
  String get label_photo => 'Foto';

  @override
  String get label_gallery => 'Galeria';

  @override
  String get label_video => 'Vídeo';

  @override
  String get label_sounds => 'Sons';

  @override
  String get label_vocal => 'Vocalização';

  @override
  String get pet_journal_recording => 'Gravando...';

  @override
  String get pet_journal_audio_saved => 'Áudio salvo';

  @override
  String get pet_journal_photo_saved => 'Foto salva!';

  @override
  String get pet_journal_video_saved => 'Vídeo salvo!';

  @override
  String get error_file_too_large => 'Máx 20MB';

  @override
  String get pet_journal_searching_address => 'Endereço...';

  @override
  String get pet_journal_address_not_found => 'Não achado';

  @override
  String get pet_journal_report_action => 'Relatar';

  @override
  String get pet_journal_question => 'O que houve?';

  @override
  String get pet_journal_hint_text => 'Escreva aqui...';

  @override
  String get pet_journal_register_button => 'Registrar';

  @override
  String get help_guide_title => 'Guia';

  @override
  String get btn_got_it => 'Entendi';

  @override
  String get map_alert_title => 'Reportar';

  @override
  String get map_type_normal => 'Padrão';

  @override
  String get map_type_satellite => 'Satélite';

  @override
  String get common_delete_confirm_title => 'Excluir?';

  @override
  String get common_delete_confirm_message => 'Deseja remover?';

  @override
  String get pet_profile_title_simple => 'Perfil';

  @override
  String get pet_action_save_profile_simple => 'Salvar';

  @override
  String get funeral_save_success => 'Salvo!';

  @override
  String get health_plan_saved_success => 'Salvo!';

  @override
  String pet_age_years(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anos',
      one: '1 ano',
    );
    return '$_temp0';
  }

  @override
  String get keywordFriend => 'Amigo';

  @override
  String get keywordGuest => 'Convidado';

  @override
  String get pet_agenda_view_calendar => 'Ver Calendário';

  @override
  String get pet_module_dentistry_programs =>
      'Tártaro, Gengivite, Dentes Quebrados';

  @override
  String get pet_module_dermatology_programs =>
      'Alopecias, Dermatites, Feridas, Parasitas';

  @override
  String get pet_module_gastro_programs =>
      'Consistência, Cor, Parasitas, Sangue';

  @override
  String get pet_module_ophthalmology_programs =>
      'Secreção, Vermelhidão, Catarata, Manchas';

  @override
  String get pet_module_otology_programs => 'Cera, Coceira, Odor, Vermelhidão';

  @override
  String get pet_module_physique_programs =>
      'Escore Corporal, Massa Muscular, Obesidade';

  @override
  String get pet_module_lab_programs => 'Hemograma, Bioquímico, Urina, Fezes';

  @override
  String get pet_module_food_bowl_programs =>
      'Qualidade da Ração, Comida Natural';

  @override
  String get pet_journal_audio_saved_success => 'Áudio salvo!';

  @override
  String get pet_journal_photo_saved_success => 'Foto salva!';

  @override
  String get pet_journal_video_saved_success => 'Vídeo salvo!';

  @override
  String get funeral_save_success_simple => 'Funeral salvo!';

  @override
  String get health_plan_saved_success_simple => 'Saúde salvo!';

  @override
  String get pet_module_ears => 'Ouvidos';

  @override
  String get pet_label_size => 'Porte';

  @override
  String get pet_size_small => 'Pequeno';

  @override
  String get pet_size_medium => 'Médio';

  @override
  String get pet_size_large => 'Grande';

  @override
  String get pet_label_estimated_weight => 'Peso estimado';

  @override
  String get pet_weight_unit => 'kg';

  @override
  String get pet_label_neutered => 'Castrado';

  @override
  String get pet_clinical_title => 'Clínico';

  @override
  String get pet_label_allergies => 'Alergias';

  @override
  String get pet_label_chronic => 'Doenças crônicas';

  @override
  String get pet_label_disabilities => 'Deficiências';

  @override
  String get pet_label_observations => 'Notas';

  @override
  String get pet_id_external_title => 'ID Externo';

  @override
  String get pet_label_microchip => 'Microchip';

  @override
  String get pet_label_registry => 'Registro';

  @override
  String get pet_label_qrcode => 'QR Code';

  @override
  String get pet_qrcode_future => 'Em breve';

  @override
  String get pet_plans_title => 'Planos';

  @override
  String get pet_action_manage_health_plan => 'Saúde';

  @override
  String get health_plan_title => 'Plano de Saúde';

  @override
  String get health_plan_section_identification => '1. Identificação';

  @override
  String get health_plan_section_coverages => '2. Coberturas';

  @override
  String get health_plan_section_limits => '3. Regras';

  @override
  String get health_plan_section_support => '4. Suporte';

  @override
  String get health_plan_action_save => 'SALVAR';

  @override
  String get health_plan_label_operator => 'Operadora';

  @override
  String get health_plan_label_plan_name => 'Nome';

  @override
  String get health_plan_label_holder_name => 'Titular';

  @override
  String get health_plan_label_grace_period => 'Carência';

  @override
  String get health_plan_label_annual_limit => 'Limite';

  @override
  String get health_plan_label_copay => 'Copart.';

  @override
  String get health_plan_label_reimburse => 'Reembolso';

  @override
  String get health_plan_label_deductible => 'Franquia';

  @override
  String get health_plan_label_main_clinic => 'Clínica';

  @override
  String get health_plan_label_city => 'Cidade';

  @override
  String get health_plan_label_24h => '24h';

  @override
  String get health_plan_label_phone => 'Telefone';

  @override
  String get health_plan_label_whatsapp => 'WhatsApp';

  @override
  String get health_plan_label_email => 'E-mail';

  @override
  String get health_cov_consultations => 'Consultas';

  @override
  String get health_cov_vaccines => 'Vacinas';

  @override
  String get health_cov_lab_exams => 'Exames Lab';

  @override
  String get health_cov_imaging => 'Imagem';

  @override
  String get health_cov_surgery => 'Cirurgia';

  @override
  String get health_cov_hospitalization => 'Internação';

  @override
  String get health_cov_emergency => 'Emergência';

  @override
  String get health_cov_pre_existing => 'Pré-existentes';

  @override
  String get health_cov_dentistry => 'Odonto';

  @override
  String get health_cov_physiotherapy => 'Fisio';

  @override
  String get pet_db_sync_error => 'Erro de Sincronização';

  @override
  String get pet_action_manage_funeral_plan => 'Funeral';

  @override
  String get funeral_plan_title => 'Plano Funerário';

  @override
  String get funeral_section_identity => '1. Identificação';

  @override
  String get funeral_section_services => '2. Serviços';

  @override
  String get funeral_section_rules => '3. Regras';

  @override
  String get funeral_section_emergency => '4. EMERGÊNCIA';

  @override
  String get funeral_label_company => 'Empresa';

  @override
  String get funeral_label_plan_name => 'Plano';

  @override
  String get funeral_label_contract => 'Contrato';

  @override
  String get funeral_label_start_date => 'Início';

  @override
  String get funeral_label_status => 'Status';

  @override
  String get funeral_label_grace_period => 'Carência';

  @override
  String get funeral_label_max_weight => 'Peso Máx';

  @override
  String get funeral_label_24h => '24h';

  @override
  String get funeral_label_phone => 'Telefone';

  @override
  String get funeral_label_whatsapp => 'WhatsApp';

  @override
  String get funeral_label_value => 'Valor';

  @override
  String get funeral_label_extra_fees => 'Taxas';

  @override
  String get funeral_svc_removal => 'Remoção';

  @override
  String get funeral_svc_viewing => 'Velório';

  @override
  String get funeral_svc_cremation_ind => 'Cremação Ind.';

  @override
  String get funeral_svc_cremation_col => 'Cremação Col.';

  @override
  String get funeral_svc_burial => 'Enterro';

  @override
  String get funeral_svc_urn => 'Urna';

  @override
  String get funeral_svc_ashes => 'Cinzas';

  @override
  String get funeral_svc_certificate => 'Certificado';

  @override
  String get funeral_action_call_emergency => 'EMERGÊNCIA';

  @override
  String get funeral_action_save => 'SALVAR';

  @override
  String get pet_action_analyses => 'Análises';

  @override
  String get pet_action_health => 'Saúde';

  @override
  String get pet_action_agenda => 'Agenda';

  @override
  String get pet_history_button => 'Histórico';

  @override
  String ai_assistant_title(Object name) {
    return 'IA $name';
  }

  @override
  String get ai_input_hint => 'Pergunte aqui...';

  @override
  String get ai_listening => 'Ouvindo...';

  @override
  String get ai_error_mic => 'Microfone negado';

  @override
  String get ai_thinking => 'Pensando...';

  @override
  String pet_age_months(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meses',
      one: '1 mês',
    );
    return '$_temp0';
  }

  @override
  String get pet_age_estimate_label => 'Idade estimada:';

  @override
  String get pet_event_type_food => 'Alimentação';

  @override
  String get pet_event_type_health => 'Saúde';

  @override
  String get pet_event_type_weight => 'Peso';

  @override
  String get pet_event_type_hygiene => 'Higiene';

  @override
  String get pet_event_type_other => 'Outros';

  @override
  String pet_agenda_coming_soon(Object name) {
    return 'Módulo Agenda para $name';
  }

  @override
  String get pet_medical_history_empty => 'Sem histórico médico.';

  @override
  String get pet_share_not_implemented => 'Em breve.';

  @override
  String get pet_ai_brain_not_ready => 'IA carregando...';

  @override
  String pet_ai_connection_error(Object error) {
    return 'Erro IA: $error';
  }

  @override
  String get pet_ai_trouble_thinking => 'Dificuldade em processar.';

  @override
  String get pet_stt_not_available => 'STT indisponível';

  @override
  String pet_stt_error(Object error) {
    return 'STT Erro: $error';
  }

  @override
  String get pet_entry_deleted => 'Excluído';

  @override
  String pet_error_history_load(Object error) {
    return 'Erro Histórico: $error';
  }

  @override
  String pet_ai_greeting(Object name) {
    return 'Olá! Sou a IA do $name.';
  }

  @override
  String get pet_event_food => 'Comida';

  @override
  String get pet_event_health => 'Saúde';

  @override
  String get pet_event_weight => 'Peso';

  @override
  String get pet_event_walk => 'Passeio';

  @override
  String get pet_event_hygiene => 'Banho';

  @override
  String get pet_event_behavior => 'Comportamento';

  @override
  String get pet_event_medication => 'Remédio';

  @override
  String get pet_event_note => 'Nota';

  @override
  String get pet_ai_thinking_status => 'IA Pensando...';

  @override
  String get pet_agenda_title => 'Agenda';

  @override
  String pet_agenda_title_dynamic(Object petName) {
    return 'Agenda: $petName';
  }

  @override
  String get pet_agenda_empty => 'Agenda vazia';

  @override
  String pet_agenda_add_event_dynamic(Object petName) {
    return 'Evento para $petName';
  }

  @override
  String get pet_agenda_today => 'Hoje';

  @override
  String get pet_agenda_yesterday => 'Ontem';

  @override
  String get pet_agenda_select_type => 'Tipo';

  @override
  String get pet_agenda_event_date => 'Data';

  @override
  String get pet_agenda_event_time => 'Hora';

  @override
  String get pet_agenda_notes_hint => 'Notas';

  @override
  String get pet_agenda_save => 'Salvar';

  @override
  String pet_journal_add_event(Object petName) {
    return 'Diário $petName';
  }

  @override
  String get pet_journal_placeholder => 'Descreva...';

  @override
  String get pet_journal_register => 'Registrar';

  @override
  String get label_friend_name => 'Amigo';

  @override
  String get label_tutor_name => 'Tutor';

  @override
  String get ai_simulating_analysis => 'Analisando...';

  @override
  String get pet_journal_location_loading => 'GPS...';

  @override
  String get pet_journal_location_captured => 'Local salvo';

  @override
  String get pet_journal_audio_recording => 'Gravando...';

  @override
  String get ai_audio_analysis_cough_detected => 'Tosse detectada.';

  @override
  String get ai_suggest_health_category => 'Saúde?';

  @override
  String get pet_journal_location_name_simulated => 'Local simulado';

  @override
  String get journal_guide_title => 'IA Diário';

  @override
  String get journal_guide_voice => 'Fale e a IA organiza.';

  @override
  String get journal_guide_camera => 'Analise fotos.';

  @override
  String get journal_guide_audio => 'Grave sons clínicos.';

  @override
  String get journal_guide_location => 'Registre o local.';

  @override
  String get common_ok => 'OK';

  @override
  String get pet_journal_analyzed_by_nano => 'Análise Nano Banana';

  @override
  String get pet_journal_social_context => 'Contexto Social';

  @override
  String get journal_guide_unlock_hint => 'Comece relatando.';

  @override
  String get pet_journal_mic_permission_denied => 'Microfone negado.';

  @override
  String get label_relate => 'Relatar';

  @override
  String get label_place => 'Local';

  @override
  String get label_audio => 'Áudio';

  @override
  String get label_alert => 'Alerta';

  @override
  String get alert_poison => 'Veneno';

  @override
  String get alert_dog_loose => 'Cão Bravo';

  @override
  String get alert_risk_area => 'Perigo';

  @override
  String get alert_noise => 'Barulho';

  @override
  String error_gps(Object error) {
    return 'GPS: $error';
  }

  @override
  String get gps_error_snack => 'Erro GPS.';

  @override
  String get map_type_hybrid => 'Híbrido';

  @override
  String get map_type_terrain => 'Terreno';

  @override
  String get label_map_type => 'Mapa';

  @override
  String get map_alert_dog => 'Cão Bravo';

  @override
  String get map_alert_poison => 'Veneno';

  @override
  String get map_alert_noise => 'Barulho';

  @override
  String get map_alert_risk => 'Risco';

  @override
  String get map_alert_success => 'Sucesso!';

  @override
  String get map_alert_description_user => 'Pelo usuário';

  @override
  String get pet_journal_gps_error => 'Erro GPS';

  @override
  String get pet_journal_loading_gps => 'GPS...';

  @override
  String get pet_journal_location_unknown => 'Desconhecido';

  @override
  String get pet_journal_location_approx => 'Aproximado';

  @override
  String pet_journal_file_selected(Object name) {
    return 'Arquivo: $name';
  }

  @override
  String pet_journal_file_error(Object error) {
    return 'Erro: $error';
  }

  @override
  String get pet_journal_help_title => 'Ajuda';

  @override
  String get pet_journal_help_photo_title => 'Fotos';

  @override
  String get pet_journal_help_photo_desc => 'Envie fotos.';

  @override
  String get pet_journal_help_audio_title => 'Áudio';

  @override
  String get pet_journal_help_audio_desc => 'Grave sons.';

  @override
  String get pet_journal_help_map_title => 'Mapa';

  @override
  String get pet_journal_help_map_desc => 'Local automático.';

  @override
  String get pet_journal_help_notes_title => 'Notas';

  @override
  String get pet_journal_help_notes_desc => 'Descreva tudo.';

  @override
  String get pet_journal_help_videos_title => 'Vídeo';

  @override
  String get pet_journal_help_videos_desc => 'Em breve.';

  @override
  String get pet_journal_help_ai_title => 'IA';

  @override
  String get pet_journal_help_ai_desc => 'Parecer clínico IA.';

  @override
  String pet_error_ai_analysis_failed(Object error) {
    return 'IA Erro: $error';
  }

  @override
  String pet_error_repository_failure(Object status) {
    return 'Falha: $status';
  }

  @override
  String pet_error_saving_event(Object error) {
    return 'Salvar Erro: $error';
  }

  @override
  String pet_agenda_summary_format(int count) {
    return '$count eventos';
  }

  @override
  String get common_delete => 'Excluir';

  @override
  String get pet_error_delete_event => 'Erro ao excluir';

  @override
  String get pet_label_address => 'Endereço';

  @override
  String get pet_label_ai_summary => 'Resumo IA';

  @override
  String get pet_analysis_data_not_found => 'Sem dados.';

  @override
  String get pet_logic_keywords_health => 'vômito,diarreia,tosse';

  @override
  String get pet_ai_language => 'pt_BR';

  @override
  String get map_gps_disabled => 'Ative o GPS.';

  @override
  String get map_permission_denied => 'Sem permissão.';

  @override
  String get map_permission_denied_forever => 'Abra configurações.';

  @override
  String map_error_location(Object error) {
    return 'Erro: $error';
  }

  @override
  String get map_title_pet_location => 'Localização';

  @override
  String get action_open_settings => 'Configurações';

  @override
  String get map_sync_satellites => 'Satélites...';

  @override
  String get pet_journal_audio_processing => 'Processando...';

  @override
  String get pet_journal_audio_error_file_not_found => 'Sem áudio.';

  @override
  String get pet_journal_audio_error_generic => 'Sem resultado.';

  @override
  String get pet_journal_audio_pending => 'Pendente.';

  @override
  String get pet_journal_video_processing => 'Analisando...';

  @override
  String get pet_journal_video_error => 'Erro vídeo.';

  @override
  String get error_video_too_long => 'Máx 60s';

  @override
  String get btn_scan_image => 'Escanear';

  @override
  String get generic_analyzing => 'Analisando...';

  @override
  String get pet_error_image_not_found => 'Imagem não encontrada.';

  @override
  String get btn_go => 'Ir';

  @override
  String get pet_created_at_label => 'Criado em';

  @override
  String get pet_initial_assessment => 'Avaliação Inicial';

  @override
  String get pet_hint_select_type => 'Selecione';

  @override
  String get pet_label_info => 'Informação';

  @override
  String get pet_type_profile => 'Perfil';

  @override
  String get pet_type_posture => 'Postura';

  @override
  String get pet_profile_title => 'Perfil do Pet';

  @override
  String get pet_management_title => 'Gestão';

  @override
  String get pet_label_health_plan => 'Plano de Saúde';

  @override
  String get pet_label_funeral_plan => 'Plano Funerário';

  @override
  String get pet_label_weight => 'Peso';

  @override
  String get pet_label_birth_date => 'Nascimento';

  @override
  String get pet_btn_add_metric => 'Métrica';

  @override
  String get pet_agenda_add_event => 'Adicionar evento';

  @override
  String get error_unexpected_title => 'Erro Inesperado';

  @override
  String get error_unexpected_message => 'Reinicie o app.';

  @override
  String get error_try_recover => 'Recuperar';

  @override
  String get pet_profile_save_success => 'Perfil atualizado';

  @override
  String get pet_action_save_profile => 'SALVAR PERFIL';

  @override
  String get pet_not_found => 'Pet não encontrado';

  @override
  String pet_analyses_title(Object name) {
    return 'Análises: $name';
  }

  @override
  String pet_profile_title_dynamic(Object name) {
    return 'Perfil: $name';
  }

  @override
  String pet_health_title(Object name) {
    return 'Saúde: $name';
  }

  @override
  String pet_health_plan_title(Object name) {
    return 'Plano Saúde: $name';
  }

  @override
  String pet_funeral_plan_title(Object name) {
    return 'Plano Funeral: $name';
  }

  @override
  String pet_analysis_title(Object name) {
    return 'Análise: $name';
  }

  @override
  String get label_file => 'Arquivo';

  @override
  String get common_cancel => 'Cancelar';
}
