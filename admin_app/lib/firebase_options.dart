// Placeholder Firebase configuration for Flutter web.
// Replace with real values via `flutterfire configure` before deploying.

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
      case TargetPlatform.linux:
        return web;
      default:
        throw UnsupportedError(
            'DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment('WEB_API_KEY', defaultValue: 'CHANGE_ME'),
    appId: String.fromEnvironment('WEB_APP_ID', defaultValue: 'CHANGE_ME'),
    messagingSenderId:
        String.fromEnvironment('WEB_MESSAGING_SENDER', defaultValue: 'CHANGE_ME'),
    projectId: String.fromEnvironment('WEB_PROJECT_ID', defaultValue: 'CHANGE_ME'),
    authDomain:
        String.fromEnvironment('WEB_AUTH_DOMAIN', defaultValue: 'CHANGE_ME.firebaseapp.com'),
    storageBucket:
        String.fromEnvironment('WEB_STORAGE_BUCKET', defaultValue: 'CHANGE_ME.appspot.com'),
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment('ANDROID_API_KEY', defaultValue: 'CHANGE_ME'),
    appId: String.fromEnvironment('ANDROID_APP_ID', defaultValue: 'CHANGE_ME'),
    messagingSenderId:
        String.fromEnvironment('ANDROID_MESSAGING_SENDER', defaultValue: 'CHANGE_ME'),
    projectId: String.fromEnvironment('ANDROID_PROJECT_ID', defaultValue: 'CHANGE_ME'),
    storageBucket:
        String.fromEnvironment('ANDROID_STORAGE_BUCKET', defaultValue: 'CHANGE_ME.appspot.com'),
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment('IOS_API_KEY', defaultValue: 'CHANGE_ME'),
    appId: String.fromEnvironment('IOS_APP_ID', defaultValue: 'CHANGE_ME'),
    messagingSenderId:
        String.fromEnvironment('IOS_MESSAGING_SENDER', defaultValue: 'CHANGE_ME'),
    projectId: String.fromEnvironment('IOS_PROJECT_ID', defaultValue: 'CHANGE_ME'),
    storageBucket:
        String.fromEnvironment('IOS_STORAGE_BUCKET', defaultValue: 'CHANGE_ME.appspot.com'),
    iosClientId: String.fromEnvironment('IOS_CLIENT_ID', defaultValue: 'CHANGE_ME'),
    iosBundleId:
        String.fromEnvironment('IOS_BUNDLE_ID', defaultValue: 'com.example.rosterMaker'),
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: String.fromEnvironment('MACOS_API_KEY', defaultValue: 'CHANGE_ME'),
    appId: String.fromEnvironment('MACOS_APP_ID', defaultValue: 'CHANGE_ME'),
    messagingSenderId:
        String.fromEnvironment('MACOS_MESSAGING_SENDER', defaultValue: 'CHANGE_ME'),
    projectId: String.fromEnvironment('MACOS_PROJECT_ID', defaultValue: 'CHANGE_ME'),
    storageBucket:
        String.fromEnvironment('MACOS_STORAGE_BUCKET', defaultValue: 'CHANGE_ME.appspot.com'),
    iosClientId: String.fromEnvironment('MACOS_CLIENT_ID', defaultValue: 'CHANGE_ME'),
    iosBundleId:
        String.fromEnvironment('MACOS_BUNDLE_ID', defaultValue: 'com.example.rosterMaker'),
  );
}
