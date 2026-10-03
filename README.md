# GidiHomes — Lagos Property Marketplace 🇳🇬

### 🔗 Live demo: https://covenant-peace.github.io/gidi_homes/

A Rightmove / Zoopla–style, two-sided property marketplace for **Lagos, Nigeria**,
connecting **renters, shortlet guests and land buyers** with **agents and landlords**.

**One Flutter codebase powers both the website (Flutter Web) and the mobile app
(Android / iOS)** — exactly as planned.

**Backend is live:** **Firebase Auth** (Email/Password + Google Sign-In) and
**Cloud Firestore** (listings + user profiles), with **Cloudinary** for image &
video uploads. The Firestore database is seeded with real Lagos sample listings.
To run fully offline, swap the three repository providers in
`lib/providers/providers.dart` back to the in-memory implementations.

---

## What it does

**For buyers / renters**
- Browse & search listings for **Rent (yearly)**, **Shortlet (per night)** and **Land**
- Hero search by keyword, Lagos **area** (Lekki, Ikoyi, VI, Ikeja GRA, Yaba, Ajah…) and type
- Rich filters: price range (₦), bedrooms, furnishing, **land title** (C of O, Governor's Consent, Gazette…), and sort
- **Map view** of results on an OpenStreetMap of Lagos with price pins
- Property detail: swipeable gallery, key facts, amenities, service charge, mini-map
- One-tap contact: **WhatsApp**, call, or email the agent
- Save / favourite listings (persisted locally)

**For agents / landlords**
- Register as an agent, sign in
- **Agent dashboard** with listing stats
- **Post / edit / delete** listings (rent, shortlet or land) with a Lagos-aware form
- Verified-agent badges

**Responsive by design** — a polished top-nav **website** layout on desktop/tablet,
a bottom-nav **app** layout on phones, from the same widgets.

---

## Tech stack

| Concern | Choice |
|---|---|
| UI / framework | Flutter 3.38 (Material 3) — web + Android + iOS |
| State management | Riverpod |
| Routing / deep links | go_router (`StatefulShellRoute`) |
| Maps | `flutter_map` + OpenStreetMap tiles (no API key) |
| Backend (intended) | Firebase Auth + Cloud Firestore + Storage |
| Images, fonts | `cached_network_image`, `google_fonts` (Plus Jakarta Sans) |
| Contact | `url_launcher` (tel: / wa.me / mailto:) |
| Local persistence | `shared_preferences` (session + favourites) |

Currency is Naira (**₦**), formatted with compact helpers (₦2.5M, ₦850K, ₦1.2B).

---

## Running it

> Requires Flutter 3.38+ (`flutter --version`).

```bash
flutter pub get
```

### The website (Flutter Web)
```bash
flutter run -d chrome
# or build static files to deploy anywhere (Firebase Hosting, Netlify, S3…):
flutter build web
```

### The mobile app
```bash
flutter run            # a connected device / emulator
flutter build apk      # Android
flutter build ios      # iOS (on macOS, after pod install)
```

### Try it immediately
- Browse, search, filter and view listings with **no login**.
- **Sign in** → `demo@gidihomes.ng` / `password` (buyer), or any seed agent email
  (e.g. `chinwe@primelekki.ng`) / `password` to see the agent dashboard & posting.
- Or tap **"Continue with demo account"**.

---

## Project structure

```
lib/
├── main.dart                     # ProviderScope + app bootstrap
├── app/
│   ├── app.dart                  # MaterialApp.router + theme
│   └── router.dart               # go_router routes (shell + detail/auth/agent)
├── core/                         # format (₦, time-ago), responsive, contact (wa/tel)
├── theme/app_theme.dart          # Lagos green + gold design system
├── models/                       # Property, AppUser, enums, filter, Lagos areas
├── data/
│   ├── sample_data.dart          # seeded Lagos listings + agents
│   ├── property_images.dart      # curated themed photos
│   ├── *_repository.dart         # abstract + in-memory implementations
│   └── firestore_repositories.dart  # Firebase implementations (opt-in)
├── providers/providers.dart      # Riverpod wiring
└── features/
    ├── shell/                    # responsive nav chrome
    ├── home/                     # hero search, categories, featured, areas
    ├── search/                   # results, filter sheet, map view
    ├── property/                 # detail + gallery
    ├── saved/  auth/  account/  agent/
```

The app talks to data through **repository interfaces** (`PropertyRepository`,
`AuthRepository`, `AgentRepository`). Swapping in-memory for Firebase is just a
change of provider wiring — no UI changes.

---

## Going live with Firebase

The Firebase implementations are already written in
[`lib/data/firestore_repositories.dart`](lib/data/firestore_repositories.dart).

1. Create a Firebase project; enable **Email/Password** (and optionally Anonymous) auth,
   **Cloud Firestore**, and **Storage**.
2. Install the FlutterFire CLI and generate config:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure      # creates lib/firebase_options.dart
   ```
3. In `main.dart`, initialise Firebase before `runApp`:
   ```dart
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   ```
4. In `lib/providers/providers.dart`, point the three repository providers at the
   Firestore implementations (snippet is in the header of `firestore_repositories.dart`).
5. Deploy the included security rules:
   ```bash
   firebase deploy --only firestore:rules,storage
   ```
   (`firestore.rules`, `storage.rules` are in the repo root.)

**Firestore layout:** `properties/{id}` ← `Property.toMap()`, `users/{uid}` ← `AppUser.toMap()`.

---

## Notes & roadmap

- **Media:** agents upload their own photos **and a video tour** when posting a
  listing; files go to **Cloudinary** (unsigned preset — no credit card) and the
  URLs are saved on the listing. Seeded demo listings use curated Unsplash photos.
  (Firebase Storage was avoided because it now requires the paid Blaze plan.)
- Web routing uses Flutter's default **hash URLs** (`/#/search`). For clean paths,
  set the URL strategy via `flutter_web_plugins` `usePathUrlStrategy()`.
- Natural next steps: in-app chat, inspection booking, saved searches & alerts,
  Paystack/Flutterwave for shortlet payments, agent verification (NIN/CAC), and
  listing moderation.

---

*Built as an MVP scaffold. "Gidi" is affectionate Lagos slang for the city.*
