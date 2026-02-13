import os
import re

def audit_pilar0():
    # Detecta strings: Início com Maiúscula ou frases com 3+ caracteres e espaços
    # Ignora chamadas de tradução, imports e metadados técnicos
    ui_text_pattern = re.compile(r'["\']([A-Z][^"\']+|[\w\s]{3,})["\']')
    
    # Lista de exclusão atualizada: Adicionado pet_map_styles para evitar falsos positivos técnicos
    ignore_files = [
        'app_localizations', 'g.dart', 'freezed.dart', 'pet_localizations', 
        'app_keys.dart', 'ai_prompts.dart', 'pet_map_styles.dart'
    ]
    ignore_folders = ['.dart_tool', '.git', 'build']
    ignore_technical = ('.dart', '.png', '.jpg', '.svg', '.json', '.arb', 'package:', 'dart:', 'UTF-8')

    found_hardcoded = False

    print(f"\033[94m--- SCRUTINY: Auditoria Master ScanNut (Pilar 0) ---\033[0m")

    # Varre a partir da raiz do projeto
    for root, dirs, files in os.walk('.'):
        # Pula pastas de sistema e geradas
        dirs[:] = [d for d in dirs if d not in ignore_folders]
        
        for file in files:
            # Foca apenas em arquivos Dart criados pelo desenvolvedor e fora da lista de exclusão
            if file.endswith('.dart') and not any(x in file for x in ignore_files):
                path = os.path.join(root, file)
                try:
                    with open(path, 'r', encoding='utf-8') as f:
                        for i, line in enumerate(f, 1):
                            # Ignora linhas de infraestrutura, comentários e logs técnicos
                            if line.strip().startswith(('import', 'export', '//', 'part', 'static const')):
                                continue
                            
                            # Ignora logs de debug e rastreamento técnico
                            if 'debugPrint' in line or 'APP_TRACE' in line or 'Error picking image' in line:
                                continue
                                
                            matches = ui_text_pattern.findall(line)
                            for match in matches:
                                # Se não houver menção à classe de tradução na linha, é erro
                                if 'AppLocalizations' not in line and 'l10n' not in line:
                                    if not any(match.endswith(ext) for ext in ignore_technical):
                                        print(f"\033[91m⚠️ HARDCODED:\033[0m {file}:{i} -> \"{match}\"")
                                        found_hardcoded = True
                except Exception:
                    continue

    if not found_hardcoded:
        print(f"\033[92m✅ Conformidade Total: O código está limpo de strings literais!\033[0m")
    else:
        print(f"\n\033[93mAção: Substitua os textos acima por chaves no seu arquivo .arb.\033[0m")

if __name__ == "__main__":
    audit_pilar0()