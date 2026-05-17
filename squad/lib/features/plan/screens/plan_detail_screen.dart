import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:squad/core/models/user_model.dart';
import 'package:squad/core/providers.dart';
import 'package:squad/core/theme/app_colors.dart';
import 'package:squad/core/theme/app_text_styles.dart';
import 'package:squad/core/utils/upi_utils.dart';
import 'package:squad/features/plan/models/expense.dart';
import 'package:squad/features/plan/models/plan.dart';
import 'package:squad/features/plan/models/poll_option.dart';
import 'package:squad/features/plan/models/itinerary_item.dart';
import 'package:squad/features/plan/models/plan_balance.dart';
import 'package:squad/features/plan/providers/plan_provider.dart';
import 'package:squad/core/utils/calendar_utils.dart';


class PlanDetailScreen extends ConsumerWidget {
  final String planId;
  const PlanDetailScreen({super.key, required this.planId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(planStreamProvider(planId));
    final pollOptionsAsync = ref.watch(pollOptionsProvider(planId));
    final expensesAsync = ref.watch(expensesProvider(planId));
    final currentUserId = ref.watch(currentUserIdProvider);

    // Surface mutation errors globally for this screen
    ref.listen<AsyncValue<void>>(planNotifierProvider, (_, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.error}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return planAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Plan')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (plan) {
        if (plan == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Plan')),
            body: const Center(child: Text('Plan not found')),
          );
        }

        final isOrganiser = currentUserId == plan.createdBy;
        final membersAsync = ref.watch(planMembersProvider(plan.memberIds));
        final members = membersAsync.valueOrNull;

        return Scaffold(
          appBar: AppBar(
            title: Text(plan.title, overflow: TextOverflow.ellipsis),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {
                  final link = 'https://townsquaredotin.web.app/invite/$planId';
                  Share.share(
                    'Join our squad "${plan.title}" on Squad App!\n$link',
                  );
                },
              ),
              if (isOrganiser)
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      _showEditPlanDialog(context, ref, plan);
                    } else if (value == 'complete') {
                      await ref
                          .read(planNotifierProvider.notifier)
                          .completePlan(planId);
                    } else if (value == 'delete') {
                      final confirmed = await _confirmDelete(
                        context,
                        'Delete plan "${plan.title}"? This cannot be undone.',
                      );
                      if (confirmed && context.mounted) {
                        await ref
                            .read(planNotifierProvider.notifier)
                            .deletePlan(planId);
                        if (context.mounted) context.go('/home');
                      }
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit Plan'),
                    ),
                    if (plan.status == PlanStatus.confirmed)
                      const PopupMenuItem(
                        value: 'complete',
                        child: Text('Mark Complete'),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete Plan',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _PlanStatusSection(plan: plan),
              const SizedBox(height: 12),
              _RSVPSection(
                plan: plan,
                currentUserId: currentUserId,
                members: members,
                ref: ref,
              ),
              const SizedBox(height: 20),
              _SectionHeader(
                title: 'Date Poll',
                icon: Icons.how_to_vote_outlined,
                trailing: isOrganiser && plan.status == PlanStatus.polling
                    ? TextButton(
                        onPressed: () =>
                            context.go('/home/plan/$planId/confirm'),
                        child: const Text('Confirm Plan'),
                      )
                    : null,
              ),
              pollOptionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
                data: (options) => _PollSection(
                  planId: planId,
                  options: options,
                  currentUserId: currentUserId,
                  plan: plan,
                  ref: ref,
                  isOrganiser: isOrganiser,
                ),
              ),
              const SizedBox(height: 20),
              _SectionHeader(
                title: 'Expenses',
                icon: Icons.receipt_long_outlined,
                trailing: TextButton(
                  onPressed: () => context.go('/home/plan/$planId/add-expense'),
                  child: const Text('Add'),
                ),
              ),
              expensesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
                data: (expenses) {
                  final balance = ref.watch(planBalanceProvider(planId));
                  return Column(
                    children: [
                      if (expenses.isNotEmpty) ...[
                        _BalanceSummary(balance: balance, members: members),
                        const SizedBox(height: 12),
                      ],
                      _ExpenseSection(
                        expenses: expenses,
                        currentUserId: currentUserId,
                        planId: planId,
                        planTitle: plan.title,
                        ref: ref,
                        members: members,
                        isOrganiser: isOrganiser,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              if (plan.status == PlanStatus.confirmed ||
                  plan.status == PlanStatus.completed) ...[
                _SectionHeader(
                  title: 'Itinerary',
                  icon: Icons.map_outlined,
                  trailing: isOrganiser
                      ? TextButton(
                          onPressed: () =>
                              _showAddItineraryDialog(context, ref, planId),
                          child: const Text('Add'),
                        )
                      : null,
                ),
                ref
                    .watch(itineraryProvider(planId))
                    .when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error: $e'),
                      data: (items) => _ItinerarySection(
                        items: items,
                        planId: planId,
                        isOrganiser: isOrganiser,
                        ref: ref,
                      ),
                    ),
                const SizedBox(height: 32),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: Text(message),
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
        ) ??
        false;
  }

  void _showEditPlanDialog(BuildContext context, WidgetRef ref, Plan plan) {
    final titleC = TextEditingController(text: plan.title);
    final descC = TextEditingController(text: plan.description ?? '');
    final locC = TextEditingController(text: plan.location ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleC,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descC,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: locC,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(planNotifierProvider.notifier)
                  .updatePlan(
                    plan.planId,
                    title: titleC.text.trim(),
                    description: descC.text.trim(),
                    location: locC.text.trim(),
                  );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddItineraryDialog(
    BuildContext context,
    WidgetRef ref,
    String planId,
  ) {
    final titleC = TextEditingController();
    final locC = TextEditingController();
    DateTime pickedTime = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add stop to itinerary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleC,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: locC,
                decoration: const InputDecoration(
                  labelText: 'Store/Venue Location',
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('Time: ${DateFormat('h:mm a').format(pickedTime)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(pickedTime),
                  );
                  if (time != null) {
                    setDialogState(() {
                      pickedTime = DateTime(
                        pickedTime.year,
                        pickedTime.month,
                        pickedTime.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (titleC.text.isEmpty) return;
                Navigator.pop(ctx);
                await ref
                    .read(planNotifierProvider.notifier)
                    .addItineraryItem(
                      planId,
                      ItineraryItem(
                        itemId: '',
                        title: titleC.text.trim(),
                        location: locC.text.trim(),
                        time: pickedTime,
                      ),
                    );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _PlanStatusSection extends StatelessWidget {
  final Plan plan;
  const _PlanStatusSection({required this.plan});

  String _statusLabel(PlanStatus s) => switch (s) {
    PlanStatus.draft => 'Draft',
    PlanStatus.polling => 'Voting in progress',
    PlanStatus.confirmed => 'Confirmed',
    PlanStatus.completed => 'Completed',
  };

  Color _statusColor(PlanStatus s) => switch (s) {
    PlanStatus.draft => AppColors.textSecondary,
    PlanStatus.polling => AppColors.warning,
    PlanStatus.confirmed => AppColors.success,
    PlanStatus.completed => AppColors.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(plan.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusLabel(plan.status),
              style: AppTextStyles.label.copyWith(color: statusColor),
            ),
          ),
          if (plan.description != null && plan.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(plan.description!, style: AppTextStyles.body),
          ],
          if (plan.location != null && plan.location!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(plan.location!, style: AppTextStyles.body),
              ],
            ),
          ],
          if (plan.confirmedDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.event_outlined,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormat('EEEE, d MMMM yyyy').format(plan.confirmedDate!),
                  style: AppTextStyles.body.copyWith(color: AppColors.success),
                ),
              ],
            ),
          ],
          if (plan.confirmedVenue != null &&
              plan.confirmedVenue!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.place_outlined,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 6),
                Text(
                  plan.confirmedVenue!,
                  style: AppTextStyles.body.copyWith(color: AppColors.success),
                ),
              ],
            ),
          ],
          if (plan.status == PlanStatus.confirmed ||
              plan.status == PlanStatus.completed) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                final success = await CalendarUtils.addToCalendar(plan);
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not open calendar. Make sure a calendar app is installed.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              label: const Text('Add to Calendar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.success,
                side: BorderSide(color: AppColors.success.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(
                Icons.people_outline,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                '${plan.memberIds.length} member${plan.memberIds.length == 1 ? "" : "s"}',
                style: AppTextStyles.label,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RSVPSection extends StatelessWidget {
  final Plan plan;
  final String? currentUserId;
  final List<UserModel>? members;
  final WidgetRef ref;

  const _RSVPSection({
    required this.plan,
    required this.currentUserId,
    required this.members,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    if (plan.status != PlanStatus.confirmed) return const SizedBox.shrink();

    final rsvps = plan.rsvps;
    final goingCount = rsvps.values.where((s) => s == 'going').length;
    final maybeCount = rsvps.values.where((s) => s == 'maybe').length;
    final notGoingCount = rsvps.values.where((s) => s == 'declined').length;
    final myStatus = currentUserId != null ? rsvps[currentUserId] : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.event_available,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text('RSVPs', style: AppTextStyles.h2),
              const Spacer(),
              Text(
                '$goingCount Going · $maybeCount Maybe · $notGoingCount Not Going',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '"Répondez s\'il vous plaît" - which translates to "Please respond" or "Please reply"',
            style: AppTextStyles.label.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _RSVPButton(
                  label: 'Going',
                  isSelected: myStatus == 'going',
                  color: AppColors.success,
                  onTap: () => _updateRSVP('going'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _RSVPButton(
                  label: 'Maybe',
                  isSelected: myStatus == 'maybe',
                  color: AppColors.warning,
                  onTap: () => _updateRSVP('maybe'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _RSVPButton(
                  label: 'No',
                  isSelected: myStatus == 'declined',
                  color: AppColors.error,
                  onTap: () => _updateRSVP('declined'),
                ),
              ),
            ],
          ),
          if (members != null && rsvps.isNotEmpty) ...[
            const Divider(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: members!.map((user) {
                final status = rsvps[user.uid];
                if (status == null) return const SizedBox.shrink();

                final statusColor = status == 'going'
                    ? AppColors.success
                    : (status == 'maybe' ? AppColors.warning : AppColors.error);

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    user.displayName ?? 'Friend',
                    style: AppTextStyles.label.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _updateRSVP(String status) {
    if (currentUserId == null) return;
    ref
        .read(planNotifierProvider.notifier)
        .updateRSVP(plan.planId, currentUserId!, status);
  }
}

class _RSVPButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _RSVPButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : AppColors.divider),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  const _SectionHeader({
    required this.title,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: AppTextStyles.h2)),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _PollSection extends StatelessWidget {
  final String planId;
  final List<PollOption> options;
  final String? currentUserId;
  final Plan plan;
  final WidgetRef ref;
  final bool isOrganiser;

  const _PollSection({
    required this.planId,
    required this.options,
    required this.currentUserId,
    required this.plan,
    required this.ref,
    required this.isOrganiser,
  });

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'No date options yet.',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      );
    }
    final maxVotes = options.isEmpty
        ? 0
        : options.map((o) => o.voteCount).reduce((a, b) => a > b ? a : b);

    return Column(
      children: options.map((option) {
        final hasVoted =
            currentUserId != null && option.voterIds.contains(currentUserId);
        final isWinner =
            plan.status == PlanStatus.confirmed &&
            option.voteCount == maxVotes &&
            maxVotes > 0;

        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Dismissible(
            key: Key(option.optionId),
            direction: isOrganiser && plan.status == PlanStatus.polling
                ? DismissDirection.endToStart
                : DismissDirection.none,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
            confirmDismiss: (_) async => await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Remove date option?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text(
                      'Remove',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
            onDismissed: (_) async {
              await ref
                  .read(planServiceProvider)
                  .deletePollOption(planId, option.optionId);
            },
            child: GestureDetector(
              onTap: plan.status == PlanStatus.polling && currentUserId != null
                  ? () async {
                      if (currentUserId != null) {
                        await ref
                            .read(planNotifierProvider.notifier)
                            .voteOnOption(
                              planId,
                              option.optionId,
                              currentUserId!,
                            );
                      }
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: hasVoted
                      ? AppColors.accent.withValues(alpha: 0.15)
                      : isWinner
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: hasVoted
                        ? AppColors.accent
                        : isWinner
                        ? AppColors.success
                        : AppColors.divider,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat('EEE, d MMM h:mm a').format(option.dateTime),
                        style: AppTextStyles.body.copyWith(
                          color: hasVoted || isWinner
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: hasVoted
                            ? AppColors.accent
                            : isWinner
                            ? AppColors.success
                            : AppColors.divider,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${option.voteCount}',
                        style: AppTextStyles.label.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ItinerarySection extends StatelessWidget {
  final List<ItineraryItem> items;
  final String planId;
  final bool isOrganiser;
  final WidgetRef ref;

  const _ItinerarySection({
    required this.items,
    required this.planId,
    required this.isOrganiser,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'No stops added yet.',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Dismissible(
            key: Key(item.itemId),
            direction: isOrganiser
                ? DismissDirection.endToStart
                : DismissDirection.none,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
            onDismissed: (_) async {
              await ref
                  .read(planNotifierProvider.notifier)
                  .deleteItineraryItem(planId, item.itemId);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: item.isCompleted,
                    onChanged: (val) {
                      if (val != null) {
                        ref
                            .read(planNotifierProvider.notifier)
                            .toggleItineraryItemCompletion(
                              planId,
                              item.itemId,
                              val,
                            );
                      }
                    },
                    activeColor: AppColors.accent,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration: item.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: item.isCompleted
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (item.location != null && item.location!.isNotEmpty)
                          Text(item.location!, style: AppTextStyles.label),
                      ],
                    ),
                  ),
                  Text(
                    DateFormat('h:mm a').format(item.time),
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ExpenseSection extends StatelessWidget {
  final List<Expense> expenses;
  final String? currentUserId;
  final String planId;
  final String planTitle;
  final WidgetRef ref;
  final List<UserModel>? members;
  final bool isOrganiser;

  const _ExpenseSection({
    required this.expenses,
    required this.currentUserId,
    required this.planId,
    required this.planTitle,
    required this.ref,
    required this.members,
    required this.isOrganiser,
  });

  String _memberName(String uid) {
    if (uid == currentUserId) return 'You';
    final match = members?.where((m) => m.uid == uid).firstOrNull;
    return match?.displayName?.isNotEmpty == true
        ? match!.displayName!
        : 'Member ${uid.substring(0, 4)}';
  }

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'No expenses yet.',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      );
    }
    return Column(
      children: expenses.map((expense) {
        final isSettled =
            currentUserId != null && expense.settledBy.contains(currentUserId);
        final isPayer = currentUserId == expense.paidBy;

        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Dismissible(
            key: Key(expense.expenseId),
            direction: isOrganiser
                ? DismissDirection.endToStart
                : DismissDirection.none,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
            confirmDismiss: (_) async => await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete expense?'),
                content: Text(
                  'Remove "${expense.title}" (Rs.${expense.amount.toStringAsFixed(2)})?',
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
            ),
            onDismissed: (_) async {
              await ref
                  .read(planNotifierProvider.notifier)
                  .deleteExpense(planId, expense.expenseId);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      isSettled ? Icons.check_circle : Icons.receipt_outlined,
                      color: isSettled
                          ? AppColors.success
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.title,
                            style: AppTextStyles.body.copyWith(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            expense.splitAmounts.isNotEmpty
                                ? 'Custom split · paid by ${_memberName(expense.paidBy)}'
                                : 'Rs.${expense.perPersonAmount.toStringAsFixed(2)}/person · paid by ${_memberName(expense.paidBy)}',
                            style: AppTextStyles.label,
                          ),
                          if (expense.splitAmounts.containsKey(currentUserId))
                            Text(
                              'Your share: Rs.${expense.splitAmounts[currentUserId]!.toStringAsFixed(2)}',
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rs.${expense.amount.toStringAsFixed(2)}',
                          style: AppTextStyles.mono.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (!isPayer && !isSettled && currentUserId != null)
                          GestureDetector(
                            onTap: () async {
                              try {
                                if (currentUserId != null) {
                                  await ref
                                      .read(planNotifierProvider.notifier)
                                      .markExpenseSettled(
                                        planId,
                                        expense.expenseId,
                                        currentUserId!,
                                      );
                                }

                                // Look up payer's UPI ID from the members list
                                final payer = members
                                    ?.where((m) => m.uid == expense.paidBy)
                                    .firstOrNull;
                                final payerUpi = payer?.upiId;
                                if (payerUpi != null && payerUpi.isNotEmpty) {
                                  try {
                                    await UpiUtils.launchUpi(
                                      upiId: payerUpi,
                                      payeeName: _memberName(expense.paidBy),
                                      amount: expense.perPersonAmount,
                                      note:
                                          'Squad: $planTitle - ${expense.title}',
                                    );
                                  } catch (_) {
                                    // UPI launch failure is non-fatal
                                  }
                                } else if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${_memberName(expense.paidBy)} hasn\'t added a UPI ID yet.',
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
                            },
                            child: Text(
                              'TAP TO PAY',
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _BalanceSummary extends StatelessWidget {
  final PlanBalance balance;
  final List<UserModel>? members;

  const _BalanceSummary({required this.balance, required this.members});

  String _memberName(String uid) {
    if (members == null) return 'Member ${uid.substring(0, 4)}';
    final match = members!.where((m) => m.uid == uid).firstOrNull;
    return match?.displayName?.isNotEmpty == true
        ? match!.displayName!
        : 'Member ${uid.substring(0, 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final net = balance.netBalance;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: AppColors.accent, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('NET BALANCE', style: AppTextStyles.label),
              Text(
                '${net >= 0 ? "+" : "-"} Rs.${net.abs().toStringAsFixed(2)}',
                style: AppTextStyles.h2.copyWith(
                  color: net >= 0 ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            net >= 0 ? 'People owe you money' : 'You owe money to others',
            style: AppTextStyles.body.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          if (balance.peerBalances.isNotEmpty) ...[
            const Divider(height: 24, color: AppColors.divider),
            ...balance.peerBalances.entries.map((entry) {
              final peerId = entry.key;
              final peerBal = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_memberName(peerId), style: AppTextStyles.body),
                    Text(
                      '${peerBal >= 0 ? "+" : "-"} Rs.${peerBal.abs().toStringAsFixed(2)}',
                      style: AppTextStyles.mono.copyWith(
                        color: peerBal >= 0
                            ? AppColors.success
                            : AppColors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
