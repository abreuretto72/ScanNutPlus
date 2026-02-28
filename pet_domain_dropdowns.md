# 📋 Mapeamento de Menus Suspensos (Dropdowns e ActionSheets) - Domínio PET

Este documento cataloga todos os valores engessados dentro dos componentes dinâmicos do módulo Pet do ScanNut+. A listagem garante que as injeções de contexto na IA contenham apenas opções rígidas validadas da interface.

---

### 1. `pet_profile_view.dart` (Perfil e Identidade)
* **Sexo do Pet:** 
  * Macho (`Male`)
  * Fêmea (`Female`)
* **Porte/Tamanho:** 
  * Pequeno (`Small`)
  * Médio (`Medium`)
  * Grande (`Large`)

### 2. `pet_record_form_screen.dart` (Formulário Mestre da Agenda)
A interface transmuta os componentes baseado na Natureza do Evento:
* **Remédios > Categoria:** 
  * Contínuo, Vermífugo, Antipulgas, Antibiótico
* **Energia > Nível:** 
  * Baixa, Normal, Ativa, Hiperativa
* **Energia > Período do Dia:** 
  * Manhã, Tarde, Noite, Dia Todo
* **Apetite > Consumo de Ração:** 
  * Nada, Metade, Tudo
* **Apetite > Sede:** 
  * Normal, Reduzida, Excessiva
* **Incidentes Clínicos > Gravidade:** 
  * Leve, Moderada, Urgente
* **Eventos Diversos > Categoria:** 
  * Higiene, Cio, Socialização
* **Despesas via OCR (Receipt Scanner) > Categoria:** 
  * Alimentação, Saúde, Higiene, Medicamentos, Mimos, Serviços.

### 3. `pet_appointment_screen.dart` (Marcação de Consultas Prévias)
* **Categoria da Especialidade Clínica:** 
  * Saúde, Nutrição, Bem-estar, Comportamento, Serviços, Documentos
* **Motivo/Tipo Específico do Atendimento:** *(Condicionado à Categoria base)*
   - *Se "Saúde":* Consulta Clínica, Retorno, Exame de Sangue, Exame de Imagem, Cirurgia, Outro Exame.
   - *Se "Nutrição":* Nutricionista, Ajuste de Dieta.
   - *Se "Bem-estar":* Acupuntura, Fisioterapia, Ozonioterapia, Massagem.
   - *Se "Comportamento":* Adestramento, Consulta Comportamental.
   - *Se "Serviços":* Banho e Tosa, Transporte.
   - *Se "Documentos":* Emissão de Atestado, Microchipagem, Outro.
* **Alertas do iOS/Android Push Notifications:** 
  * Nenhum, 1h antes, 2h antes, 1 dia antes, 1 semana antes.

### 4. `pet_medication_screen.dart` (Módulo Farmacológico)
*Nota Arquitetural: Utiliza iOS ActionSheets no piso da tela.*
* **Unidade Físico-Química da Medida:** 
  * `mg`, `ml`, `gotas`, `comp` (Comprimido), `cp` (Cápsula), `UI`
* **Via de Administração Fisiológica:** 
  * Oral, Injetável, Tópica, Gotas
* **Tempo do Alarme Lembrete Contínuo:** 
  * Nenhum, 1h antes, 2h antes, 1 dia antes, 1 semana antes.

### 5. `pet_expense_dashboard_screen.dart` & `pet_expense_history_screen.dart` (Finanças)
* **Mês de Filtro do Relatório:** 
  * Todos, 01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12
* **Ano Corrente:** 
  * Todos, 2026, 2025, 2024
* **Gráfico de Fatiamento de Investimentos (PIE) > Categorias:** 
  * Todas, Alimentação, Saúde, Higiene, Medicamentos, Mimos, Serviços.

### 6. `pet_dashboard_view.dart` (Central de Ações e Captura do Pet)
* **Selecionador de Amigo/Companheiro:** 
  * Vetor gerado iterativamente *(Array Mapping via ObjectBox `_friendPets.map()...`)* - Permite ao app não misturar ocorrências cruzadas caso você acione uma "Comida Caseira" sem querer pro gato em vez do cachorro.

### 7. Trabalhos Fúnebres & Seguros Saúde (`funeral_plan_view.dart`)
* **Status do Plano/Apólice:** 
  * Importados dinamicamente das globais do Domínio (*Ativo, Suspenso temporariamente, Processando Vínculo*).
