// Posts ONE test listing as a throwaway test agent, through the normal
// Firebase client SDK + security rules — so it lands as "pending" exactly like
// a real post. Used only for the end-to-end test pass.
import { initializeApp } from 'firebase/app';
import {
  getAuth,
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
} from 'firebase/auth';
import { getFirestore, doc, setDoc } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: 'AIzaSyCyyE4Fhpehh70d40pXzVm0YTelfXr-_JQ',
  authDomain: 'gidihomes-ng.firebaseapp.com',
  projectId: 'gidihomes-ng',
  storageBucket: 'gidihomes-ng.firebasestorage.app',
  messagingSenderId: '741033924561',
  appId: '1:741033924561:web:238b8cbe63546397c1f2f0',
};

const EMAIL = 'demoagent.oct4@gidihomes.ng';
const PASSWORD = 'test1234';

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

async function signInOrCreate() {
  try {
    const cred = await createUserWithEmailAndPassword(auth, EMAIL, PASSWORD);
    return { uid: cred.user.uid, created: true };
  } catch (e) {
    if (e.code === 'auth/email-already-in-use') {
      const cred = await signInWithEmailAndPassword(auth, EMAIL, PASSWORD);
      return { uid: cred.user.uid, created: false };
    }
    throw e;
  }
}

const { uid, created } = await signInOrCreate();

// Agent profile
await setDoc(doc(db, 'users', uid), {
  id: uid,
  name: 'Demo Tester',
  email: EMAIL,
  phone: '+2348100000001',
  role: 'agent',
  agencyName: 'Demo Test Realty',
  verified: false,
});

// Pending listing
const id = 'test_' + Date.now().toString(36);
const title = 'TEST — 2 Bedroom Serviced Apartment';
await setDoc(doc(db, 'properties', id), {
  id,
  title,
  type: 'shortlet',
  price: 95000,
  area: 'Lekki Phase 1',
  address: 'Admiralty Way, Lekki Phase 1',
  description:
    'End-to-end test listing created via the client SDK. Serviced 2-bedroom with 24/7 power and fast Wi-Fi.',
  images: [
    'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=900&q=80&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=900&q=80&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=900&q=80&auto=format&fit=crop',
  ],
  agentId: uid,
  lat: 6.4431,
  lng: 3.4725,
  createdAt: new Date().toISOString(),
  bedrooms: 2,
  bathrooms: 2,
  toilets: 2,
  furnishing: 'serviced',
  amenities: ['24/7 Power', 'Wi-Fi', 'Air Conditioning', 'Parking (2)'],
  featured: false,
  serviceCharge: null,
  videos: [],
  status: 'pending',
});

console.log(JSON.stringify({ ok: true, accountCreated: created, uid, listingId: id, title }, null, 2));
process.exit(0);
