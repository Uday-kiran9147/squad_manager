import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:squad/core/providers.dart';
import 'package:squad/core/theme/app_colors.dart';
import 'package:squad/core/theme/app_text_styles.dart';
import 'package:squad/features/plan/providers/plan_provider.dart';
import 'package:squad/features/auth/providers/auth_provider.dart';

class InviteHandlerScreen extends ConsumerStatefulWidget {
  final String planId;
  const InviteHandlerScreen({super.key, required this.planId});

  @override
  ConsumerState<InviteHandlerScreen> createState() =>
      _InviteHandlerScreenState();
}

class _InviteHandlerScreenState extends ConsumerState<InviteHandlerScreen> {
  Future<void> _joinPlan() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to join the plan')),
      );
      context.go('/auth/email');
      return;
    }

    try {
      await ref
          .read(planNotifierProvider.notifier)
          .addMemberToPlan(widget.planId, userId);
      if (mounted) context.go('/home/plan/${widget.planId}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error joining plan: $e'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _continueAsGuest() async {
    final name = await _showGuestNameDialog();
    if (name == null || name.isEmpty) return;

    try {
      await ref.read(authNotifierProvider.notifier).signInAnonymously(name);
      await _joinPlan();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error joining as guest: $e'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<String?> _showGuestNameDialog() async {
    String name = '';
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter your name'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Your name'),
          onChanged: (value) => name = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, name),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(planProvider(widget.planId));
    final currentUserId = ref.watch(currentUserIdProvider);
    final isLoading = ref.watch(planNotifierProvider).isLoading;

    return Scaffold(
      body: Center(
        child: planAsync.when(
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Invalid or expired invite', style: AppTextStyles.h2),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go Home'),
              ),
            ],
          ),
          data: (plan) {
            if (plan == null) {
              return Text('Plan not found', style: AppTextStyles.h2);
            }

            final isAlreadyMember = plan.memberIds.contains(currentUserId);
            if (isAlreadyMember) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/home/plan/${widget.planId}');
              });
              return const SizedBox();
            }

            return Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.celebration_outlined,
                      size: 80, color: AppColors.accent),
                  const SizedBox(height: 24),
                  Text("You're invited to", style: AppTextStyles.body),
                  const SizedBox(height: 8),
                  Text(plan.title,
                      style: AppTextStyles.h1,
                      textAlign: TextAlign.center),
                  if (plan.description != null &&
                      plan.description!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      plan.description!,
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _joinPlan,
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white)
                          : const Text('Join Squad Plan'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: isLoading ? null : _continueAsGuest,
                      child: const Text('Continue as Guest'),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Not now'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}