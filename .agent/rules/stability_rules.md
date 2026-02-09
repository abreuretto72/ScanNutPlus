---
trigger: always_on
---

# 🛡️ Protocolo de Estabilidade ScanNutPlus (Versão Consolidada 2026)


Proibição: É terminantemente proibido o uso de Strings literais entre aspas para qualquer texto visível ao usuário.
Interceptação: Antes de gerar qualquer Widget ou Serviço, você deve mapear as strings para chaves l10n.
Fallback: Se você estiver em dúvida se uma string é técnica ou de UI, trate-a como UI e crie a chave l10n.
Verificação Linter: Todo código gerado deve passar por uma auto-auditoria interna de aspas antes de ser exibido.


## 1. DIRETRIZ DE EXECUÇÃO E NÃO REGRESSÃO (LEI DE FERRO)
- **Proibição de Novidades e Alucinação:** Proibido inventar ou inserir funcionalidades, variáveis ou lógicas sem pedido expresso. Se houver incerteza sobre uma referência, o agente **deve perguntar** antes de agir.
- **Imunidade a Erros:** Todo código deve ser imune a crashes, overflows e travamentos. Rotinas críticas devem possuir tratamentos de erro com feedback visual (Fundo Verde para sucesso, Fundo Vermelho para erro) via chaves de internacionalização (`l10n`).
- **Saneamento Invariável:** Converter automaticamente `.withOpacity(x)` para `.withValues(alpha: x)` (Flutter 3.27+) em todos os arquivos editados. 
- **Zero Hardcoded:** Proibido o uso de strings manuais. Todos os textos devem vir obrigatoriamente das chaves de tradução.


Módulo Novo Pet: Restaurado ao estado anterior de alta performance. A IA voltará a fornecer as análises profundas e completas que você aprovou.

Módulos por Imagem: Cada um (Gastro, Dermato, etc.) operando de forma isolada, sem interferir na lógica de nascimento do pet.

Telas de Resultado: Foco 100% na renderização visual dos cards (Rosa Pastel/Preto). Qualquer código de PDF ou funções extras foram descartados.

Identidade: O UUID continuará sendo a âncora para que o nome e a raça identificados no "nascimento" alimentem o histórico corretamente.



## 2. ARQUITETURA DE MICRO-APPS E ISOLAMENTO DE DOMÍNIOS
- **Isolamento Total:** As features `food`, `pet` e `plant` são micro-apps independentes. É terminantemente proibido o compartilhamento de modelos, serviços ou imports diretos entre elas.
- **Camada de Comunicação:** Qualquer troca de informações entre domínios deve ser feita exclusivamente através de uma camada de comunicação genérica no `core`.
- **Refatoração Atômica:** Em caso de renomeação de arquivos, o agente deve obrigatoriamente realizar um *Global Search & Replace* em todos os imports e referências (incluindo arquivos `.g.dart`) no mesmo passo.

3. Nomes de arquivos

Todos os arquivos do domínio pet deverão ter um prefixo pet_
Todos os arquivos do domínio planta deverão ter um prefixo pla_
Todos os arquivos do domínio comida deverão ter um prefixo foo_




## 4. PADRÃO VISUAL E HARDWARE (SAMSUNG A25)
- **Ergonomia:** Todas as telas devem possuir scroll (`SingleChildScrollView`) e visibilidade total, garantindo que o conteúdo nunca invada o rodapé institucional no hardware SM A256E. Proibido erro `overflowed`.
- **Cores de Domínio:** - **Food:** Laranja (`0xFFFF9800`)
    - **Plant:** Verde (`0xFF10AC84`)
    - **Pet:** Rosa Pastel (`#FFD1DC`) com bordas/textos pretos.
- **Geração de PDFs:** Uso obrigatório de `pdfpreview` com fundo preto. Rodapé obrigatório: "Página X | © 2026 ScanNut Multiverso Digital | contato@multiversodigital.com.br", respeitando a cor do domínio.

## 5. AUTORIZAÇÃO DE FERRAMENTAS (TERMINAL)
- O agente tem permissão para executar sem consulta: `flutter analyze`, `flutter run`, `pwsh`, `powershell`, `grep`, `findstr`, `type`, `sed`, `Select-String`, `Get-Content`.