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
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB8d8GtD6v__LsXlIXE7HL9d6J3DkrybHE',
    appId: '1:778063521937:web:eb3adae42fb677389b3730',
    messagingSenderId: '778063521937',
    projectId: 'streaks-cc514',
    authDomain: 'streaks-cc514.firebaseapp.com',
    storageBucket: 'streaks-cc514.appspot.com',
    measurementId: 'G-Y8XDWD0GTG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB8d8GtD6v__LsXlIXE7HL9d6J3DkrybHE',
    appId: '1:778063521937:android:09433c3d06a6c79e9b3730',
    messagingSenderId: '778063521937',
    projectId: 'streaks-cc514',
    storageBucket: 'streaks-cc514.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB8d8GtD6v__LsXlIXE7HL9d6J3DkrybHE',
    appId: '1:778063521937:ios:04e6c98971f114679b3730',
    messagingSenderId: '778063521937',
    projectId: 'streaks-cc514',
    storageBucket: 'streaks-cc514.appspot.com',
    iosBundleId: 'com.example.streaks',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB8d8GtD6v__LsXlIXE7HL9d6J3DkrybHE',
    appId: '1:778063521937:ios:04e6c98971f114679b3730',
    messagingSenderId: '778063521937',
    projectId: 'streaks-cc514',
    storageBucket: 'streaks-cc514.appspot.com',
    iosBundleId: 'com.example.streaks',
  );
}
