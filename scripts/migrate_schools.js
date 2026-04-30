const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

/**
 * INSTRUCTIONS:
 * 1. Go to Firebase Console -> Project Settings -> Service Accounts.
 * 2. Click "Generate New Private Key".
 * 3. Save the file as "serviceAccountKey.json" in this "scripts" folder.
 * 4. Run:
 *    cd scripts
 *    npm install firebase-admin
 *    node migrate_schools.js
 */

const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');

if (!fs.existsSync(serviceAccountPath)) {
  console.error('Error: serviceAccountKey.json not found in the scripts folder.');
  process.exit(1);
}

const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const schoolsDir = path.join(__dirname, '../assets/data/schools');

async function migrate() {
  const files = fs.readdirSync(schoolsDir).filter(file => file.endsWith('.json') && file !== 'index.json');

  for (const file of files) {
    console.log(`Processing ${file}...`);
    const filePath = path.join(schoolsDir, file);
    const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));

    const batch = db.batch();
    for (const school of data) {
      const docRef = db.collection('schools').doc();
      batch.set(docRef, {
        ...school,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });
    }
    await batch.commit();
    console.log(`Successfully migrated ${file}`);
  }
  console.log('All schools migrated successfully!');
}

migrate().catch(console.error);
