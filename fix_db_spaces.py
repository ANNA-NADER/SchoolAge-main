import urllib.request
import json

PROJECT_ID = 'schoolage-41aba'
BASE_URL = f'https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/schools'

def get_all_docs():
    docs = []
    url = f'{BASE_URL}?pageSize=300'
    try:
        data = json.loads(urllib.request.urlopen(url).read().decode('utf-8'))
        docs.extend(data.get('documents', []))
    except: pass
    return docs

def update_doc(doc_name, fields):
    url = f'https://firestore.googleapis.com/v1/{doc_name}'
    payload = json.dumps({'fields': fields}).encode('utf-8')
    req = urllib.request.Request(url, method='PATCH', data=payload, headers={'Content-Type': 'application/json'})
    try: urllib.request.urlopen(req)
    except: pass

docs = get_all_docs()
count = 0
for d in docs:
    fields = d.get('fields', {})
    img = fields.get('image_url', {}).get('stringValue', '')
    if img and ' ' in img:
        new_img = img.replace(' ', '_')
        print(f"Updating {d['name']}: {img} -> {new_img}")
        fields['image_url'] = {'stringValue': new_img}
        update_doc(d['name'], fields)
        count += 1

print(f"Finished updating {count} records in DB.")
