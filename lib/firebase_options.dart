import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB8d8GtD6v__LsXlIXE7HL9d6J3DkrybHE',
    appId: '1:778063521937:android:09433c3d06a6c79e9b3730',
    messagingSenderId: '778063521937',
    projectId: 'streaks-cc514',
    storageBucket: 'streaks-cc514.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCA_ZRDbp0And8oNWQIs8nFaZUb-D3VvNE',
    appId: '1:778063521937:ios:12e91b605f8e52b09b3730',
    messagingSenderId: '778063521937',
    projectId: 'streaks-cc514',
    storageBucket: 'streaks-cc514.firebasestorage.app',
    iosBundleId: 'com.example.streaks',
  );
}
