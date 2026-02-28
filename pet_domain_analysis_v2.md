# 🐾 Análise Classe-a-Classe (Programa por Programa) do Domínio PET - ScanNut+

Este relatório foi gerado para descrever a micro-arquitetura do módulo Pet. Abaixo, listamos **todos** os principais programas `.dart` (arquivos de código-fonte) presentes dentro das pastas de `lib/features/pet` e o que cada um faz de forma isolada.

---

## 📁 1. `lib/features/pet/agenda/` (O Motor Logístico)

### 📂 `agenda/data/models/`
- **`partner_model.dart`**: Define a estrutura de dados (Objeto) para os "Parceiros/Amigos" do pet, permitindo vinculá-lo a outros animais na rede local.
- **`pending_analysis.dart`**: Cria uma tabela de dados para salvar Fotos e Áudios temporalmente caso a internet caia, para que a IA processe a análise depois.

### 📂 `agenda/domain/`
- **`pet_context_service.dart`**: Um motor de inteligência crucial. Toda vez que o usuário abre o chat da IA, esse programa puxa todo o histórico de doenças, a idade exata, raça e vacinas do banco e injeta no prompt invisivelmente para que o Gemini tenha "memória".
- **`pet_event_type_extension.dart`**: Contém lógicas puramente visuais. Ele pega o tipo do evento (ex: `BANHO`) e magicamente converte em um Ícone do Flutter e em uma Cor padrão para desenhar na tela.
- **`pet_weather_service.dart`**: Serviço que verifica previsões meteorológicas para sugerir se o dia está bom para passeios usando o mapa.

### 📂 `agenda/logic/`
- **`pet_medication_service.dart`**: A "Calculadora Farmacêutica". Você entra com "de 8 em 8 horas por 5 dias", e esse arquivo processa a matemática de datas criando 15 eventos individuais exatos na agenda.
- **`pet_notification_manager.dart`**: Comunica-se com o Sistema Operacional do celular (Android/iOS) para agendar os alarmes visuais (`Push Notifications`) das vacinas e remédios que estão para vencer.

### 📂 `agenda/presentation/` (Telas Visuais)
- **`create_pet_event_screen.dart`**: A maior tela modular. Usada no Passeio. Inicia acesso ao Microfone, levanta a Câmera nativa, ativa o GPS, faz o rastreio latitudinal do cachorro e salva a distância final andada e calorias gastas.
- **`pet_agenda_screen.dart`**: A representação visual clássica do Calendário. Permite tocar nos dias e ver o que está marcado (Consultas, Banhos, Remedios).
- **`pet_appointment_screen.dart`**: Tela com formulários complexos para você digitar os dados de uma consulta veterinária futura. Tem acesso nativo ao OCR (para escanear receitas médicas da clínica).
- **`pet_expense_dashboard_screen.dart` & `pet_expense_history_screen.dart`**: Renderizam os gráficos financeiros (Gráfico de Pizza para dividir os gastos por categoria e Gráfico de Linha Mensal).
- **`pet_medication_screen.dart`**: Formulário de remédios. Abre opções se a via de administração é Oral, Injetável ou Tópica.
- **`pet_metrics_screen.dart`**: Painel "Check-in Médico Diário". Abre botões simpáticos para dar notas ("Apetite Muito Bom", "Energia Baixa") e salvar o humor do cão. O PDF com o relatorio de saude é filtrado por aqui.
- **`pet_map_styles.dart` & `utils/pet_map_markers.dart`**: Arquivos que não tem tela. Servem apenas para desenhar o MapBox escuro e converter icones brancos em marcadores de GPS coloridos customizados na pista.

### 📂 `agenda/services/` (Serviços Autônomos)
- **`pet_metrics_pdf_service.dart`**: Constrói um Canvas 2D em memória (Desenha tabelas e linhas num papel virtual A4) e "imprime" um Arquivo PDF com todos os batimentos, consultas e humor do animal em um intervalo de tempo.
- **`pet_vocal_ai_service.dart` / `pet_video_ai_service.dart`**: Extratores de mídia pesada. O programa de vídeo recorta frames a cada 3 segundos de um mp4 e envia como mosaico pro Gemini (pra ele entender uma convulsão por exemplo). O vocal capta áudio do microfone e manda interpretar o latido/miado.

---

## 📁 2. `lib/features/pet/data/` (A Persistência Subterrânea)

- **`pet_ai_repository.dart`**: É a ponte de rede HTTP. Este arquivo gerencia todas as chaves de API do Google, inicializa o Model Gemini Pro e trata se ocorrer `Timeout` de internet na requisição com o Google.
- **`pet_constants.dart`**: O Cérebro Literário (Protocolos). Armazena constantes gigantescas de Strings (textos de prompt pesados). Ele dita as regras de como a IA deve responder ("Não prescreva remédios, indique ir ao veterinário").
- **`pet_manager.dart`**: Camada que embrulha o "ObjectBox" (o nosso banco de dados NoSQL de alta velocidade), garantindo que as gravações de ID ocorram sem corromper memória.
- **`pet_rag_service.dart`**: Controla o Vetor de RAG. Impede que a inteligência artificial se confunda com diferentes pets da sua casa. Ele garante que "Se o cão tem 10 anos" as sugestões nutricionais focam em idosos.
- **`pet_repository.dart`**: A engrenagem (CRUD). Contém funções cruas no disco como `getPetById`, `createNewPet`, `deletePet`, e `updatePetAvatar`.

---

## 📁 3. `lib/features/pet/presentation/` (As Interfaces Dianteiras)

- **`my_pets_view.dart`**: É a primeira coisa que o usuário enxerga ao abrir a área Pet. Carrega a lista com as fotos de todos os cães/gatos casados na base local e os empilha verticalmente na página.
- **`pet_profile_view.dart`**: Tela dedicada a dados puramente de "Registro Civil". Onde o teclado sobe para o usuário editar Data de Nascimento, Peso Bruto Inicial, Espécie e anexar uma Fotografia pela Câmera que será salva localmente no disco.
- **`pet_dashboard_view.dart`**: É um grid de 12 botões ("Fezes", "Urina", "Pele", "Olhos", "Comida Caseira"). É a central de análises separada por tópicos médicos precisos.
- **`pet_ai_chat_view.dart`**: O WhatsApp do cachorro. Constroi os balões do usuário verdes na direita e os da Inteligência Artificial rosas e pretos na esquerda, permitindo rolagem, gravação multimodo e renderização de Tabelas de Marcação da IA na tela.
- **`pet_capture_view.dart`**: Foco único: Levantar a imagem interativa da câmera pra bater uma foto limpa focada em IA, disparando um Loader de carregamento animado até o Gemini devolver a interpretação.
- **`history/pet_history_timeline_view.dart`**: Organiza as devoluções passadas em uma linha do tempo vertical interligada com "bolinhas" pontilhadas tipo "Feed".

### 📂 `widgets/` (Componentes Visuais Recicláveis)
- **`pet_card_widget.dart`**: Um bloco visual contendo a Foto do Cão circulada, título, descrição e sub-botões que você exportou para ser injetado no `my_pets_view`.
- **`tutorial_speech_bubble.dart`**: A balãozinha amigável e fofinha que pula nos botões guiando o usuário no card.
- **`pet_card_actions/`**: Esta pasta fragmentou o `pet_card_widget`. Dentro dela existem `pet_walk_button.dart`, `pet_nutrition_button.dart` - cada arquivo é dono de apenas 1 botãozinho daquele card e cuida do clique de navegação específico dele, isolando de eventuais bugs.

---

### 🌟 Resumo Técnico da Arquitetura Mapeada
Notou o padrão rígido? Os programas que terminam em **`_view.dart`** ou **`_screen.dart`** apenas desenham coisas estúpidas na tela. Os que terminam com **`_service.dart`** fazem as operações matemáticas, cronologia e roteamento nos bastidores. E os que terminam em **`_repository.dart`** conversam permanentemente com o Banco de Dados. Isso isola o seu app inteiro e garante que, ao escalar o app futuramente, não tenhamos "Código Espaguete".
