import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

/// Firebase configuration for all platforms
///
/// SECURITY NOTE:
/// In production, consider moving these credentials to:
/// - Environment variables
/// - Firebase Remote Config
/// - Cloud Functions with restricted access
/// - CI/CD secrets management
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return ios;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  /// iOS Firebase Configuration
  /// Get from: Firebase Console ? Project Settings ? GoogleService-Info.plist
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    iosBundleId: 'YOUR_IOS_BUNDLE_ID',
  );

  /// Android Firebase Configuration
  /// Get from: Firebase Console ? Project Settings
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  );

  /// Web Firebase Configuration
  /// Get from: Firebase Console ? Project Settings ? Web app config
  /// TODO: Fill in your web Firebase credentials
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    authDomain: 'YOUR_AUTH_DOMAIN',
  );
}
