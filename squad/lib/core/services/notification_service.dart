import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    if (kIsWeb) return;

    // Request permissions for iOS
    if (Platform.isIOS) {
      await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received: ${message.notification?.title}');
      // You could show a local notification here if needed
    });
  }

  Future<void> updateToken(String userId) async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        await _firestore.collection('squadusers').doc(userId).update({
          'fcmToken': token,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error updating FCM token: $e');
    }
  }

  /// Note: Sending notifications directly from the client is generally discouraged for production 
  /// apps due to security risks. Usually, you'd trigger a Cloud Function.
  /// However, for this MVP, we are setting up the groundwork for receiving notifications.
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());
