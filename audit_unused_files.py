import os
import sys

# Forçar a saída de mensagens imediatamente no terminal
def log(msg, color=""):
    colors = {"red": "\033[91m", "green": "\033[92m", "blue": "\033[94m", "end": "\033[0m"}
    if color in colors:
        print(f"{colors[color]}{msg}{colors['end']}")
    else:
        print(msg)

log("🚀 [DEBUG] Script iniciado...", "blue")
log(f"📍 [DEBUG] Pasta atual: {os.getcwd()}")

def auditoria():
    lib_path = 'lib'
    
    # Verificação de Pasta
    if not os.path.exists(lib_path):
        log(f"🔴 Erro: A pasta '{lib_path}' não foi encontrada em {os.getcwd()}", "red")
        log("Certifique-se de rodar o script na raiz do projeto (onde fica o pubspec.yaml).")
        return

    log(f"🟢 Pasta '{lib_path}' encontrada. Mapeando arquivos...", "green")

    todos_arquivos = []
    for root, _, files in os.walk(lib_path):
        for f in files:
            if f.endswith('.dart'):
                todos_arquivos.append(os.path.join(root, f))
    
    log(f"📦 Total de arquivos .dart encontrados: {len(todos_arquivos)}")

    if len(todos_arquivos) == 0:
        log("⚠️ Nenhum arquivo .dart detectado para análise.", "red")
        return

    # Procura por Imports
    arquivos_usados = {"main.dart"}
    for path in todos_arquivos:
        try:
            with open(path, 'r', encoding='utf-8') as f:
                conteudo = f.read()
                # Busca simples por nomes de arquivos nos imports
                for outro_arquivo in todos_arquivos:
                    nome_simples = os.path.basename(outro_arquivo)
                    if nome_simples != os.path.basename(path) and nome_simples in conteudo:
                        arquivos_usados.add(os.path.relpath(outro_arquivo, lib_path).replace('\\', '/'))
        except Exception as e:
            log(f"❌ Erro ao ler {path}: {e}", "red")

    log("🔍 Cruzando dados de uso...")
    
    mortos = []
    for arq in todos_arquivos:
        rel = os.path.relpath(arq, lib_path).replace('\\', '/')
        if rel not in arquivos_usados and not rel.endswith('.g.dart') and rel != 'main.dart':
            mortos.append(rel)

    if mortos:
        log(f"🔴 Encontrados {len(mortos)} arquivos possivelmente sem uso:", "red")
        for m in mortos:
            log(f"  - lib/{m}")
    else:
        log("🟢 Sucesso! Todos os arquivos parecem estar em uso.", "green")

# Execução direta (sem o if __name__ para garantir que rode em qualquer lugar)
auditoria()
log("🏁 Script finalizado.")