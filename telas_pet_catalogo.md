# 📱 Catálogo de Telas (Presentation Layer) - Domínio PET

Este documento lista e descreve a responsabilidade de todas as **33 telas interativas** (arquivos `_screen.dart` e `_view.dart`) que compõem a interface com o usuário dentro do módulo Pet (`lib/features/pet/`).

As telas estão organizadas por seus respectivos subdomínios clínicos e operacionais.

---

## 1. 🧬 Módulo Core (Perfil e Gerenciamento)
Telas responsáveis pela identidade, listagem e ciclo de vida básico do Pet.

* **`my_pets_view.dart`**
  Tela inicial (Home) que lista todos os pets cadastrados do usuário em formato de Cards verticais.
* **`pet_list_view.dart`** 
  Variação/Apoio da listagem principal com design alternativo ou reuso em fluxos de seleção.
* **`pet_profile_view.dart` / `pet_profile_screen.dart`**
  Tela de Perfil detalhado do animal. Permite editar dados vitais (Raça, Sexo, Tamanho, Tutor).
* **`pet_form_view.dart`** 
  Formulário dedicado exclusivo para a criação/cadastro inicial de um novo Pet no banco de dados.
* **`pet_management_screen.dart`**
  Painel administrativo superior para gerir a frota de pets cadastrados.

---

## 2. 🤖 Módulo AI & Scanner (Análises e Capturas)
Telas ligadas diretamente ao RAG, Processamento de Imagens e Interação com Inteligência Artificial.

* **`pet_dashboard_view.dart`**
  *A Tela de Ações de Análise*. É onde o usuário seleciona se a foto/vídeo a ser escaneado é de Dermatologia, Comportamento, Nutrição, Raio-X, etc.
* **`pet_capture_view.dart`**
  A câmera embutida do app. Controla a captura em tempo real de Fotos, Vídeos e Áudio (speech-to-text) para enviar para análise.
* **`pet_analysis_result_view.dart`**
  A tela final que recebe o longo e detalhado Laudo Clínico estruturado gerado pelo Gemini após uma etapa de Scan.
* **`pet_ai_chat_view.dart`** 
  O chat contínuo com a IA (veterinária/nutricionista virtual) contextualizada sobre o histórico do Pet.
* **`universal_pdf_preview_screen.dart`**
  Gerador de PDF. Universal para todo o domínio Pet, converte Laudos do RAG e Dashboards Financeiros em documentos imprimíveis usando a `pdfpreview`.

---

## 3. 🗓️ Módulo Agenda (Linha do Tempo e Eventos)
O motor central de registros diários do Pet.

* **`pet_agenda_screen.dart`** 
  A "Timeline" principal. Um calendário infinito gerindo Compromissos, Exames, Medicações e alertas futuros.
* **`create_pet_event_screen.dart`**
  Tela coringa de criação rápida de evento na agenda. Dispara o GPS para Passeios ou grava áudio avulso.
* **`pet_scheduled_events_screen.dart`** 
  Visão estrita de "Eventos Agendados Futuros" separada da timeline do dia a dia.
* **`pet_event_detail_screen.dart`**
  Visão profunda de um card de evento já ocorrido, mostrando detalhes e relatórios vinculados àquele dia.

---

## 4. 📝 Submódulos Específicos da Agenda (Clínica e Dinheiro)
Formulários acoplados à Timeline (Agenda) para gestão hiper-nichada.

* **`pet_record_form_screen.dart`**
  Formulário metamorfo. Transmuta para virar um formulário de "Alimentação", "Incidente", "Sede", "Medicamento", etc., com base na escolha do usuário.
* **`pet_appointment_screen.dart`**
  Formulário complexo dedicado a marcação de consultas, cirurgias, banho e tosa e retornos, criando alertas nativos no celular. 
* **`pet_expense_dashboard_screen.dart`**
  Painel Financeiro em Gráfico de Pizza (PieChart), que mapeia todos os gastos com OCR/Recibos agrupados por Categoria (Comida, Remédio, Mimos).
* **`pet_expense_history_screen.dart`** 
  Listagem tabular ("Extrato") de todas as despesas financeiras em ordem cronológica de notas fiscais.
* **`pet_medication_screen.dart`** 
  Farmácia. Formulário crítico para registro de receitas de remédios (Unidade de Medida, Via de Administração, Duração).
* **`pet_metrics_screen.dart`**
  Gráficos de Linha (LineChart) que analisam a evolução do Humor, Energia e Apetite do Pet através dos tempos.
* **`pet_walk_events_screen.dart`**
  Histórico focado em listar todos os traçados (Passeios com GPS) feitos pelo animal.
* **`pet_partner_selection_screen.dart`**
  Seletor modal em casos onde ações precisam cruzar os dados de mais de um Pet no mesmo evento (Ex: Passeio conjunto).

---

## 5. 🏥 Módulo de Saúde e Nutrição (Direcionados)
Hubs de dados mastigados focados no bem estar e histórico.

* **`pet_health_screen.dart`**
  O Hub Clínico principal. Concentra Planos Nutricionais, Vacinas e visão geral da biometria de saúde.
* **`pet_history_screen.dart`** / **`pet_history_list_view.dart`** / **`pet_history_timeline_view.dart`** / **`pet_history_detail_screen.dart`**
  A biblioteca de arquivos passados! Lista cronológica em texto puro de todos os retornos já recebidos pela inteligência artificial arquivados no banco de dados.
* **`pet_nutrition_history_screen.dart`**
  Listagem filtrada contendo **somente** os Cardápios e Planos Alimentares já expedidos e aprovados, limpando o lixo logístico clínico.
* **`placeholder_health_view.dart`** 
  Tela temporária (mock) utilizada durante refatorações para preencher rotas clínicas.

---

## 6. 🗺️ Módulo GPS
* **`pet_map_screen.dart`**
  Integração direta com bibliotecas de mapa interativo focada em plotar rotas, mostrar as coordenadas de caminhadas e incidentes rastreados via coleira.

---

## 7. 🛡️ Módulo Institucional / Seguros
* **`health_plan_view.dart`**
  Integração e visualização da Apólice do Plano de Saúde ou convênio atrelado ao animal (Rede Credenciada).
* **`funeral_plan_view.dart`**
  Gestão preventiva, status de cobertura e visualização do serviço fúnebre / cremação contratado (Contrato de Guarda).
