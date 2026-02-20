import os
import re

def audit_pilar0_ultra():
    # Regex para capturar textos que parecem frases (Início maiúsculo ou espaços)
    ui_pattern = re.compile(r'["\']([A-Z][^"\']+|[\w\s]{4,})["\']')
    
    ignore_files = ['app_localizations', 'g.dart', 'freezed.dart', 'pet_localizations', 'app_keys.dart']
    
    # NOVOS FILTROS: Ignorar termos técnicos recorrentes do seu log
    ignore_technical = (
        '.dart', '.png', '.jpg', '.jpeg', '.webp', '.heic', '.mp4', '.json', '.arb', 
        'package:', 'dart:', 'HH:mm', 'MMMM', 'yyyy', 'APP_TRACE', 'Error', 'Exception',
        'source', 'journal', 'none', 'true', 'false', 'OK', 'place_id', 'vicinity'
    )

    found_hardcoded = False
    print(f"\033[94m--- SCRUTINY: Auditoria de UI Pura (ScanNut+) ---\033[0m")

    for root, dirs, files in os.walk('lib'):
        for file in files:
            if file.endswith('.dart') and not any(x in file for x in ignore_files):
                path = os.path.join(root, file)
                try:
                    with open(path, 'r', encoding='utf-8') as f:
                        for i, line in enumerate(f, 1):
                            clean_line = line.strip()
                            # Ignora logs, traces e chaves de mapa
                            if any(x in clean_line for x in ['debugPrint', 'APP_TRACE', 'log(', 'Error', 'key:']):
                                continue
                            if '[' in clean_line and ']' in clean_line: # Ignora data['key']
                                continue

                            matches = ui_pattern.findall(line)
                            for m in matches:
                                # Filtra extensões e termos técnicos
                                if any(tech in m for tech in ignore_technical) or len(m) < 3:
                                    continue
                                # Filtra se for apenas snake_case (chave técnica)
                                if '_' in m and ' ' not in m:
                                    continue

                                print(f"\033[91m🔴 TRADUZIR:\033[0m {file}:{i} -> \"{m}\"")
                                found_hardcoded = True
                except: continue

    if not found_hardcoded:
        print(f"\033[92m✅ Código Limpo!\033[0m")

if __name__ == "__main__":
    audit_pilar0_ultra()