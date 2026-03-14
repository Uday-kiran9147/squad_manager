import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../../core/theme/app_text_styles.dart";

class OtpAuthScreen extends ConsumerWidget {
  final String phoneNumber;

  const OtpAuthScreen({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otpController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Verify OTP", style: AppTextStyles.h1),
              const SizedBox(height: 12),
              Text("We sent a 6-digit code to +91 $phoneNumber",
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center),
              const SizedBox(height: 48),
              TextField(
                controller: otpController,
                decoration: const InputDecoration(
                  hintText: "000000",
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: AppTextStyles.mono,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement OTP verification
                },
                child: const Text("Verify OTP"),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // TODO: Resend OTP
                },
                child: const Text("Resend OTP"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
