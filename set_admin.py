import urllib.request
import json

PROJECT_ID = 'schoolage-41aba'
TARGET_EMAIL = 'annanader83@gmail.com'
ADMIN_SCHOOL_ID = 'Cairo-English-School'

def query_user_by_email(email):
    """Query the users collection for a matching email."""
    url = f'https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents:runQuery'
    query = {
        "structuredQuery": {
            "from": [{"collectionId": "users"}],
            "where": {
                "fieldFilter": {
                    "field": {"fieldPath": "email"},
                    "op": "EQUAL",
                    "value": {"stringValue": email}
                }
            },
            "limit": 1
        }
    }
    payload = json.dumps(query).encode('utf-8')
    req = urllib.request.Request(
        url, method='POST', data=payload,
        headers={'Content-Type': 'application/json'}
    )
    response = urllib.request.urlopen(req)
    results = json.loads(response.read().decode('utf-8'))
    for r in results:
        if 'document' in r:
            return r['document']
    return None

def update_user_to_admin(doc_name):
    """PATCH the user document to set role=admin and schoolId."""
    url = f'https://firestore.googleapis.com/v1/{doc_name}?updateMask.fieldPaths=role&updateMask.fieldPaths=schoolId'
    payload = json.dumps({
        'fields': {
            'role': {'stringValue': 'admin'},
            'schoolId': {'stringValue': ADMIN_SCHOOL_ID}
        }
    }).encode('utf-8')
    req = urllib.request.Request(
        url, method='PATCH', data=payload,
        headers={'Content-Type': 'application/json'}
    )
    urllib.request.urlopen(req)

print(f"Searching for user: {TARGET_EMAIL} ...")
doc = query_user_by_email(TARGET_EMAIL)

if doc is None:
    print("ERROR: User not found in Firestore! Make sure they have logged in at least once.")
else:
    doc_name = doc['name']
    current_role = doc.get('fields', {}).get('role', {}).get('stringValue', 'N/A')
    print(f"Found user: {doc_name}")
    print(f"Current role: {current_role}")
    
    update_user_to_admin(doc_name)
    print(f"SUCCESS! Role updated to 'admin' with schoolId='{ADMIN_SCHOOL_ID}'")
    print("Hot-restart the app and log in again to see the Admin Dashboard.")
