class UpiUtils {
  static String buildUpiLink({
    required String upiId,
    required String payeeName,
    required double amount,
    required String note,
  }) {
    final encoded = Uri.encodeComponent(note);
    return 'upi://pay?pa=\&pn=\&am=\&cu=INR&tn=\';
  }

  static bool isValidUpiId(String upiId) {
    final regex = RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z]{3,}$');
    return regex.hasMatch(upiId);
  }
}
