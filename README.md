# ScanNutPlus 📱🌿🐾🍎

**ScanNutPlus** é um "Super App" de inteligência artificial focado na análise e monitoramento de domínios biológicos. O projeto integra visão computacional, inteligência artificial generativa (Gemini) e uma arquitetura modular robusta para oferecer insights profundos sobre **Alimentação**,
- **Pet Analysis**:
  - **Dynamic UI**: AI-driven interface that adapts to the analysis content using structured blocks (Protocol 2026).
  - **Pilar 0 Compliance**: 100% adherence to "Zero Hardcoded Strings" policy.
  - **Urgency Detection**: Automatic status classification (Green/Yellow/Red) based on AI assessment.
e **Plantas**.

Desenvolvido sob o **Protocolo Master 2026**, o app segue padrões rigorosos de engenharia de software (Pilar 0), internacionalização total e isolamento de domínios.

---

## 🚀 Funcionalidades Principais

### 🍎 Módulo Food (Nutrição)
*   **Análise de Pratos:** Foto do prato -> Identificação de calorias, macros e qualidade nutricional.
*   **Chef Vision:** Escaneamento de ingredientes na geladeira/despensa para sugestão de receitas personalizadas.
*   **Diário Alimentar:** Histórico visual e estatístico das refeições.
*   **Conversa Nutricional:** Chat AI especializado em nutrição.

### 🐾 Módulo Pet (Veterinária IA)
*   **Identificação Biométrica:** Reconhecimento visual do pet (RAG - Retrieval-Augmented Generation).
*   **Análise Multimodal:**
    *   **Geral:** Identificação de raça e características.
    *   **Feridas/Pele:** Análise preeliminar de lesões.
    *   **Fezes:** Escala de Bristol e saúde digestiva.
    *   **Olhos/Boca:** Detecção de sinais clínicos visíveis.
*   **Dossiê Veterinário 360:** PDF gerado automaticamente com todo o histórico clínico.
*   **Comando de Voz:** "Quem é este pet?" - Cadastro automático via voz.

### 🌿 Módulo Plant (Botânica)
*   **Identificação de Plantas:** Espécie, cuidados e toxicidade.
*   **Diagnóstico de Doenças:** Análise visual de folhas e caules.
*   **Guia de Cultivo:** Rega, luz e adubação ideais.

---

## 🛠️ Tecnologias e Arquitetura

*   **Frontend:** Flutter 3.x (Dart)
*   **Gerenciamento de Estado:** Riverpod
*   **AI Core:** Google Gemini (Multimodal)
*   **Persistência:** ObjectBox (NoSQL local de alta performance)
*   **Internacionalização:** `flutter_localizations` (Suporte total PT/EN)
*   **Hardware Target:** Otimizado para Samsung SM-A256E (Ergonomia e Performance).

### Protocolo Master 2026 (Pilar 0)
Este projeto segue rigorosamente o "Pilar 0":
1.  **Zero Hardcoded Strings:** Todo texto visível vem de arquivos `.arb` (l10n).
2.  **Isolamento de Domínios:** `Food`, `Pet`, e `Plant` não compartilham dependências diretas, comunicando-se apenas via `Core`.
3.  **Auditoria Contínua:** Scripts Python (`audit_pilar0.py`) garantem a conformidade do código antes de cada build.
4.  **Resiliência:** Tratamento de erros com feedback visual claro (Verde/Vermelho/Amarelo) e falha graciosa.

---

## 📦 Instalação e Execução

### Pré-requisitos
*   Flutter SDK instalado.
*   Chave API do Gemini configurada em `assets/.env`.

### Comandos Básicos

```bash
# Instalar dependências
flutter pub get

# Gerar arquivos de tradução e rotas
flutter pub run build_runner build --delete-conflicting-outputs

# Executar em modo Debug
flutter run

# Análise estática (Linter)
flutter analyze
```

## 🌍 Internacionalização (l10n)

Para adicionar novos textos:
1. Edite `lib/features/<domain>/l10n/<domain>_en.arb` (Inglês) e `<domain>_pt.arb` (Português).
2. Execute o build para regenerar as classes `Localizations`.

---

## 📄 Licença

Multiverso Digital © 2026. Todos os direitos reservados.
