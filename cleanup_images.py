import urllib.request
import json
import os

PROJECT_ID = 'schoolage-41aba'
BASE_URL = f'https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/schools'

def get_all_docs():
    docs = []
    url = f'{BASE_URL}?pageSize=300'
    try:
        data = json.loads(urllib.request.urlopen(url).read().decode('utf-8'))
        docs.extend(data.get('documents', []))
    except Exception as e:
        print(f'Error fetching: {e}')
    return docs

def update_doc(doc_name, fields):
    url = f'https://firestore.googleapis.com/v1/{doc_name}'
    payload = json.dumps({'fields': fields}).encode('utf-8')
    req = urllib.request.Request(url, method='PATCH', data=payload, headers={'Content-Type': 'application/json'})
    try: urllib.request.urlopen(req)
    except Exception as e: print(f'Failed update: {e}')

local_images = [f.lower() for f in os.listdir('assets/images')]

docs = get_all_docs()
for d in docs:
    fields = d.get('fields', {})
    gov = fields.get('governorate', {}).get('stringValue', '')
    img_url = fields.get('image_url', {}).get('stringValue', '')
    
    if gov.lower() in ['cairo', 'alexandria']:
        continue
    
    filename = img_url.replace('assets/images/', '').lower()
    
    if img_url and (filename not in local_images or img_url.startswith('http')):
        print(f"Cleaning image for {fields.get('name', {}).get('stringValue')}: {img_url}")
        new_fields = {k: v for k, v in fields.items()}
        new_fields['image_url'] = {'nullValue': None}
        update_doc(d['name'], new_fields)

print('Database image cleanup complete')
