import re

file_path = r'e:\antigravity_projetos\ScanNutPlus\lib\features\pet\agenda\presentation\pet_scheduled_events_screen.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    orig_content = f.read()

# Replace the specific syntax issue ),                ),
new_content = orig_content.replace('),                ),', '),\n')

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(new_content)

print("Block replaced!")
