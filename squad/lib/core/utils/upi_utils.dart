import 'package:url_launcher/url_launcher.dart';

class UpiUtils {
  static String buildUpiLink({
    required String upiId,
    required String payeeName,
    required double amount,
    required String note,
  }) {
    final encodedNote = Uri.encodeComponent(note);
    final encodedName = Uri.encodeComponent(payeeName);
    return 'upi://pay?pa=$upiId&pn=$encodedName&am=${amount.toStringAsFixed(2)}&cu=INR&tn=$encodedNote';
  }

  static Future<void> launchUpi({
    required String upiId,
    required String payeeName,
    required double amount,
    required String note,
  }) async {
    final link = buildUpiLink(
      upiId: upiId,
      payeeName: payeeName,
      amount: amount,
      note: note,
    );
    
    final uri = Uri.parse(link);
    try {
      final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!success) {
        throw 'Could not launch UPI app. Please ensure you have a UPI app installed.';
      }
    } catch (_) {
      throw 'Could not launch UPI app. Please ensure you have a UPI app installed.';
    }
  }
}