import json
import os
import re

def check_mismatch(filename):
    mismatched = []
    try:
        with open(f'assets/data/schools/{filename}.json', 'r', encoding='utf-8') as f:
            data = json.load(f)
            for s in data:
                img = s.get('image_url', '')
                if not img:
                    mismatched.append(f"{s['name']} (No Image)")
                    continue
                
                if img.startswith('http'):
                    mismatched.append(f"{s['name']} (External Link)")
                    continue
                
                # Check for "Random" match
                school_name_parts = re.findall(r'\w+', s['name'].lower())
                img_name = img.split('/')[-1].lower()
                
                # If none of the school name words (longer than 3 chars) are in the image filename, flag it
                significant_words = [w for w in school_name_parts if len(w) > 3 and w not in ['school', 'international', 'language', 'college', 'private']]
                
                if not significant_words:
                    # If it's a generic name like 'St. Fatima', just check one word
                    significant_words = [w for w in school_name_parts if len(w) > 2]

                found_match = False
                for w in significant_words:
                    if w in img_name:
                        found_match = True
                        break
                
                if not found_match:
                    mismatched.append(f"{s['name']} (Likely Random Image: {img_name})")
                    
    except Exception as e:
        print(f"Error reading {filename}: {e}")
    return mismatched

cairo_mismatched = check_mismatch('cairo')
alex_mismatched = check_mismatch('alexandria')

print("--- Cairo Schools with Potential Random Images ---")
for m in cairo_mismatched: print(m)
print("\n--- Alexandria Schools with Potential Random Images ---")
for m in alex_mismatched: print(m)
