import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:squad/core/providers.dart';
import 'package:squad/core/theme/app_colors.dart';
import 'package:squad/core/theme/app_text_styles.dart';
import 'package:squad/core/utils/validators.dart';
import 'package:squad/features/plan/models/plan.dart';
import 'package:squad/features/plan/providers/plan_provider.dart';

class CreatePlanScreen extends ConsumerStatefulWidget {
  const CreatePlanScreen({super.key});

  @override
  ConsumerState<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends ConsumerState<CreatePlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  final List<DateTime> _dateOptions = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _addDateOption() async {
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
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 19, minute: 0),
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
    if (time == null || !mounted) return;

    setState(() {
      _dateOptions
          .add(DateTime(date.year, date.month, date.day, time.hour, time.minute));
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateOptions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please add at least one date option for the poll')),
      );
      return;
    }

    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    final plan = Plan(
      planId: '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      createdBy: user.uid,
      status: PlanStatus.polling,
      location: _locationController.text.trim(),
      memberIds: [user.uid],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final planId = await ref
          .read(planNotifierProvider.notifier)
          .createPlan(plan, _dateOptions);
      if (mounted) context.go('/home/plan/$planId');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final planState = ref.watch(planNotifierProvider);
    final isLoading = planState.isLoading;

    // Listen for errors from notifier and surface as snackbar
    ref.listen<AsyncValue<void>>(planNotifierProvider, (_, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${next.error}'),
              backgroundColor: AppColors.error),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Create Plan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('The Basics', style: AppTextStyles.h2),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Plan Title',
                  hintText: 'e.g., Goa Trip 🌴',
                ),
                validator: (v) => Validators.validatePlanTitle(v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: "What's the vibe?",
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (Optional)',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: Text('Date Options', style: AppTextStyles.h2)),
                  IconButton(
                    onPressed: _addDateOption,
                    icon: const Icon(Icons.add_circle_outline,
                        color: AppColors.accent),
                  ),
                ],
              ),
              Text('Add options for your friends to vote on',
                  style: AppTextStyles.label),
              const SizedBox(height: 12),
              if (_dateOptions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.calendar_month,
                          color: AppColors.textSecondary, size: 40),
                      const SizedBox(height: 12),
                      Text('No dates added yet',
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.textSecondary)),
                      TextButton(
                          onPressed: _addDateOption,
                          child: const Text('Add a Date')),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _dateOptions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final date = _dateOptions[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event,
                              color: AppColors.accent, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              DateFormat('EEE, d MMM — h:mm a').format(date),
                              style: AppTextStyles.body,
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                setState(() => _dateOptions.removeAt(index)),
                            icon: const Icon(Icons.remove_circle_outline,
                                color: AppColors.error, size: 20),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Create & Share'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}