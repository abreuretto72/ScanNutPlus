import os
import re

# Configurações: Pastas para varrer e extensões
TARGET_DIR = './lib'
FILE_EXTENSION = '.dart'

# Regex para encontrar blocos de prompts (strings triplas ''' ou """)
# Ele busca por blocos que contenham palavras típicas de prompts do ScanNut
PROMPT_PATTERN = re.compile(r"(['\"]{3})(.*?)(\1)", re.DOTALL)

# Palavras em português que indicam que o prompt não foi totalmente convertido
PORTUGUESE_KEYWORDS = [
    'OBJETIVO', 'DIRETRIZES', 'SAÍDA', 'OBRIGATÓRIA', 'IDENTIFICAÇÃO', 
    'SAÚDE', 'TOXICIDADE', 'MANUTENÇÃO', 'DADOS', 'RÓTULO', 'EXAME'
]

def analyze_prompts():
    print(f"🚀 Scanning for hardcoded Portuguese strings in Prompts...\n")
    found_count = 0

    for root, dirs, files in os.walk(TARGET_DIR):
        for file in files:
            if file.endswith(FILE_EXTENSION):
                path = os.path.join(root, file)
                with open(path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    
                    # Encontra blocos de strings longas
                    matches = PROMPT_PATTERN.finditer(content)
                    
                    for match in matches:
                        prompt_text = match.group(2)
                        
                        # Verifica se o bloco parece um prompt e contém português
                        if any(word in prompt_text.upper() for word in PORTUGUESE_KEYWORDS):
                            found_count += 1
                            line_number = content.count('\n', 0, match.start()) + 1
                            
                            print(f"⚠️  [ISSUE FOUND]")
                            print(f"   File: {path}")
                            print(f"   Line: {line_number}")
                            print(f"   Excerpt: {prompt_text.strip()[:100]}...")
                            print("-" * 50)

    if found_count == 0:
        print("✅ Success! No Portuguese hardcoded strings found in prompts.")
    else:
        print(f"❌ Total issues found: {found_count}")

if __name__ == "__main__":
    analyze_prompts()