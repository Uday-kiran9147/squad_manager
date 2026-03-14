class Validators {
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value.replaceAll(RegExp(r'[^\d]'), ''))) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'OTP must be 6 digits';
    }
    return null;
  }

  static String? validatePlanTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Plan title is required';
    }
    if (value.length < 3) {
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
    return null;
  }
}
