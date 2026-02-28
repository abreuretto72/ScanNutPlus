# 🐾 Análise Profunda e Detalhada do Domínio PET - ScanNut+

Este documento reflete uma varredura rigorosa e classe a classe (Deep Dive) do diretório `lib/features/pet` e de seus submódulos. Cada tela abaixo possui responsabilidades sistêmicas e atômicas exclusivas e independentes que constroem a gestão animal.

---

## 1. 📇 Gestão de Identidade e Painel Principal
A base de dados onde as características vitais do animal nascem e alimentam o restante do aplicativo (incluindo as injeções de prompt da IA).

### `pet_profile_view.dart` (O Cadastro Mestre)
* **Visualização Leitura/Edição (`_buildReadOnlyCard` & `_buildFixedDataCard`):** Exibe e edita dados sensíveis. O usuário define o **Nome**, **Espécie** (Canina/Felina), **Raça**, **Data de Nascimento** (que recalcula a idade em meses e anos dinamicamente via `_getFormattedAge`), **Peso**, e restrições.
* **Dados Clínicos Complementares:** Permite vincular **Número do Chip** e **Pedigree**.
* **Foto Local:** Integra captura (câmera) e galeria para atribuir o avatar de rosto do Pet (`ImageSource.camera`).

### `pet_dashboard_view.dart` (Visão Macro do Tutor)
* **Grade de Ações Rápidas (`_buildDropdownItem`):** Um painel limpo baseado em cartões. Controla o acesso às funções de captura isoladas: **Analise de Comida Caseira**, **Análise de Ração**, **Exame de Fezes/Urina**, etc.
* **Componente de Cartão de Análise (`_buildAnalysisCard`):** Foco ergonômico onde a IA pode ser acionada diretamente do card resumido.

---

## 2. 🤖 Assistente IA Dinâmica e Captura Universal
A exclusividade tecnológica do aplicativo roda por trás destes dois grandes nós de processamento analítico com a API Gemini Google Generative AI.

### `pet_ai_chat_view.dart` (Chat Interativo e Exclusivo)
* **InitContext (`_loadContext`):** Antes do chat abrir, carrega todo o histórico do `PetRepository` para gerar uma *persona médica*.
* **Escuta Multimodal (`_initSpeech` / `_toggleListening`):** Permite entrada através de texto ou voz fluida usando a biblioteca `speech_to_text`.
* **Fluxo de Chat (`_sendMessage`):** Gerencia animações e carregamentos assíncronos (`CircularProgressIndicator`) na árvore de UI enquanto a IA constrói diagnósticos baseados na identidade do pet. 

### `pet_capture_view.dart` (Motor Universal de Exames)
* **Captura Inteligente Fotográfica (`_pickImage`):** Lida com hardware de câmera/vídeo e galeria via `image_picker`.
* **Geração de Miniaturas (`_generateThumbnail`):** Processa _frames_ de vídeos de comportamento agressivo ou sintomas clínicos.
* **Roteamento Dinâmico de Captura (`_processAnalysis`):** Classifica a imagem com base na intenção (Exame Nutricional vs. Exame Físico Mapeado) invocando `UniversalAiService` ou `UniversalOcrService`. Salva automaticamente no smartphone (via biblioteca `gal`).

---

## 3. 🗺️ Monitoramento de Roteiro e GPS
Sistemas para acompanhamento da geografia e comportamento animal em ambiente externo.

### `create_pet_event_screen.dart` (Central de Telemetria e Passeio)
* **Câmera/Voz *On-The-Fly* (`_pickImage`, `_pickAudioFile`):** Permite o registro em tempo real de áudios ("analisar tosse"), vídeos ou imagens sem fechar a janela de tráfego. 
* **GPS Interativo Dinâmico (`_initGPS` e `_updatePetMarker`):** Desenha marcadores em tempo real para o Pet. Permite a troca rápida do visual geográfico via `_loadMapTypePreference` (Estrada ou Satélite).
* **Tracking Submerso (`_startWalkTracking` vs `_startIdleTracking`):** Dispara _loops_ cronometrados que analisam distâncias, trajetos curtos ou repouso e salva as coordenadas mapeando calorias gastas (via `_generateWalkSummaryInBackground`).
* **Alertas do Mapa (`_loadMapAlerts` & `_registerAlert`):** Insere botões flutuantes na tela alertando perigos geolocalizados ("Aviso de Envenenadores", "Cães Agressivos na via", "Gato Perdido") criados pelos próprios usuários na região.

---

## 4. 📈 Saúde Integrada, Evolução e Biometria
A evolução diária rastreável para prever anomalias físicas pela IA.

### `pet_metrics_screen.dart` (O Caderno de Saúde)
* **Check-ins Rápidos (`_showMetricBottomSheet` e `_saveMetric`):** Botões simplificados de UI para salvar índices quantitativos diários na agenda:
    * Energia / Calorias Ingeridas / Apetite / Água Bebida.
* **Componente de Relatório em PDF (`_showPdfFilterBottomSheet`):** Janela interativa inferior (Slide Up) permitindo filtrar por data. Coleta no banco de dados todas as métricas em formato textual numérico e gera o arquivo físico de Laudo via `pet_metrics_pdf_service.dart`.
* **Renderização Gráfica (`_showMetricChart`):** Abre abas visuais (`fl_chart`) dos repasses vitais.

---

## 5. 📅 A "Agenda Motor" (Eventos e Medicamentos)
O verdadeiro banco de dados logístico da vida do Pet, operando via `TargetFocus` de calendário e alarmes.

### `pet_appointment_screen.dart` (Motor de Marcações)
* **Datas/Horários Rigorosas (`_selectDate` & `_selectTime`):** Interação assíncrona para registrar Consultas Veterinais, Aniversários ou Banhos.
* **Voz Ativa (`_toggleVoiceInput`):** Transforma ditados de voz em texto processado preenchendo o "Motivo da Consulta" no formulário dinamicamente!
* **Upload Clínico Inteligente (`_pickFile` & `_generateAISummaryPDF`):** Permite anexar arquivos físicos de Laudos Radiológicos/Sangue à consulta e processar resumos executivos automatizados desses papéis através da API de OCR conectada ao banco.

### `pet_medication_screen.dart` (Farmácia Integrada)
* **Gerador de Ciclos (`_saveMedication` via `PetMedicationService`):** Grava caixas diárias. Calcula durações ou tratamentos contínuos de comprimidos (`dosage`) repetidos.
* **Extrator Interativo (`_showActionSheet`):** Um menu iOS/Android híbrido limpo que exorta se o remédio é Oral, Tópico ou Injetável para moldar os blocos de alerta matinais.

### `pet_expense_dashboard_screen.dart` (O Módulo Financeiro Pet)
* **Filtragem Lógica de Janela (`_buildFilters`):** Permite olhar trimestres ou semestres dos gastos.
* **Plotagem Híbrida em Tempo Real:** 
    * `_buildPieChart`: Divide a despesa do mês em Fatias Coloridas baseadas na Categoria (ex: Rosa Nutrição, Azul Veterinário) usando o `fl_chart`.
    * `_buildStackedAreaChart` e `_buildLineChart`: Empilha curvas de tendência com o custo do Pet, unificando a projeção financeira ao longo dos meses diretamente dentro da tela do animal.
