// IMPORTANT: This file was pre-filled with your Firebase project ID.
// To generate the full config automatically, run:
//   dart pub global activate flutterfire_cli
//   flutterfire configure --project=koora365-40e1f
//
// OR manually fill in the values below from:
// Firebase Console → Project Settings → Your Apps → SDK Setup & Configuration

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ── Android ───────────────────────────────────────────────────────────────

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDtz9scicSGBp9rMniAuVUM826sHJCKLMo',
    appId: '1:1024864879199:android:11c43523a5dbc084ea91ea',
    messagingSenderId: '1024864879199',
    projectId: 'koora365-40e1f',
    storageBucket: 'koora365-40e1f.firebasestorage.app',
  );

  // Get from: google-services.json → client[0].api_key[0].current_key

  // ── iOS ───────────────────────────────────────────────────────────────────

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCoDubhmm1lHMu7wOFXjoo5r6IH2PIRG-Q',
    appId: '1:1024864879199:ios:92470a53908e994dea91ea',
    messagingSenderId: '1024864879199',
    projectId: 'koora365-40e1f',
    storageBucket: 'koora365-40e1f.firebasestorage.app',
    iosClientId: '1024864879199-ua3p8n00gt817s0ibdfe2fu8etubaug1.apps.googleusercontent.com',
    iosBundleId: 'com.matchtracker.matchTracker',
  );

  // Get from: GoogleService-Info.plist

  // ── Web ───────────────────────────────────────────────────────────────────

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCK1R0-mtMSzwT5V-xvNGqtBBkJn307K4c',
    appId: '1:1024864879199:web:712336ff4fc71561ea91ea',
    messagingSenderId: '1024864879199',
    projectId: 'koora365-40e1f',
    authDomain: 'koora365-40e1f.firebaseapp.com',
    storageBucket: 'koora365-40e1f.firebasestorage.app',
    measurementId: 'G-6B3TQ2THN8',
  );

  // Get from: Firebase Console → Project Settings → Web apps

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCoDubhmm1lHMu7wOFXjoo5r6IH2PIRG-Q',
    appId: '1:1024864879199:ios:92470a53908e994dea91ea',
    messagingSenderId: '1024864879199',
    projectId: 'koora365-40e1f',
    storageBucket: 'koora365-40e1f.firebasestorage.app',
    iosClientId: '1024864879199-ua3p8n00gt817s0ibdfe2fu8etubaug1.apps.googleusercontent.com',
    iosBundleId: 'com.matchtracker.matchTracker',
  );

  // ── macOS ────────────────────────────────────────────────────────────────

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCK1R0-mtMSzwT5V-xvNGqtBBkJn307K4c',
    appId: '1:1024864879199:web:0e26d0e56db9f9f8ea91ea',
    messagingSenderId: '1024864879199',
    projectId: 'koora365-40e1f',
    authDomain: 'koora365-40e1f.firebaseapp.com',
    storageBucket: 'koora365-40e1f.firebasestorage.app',
    measurementId: 'G-MJK9BGRC8Q',
  );

  // ── Windows ───────────────────────────────────────────────────────────────
}