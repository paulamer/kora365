# kora365
# MatchTracker — Setup Guide

## 🔥 Firebase Setup (Your Project: Koora365)

Your Firebase project ID is `koora365-40e1f`. You need to fill in the API keys.

### Option A — Auto-configure (Recommended)
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Run from the project root
flutterfire configure --project=koora365-40e1f
```
This auto-generates `lib/firebase_options.dart` with all values filled in.

### Option B — Manual
1. Go to [Firebase Console](https://console.firebase.google.com/project/koora365-40e1f/settings/general)
2. Click **Add app** → Android (or iOS)
3. Download `google-services.json` → place in `android/app/`
4. Copy the values into `lib/firebase_options.dart`

---

## ⚽ API Key (Optional)

The app ships with full **mock data** — it works without an API key.

To get live scores:
1. Sign up at [RapidAPI](https://rapidapi.com/api-sports/api/api-football) (free tier: 100 calls/day)
2. Open `lib/core/constants/app_strings.dart`
3. Replace `YOUR_RAPIDAPI_KEY_HERE` with your key

---

## 🚀 Run the App

```bash
cd match_tracker
flutter pub get
flutter run
```

---

## 📁 File Structure

```
lib/
├── core/
│   ├── constants/       app_colors.dart, app_strings.dart
│   ├── network/         api_client.dart (API-Football + mock fallback)
│   ├── theme/           app_theme.dart (dark 365-style)
│   └── utils/           date_formatter.dart
│
├── features/
│   ├── auth/            Firebase Email + Google Sign-in
│   ├── matches/         Home screen, match detail, match card widget
│   ├── standings/       League table with UCL/UEL/Relegation colors
│   └── favorites/       Firestore-backed favorites
│
├── firebase_options.dart   ← Fill in your Firebase keys here
└── main.dart
```

---

## ✅ Features

| Feature | Status |
|---|---|
| Live & today's matches (mock data) | ✅ |
| League filter (PL, La Liga, Bundesliga, etc.) | ✅ |
| All / Live / Upcoming / Finished filter | ✅ |
| Match detail with Stats & Timeline tabs | ✅ |
| Standings table (color-coded) | ✅ |
| Favorites (Firestore, requires login) | ✅ |
| Firebase Auth (Email + Google) | ✅ |
| Profile screen | ✅ |
| Dark 365-style theme | ✅ |
| Mock data when no API key | ✅ |
