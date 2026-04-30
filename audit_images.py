import json
import os

GENERIC_IMAGE = 'city_internation_national.jpeg'
DATA_DIR = 'assets/data/schools'

def audit_city(city_file):
    path = os.path.join(DATA_DIR, city_file)
    if not os.path.exists(path):
        return []
    
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    issues = []
    for school in data:
        name = school.get('name', 'Unknown')
        img = school.get('image_url', '')
        
        if not img:
            issues.append({'name': name, 'reason': 'No image linked'})
        elif GENERIC_IMAGE in img:
            issues.append({'name': name, 'reason': 'Using generic placeholder'})
            
    return issues

print("--- AUDIT REPORT: CAIRO & ALEXANDRIA ---")

cairo_issues = audit_city('cairo.json')
print(f"\nCAIRO ({len(cairo_issues)} schools with issues):")
for issue in cairo_issues:
    print(f"- {issue['name']}: {issue['reason']}")

alex_issues = audit_city('alexandria.json')
print(f"\nALEXANDRIA ({len(alex_issues)} schools with issues):")
for issue in alex_issues:
    print(f"- {issue['name']}: {issue['reason']}")

print("\n----------------------------------------")
