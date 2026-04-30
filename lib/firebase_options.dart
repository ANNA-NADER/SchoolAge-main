import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBxAJvvIthE6DN8Y0AKtsvH1CJn5Apk93Q',
    appId: '1:576394283019:web:f25e725d1b0c770b8d9f0e',
    messagingSenderId: '576394283019',
    projectId: 'schoolage-41aba',
    authDomain: 'schoolage-41aba.firebaseapp.com',
    storageBucket: 'schoolage-41aba.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBxAJvvIthE6DN8Y0AKtsvH1CJn5Apk93Q',
    appId: '1:576394283019:android:4803ae92892900458d9f0e', // Fallback from common keys
    messagingSenderId: '576394283019',
    projectId: 'schoolage-41aba',
    storageBucket: 'schoolage-41aba.firebasestorage.app',
  );
}
