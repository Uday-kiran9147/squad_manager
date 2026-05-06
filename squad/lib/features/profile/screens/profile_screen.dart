import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:squad/core/providers.dart';
import 'package:squad/core/theme/app_colors.dart';
import 'package:squad/core/theme/app_text_styles.dart';
import 'package:squad/core/utils/validators.dart';
import 'package:squad/features/auth/providers/auth_provider.dart'
    hide authStateProvider, authServiceProvider;
import 'package:squad/features/profile/providers/profile_provider.dart';
import 'package:squad/core/widgets/feedback_sheet.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _upiController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _prefilled = false;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = 'v${packageInfo.version}+${packageInfo.buildNumber}';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _upiController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _prefillIfNeeded() {
    if (_prefilled) return;
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    _prefilled = true;
    _nameController.text = user.displayName ?? '';
    _upiController.text = user.upiId ?? '';
    _phoneController.text = user.phone ?? '';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref
          .read(profileNotifierProvider.notifier)
          .updateProfile(
            displayName: _nameController.text.trim(),
            upiId: _upiController.text.trim().toLowerCase(),
            phone: _phoneController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account and all your data. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(profileNotifierProvider.notifier).deleteAccount();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting account: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAnonymous =
        ref.watch(authStateProvider).value?.isAnonymous ?? false;

    // Guest users have no real profile — show a prompt to sign up instead
    // of exposing a form that would write data for a throwaway account.
    if (isAnonymous) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () => ref.read(authServiceProvider).signOut(),
              tooltip: 'Exit Guest Mode',
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_off_outlined,
                  size: 80,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 24),
                Text('You\'re a Guest', style: AppTextStyles.h1),
                const SizedBox(height: 12),
                Text(
                  'Create a free account to save your profile, sync plans across devices, and collaborate with friends.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(authNotifierProvider.notifier).signOut();
                  },
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Sign In / Create Account'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final userAsync = ref.watch(currentUserProvider);
    final isSaving = ref.watch(profileNotifierProvider).isLoading;

    // Prefill form when user data first arrives
    ref.listen(currentUserProvider, (_, next) {
      if (!_prefilled && next.hasValue && next.value != null) {
        _prefillIfNeeded();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(authServiceProvider).signOut(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not found'));
          }
          _prefillIfNeeded();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          width: 4,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.surface,
                        backgroundImage: user.photoURL != null
                            ? CachedNetworkImageProvider(user.photoURL!)
                            : null,
                        child: user.photoURL == null
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: AppColors.accent,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      user.email ?? 'Guest User',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildFieldLabel('Display Name'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    style: AppTextStyles.body,
                    decoration: const InputDecoration(
                      hintText: 'Your name',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (v) => Validators.validateRequired(v, 'Name'),
                  ),
                  const SizedBox(height: 24),
                  _buildFieldLabel('UPI ID (For bill splitting)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _upiController,
                    style: AppTextStyles.body,
                    decoration: const InputDecoration(
                      hintText: 'e.g., uday@okaxis',
                      prefixIcon: Icon(Icons.payment_rounded),
                    ),
                    validator: Validators.validateUpiId,
                  ),
                  const SizedBox(height: 24),
                  _buildFieldLabel('Phone Number'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    style: AppTextStyles.body,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: '10-digit mobile number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: Validators.validatePhoneNumber,
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 32),
                  const SizedBox(height: 32),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 24),
                  _buildFieldLabel('How\'s your experience?'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.surface,
                          AppColors.surface.withValues(alpha: 0.5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'We building Squad for you and your friends.',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Share your thoughts and help us make it better together.',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => FeedbackSheet.show(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent.withValues(
                              alpha: 0.1,
                            ),
                            foregroundColor: AppColors.accent,
                            elevation: 0,
                            side: const BorderSide(color: AppColors.accent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Share Feedback'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 16),
                  _buildFieldLabel('Danger Zone'),
                  const SizedBox(height: 12),
                  // Delete Account is only available for real (non-anonymous) accounts.
                  // Anonymous users cannot re-authenticate so the Firebase delete
                  // call would throw requires-recent-login.
                  if (!isAnonymous)
                    OutlinedButton.icon(
                      onPressed: isSaving ? null : _deleteAccount,
                      icon: const Icon(
                        Icons.delete_forever_rounded,
                        color: AppColors.error,
                      ),
                      label: const Text(
                        'Delete Account',
                        style: TextStyle(color: AppColors.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  if (_appVersion.isNotEmpty)
                    Center(
                      child: Text(
                        'Squad $_appVersion',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.label.copyWith(
        color: AppColors.accent,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }
}