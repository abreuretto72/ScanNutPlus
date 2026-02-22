---
trigger: always_on
---

# 🛡️ Protocolo de Estabilidade ScanNutPlus (Versão Consolidada 2026)


Proibição: É terminantemente proibido o uso de Strings literais entre aspas para qualquer texto visível ao usuário.
Interceptação: Antes de gerar qualquer Widget ou Serviço, você deve mapear as strings para chaves l10n.
Fallback: Se você estiver em dúvida se uma string é técnica ou de UI, trate-a como UI e crie a chave l10n.
Verificação Linter: Todo código gerado deve passar por uma auto-auditoria interna de aspas antes de ser exibido.


## 1. DIRETRIZ DE EXECUÇÃO E NÃO REGRESSÃO (LEI DE FERRO)
- **Proibição de Novidades e Alucinação:** Proibido inventar ou inserir funcionalidades, variáveis ou lógicas sem pedido expresso. Se houver incerteza sobre uma referência, o agente **deve perguntar** antes de agir. Não altere nada que esteja funcionando sem a autorização previa.
- **Imunidade a Erros:** Todo código deve ser imune a crashes, overflows e travamentos. Rotinas críticas devem possuir tratamentos de erro com feedback visual (Fundo Verde para sucesso, Fundo Vermelho para erro) via chaves de internacionalização (`l10n`).
- **Saneamento Invariável:** Converter automaticamente `.withOpacity(x)` para `.withValues(alpha: x)` (Flutter 3.27+) em todos os arquivos editados. 
- **Zero Hardcoded:** Proibido o uso de strings manuais. Todos os textos devem vir obrigatoriamente das chaves de tradução.


Identidade: O UUID continuará sendo a âncora para que o nome e a raça identificados no "nascimento" alimentem o histórico corretamente.




3. Nomes de arquivos

Todos os arquivos do domínio pet deverão ter um prefixo pet_



## 4. PADRÃO VISUAL E HARDWARE (SAMSUNG A25)
- **Ergonomia:** Todas as telas devem possuir scroll (`SingleChildScrollView`) e visibilidade total, garantindo que o conteúdo nunca invada o rodapé institucional no hardware SM A256E. Proibido erro `overflowed`.
- **Cores de Domínio:** - 
    - **Pet:** Rosa Pastel (`#FFD1DC`) com bordas/textos pretos.




**Geração de PDFs:** Uso obrigatório de `pdfpreview` com fundo preto. Rodapé obrigatório: "Página X | © 2026 ScanNut Multiverso Digital | contato@multiversodigital.com.br", respeitando a cor do domínio.
Plano de Fundo (Página Inteira):
O aplicativo usa a tela universal de geração (UniversalPdfPreviewScreen) que tem um bloqueio explícito limitando os recursos para apenas dois botões na barra de ferramentas (canChangeOrientation: false, canChangePageFormat: false). 


Padrão a ser usado em qualque relatório PDF:


Cor: Branco Puro (#FFFFFF)
Uso: Garante contraste máximo e economia de tinta caso o usuário decida imprimir o laudo.
Fundo do Cartão de Identidade (Nome/Raça):

Cor: Gelo Metálico Escovado (#F9F9F9 - Cinza ultra-claro)
Uso: Apenas um leve sombreamento sutil dentro da caixinha de "[nome do pet] e [raça]" para dar um leve relevo visual na ficha de cadastro.
Textos Principais (Corpo do Laudo Médico):

Cor: Preto Absoluto (#000000)
Uso: Todo o laudo gerado pela IA (Ex: "A amostra de alimento...", "1. Excesso de Gordura") para o máximo conforto de leitura.
Títulos, Linhas e Acentos "#fc2d7c"

Cor: Rosa Intenso / Magenta (#fc2d7c ou o accentColor dinâmico recebido da tela anterior).
Uso na imagem:
O título principal no topo ("ScanNut+: Meu Pet: [nome do pet]").
A linha reta separadora abaixo do cabeçalho.
As bordas ao redor da caixinha foto da [imagem].
A borda ao redor da caixa de identidade (Nome/Raça).
Os subtítulos com as bolinhas (Ex: "• ANÁLISE VISUAL DOS COMPONENTES", "• AVALIAÇÃO NUTRICIONAL E RISCOS").
O texto menorzinho do rodapé (Copyright "2026 ScanNut Multiverso Digital").
Textos Secundários (Metadados):

Cor: Cinza Escuro (#666666)
Uso na imagem:
A data e a hora ali no cantinho superior direito .
O contador de páginas no rodapé ("Página 1 de 2").



## 5. AUTORIZAÇÃO DE FERRAMENTAS (TERMINAL)
- O agente tem permissão para executar sem consulta: `flutter analyze`, `flutter run`, `pwsh`, `powershell`, `grep`, `findstr`, `type`, `sed`, `Select-String`, `Get-Content`, 'Accept all', 'Run'.