import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:squad/core/theme/app_colors.dart';
import 'package:squad/core/theme/app_text_styles.dart';
import 'package:squad/features/plan/models/poll_option.dart';
import 'package:squad/features/plan/providers/plan_provider.dart';

class ConfirmPlanScreen extends ConsumerStatefulWidget {
  final String planId;
  const ConfirmPlanScreen({super.key, required this.planId});

  @override
  ConsumerState<ConfirmPlanScreen> createState() => _ConfirmPlanScreenState();
}

class _ConfirmPlanScreenState extends ConsumerState<ConfirmPlanScreen> {
  final _venueController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _venueController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await _showDateTimePicker(context);
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<DateTime?> _showDateTimePicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null || !context.mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _confirmPlan() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }
    if (_venueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a venue')),
      );
      return;
    }

    try {
      await ref.read(planNotifierProvider.notifier).confirmPlan(
            widget.planId,
            _selectedDate!,
            _venueController.text.trim(),
          );
      if (mounted) context.go('/home/plan/${widget.planId}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error confirming plan: $e'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _selectFromPollOption(PollOption option) {
    setState(() => _selectedDate = option.dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final pollOptionsAsync = ref.watch(pollOptionsProvider(widget.planId));
    final isLoading = ref.watch(planNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Plan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Pick a date from votes:', style: AppTextStyles.h2),
            const SizedBox(height: 12),
            pollOptionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error loading options: $e'),
              data: (options) {
                if (options.isEmpty) {
                  return Text('No poll options available.',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textSecondary));
                }
                final sorted = List<PollOption>.from(options)
                  ..sort((a, b) => b.voteCount.compareTo(a.voteCount));
                return Column(
                  children: sorted.map((option) {
                    final isSelected = _selectedDate != null &&
                        _selectedDate!.isAtSameMomentAs(option.dateTime);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () => _selectFromPollOption(option),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accent.withValues(alpha: 0.15)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.divider,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  DateFormat('EEE, d MMM h:mm a')
                                      .format(option.dateTime),
                                  style: AppTextStyles.body,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.accent
                                      : AppColors.divider,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${option.voteCount} votes',
                                  style: AppTextStyles.label
                                      .copyWith(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 20),
            Text('Or pick a custom date:', style: AppTextStyles.h2),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedDate != null
                        ? AppColors.accent
                        : AppColors.divider,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate != null
                          ? DateFormat('EEE, d MMM yyyy h:mm a')
                              .format(_selectedDate!)
                          : 'Select date & time',
                      style: AppTextStyles.body.copyWith(
                        color: _selectedDate != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Final venue:', style: AppTextStyles.h2),
            const SizedBox(height: 12),
            TextFormField(
              controller: _venueController,
              decoration: const InputDecoration(
                hintText: 'e.g., Banjara Hills, Hyderabad',
                prefixIcon: Icon(Icons.place_outlined,
                    color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isLoading ? null : _confirmPlan,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Confirm Plan'),
            ),
          ],
        ),
      ),
    );
  }
}