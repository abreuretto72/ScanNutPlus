import os
import re
import sys

# Configurações
TARGET_DIR = './lib'

# Regex usando códigos hex: \x27 = ' | \x22 = "
# Busca blocos de aspas triplas no Dart
pattern = r'([\x27\x22]{3})(.*?)(\1)'
PROMPT_PATTERN = re.compile(pattern, re.DOTALL)

# Termos em português para identificar prompts não convertidos
PORTUGUESE_KEYWORDS = [
    'OBJETIVO', 'DIRETRIZES', 'SAIDA', 'OBRIGATORIA', 'IDENTIFICACAO', 
    'SAUDE', 'TOXICIDADE', 'MANUTENCAO', 'DADOS', 'ROTULO', 'EXAME',
    'MODO', 'PADRAO', 'BOTANICO', 'OBRIGATORIO', 'REGRAS'
]

def analyze_prompts():
    # Removido todos os emojis e acentos para compatibilidade total com Windows
    print("--- ScanNut Plus: Prompt Inspector ---")
    print("Scanning directory: " + TARGET_DIR + "\n")
    
    found_count = 0

    if not os.path.exists(TARGET_DIR):
        print("Error: Directory not found.")
        return

    for root, _, files in os.walk(TARGET_DIR):
        for file in files:
            if file.endswith('.dart'):
                path = os.path.join(root, file)
                try:
                    # Abre com utf-8 e ignora erros de caracteres do arquivo
                    with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                        content = f.read()
                        
                        for match in PROMPT_PATTERN.finditer(content):
                            prompt_body = match.group(2)
                            # Remove acentos para comparação simples
                            text_to_check = prompt_body.upper()
                            
                            found_words = [w for w in PORTUGUESE_KEYWORDS if w in text_to_check]
                            
                            if found_words:
                                found_count += 1
                                line = content.count('\n', 0, match.start()) + 1
                                print("FILE: " + path + " (Line " + str(line) + ")")
                                print("   Keywords found: " + ", ".join(found_words))
                                # Limpa o snippet para evitar quebras no print do terminal
                                snippet = prompt_body.strip()[:70].replace('\n', ' ')
                                print("   Snippet: " + snippet + "...")
                                print("-" * 50)
                except Exception as e:
                    pass # Silencioso para não poluir o terminal

    if found_count == 0:
        print("SUCCESS: All prompts are clean (English only).")
    else:
        print("\nTOTAL ISSUES FOUND: " + str(found_count))

if __name__ == "__main__":
    analyze_prompts()