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
  String get pet_section_species => 'Identificação da Espécie';

  @override
  String get pet_section_health => 'Saúde e Comportamento Geral';

  @override
  String get pet_section_coat => 'Condição Geral da Pelagem';

  @override
  String get pet_section_skin => 'Aparência da Pele';

  @override
  String get pet_action_share => 'Compartilhar';

  @override
  String get source_merck => 'Manual Veterinário Merck (MSD Digital 2026)';

  @override
  String get source_scannut => 'Protocolo de Biometria e Fenotipagem ScanNut+';

  @override
  String get source_aaha => 'Diretrizes de Exame Físico AAHA/WSAVA';

  @override
  String get pet_section_ears => 'Saúde dos Ouvidos';

  @override
  String get pet_section_nose => 'Nariz';

  @override
  String get pet_section_eyes => 'Olhos';

  @override
  String get pet_section_body => 'Corpo';

  @override
  String get pet_section_issues => 'Problemas Potenciais';

  @override
  String get pet_status_healthy => 'STATUS SAUDÁVEL';

  @override
  String get pet_status_attention => 'ATENÇÃO NECESSÁRIA';

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
  String get pet_delete_content =>
      'Tem certeza que deseja excluir este pet e todo o histórico?';

  @override
  String get pet_delete_confirm => 'Excluir';

  @override
  String get pet_delete_cancel => 'Cancelar';

  @override
  String get pet_history_delete_success => 'Histórico excluído com sucesso!';

  @override
  String get pet_ai_overloaded_message =>
      'IA sobrecarregada! Por favor, tente novamente em alguns instantes.';

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

  @override
  String get pet_profile_title => 'Perfil do Pet';

  @override
  String get pet_management_title => 'Gestão do Pet';

  @override
  String get pet_label_health_plan => 'Plano de Saúde';

  @override
  String get pet_label_funeral_plan => 'Plano Funerário';

  @override
  String get pet_label_weight => 'Peso';

  @override
  String get pet_label_size => 'Porte';

  @override
  String get pet_label_neutered => 'Castrado';

  @override
  String get pet_label_birth_date => 'Data de Nascimento';

  @override
  String get pet_agenda_add_event => 'Adicionar evento';

  @override
  String get error_unexpected_title => 'Ops! Algo inesperado aconteceu.';

  @override
  String get error_unexpected_message =>
      'Nosso time de esquilos já foi notificado. Por favor, reinicie o app.';

  @override
  String get error_try_recover => 'Tentar Recuperar';

  @override
  String get pet_btn_add_metric => 'Adicionar Métrica';

  @override
  String get pet_profile_save_success => 'Perfil atualizado com sucesso';

  @override
  String get pet_action_save_profile => 'SALVAR PERFIL PET';

  @override
  String get pet_not_found => 'Pet não encontrado';

  @override
  String get pet_plans_title => 'Planos';

  @override
  String get pet_action_manage_health_plan => 'Gerenciar Plano de Saúde';

  @override
  String get health_plan_title => 'Gestão do Plano de Saúde';

  @override
  String get health_plan_section_identification => '1. Identificação';

  @override
  String get health_plan_section_coverages => '2. Coberturas';

  @override
  String get health_plan_section_limits => '3. Limites e Regras';

  @override
  String get health_plan_section_support => '4. Rede e Suporte';

  @override
  String get health_plan_saved_success => 'Plano de Saúde salvo com sucesso!';

  @override
  String get health_plan_action_save => 'SALVAR PLANO';

  @override
  String get health_plan_label_operator => 'Operadora';

  @override
  String get health_plan_label_plan_name => 'Nome do Plano';

  @override
  String get health_plan_label_card_number => 'Nº da Carteirinha';

  @override
  String get health_plan_label_holder_name => 'Nome do Titular';

  @override
  String get health_plan_label_grace_period => 'Carência (Dias)';

  @override
  String get health_plan_label_annual_limit => 'Limite Anual';

  @override
  String get health_plan_label_copay => 'Coparticipação %';

  @override
  String get health_plan_label_reimburse => 'Reembolso %';

  @override
  String get health_plan_label_deductible => 'Franquia';

  @override
  String get health_plan_label_main_clinic => 'Clínica Principal';

  @override
  String get health_plan_label_city => 'Cidade';

  @override
  String get health_plan_label_24h => 'Atendimento 24h';

  @override
  String get health_plan_label_phone => 'Telefone';

  @override
  String get health_plan_label_whatsapp => 'WhatsApp';

  @override
  String get health_plan_label_email => 'E-mail de Suporte';

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
  String get health_cov_physiotherapy => 'Fisioterapia';

  @override
  String get pet_db_sync_error =>
      'Erro de Sincronização - Por favor reinicie o app';

  @override
  String get pet_action_manage_funeral_plan => 'Gerenciar Plano Funerário';

  @override
  String get funeral_plan_title => 'Gestão do Plano Funerário';

  @override
  String get funeral_section_identity => '1. Identificação';

  @override
  String get funeral_section_services => '2. Serviços Inclusos';

  @override
  String get funeral_section_rules => '3. Regras';

  @override
  String get funeral_section_emergency => '4. EMERGÊNCIA';

  @override
  String get funeral_label_company => 'Empresa Funerária';

  @override
  String get funeral_label_plan_name => 'Nome do Plano';

  @override
  String get funeral_label_contract => 'Número do Contrato';

  @override
  String get funeral_label_start_date => 'Data de Início';

  @override
  String get funeral_label_status => 'Status';

  @override
  String get funeral_label_grace_period => 'Carência (Dias)';

  @override
  String get funeral_label_max_weight => 'Peso Limite (kg)';

  @override
  String get funeral_label_24h => 'Atendimento 24h';

  @override
  String get funeral_label_phone => 'Telefone 24h';

  @override
  String get funeral_label_whatsapp => 'WhatsApp';

  @override
  String get funeral_label_value => 'Valor do Plano';

  @override
  String get funeral_label_extra_fees => 'Taxas Extras';

  @override
  String get funeral_svc_removal => 'Remoção 24h';

  @override
  String get funeral_svc_viewing => 'Velório';

  @override
  String get funeral_svc_cremation_ind => 'Cremação Individual';

  @override
  String get funeral_svc_cremation_col => 'Cremação Coletiva';

  @override
  String get funeral_svc_burial => 'Sepultamento';

  @override
  String get funeral_svc_urn => 'Urna';

  @override
  String get funeral_svc_ashes => 'Entrega de Cinzas';

  @override
  String get funeral_svc_certificate => 'Certificado';

  @override
  String get funeral_action_call_emergency => 'LIGAR EMERGÊNCIA AGORA';

  @override
  String get funeral_action_save => 'SALVAR PLANO FUNERÁRIO';

  @override
  String get funeral_save_success => 'Plano Funerário salvo com sucesso!';

  @override
  String get pet_action_analyses => 'Análises';

  @override
  String get pet_action_health => 'Saúde';

  @override
  String get pet_action_agenda => 'Agenda';

  @override
  String get pet_history_button => 'Histórico de Análises';

  @override
  String ai_assistant_title(String name) {
    return 'Assistente IA do $name';
  }

  @override
  String get ai_input_hint => 'Pergunte sobre seu pet...';

  @override
  String get ai_listening => 'Ouvindo...';

  @override
  String get ai_error_mic => 'Permissão de microfone necessária';

  @override
  String get ai_thinking => 'Pensando...';

  @override
  String pet_age_years(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anos',
      one: '1 ano',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String pet_age_months(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meses',
      one: '1 mês',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get pet_age_estimate_label => 'Idade estimada: ';

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
  String get pet_clinical_title => 'Condições Clínicas Fixas';

  @override
  String get pet_label_allergies => 'Alergias conhecidas';

  @override
  String get pet_label_chronic => 'Doenças crônicas';

  @override
  String get pet_label_disabilities => 'Deficiências';

  @override
  String get pet_label_observations => 'Observações importantes';

  @override
  String get pet_id_external_title => 'Identificação Externa (opcional)';

  @override
  String get pet_label_microchip => 'Microchip';

  @override
  String get pet_label_registry => 'Registro (Pedigree/ONG)';

  @override
  String get pet_label_qrcode => 'QR Code';

  @override
  String get pet_qrcode_future => 'Em breve';

  @override
  String pet_analyses_title(Object name) {
    return 'Análises: $name';
  }

  @override
  String pet_profile_title_dynamic(Object name) {
    return 'Perfil do Pet: $name';
  }

  @override
  String pet_health_title(Object name) {
    return 'Saúde: $name';
  }

  @override
  String pet_health_plan_title(Object name) {
    return 'Plano de Saúde: $name';
  }

  @override
  String pet_funeral_plan_title(Object name) {
    return 'Plano Funerário: $name';
  }

  @override
  String get pet_event_type_food => 'Alimentação';

  @override
  String get pet_event_type_health => 'Saúde';

  @override
  String get pet_event_type_weight => 'Peso';

  @override
  String get pet_event_type_hygiene => 'Higiene';

  @override
  String get pet_event_type_activity => 'Atividade';

  @override
  String get pet_event_type_other => 'Outros';

  @override
  String pet_agenda_coming_soon(Object name) {
    return 'Módulo Agenda em Breve para $name';
  }

  @override
  String get pet_medical_history_empty =>
      'Nenhum histórico médico registrado ainda.';

  @override
  String get pet_share_not_implemented =>
      'Compartilhamento não implementado para histórico ainda';

  @override
  String get pet_ai_brain_not_ready =>
      'Cérebro da IA não está pronto. Verifique a internet ou a chave API.';

  @override
  String pet_ai_connection_error(Object error) {
    return 'Erro de Conexão: $error';
  }

  @override
  String get pet_ai_trouble_thinking =>
      'Estou com dificuldades para pensar agora. Por favor, tente novamente.';

  @override
  String get pet_stt_not_available => 'STT não disponível';

  @override
  String pet_stt_error(Object error) {
    return 'Erro STT: $error';
  }

  @override
  String get pet_entry_deleted => 'Entrada excluída';

  @override
  String pet_error_history_load(String error) {
    return 'Erro ao carregar histórico: $error';
  }

  @override
  String pet_ai_greeting(String name) {
    return 'Olá! Analisei os dados de $name. Como posso ajudar?';
  }

  @override
  String pet_analysis_title(String name) {
    return 'Análise: $name';
  }

  @override
  String get pet_event_food => 'Alimentação';

  @override
  String get pet_event_health => 'Saúde';

  @override
  String get pet_event_weight => 'Peso';

  @override
  String get pet_event_walk => 'Passeio';

  @override
  String get pet_event_hygiene => 'Higiene';

  @override
  String get pet_event_behavior => 'Comportamento';

  @override
  String get pet_event_medication => 'Medicação';

  @override
  String get pet_event_note => 'Anotação';

  @override
  String get pet_ai_thinking_status => 'Pensando...';

  @override
  String get pet_agenda_title => 'Agenda do Pet';

  @override
  String pet_agenda_title_dynamic(String petName) {
    return 'Agenda do Pet: $petName';
  }

  @override
  String get pet_agenda_empty => 'Nenhum evento agendado';

  @override
  String pet_agenda_add_event_dynamic(String petName) {
    return 'Adicionar evento: $petName';
  }

  @override
  String get pet_agenda_today => 'Hoje';

  @override
  String get pet_agenda_yesterday => 'Ontem';

  @override
  String get pet_agenda_select_type => 'Selecione o tipo';

  @override
  String get pet_agenda_event_date => 'Data';

  @override
  String get pet_agenda_event_time => 'Hora';

  @override
  String get pet_agenda_notes_hint => 'Observações (opcional)';

  @override
  String get pet_agenda_save => 'Salvar Evento';

  @override
  String pet_journal_add_event(String petName) {
    return 'Diário de $petName';
  }

  @override
  String get pet_journal_question => 'O que aconteceu?';

  @override
  String get pet_journal_placeholder => 'Descreve o que aconteceu...';

  @override
  String get pet_journal_register => 'Registar Evento';

  @override
  String get label_friend_name => 'Nome do Amigo';

  @override
  String get label_tutor_name => 'Nome do Tutor';

  @override
  String get ai_simulating_analysis => 'Microscópio ativo... analisando...';

  @override
  String get pet_journal_location_loading => 'Obtendo GPS...';

  @override
  String get pet_journal_location_captured => 'Localização capturada';

  @override
  String get pet_journal_audio_recording => 'Gravando...';

  @override
  String get pet_journal_audio_saved => 'Áudio salvo!';

  @override
  String get ai_audio_analysis_cough_detected => 'IA detectou som de tosse.';

  @override
  String get ai_suggest_health_category => 'Mudar para categoria Saúde?';

  @override
  String get pet_journal_location_name_simulated => 'Parque Ibirapuera, SP';

  @override
  String get journal_guide_title => 'Capacidades do Diário IA';

  @override
  String get journal_guide_voice =>
      'Conte o que aconteceu e a IA organiza para você.';

  @override
  String get journal_guide_camera =>
      'Analise na hora fotos de saúde (fezes, pele), comida ou amigos.';

  @override
  String get journal_guide_audio =>
      'Grave sons de tosse ou respiração para análise clínica imediata.';

  @override
  String get journal_guide_location =>
      'Registre onde os eventos importantes acontecem.';

  @override
  String get common_ok => 'OK';

  @override
  String get pet_journal_analyzed_by_nano => 'Imagem analisada por Nano Banana';

  @override
  String get pet_journal_social_context => 'Contexto Social Detectado';

  @override
  String get journal_guide_unlock_hint =>
      'Comece contando o que houve para liberar a análise de fotos, áudio e localização.';

  @override
  String get pet_journal_mic_permission_denied =>
      'Permissão de microfone negada. Habilite nas configurações.';

  @override
  String get label_relate => 'Relatar';

  @override
  String get label_photo => 'Foto';

  @override
  String get label_place => 'Local';

  @override
  String get label_audio => 'Áudio';

  @override
  String get label_sounds => 'Sons';

  @override
  String get label_alert => 'Alerta';

  @override
  String get alert_poison => 'Isca / Veneno';

  @override
  String get alert_dog_loose => 'Cão Bravo';

  @override
  String get alert_risk_area => 'Perigo / Assalto';

  @override
  String get alert_noise => 'Barulho Excessivo';

  @override
  String error_gps(Object error) {
    return 'Erro GPS: $error';
  }

  @override
  String get gps_error_snack =>
      'Não foi possível obter a localização atual. Verifique o GPS.';

  @override
  String get map_type_normal => 'Padrão';

  @override
  String get map_type_satellite => 'Satélite';

  @override
  String get map_type_hybrid => 'Híbrido';

  @override
  String get map_type_terrain => 'Terreno';

  @override
  String get label_map_type => 'Tipo de Mapa';

  @override
  String get pet_journal_hint_text => 'Descreva o evento...';

  @override
  String get pet_journal_register_button => 'Registrar Evento';

  @override
  String get pet_journal_report_action => 'Relatar';

  @override
  String get map_alert_title => 'Reportar Perigo';

  @override
  String get map_alert_dog => 'Cão Bravo';

  @override
  String get map_alert_poison => 'Risco de Veneno';

  @override
  String get map_alert_noise => 'Barulho Excessivo';

  @override
  String get map_alert_risk => 'Área de Risco';

  @override
  String get map_alert_success => 'Alerta Registrado!';

  @override
  String get pet_journal_recording => 'Gravando som ambiente...';

  @override
  String get pet_journal_photo_saved => 'Foto salva!';

  @override
  String get map_alert_description_user => 'Reportado pelo usuário';

  @override
  String get pet_journal_gps_error => 'Erro ao obter GPS';

  @override
  String get pet_journal_loading_gps => 'Obtendo GPS...';

  @override
  String get pet_journal_location_unknown => 'Localização desconhecida';

  @override
  String get pet_journal_location_approx => 'Localização Aproximada';

  @override
  String get label_gallery => 'Galeria';

  @override
  String get label_file => 'Arquivo';

  @override
  String pet_journal_file_selected(String name) {
    return 'Arquivo selecionado: $name';
  }

  @override
  String pet_journal_file_error(String error) {
    return 'Erro ao selecionar arquivo: $error';
  }

  @override
  String get pet_journal_help_title => 'Diretrizes';

  @override
  String get pet_journal_help_photo_title => 'Foto/Galeria';

  @override
  String get pet_journal_help_photo_desc =>
      'Capture ou suba imagens para análise imediata da saúde ou comportamento do pet via IA.';

  @override
  String get pet_journal_help_audio_title => 'Áudio/Upload';

  @override
  String get pet_journal_help_audio_desc =>
      'Grave sons (respiração, tosse, latido) ou suba arquivos para detecção de anomalias.';

  @override
  String get pet_journal_help_map_title => 'Mapa/Endereço';

  @override
  String get pet_journal_help_map_desc =>
      'O local é capturado automaticamente. Toque no mapa se precisar ajustar o ponto do evento.';

  @override
  String get pet_journal_help_notes_title => 'Notas';

  @override
  String get pet_journal_help_notes_desc =>
      'Descreva o que aconteceu. A IA cruzará seu texto com as mídias para gerar o alerta correto.';

  @override
  String get pet_journal_help_videos_title => 'Vídeos (Em Breve)';

  @override
  String get pet_journal_help_videos_desc =>
      'Focamos em foto e áudio para agilidade, mas vídeos chegarão logo!';

  @override
  String get pet_journal_help_ai_title => 'Inteligência Artificial';

  @override
  String get pet_journal_help_ai_desc =>
      'Escreva do seu jeito. A IA cruza dados de fotos e sons para um parecer clínico.';

  @override
  String get btn_got_it => 'Entendi!';

  @override
  String get help_guide_title => 'Guia de Campo do Tutor';

  @override
  String get pet_journal_searching_address => 'Buscar endereço...';

  @override
  String get pet_journal_address_not_found => 'Endereço não encontrado';

  @override
  String pet_error_ai_analysis_failed(String error) {
    return 'Falha na análise IA: $error';
  }

  @override
  String pet_error_repository_failure(String status) {
    return 'Falha no repositório: $status';
  }

  @override
  String pet_error_saving_event(String error) {
    return 'Erro ao salvar evento: $error';
  }

  @override
  String pet_agenda_summary_format(String keywords) {
    return '$keywords';
  }

  @override
  String get common_delete_confirm_title => 'Excluir Evento?';

  @override
  String get common_delete_confirm_message =>
      'Esta ação não pode ser desfeita. Deseja realmente remover este registro?';

  @override
  String get common_cancel => 'Cancelar';

  @override
  String get common_delete => 'Excluir';

  @override
  String get pet_error_delete_event => 'Erro ao excluir evento';

  @override
  String get pet_label_address => 'Endereço';

  @override
  String get pet_label_ai_summary => 'Sumário IA';

  @override
  String get pet_analysis_data_not_found => 'Dados de análise não encontrados.';

  @override
  String get pet_logic_keywords_health =>
      'vômito,diarreia,sangue,machucado,dor,febre,vacina,veterinário,remédio,cocô,fezes,amarelado,latido,uivo,chorando,tosse,engasgo,espirro,respiração,tontura,desmaio,convulsão,verme,carrapato,pulga,coceira,inchaço,vermelhidão,secreção,pus,claudicação,mancando,tremor,espasmo,andando em círculos,pressionando cabeça,gemido';

  @override
  String get pet_ai_language => 'pt_BR';

  @override
  String get map_gps_disabled => 'O GPS está desativado. Por favor, ative-o.';

  @override
  String get map_permission_denied => 'Permissão de localização negada.';

  @override
  String get map_permission_denied_forever =>
      'As permissões estão negadas permanentemente. Abra as configurações para liberar o acesso.';

  @override
  String map_error_location(String error) {
    return 'Erro ao obter localização: $error';
  }

  @override
  String get map_title_pet_location => 'Localização do Pet';

  @override
  String get action_open_settings => 'Abrir Configurações';

  @override
  String get map_sync_satellites => 'Sincronizando satélites GPS...';

  @override
  String get pet_analysis_visual_title => 'Análise Visual';

  @override
  String get pet_icon_pet => 'Pet';

  @override
  String get pet_journal_audio_processing => 'Processando áudio...';

  @override
  String get pet_journal_audio_error_file_not_found =>
      'Arquivo de áudio não encontrado.';

  @override
  String get pet_journal_audio_error_generic =>
      'Sem resultado na análise de áudio.';

  @override
  String get pet_journal_audio_pending => 'Áudio registrado. Análise pendente.';

  @override
  String get pet_journal_video_saved => 'Vídeo curto salvo!';

  @override
  String get pet_journal_video_processing => 'Analisando movimento...';

  @override
  String get pet_journal_video_error => 'Erro na análise de vídeo.';

  @override
  String get label_video => 'Vídeo';

  @override
  String get label_vocal => 'Vocal';

  @override
  String get error_file_too_large => 'Arquivo muito grande (Máx 30MB).';

  @override
  String get error_video_too_long => 'Vídeo muito longo (Máx 60s).';

  @override
  String get keywordFriend =>
      'amigo,visitante,hóspede,outro cachorro,cachorro do vizinho';

  @override
  String get keywordGuest => 'convidado,visitante,estranho';

  @override
  String get pet_agenda_view_calendar => 'Ver Calendário';
}
