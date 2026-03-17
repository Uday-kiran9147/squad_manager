import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'feedback';

  Future<void> submitFeedback({
    required String? userId,
    required String vibe,
    required String? comment,
  }) async {
    await _firestore.collection(_collection).add({
      'userId': userId,
      'vibe': vibe,
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(),
      'platform': getPlatform(),
    });
  }

  String getPlatform() {
    if (kIsWeb) {
      return 'Web';
    }
    return Platform.isAndroid ? 'Android' : 'iOS';
  }
}
