import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';

class PhoneAuthScreen extends ConsumerWidget {
  const PhoneAuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phoneController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome to Squad', style: AppTextStyles.display),
              const SizedBox(height: 12),
              Text('Plan together, the easy way',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center),
              const SizedBox(height: 48),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  hintText: 'Enter your mobile number',
                  prefixText: '+91 ',
                  prefixStyle: AppTextStyles.body,
                ),
                keyboardType: TextInputType.phone,
                maxLength: 10,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement phone auth
                },
                child: const Text('Send OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
