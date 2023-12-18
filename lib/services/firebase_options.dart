// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCB7Ms8unVy9dna_A7RXGpEIit-FElJSBg',
    appId: '1:531013255278:web:b292b90e5a318c08d2e67f',
    messagingSenderId: '531013255278',
    projectId: 'to-do-list-2b3ff',
    authDomain: 'to-do-list-2b3ff.firebaseapp.com',
    storageBucket: 'to-do-list-2b3ff.appspot.com',
    measurementId: 'G-H4M2Y0G18V',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAjzw3tAIZ6nMzC5-CGVGGUFd8-lDDmPdQ',
    appId: '1:531013255278:android:900f00dc723dcef7d2e67f',
    messagingSenderId: '531013255278',
    projectId: 'to-do-list-2b3ff',
    storageBucket: 'to-do-list-2b3ff.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBgSE5rODq7rDlpoc6x17KDJUSsrRK67Es',
    appId: '1:531013255278:ios:517653499f3a1dc8d2e67f',
    messagingSenderId: '531013255278',
    projectId: 'to-do-list-2b3ff',
    storageBucket: 'to-do-list-2b3ff.appspot.com',
    iosBundleId: 'com.example.todoList',
  );
}
