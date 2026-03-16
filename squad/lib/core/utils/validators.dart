class Validators {
  // optional
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length != 10) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  static String? validatePlanTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Plan title is required';
    }
    if (value.trim().length < 3) {
      return 'Title must be at least 3 characters';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    if (double.tryParse(value) == null) {
      return 'Enter a valid amount';
    }
    if (double.parse(value) <= 0) {
      return 'Amount must be greater than 0';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateUpiId(String? value) {
    if (value == null || value.isEmpty) return null; // Optional
    final upiRegex = RegExp(r'^[\w.-]+@[\w.-]+$');
    if (!upiRegex.hasMatch(value) && value.isNotEmpty) {
      return 'Enter a valid UPI ID (e.g., name@bank)';
    }
    return null;
  }
}
