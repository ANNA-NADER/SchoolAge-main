import urllib.request
import json

PROJECT_ID = 'schoolage-41aba'
BASE_URL = f'https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/schools'

def audit_alexandria():
    url = f'{BASE_URL}?pageSize=300'
    try:
        response = urllib.request.urlopen(url)
        data = json.loads(response.read().decode('utf-8'))
        docs = data.get('documents', [])
        
        print(f"{'School Name':<40} | {'Image URL'}")
        print("-" * 80)
        
        for d in docs:
            fields = d.get('fields', {})
            city = fields.get('governorate', {}).get('stringValue', '')
            name = fields.get('name', {}).get('stringValue', '')
            img = fields.get('image_url', {}).get('stringValue', '')
            
            if city.lower() == 'alexandria':
                print(f"{name[:40]:<40} | {img}")
                
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    audit_alexandria()
