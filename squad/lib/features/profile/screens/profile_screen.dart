import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Center(
                  child: Text('A', style: AppTextStyles.display),
                ),
              ),
              const SizedBox(height: 16),
              Text('Alice Johnson', style: AppTextStyles.h1),
              const SizedBox(height: 8),
              Text('+91 9876543210', style: AppTextStyles.label),
              const SizedBox(height: 24),
              // Pro badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Pro Member',
                    style: AppTextStyles.label.copyWith(color: Colors.black)),
              ),
              const SizedBox(height: 32),
              ListTile(
                title: const Text('Edit Profile'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Settings'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {},
              ),
              ListTile(
                title: const Text('About'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {},
              ),
              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: () {
                  // TODO: Sign out
                },
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
