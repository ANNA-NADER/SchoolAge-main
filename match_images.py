import os
import json
import glob
import re
from difflib import get_close_matches

# 1. Get all images from assets/images
image_files = [f for f in os.listdir('assets/images') if f.lower().endswith(('.png', '.jpg', '.jpeg'))]
image_names = {os.path.splitext(f)[0].lower(): f for f in image_files}

print(f'Found {len(image_files)} images in assets/images')

# 2. Iterate through all JSON files
json_files = glob.glob('assets/data/schools/*.json')

for json_path in json_files:
    if 'index.json' in json_path: continue
    
    with open(json_path, 'r', encoding='utf-8') as f:
        try:
            schools = json.load(f)
        except:
            continue
    
    updated = False
    for school in schools:
        name = school['name']
        match = None
        
        # Try exact match first
        if name.lower() in image_names:
            match = image_names[name.lower()]
        
        # Try cleaning the name (remove "School", governorate names etc for better fuzzy matching)
        if not match:
            clean_name = name.split(',')[0].strip().lower()
            # Also try matching without the word "School" if it's failing
            search_terms = [clean_name, clean_name.replace('school', '').strip()]
            
            for term in search_terms:
                if term in image_names:
                    match = image_names[term]
                    break
                
                # Fuzzy match
                matches = get_close_matches(term, image_names.keys(), n=1, cutoff=0.7)
                if matches:
                    match = image_names[matches[0]]
                    break
        
        if match:
            new_url = f'assets/images/{match}'
            if school.get('image_url') != new_url:
                school['image_url'] = new_url
                updated = True
                print(f'Matched: "{name}" -> "{match}"')

    if updated:
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(schools, f, indent=2)
        print(f'Updated {json_path}')
