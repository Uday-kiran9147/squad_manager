import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:squad/core/providers.dart';
import 'package:squad/core/theme/app_colors.dart';
import 'package:squad/core/theme/app_text_styles.dart';
import 'package:squad/features/auth/presentation/providers/auth_provider.dart' hide authStateProvider;
import 'package:squad/features/plan/models/plan.dart';
import 'package:squad/core/widgets/feedback_sheet.dart';
import 'package:squad/features/plan/providers/plan_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    final isAnonymous = user?.isAnonymous ?? false;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final plansAsync = ref.watch(userPlansProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Squad', style: AppTextStyles.h1),
            if (isAnonymous) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  'Guest',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.warning,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded),
            onPressed: () => FeedbackSheet.show(context),
            tooltip: 'Feedback',
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              if (isAnonymous) {
                _showGuestOptions(context, ref);
              } else {
                context.push('/profile');
              }
            },
            tooltip: isAnonymous ? 'Guest Options' : 'Profile',
          ),
        ],
      ),
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              Text('Error loading plans', style: AppTextStyles.body),
              const SizedBox(height: 8),
              Text(
                '$e',
                style: AppTextStyles.label,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        data: (plans) {
          if (plans.isEmpty) {
            return Column(
              children: [
                if (isAnonymous)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Welcome to Squad! 👋',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You are exploring as a guest. Sign in to sync your plans across devices.',
                          style: AppTextStyles.body.copyWith(fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => _showGuestOptions(context, ref),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(120, 36),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                backgroundColor: AppColors.surface,
                                foregroundColor: AppColors.textPrimary,
                              ),
                              child: const Text('Sign In / Up'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {
                                if (user.uid.isNotEmpty) {
                                  ref
                                      .read(planNotifierProvider.notifier)
                                      .createSamplePlan(user.uid);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(120, 36),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                              child: const Text('Try Demo Plan'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _EmptyState(
                    isGuest: isAnonymous,
                    onCreatePlan: () {
                      context.go('/home/create-plan');
                    },
                    onTryDemo: () {
                      if (user.uid.isNotEmpty) {
                        ref
                            .read(planNotifierProvider.notifier)
                            .createSamplePlan(user.uid);
                      }
                    },
                  ),
                ),
              ],
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userPlansProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: plans.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final plan = plans[index];
                return _PlanCard(
                  plan: plan,
                  onTap: () => context.go('/home/plan/${plan.planId}'),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/home/create-plan'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Shows a bottom sheet for guest users with clear options and a data-loss warning.
void _showGuestOptions(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Exploring as Guest', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text(
            'Sign up to save your plans permanently and sync them across devices. Plans created as a guest will be lost if you exit.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authNotifierProvider.notifier).signOut();
            },
            icon: const Icon(Icons.login_rounded),
            label: const Text('Sign In / Create Account'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: AppColors.divider),
            ),
            child: const Text('Continue as Guest'),
          ),
        ],
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreatePlan;
  final VoidCallback onTryDemo;
  final bool isGuest;

  const _EmptyState({
    required this.onCreatePlan,
    required this.onTryDemo,
    this.isGuest = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.group_outlined,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            Text('No plans yet', style: AppTextStyles.h1),
            const SizedBox(height: 8),
            Text(
              'Create your first plan and share it with your squad!',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onCreatePlan,
              icon: const Icon(Icons.add),
              label: const Text('Create a Plan'),
            ),
            if (isGuest) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onTryDemo,
                icon: const Icon(Icons.auto_awesome_outlined),
                label: const Text('Try a Sample Plan'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(200, 44),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Plan plan;
  final VoidCallback onTap;

  const _PlanCard({required this.plan, required this.onTap});

  String _getStatusLabel(PlanStatus status) {
    return switch (status) {
      PlanStatus.draft => 'Draft',
      PlanStatus.polling => 'Voting',
      PlanStatus.confirmed => 'Confirmed',
      PlanStatus.completed => 'Done',
    };
  }

  Color _getStatusColor(PlanStatus status) {
    return switch (status) {
      PlanStatus.draft => AppColors.textSecondary,
      PlanStatus.polling => AppColors.warning,
      PlanStatus.confirmed => AppColors.success,
      PlanStatus.completed => AppColors.textSecondary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(plan.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: const Border(
            left: BorderSide(color: AppColors.accent, width: 3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      plan.title,
                      style: AppTextStyles.h2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusLabel(plan.status),
                      style: AppTextStyles.label.copyWith(
                        color: statusColor,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              if (plan.description != null && plan.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  plan.description!,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${plan.memberIds.length} member${plan.memberIds.length == 1 ? '' : 's'}',
                    style: AppTextStyles.label,
                  ),
                  if (plan.confirmedDate != null) ...[
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('d MMM').format(plan.confirmedDate!),
                      style: AppTextStyles.label,
                    ),
                  ],
                  if (plan.location != null && plan.location!.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        plan.location!,
                        style: AppTextStyles.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
