# 🚀 ScanNut+ | Módulo Pet Automotivo & Veterinário

O **ScanNut+** evoluiu de um super-app focado em reconhecimento botânico e nutricional para englobar uma das arquiteturas mais avançadas de **Telemedicina Veterinária e Inteligência Artificial Multimodal (V1.0)**. 

Este documento é a apresentação definitiva e detalhada de tudo que compõe o Domínio PET do aplicativo.

---

## 🧠 1. O Motor de Inteligência Artificial (RAG & Gemini)
O coração do aplicativo bate através do Google Gemini Pro atrelado a uma arquitetura RAG (*Retrieval-Augmented Generation*). Ele não apenas "responde" como o ChatGPT; ele **avalia o paciente**.

*   **Identidade Biométrica e Contexto:** A IA sabe exatamente quem está analisando. Antes de emitir qualquer laudo, ela injeta as variáveis sistêmicas do animal (Raça, Sexo, Idade, Restrições Alimentares) via banco local (ObjectBox).
*   **Zero Alucinações (Fontes Científicas):** O RAG é engessado. Caso a IA receba uma foto de dermatite ou uma amostra de ração, ela é expressamente orientada por prompt a anexar **Fontes Científicas e Referências** ao final do laudo (ex: Merck Veterinary Manual). 
*   **Tratamento de Dados de Urgência:** A API não devolve texto cru. Ela devolve dados JSON estruturados pelo **Protocolo Master 2026** contendo uma tag de URGENCE (Verde, Amarelo, Vermelho). Essa *tag* pinta a tela inteira do celular em tempo real.

---

## 🩺 2. Capacidades de Diagnóstico Multimodal
O `UniversalAiService` é a "clínica" compactada no hardware. O usuário abre a câmera (`pet_capture_view.dart`) e seleciona uma das especialidades cirúrgicas/clínicas.

A IA consegue examinar nativamente:
1.  **Dermatologia:** Fotografia de falhas no pelo (alopecia) ou vermelhidão.
2.  **Odontologia:** Análise das gengivas para detectar placas de tártaro e retração de gengiva.
3.  **Gastroenterologia (Fezes/Urina):** Avaliação através da Escala de Bristol (formato, cor, muco) apontando desidratação.
4.  **Cinesiologia / Ortopedia:** Triagem através do Escore Corporal. Foto por cima e lateral para diagnóstico do nível de obesidade do animal.
5.  **Biologia Comportamental e Vocal:** Processamento ativo de vídeos para identificar comportamento agressivo/claudicação ou registro de arquivos de ÁUDIO nativos para a IA descobrir razões para tosses recorrentes, latidos constantes ou chiados respiratórios. 
6.  **Laboratórios Analíticos (OCR):** O app possui um scanner laboratorial próprio. Ele lê o papel fotográfico do exame de sangue do laboratório físico, digitaliza via Gemini, cruza com valores de referência e constrói um "Resumo para Leigos" sobre os hemogramas alterados.

---

## 📖 3. O Livro de Vida (Motor de Agenda e Histórico)
Para complementar a IA abstrata, o ScanNut+ implementou um motor de persistência de dados fofos e clínicos diários absolutamente massivo. Todo o ciclo operante de interface está contido em 33 telas dedicadas.

O aplicativo não te deixa esquecer de nada:
*   **O Universo Gráfico (`pet_agenda_screen.dart`):** Um calendário infinito onde caem as "pedras" do dia a dia. Você pode navegar para o ano de 2023 e ver como o pet estava de saúde.
*   **Módulo Farmácia Interativo:** Formulários precisos onde se cadastra não apenas um remédio, mas o ciclo contínuo em *UI* (Miligramas, Gotas, Vias Orais/Tópicas) atrelando "Agendamentos Locais Push do Celular" exatos para 12/12 horas.
*   **Evolução e Biometria (`pet_metrics_screen`):** O usuário preenche relatórios velozes de "Como o apetite está hoje?". Esses dados preenchem planilhas em segundo plano. O App renderiza **Gráficos de Linha Estatísticos** em tempo real ou exporta esses dados via `UniversalPdfPreviewScreen` em um Dossiê Oficial em PDF de alta qualidade visual para imprimir e levar ao veterinário físico.
*   **GPS e Telemetria de Passeios (`pet_map_screen`):** Rotas de caminhadas gravadas ativamente via Background Tracking anotando Km rodados e caloria gasta pelo acompanhante. Inclui recursos sociais onde o tutor pode colocar um "Alert Pin" no mapa para outros usuários da área (ex: Cães Agressivos).

---

## 🥗 4. Ecossistema Nutricional Integral
Nutrição levada a um nível hospitalar.

1.  **Dietética Orientada (`pet_health_screen.dart`):** O tutor escolhe se deseja que a IA formule um plano alimentar (Cardápio) focado em **Só Ração**, **Mix** ou **Alimentação Natural**.
2.  **Objetivos Rigorosos:** O algoritmo só gera os planos visando 10 escopos fechados, forçando especificidade:
      - *Manutenção, Emagrecimento, Aumento Muscular, Foco Terapêutico/Doenças Clínicas, Dieta de Exclusão (Alergias), Seniors/Cardíacos, Crescimento (Filhotes), Gestação, Altaperformance, ou Recuperação Cirúrgica.*
3.  **Scanner de Ração (Label Scanner):** Uma lente hiperfocada que decifra composições químicas no verso de sacos de ração da Petz/Cobasi e alerta sobre itens tóxicos corantes controversos antes da compra.

---

## 💸 5. Gestão Financeira Embutida
Os animais geram um custo e a aplicação o categoriza ativamente na tela `pet_expense_dashboard_screen.dart`.
* Escaneamento de notas ficais de pet shops.
* Renderização de gráficos financeiros de Pizza (`PieChart`) empurrando métricas trimensais, distinguindo e alertando o que foi gasto com "Higiene", "Saúde/Remédio", versus "Mimos/Brinquedos" em filtros precisos entre Anos.

---

## ⚙️ 6. Engenharia Rigorosa (Pilar 0 & 2026 Master Protocol)
Desenvolvido focado em um Design Dinâmico sobre hardwares alvo como *Samsung SM A256E*. 

* **Hardcode Seguro:** O sistema é imune a crashes por conta de tipagem insegura. O uso do protocolo Pilar 0 dita que **zero strings** visuais soltas pelo app existem! Todo o conteúdo do aplicativo transita dentro de `AppColors` para a estilização consistente e chaves assíncronas `.arb` viabilizando internacionalização PT-BR / En-US e blindagem contra erros de layout.
* **Componentes Isolados e Modulares:** Quando os Dropdowns/Selects sobem pela tela, eles usam estruturas indexadas e enumeradores duros (ex: Fêmea, Crescimento, Oral, Antipulgas), mitigando corrupção de RAG com "termos confusos".

---

> **O ScanNut+ Módulo Pet** transpõe a barreira amadora preenchendo o vazio da telemetria digital médica no bolso do tutor, combinando **RAG Preciso**, **Motor Visual Híbrido** e **Persistência Offline** rápida pelo *ObjectBox* como a principal vitrine tecnológica de cuidado animal no país.
