import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:squad/features/auth/domain/models/user_model.dart';
import 'package:squad/core/providers.dart';
import 'package:squad/core/theme/app_colors.dart';
import 'package:squad/core/theme/app_text_styles.dart';
import 'package:squad/core/utils/validators.dart';
import 'package:squad/features/plan/providers/plan_provider.dart';
import 'package:squad/features/plan/models/expense.dart';
import 'package:squad/features/plan/presentation/controllers/add_expense_controller.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final String planId;
  const AddExpenseScreen({super.key, required this.planId});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _initialized = false;

  void _initDefaults(List<String> memberIds) {
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addExpenseControllerProvider.notifier).initDefaults(memberIds);
    });
  }

  Future<void> _submit(List<UserModel>? members) async {
    if (!_formKey.currentState!.validate()) return;
    
    final errorMsg = await ref
        .read(addExpenseControllerProvider.notifier)
        .submit(widget.planId, members);

    if (errorMsg != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } else {
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(planProvider(widget.planId));
    final isLoading = ref.watch(planNotifierProvider).isLoading;
    final currentUid = ref.watch(currentUserIdProvider);
    final state = ref.watch(addExpenseControllerProvider);
    final controller = ref.read(addExpenseControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: planAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (plan) {
          if (plan == null) return const Center(child: Text('Plan not found'));
          _initDefaults(plan.memberIds);

          // Resolve member display names
          final membersAsync = ref.watch(planMembersProvider(plan.memberIds));

          String memberLabel(String uid, List<UserModel>? members) {
            if (uid == currentUid) return 'You';
            final match = members?.where((m) => m.uid == uid).firstOrNull;
            return match?.displayName?.isNotEmpty == true
                ? match!.displayName!
                : 'Member ${uid.substring(0, 4)}';
          }

          final members = membersAsync.valueOrNull;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    initialValue: state.title,
                    decoration: const InputDecoration(
                      labelText: 'What was it for?',
                      hintText: 'e.g., Dinner, Cab, Tickets',
                    ),
                    onChanged: controller.updateTitle,
                    validator: (v) => Validators.validateRequired(v, 'Title'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: state.amount,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Amount (Rs.)',
                      hintText: '0.00',
                      prefixText: 'Rs. ',
                    ),
                    onChanged: controller.updateAmount,
                    validator: Validators.validateAmount,
                  ),
                  const SizedBox(height: 16),
                  Text('Category:', style: AppTextStyles.h2),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ExpenseCategory>(
                    initialValue: state.category,
                    items: ExpenseCategory.values.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) controller.updateCategory(val);
                    },
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Paid by:', style: AppTextStyles.h2),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: state.paidBy,
                    items: plan.memberIds.map((id) {
                      return DropdownMenuItem(
                        value: id,
                        child: Text(memberLabel(id, members)),
                      );
                    }).toList(),
                    onChanged: controller.updatePaidBy,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Split among:', style: AppTextStyles.h2),
                      SegmentedButton<SplitMode>(
                        segments: const [
                          ButtonSegment(
                            value: SplitMode.equal,
                            label: Text('Equal'),
                          ),
                          ButtonSegment(
                            value: SplitMode.exact,
                            label: Text('Exact'),
                          ),
                        ],
                        selected: {state.splitMode},
                        onSelectionChanged: (val) {
                          controller.updateSplitMode(val.first);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: plan.memberIds.length,
                    itemBuilder: (context, index) {
                      final memberId = plan.memberIds[index];
                      final isSelected = state.splitAmong.contains(memberId);
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CheckboxListTile(
                            title: Text(memberLabel(memberId, members)),
                            value: isSelected,
                            onChanged: (checked) {
                              controller.toggleSplitMember(memberId);
                            },
                            activeColor: AppColors.accent,
                            contentPadding: EdgeInsets.zero,
                          ),
                          if (isSelected && state.splitMode == SplitMode.exact)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 48,
                                bottom: 8,
                              ),
                              child: TextFormField(
                                initialValue: state.exactAmounts[memberId],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: const InputDecoration(
                                  prefixText: 'Rs. ',
                                  isDense: true,
                                  labelText: 'Share',
                                ),
                                onChanged: (val) => controller.updateExactAmount(memberId, val),
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: isLoading ? null : () => _submit(members),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Add Expense'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
