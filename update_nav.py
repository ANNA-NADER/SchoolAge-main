import os
import re

screens_dir = r'c:\Users\HP\Desktop\front end\SchoolAge_Final\lib\screens'

for filename in os.listdir(screens_dir):
    if not filename.endswith('.dart'): continue
    filepath = os.path.join(screens_dir, filename)
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Skip if it already has the Map icon
    if 'icon: Icon(Icons.public)' in content or 'icon: const Icon(Icons.public)' in content or 'icon:Icon(Icons.public)' in content:
        continue
        
    if 'BottomNavigationBar(' not in content:
        continue

    # Add import if missing
    if 'thematic_map_screen.dart' not in content:
        imports = re.findall(r'^import .*?;', content, re.MULTILINE)
        if imports:
            last_import = imports[-1]
            content = content.replace(last_import, last_import + '\nimport \'thematic_map_screen.dart\';')

    # Update onTap
    # Change else if (index == 2)
    match = re.search(r'else if \(index == 2\) \{([^\}]+)\}', content)
    if match:
        old_index_2 = match.group(1)
        new_logic = f'''else if (index == 2) {{
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ThematicMapScreen()),
            );
          }} else if (index == 3) {{{old_index_2}}}'''
        content = content.replace(match.group(0), new_logic)

    # Now add the Map item in items
    items_match = re.finditer(r'(const\s+)?BottomNavigationBarItem\(', content)
    items = list(items_match)
    if len(items) == 3:
        last_item_pos = items[-1].start()
        map_item = "const BottomNavigationBarItem(\n            icon: Icon(Icons.public),\n            label: 'Map',\n          ),\n          "
        content = content[:last_item_pos] + map_item + content[last_item_pos:]
        
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
        print(f'Updated {filename}')
