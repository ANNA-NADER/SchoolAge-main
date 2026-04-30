import json
import os

GENERIC_IMAGE = 'city_internation_national.jpeg'
DATA_DIR = 'assets/data/schools'

def audit_all():
    files = [f for f in os.listdir(DATA_DIR) if f.endswith('.json') and f != 'index.json']
    
    total_schools = 0
    total_issues = 0
    
    print("--- GLOBAL IMAGE AUDIT REPORT ---")
    
    for city_file in sorted(files):
        path = os.path.join(DATA_DIR, city_file)
        with open(path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        city_name = city_file.replace('.json', '').title()
        issues = []
        for school in data:
            total_schools += 1
            name = school.get('name', 'Unknown')
            img = school.get('image_url', '')
            
            if not img:
                issues.append({'name': name, 'reason': 'MISSING'})
            elif GENERIC_IMAGE in img:
                issues.append({'name': name, 'reason': 'PLACEHOLDER'})
        
        if issues:
            print(f"\n{city_name} ({len(issues)} issues):")
            for issue in issues:
                print(f"  - [{issue['reason']}] {issue['name']}")
            total_issues += len(issues)
            
    print("\n----------------------------------------")
    print(f"Total Schools Scanned: {total_schools}")
    print(f"Total Issues Found: {total_issues}")
    print("----------------------------------------")

audit_all()
