import os
import re

def fix_all_dart_errors(directory):
    pattern_direct_const = re.compile(r'const\s+(Color\([^)]+\)|AppColors\.[a-zA-Z0-9_]+)\s*\.(?:withValues|withOpacity)\(')
    pattern_textstyle_const = re.compile(r'const\s+TextStyle\(([^)]*\.(?:withValues|withOpacity)\([^)]*\)[^)]*)\)')
    pattern_boxdec_const = re.compile(r'const\s+BoxDecoration\(([^)]*\.(?:withValues|withOpacity)\([^)]*\)[^)]*)\)')
    
    fixed_consts = 0
    fixed_imports = 0

    for root, _, files in os.walk(directory):
        for file in files:
            if not file.endswith('.dart'):
                continue
            
            filepath = os.path.join(root, file)
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                original_content = content
                
                # --- PARTE 1: CONSTANTS COM WITHVALUES ---
                # 1. Direto
                def replace_direct(match):
                    return match.group(0).replace('const ', '', 1)
                content = pattern_direct_const.sub(replace_direct, content)

                # 2. TextStyle
                def replace_style(match):
                    return match.group(0).replace('const TextStyle', 'TextStyle', 1)
                content = pattern_textstyle_const.sub(replace_style, content)

                # 3. BoxDecoration
                def replace_box(match):
                    return match.group(0).replace('const BoxDecoration', 'BoxDecoration', 1)
                content = pattern_boxdec_const.sub(replace_box, content)
                
                # 4. Linhas gerais
                lines = content.split('\n')
                new_lines = []
                for line in lines:
                    if 'const ' in line and ('.withValues(' in line or '.withOpacity(' in line):
                        if 'class ' not in line and 'final ' not in line:
                            new_line = line.replace('const ', '')
                            new_lines.append(new_line)
                            continue
                    
                    if 'Colors.grey.withValues(' in line:
                        line = line.replace('Colors.grey.withValues(', 'Colors.grey.shade400.withValues(')
                    if 'Colors.grey.withOpacity(' in line:
                        line = line.replace('Colors.grey.withOpacity(', 'Colors.grey.shade400.withOpacity(')
                        
                    new_lines.append(line)
                
                content = '\n'.join(new_lines)

                # --- PARTE 2: IMPORTS Ausentes (material, foundation) ---
                has_ui_elements = any(kw in content for kw in ['Color(', 'FontWeight.', 'TextAlign.', 'Widget', 'StatelessWidget', 'StatefulWidget', 'VoidCallback', 'Colors.'])
                has_material_import = 'import \'package:flutter/material.dart\';' in content
                
                # Certificar que material.dart sinta presente
                if has_ui_elements and not has_material_import:
                    import_idx = content.rfind('import \'')
                    if import_idx != -1:
                        end_of_import_line = content.find('\n', import_idx)
                        if end_of_import_line != -1:
                            content = content[:end_of_import_line] + '\nimport \'package:flutter/material.dart\';' + content[end_of_import_line:]
                        else:
                            content = 'import \'package:flutter/material.dart\';\n' + content
                    else:
                        content = 'import \'package:flutter/material.dart\';\n' + content
                    fixed_imports += 1

                # Corrigindo falhas espeficas do AppLocalizations que exige foundation pro Locale
                if 'app_localizations.dart' in file or 'pet_localizations.dart' in file:
                     if 'Locale' in content and 'import \'package:flutter/foundation.dart\';' not in content and 'import \'package:flutter/material.dart\';' not in content:
                           content = 'import \'package:flutter/foundation.dart\';\n' + content
                           fixed_imports += 1

                if content != original_content:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(content)
                    print(f"✅ Modified: {os.path.relpath(filepath, directory)}")
                    fixed_consts += 1
                    
            except Exception as e:
                print(f"Error reading {filepath}: {e}")

    print(f"\n🚀 Ultimate Audit Complete!")
    print(f"Files modified: {fixed_consts}")
    print(f"Missing imports injected/resolved: {fixed_imports}")

if __name__ == '__main__':
    project_dir = r"E:\antigravity_projetos\ScanNutPlus\lib"
    fix_all_dart_errors(project_dir)
