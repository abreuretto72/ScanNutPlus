import os
import json
import re

# Caminhos - Verifique se estes nomes estão corretos no seu projeto
ARB_PATH = 'lib/l10n/app_pt.arb'
LIB_FOLDER = 'lib'

def run_audit():
    print(f"🚀 Iniciando auditoria no diretório: {os.getcwd()}")

    # 1. Verificar o arquivo ARB
    if not os.path.exists(ARB_PATH):
        print(f"\033[91m🔴 ERRO: Arquivo não encontrado em: {ARB_PATH}\033[0m")
        return
    
    print(f"🟢 Arquivo ARB encontrado: {ARB_PATH}")

    # 2. Ler as chaves
    try:
        with open(ARB_PATH, 'r', encoding='utf-8') as f:
            data = json.load(f)
            all_keys = [k for k in data.keys() if not k.startswith('@')]
            print(f"📦 Total de chaves encontradas no ARB: {len(all_keys)}")
    except Exception as e:
        print(f"\033[91m🔴 ERRO ao ler o JSON: {e}\033[0m")
        return

    # 3. Mapear arquivos Dart
    dart_files = []
    for root, _, files in os.walk(LIB_FOLDER):
        for file in files:
            if file.endswith('.dart'):
                dart_files.append(os.path.join(root, file))
    
    print(f"📂 Total de arquivos Dart mapeados: {len(dart_files)}")

    if not dart_files:
        print("\033[91m🔴 ERRO: Nenhum arquivo .dart encontrado na pasta lib/\033[0m")
        return

    # 4. Busca
    unused = []
    for key in all_keys:
        found = False
        # Procura por l10n.chave ou .chave
        pattern = re.compile(rf'\.{key}\b')
        
        for path in dart_files:
            try:
                with open(path, 'r', encoding='utf-8') as f:
                    if pattern.search(f.read()):
                        found = True
                        break
            except:
                continue
        
        if not found:
            unused.append(key)

    # 5. Resultado Final
    print("\n--- RESULTADO DA AUDITORIA ---")
    if unused:
        print(f"\033[91m🔴 {len(unused)} chaves não estão sendo usadas:\033[0m")
        for item in unused:
            print(f"  - {item}")
    else:
        print("\033[92m🟢 Sucesso! Todas as chaves estão em uso.\033[0m")

if __name__ == "__main__":
    run_audit()