import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:squad/core/providers.dart';
import 'package:squad/core/theme/app_colors.dart';
import 'package:squad/core/theme/app_text_styles.dart';
import 'package:squad/features/plan/models/plan.dart';
import 'package:squad/core/widgets/feedback_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(currentUserIdProvider);

    if (currentUserId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final plansAsync = ref.watch(userPlansProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Squad', style: AppTextStyles.h1),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded),
            onPressed: () => FeedbackSheet.show(context),
            tooltip: 'Feedback',
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push('/profile'),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              Text('Error loading plans', style: AppTextStyles.body),
              const SizedBox(height: 8),
              Text('$e',
                  style: AppTextStyles.label, textAlign: TextAlign.center),
            ],
          ),
        ),
        data: (plans) {
          if (plans.isEmpty) {
            return _EmptyState(onCreatePlan: () {
              context.go('/home/create-plan');
            });
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

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreatePlan;

  const _EmptyState({required this.onCreatePlan});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.group_outlined,
                size: 80, color: AppColors.textSecondary),
            const SizedBox(height: 24),
            Text('No plans yet', style: AppTextStyles.h1),
            const SizedBox(height: 8),
            Text(
              'Create your first plan and share it with your squad!',
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onCreatePlan,
              icon: const Icon(Icons.add),
              label: const Text('Create a Plan'),
            ),
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
                    child: Text(plan.title,
                        style: AppTextStyles.h2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusLabel(plan.status),
                      style: AppTextStyles.label
                          .copyWith(color: statusColor, fontSize: 11),
                    ),
                  ),
                ],
              ),
              if (plan.description != null &&
                  plan.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  plan.description!,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.people_outline,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${plan.memberIds.length} member${plan.memberIds.length == 1 ? '' : 's'}',
                    style: AppTextStyles.label,
                  ),
                  if (plan.confirmedDate != null) ...[
                    const SizedBox(width: 16),
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('d MMM').format(plan.confirmedDate!),
                      style: AppTextStyles.label,
                    ),
                  ],
                  if (plan.location != null && plan.location!.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: AppColors.textSecondary),
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