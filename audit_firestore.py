import urllib.request
import json
import os
import re

PROJECT_ID = 'schoolage-41aba'
BASE_URL = f'https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/schools'
local_images = [f.lower() for f in os.listdir('assets/images')]
GENERIC_IMAGE = 'city internation national.jpeg'

def get_all_docs():
    docs = []
    url = f'{BASE_URL}?pageSize=300'
    try:
        data = json.loads(urllib.request.urlopen(url).read().decode('utf-8'))
        docs.extend(data.get('documents', []))
    except Exception as e:
        print(f'Error fetching: {e}')
    return docs

docs = get_all_docs()
cairo_flagged = []
alex_flagged = []

for d in docs:
    fields = d.get('fields', {})
    name = fields.get('name', {}).get('stringValue', 'Unknown')
    gov = fields.get('governorate', {}).get('stringValue', '')
    img = fields.get('image_url', {}).get('stringValue', '')
    
    if gov.lower() not in ['cairo', 'alexandria']:
        continue
        
    reason = None
    if not img:
        reason = "No Image"
    elif img.startswith('http'):
        reason = f"External Link: {img[:30]}..."
    elif GENERIC_IMAGE in img:
        reason = "Generic Building Image"
    else:
        fname = img.replace('assets/images/', '').lower()
        if fname not in local_images:
            reason = f"Broken Path: {img}"
        else:
            # Check for name mismatch
            school_parts = re.findall(r'\w+', name.lower())
            significant = [w for w in school_parts if len(w) > 3 and w not in ['school', 'international', 'language', 'college', 'private']]
            if not significant: significant = [w for w in school_parts if len(w) > 2]
            
            found = False
            for w in significant:
                if w in fname:
                    found = True
                    break
            if not found:
                reason = f"Likely Random/Mismatched Image: {fname}"

    if reason:
        msg = f"{name} ({reason})"
        if gov.lower() == 'cairo': cairo_flagged.append(msg)
        else: alex_flagged.append(msg)

print("--- Cairo Schools Needing Better Photos ---")
for m in sorted(cairo_flagged): print(m)
print("\n--- Alexandria Schools Needing Better Photos ---")
for m in sorted(alex_flagged): print(m)
