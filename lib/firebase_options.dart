// File generated manually for Firebase configuration
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBgeo2mvMhlBjnRggl2JUtDSHSPta1ZkLY',
    appId: '1:960879454719:android:9c3c116a2aed9571255fca',
    messagingSenderId: '960879454719',
    projectId: 'aquasmart-20418',
    databaseURL: 'https://aquasmart-20418-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'aquasmart-20418.firebasestorage.app',
  );
}
