import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:squad/core/models/user_model.dart';
import 'package:squad/core/providers.dart';
import 'package:squad/core/theme/app_colors.dart';
import 'package:squad/core/theme/app_text_styles.dart';
import 'package:squad/core/utils/validators.dart';
import 'package:squad/features/plan/providers/plan_provider.dart';

import 'package:squad/features/plan/models/expense.dart';

enum SplitMode { equal, exact }

class AddExpenseScreen extends ConsumerStatefulWidget {
  final String planId;
  const AddExpenseScreen({super.key, required this.planId});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String? _paidBy;
  List<String> _splitAmong = [];
  bool _initialized = false;
  ExpenseCategory _category = ExpenseCategory.other;
  SplitMode _splitMode = SplitMode.equal;
  final Map<String, TextEditingController> _exactAmountControllers = {};

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    for (var controller in _exactAmountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initDefaults(List<String> memberIds) {
    if (_initialized) return;
    _initialized = true;
    _splitAmong = List.from(memberIds);
    final currentUid = ref.read(currentUserIdProvider);
    _paidBy = memberIds.contains(currentUid) ? currentUid : memberIds.first;

    for (var id in memberIds) {
      _exactAmountControllers[id] = TextEditingController();
    }
  }

  void _distributeEqually() {
    final total = double.tryParse(_amountController.text) ?? 0.0;
    if (total <= 0 || _splitAmong.isEmpty) return;
    final share = total / _splitAmong.length;
    for (var id in _splitAmong) {
      _exactAmountControllers[id]?.text = share.toStringAsFixed(2);
    }
  }

  Future<void> _submit(List<UserModel>? members) async {
    if (!_formKey.currentState!.validate()) return;
    if (_paidBy == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select who paid')));
      return;
    }

    final payer = members?.where((m) => m.uid == _paidBy).firstOrNull;

    // Skip UPI validation for anonymous (guest) users — they have no UPI ID
    // by definition and should still be able to record expenses during exploration.
    final isCurrentUserAnonymous =
        ref.read(authStateProvider).value?.isAnonymous ?? false;

    if (!isCurrentUserAnonymous &&
        (payer == null || payer.upiId == null || payer.upiId!.trim().isEmpty)) {
      final isCurrentUser = payer?.uid == ref.read(currentUserIdProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCurrentUser
                ? 'You must add a UPI ID in your profile before adding an expense.'
                : '${payer?.displayName ?? 'The selected user'} must have a UPI ID to be added as a payer.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_splitAmong.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one person to split with'),
        ),
      );
      return;
    }

    final totalAmount = double.tryParse(_amountController.text.trim());
    if (totalAmount == null) return;

    Map<String, double>? splitAmounts;
    if (_splitMode == SplitMode.exact) {
      splitAmounts = {};
      double runningTotal = 0;
      for (var id in _splitAmong) {
        final val =
            double.tryParse(_exactAmountControllers[id]?.text ?? '0') ?? 0;
        splitAmounts[id] = val;
        runningTotal += val;
      }

      if ((runningTotal - totalAmount).abs() > 0.1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Individual shares (Rs.${runningTotal.toStringAsFixed(2)}) must sum up to the total (Rs.${totalAmount.toStringAsFixed(2)})',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    try {
      await ref
          .read(planNotifierProvider.notifier)
          .addExpense(
            planId: widget.planId,
            title: _titleController.text.trim(),
            amount: totalAmount,
            paidBy: _paidBy!,
            splitAmong: _splitAmong,
            category: _category,
            splitAmounts: splitAmounts,
          );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding expense: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(planProvider(widget.planId));
    final isLoading = ref.watch(planNotifierProvider).isLoading;
    final currentUid = ref.watch(currentUserIdProvider);

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
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'What was it for?',
                      hintText: 'e.g., Dinner, Cab, Tickets',
                    ),
                    validator: (v) => Validators.validateRequired(v, 'Title'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Amount (Rs.)',
                      hintText: '0.00',
                      prefixText: 'Rs. ',
                    ),
                    validator: Validators.validateAmount,
                  ),
                  const SizedBox(height: 16),
                  Text('Category:', style: AppTextStyles.h2),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ExpenseCategory>(
                    initialValue: _category,
                    items: ExpenseCategory.values.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _category = val);
                    },
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Paid by:', style: AppTextStyles.h2),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _paidBy,
                    items: plan.memberIds.map((id) {
                      return DropdownMenuItem(
                        value: id,
                        child: Text(memberLabel(id, members)),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _paidBy = val),
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
                        selected: {_splitMode},
                        onSelectionChanged: (val) {
                          setState(() {
                            _splitMode = val.first;
                            if (_splitMode == SplitMode.exact) {
                              _distributeEqually();
                            }
                          });
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
                      final isSelected = _splitAmong.contains(memberId);
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CheckboxListTile(
                            title: Text(memberLabel(memberId, members)),
                            value: isSelected,
                            onChanged: (checked) {
                              setState(() {
                                if (checked == true) {
                                  _splitAmong.add(memberId);
                                } else {
                                  _splitAmong.remove(memberId);
                                }
                                if (_splitMode == SplitMode.exact) {
                                  _distributeEqually();
                                }
                              });
                            },
                            activeColor: AppColors.accent,
                            contentPadding: EdgeInsets.zero,
                          ),
                          if (isSelected && _splitMode == SplitMode.exact)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 48,
                                bottom: 8,
                              ),
                              child: TextFormField(
                                controller: _exactAmountControllers[memberId],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: const InputDecoration(
                                  prefixText: 'Rs. ',
                                  isDense: true,
                                  labelText: 'Share',
                                ),
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
