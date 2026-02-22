import re

file_path = r'e:\antigravity_projetos\ScanNutPlus\lib\features\pet\agenda\presentation\pet_scheduled_events_screen.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# The specific broken lines from 254-260:
#                 ),
#               ),
#               const SizedBox(height: 80),
#             ],
#           ),
#         ),
#       ),
#     );
#   }
# Let's replace the block containing Expanded -> ListView.builder -> Column -> Padding -> Scaffold.

pattern = r'\s*\),\s*\),\s*const SizedBox\(height: 80\),\s*\],\s*\),\s*\),\s*\),\s*\);\s*}\s*void _confirmDelete'
replacement = r'''                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete'''

# We also need to fix any stray string literials that dart fails on like "\: \"
content = content.replace('"\: \"', '""') # Neutralize broken literal
content = content.replace('": \"', '": "')
content = content.replace('": \"', '": "') 

new_content = re.sub(pattern, replacement, content, flags=re.DOTALL)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(new_content)

print("Patch applied")
