# Firebase Integration Setup Guide

## Overview
This guide covers the complete Firebase setup for the Squad app across Android, iOS, and Web platforms.

## Prerequisites
- Firebase project created at https://console.firebase.google.com
- Flutter & Dart installed
- Xcode (for iOS)
- Android Studio (for Android)

## 1. iOS Setup

### 1.1 Download GoogleService-Info.plist
1. Go to Firebase Console ? Project Settings
2. Click "Your apps" and select the iOS app
3. Download the `GoogleService-Info.plist` file
4. Open Xcode: `open ios/Runner.xcworkspace`
5. Drag & drop the plist file into the Runner folder (check "Copy items if needed")
6. Verify it's added to all targets

### 1.2 Pod Installation
```bash
cd ios
rm Podfile.lock
pod install --repo-update
cd ..
```

## 2. Android Setup

### 2.1 google-services.json is already in place
```
android/app/google-services.json ?
```

### 2.2 Setup Release Signing (FOR APP STORE RELEASE)
1. Create keystore
2. Configure signing in build.gradle.kts
3. Add key.properties to .gitignore

## 3. Web Setup
1. Add Web app in Firebase Console
2.Update firebase_options.dart with web credentials
3. Ensure authDomain is set

## 4. Testing Firebase Integration
Use FirebaseTestUtils to verify all operations work:
```dart
final testUtils = FirebaseTestUtils(
  authService: authService,
  firestoreService: firestoreService,
);
await testUtils.runAllTests();
```

## 5. Security Rules
See Firebase Console for Firestore and Auth rules configuration.
