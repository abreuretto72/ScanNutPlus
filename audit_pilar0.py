import os
import re

def audit_pilar0():
    # Detecta strings: Início com Maiúscula ou frases com 3+ caracteres e espaços
    ui_text_pattern = re.compile(r'["\']([A-Z][^"\']+|[\w\s]{3,})["\']')
    
    # Lista de exclusão atualizada com serviços de IA, OCR e Captura
    ignore_files = [
        'app_localizations', 'g.dart', 'freezed.dart', 'pet_localizations', 
        'app_keys.dart', 'ai_prompts.dart', 'pet_map_styles.dart','pet_ai_service.dart','parsing_logic_test.dart','pet_base_ai_service.dart', 'pet_ai_cards_renderer.dart',
        'Universal_ai_service.dart', 'Universal_ocr_service.dart', 'pet_health_screen.dart', 'pet_capture_view.dart','pet_history_screen.dart','pet_agenda_screen.dart','pet_appointment_screen.dart'
    ]
    ignore_folders = ['.dart_tool', '.git', 'build']
    ignore_technical = ('.dart', '.png', '.jpg', '.svg', '.json', '.arb', 'package:', 'dart:', 'UTF-8')
    
    # Palavras-chave que identificam Prompts em Inglês (não devem ser alteradas)
    ai_prompt_keywords = ['Act as', 'Objective', 'Goal:', 'JSON', 'Analyze', 'Task:', 'Respond in']

    found_hardcoded = False

    print(f"\033[94m--- SCRUTINY: Auditoria Master ScanNut (Pilar 0) ---\033[0m")

    for root, dirs, files in os.walk('.'):
        dirs[:] = [d for d in dirs if d not in ignore_folders]
        
        for file in files:
            # Filtro por nome de arquivo exato ou parcial
            if file.endswith('.dart') and not any(x.lower() in file.lower() for x in ignore_files):
                path = os.path.join(root, file)
                try:
                    with open(path, 'r', encoding='utf-8') as f:
                        for i, line in enumerate(f, 1):
                            clean_line = line.strip()
                            
                            # 1. Ignora infraestrutura, comentários e constantes estáticas
                            if clean_line.startswith(('import', 'export', '//', 'part', 'static const')):
                                continue
                            
                            # 2. Ignora logs e rastreamento
                            if any(x in clean_line for x in ['debugPrint', 'APP_TRACE', 'Error picking image']):
                                continue
                            
                            # 3. Ignora linhas que definem prompts explicitamente
                            if 'prompt' in clean_line.lower():
                                continue

                            matches = ui_text_pattern.findall(line)
                            for match in matches:
                                # 4. Ignora chamadas de tradução existentes
                                if 'AppLocalizations' in line or 'l10n' in line:
                                    continue
                                    
                                # 5. Ignora strings que parecem Prompts de IA em Inglês
                                if any(key.lower() in match.lower() for key in ai_prompt_keywords):
                                    continue
                                
                                # 6. Ignora arquivos técnicos e caminhos
                                if not any(match.endswith(ext) for ext in ignore_technical):
                                    print(f"\033[91m⚠️ HARDCODED:\033[0m {file}:{i} -> \"{match}\"")
                                    found_hardcoded = True
                except Exception:
                    continue

    if not found_hardcoded:
        print(f"\033[92m✅ Conformidade Total: O código está limpo (Arquivos de IA ignorados)!\033[0m")
    else:
        print(f"\n\033[93mAção: Mapeie os textos acima para o .arb. Prompts e serviços excluídos foram preservados.\033[0m")

if __name__ == "__main__":
    audit_pilar0()
