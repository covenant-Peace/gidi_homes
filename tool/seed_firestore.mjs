// Seeds Firestore with GidiHomes sample data using the Admin SDK.
// The Admin SDK uses a service account and bypasses security rules — so the
// locked-down production rules stay in place.
//
// Usage:
//   node tool/seed_firestore.mjs /path/to/serviceAccountKey.json
//
// Get the key: Firebase console → Project settings → Service accounts →
// Generate new private key. Delete the key file afterwards.

import { readFileSync } from 'node:fs';
import admin from 'firebase-admin';

const keyPath = process.argv[2] || process.env.GOOGLE_APPLICATION_CREDENTIALS;
if (!keyPath) {
  console.error('Usage: node tool/seed_firestore.mjs <service-account.json>');
  process.exit(1);
}

const serviceAccount = JSON.parse(readFileSync(keyPath, 'utf8'));
admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

const data = JSON.parse(
  readFileSync(new URL('./seed.json', import.meta.url), 'utf8')
);

const batch = db.batch();
for (const a of data.agents) {
  batch.set(db.collection('users').doc(a.id), a);
}
for (const p of data.properties) {
  batch.set(db.collection('properties').doc(p.id), p);
}
await batch.commit();

console.log(
  `✅ Seeded ${data.agents.length} agents + ${data.properties.length} listings into Firestore.`
);
process.exit(0);
