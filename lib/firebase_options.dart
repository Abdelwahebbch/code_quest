import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web not configured.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCNajzwXFcpRxPW93MQIXpgGDq14dwUlZw',
    appId: '1:984696599234:android:c987c04534d4ac9e39c15b',
    messagingSenderId: '984696599234',
    projectId: 'code-quest-7150f',
    storageBucket: 'code-quest-7150f.firebasestorage.app',
  );
}