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

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _initDefaults(List<String> memberIds) {
    if (_initialized) return;
    _initialized = true;
    _splitAmong = List.from(memberIds);
    final currentUid = ref.read(currentUserIdProvider);
    _paidBy = memberIds.contains(currentUid) ? currentUid : memberIds.first;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_paidBy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select who paid')),
      );
      return;
    }
    if (_splitAmong.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one person to split with')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) return;

    try {
      await ref.read(planNotifierProvider.notifier).addExpense(
            planId: widget.planId,
            title: _titleController.text.trim(),
            amount: amount,
            paidBy: _paidBy!,
            splitAmong: _splitAmong,
            category: _category,
          );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error adding expense: $e'),
              backgroundColor: AppColors.error),
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
          final membersAsync =
              ref.watch(planMembersProvider(plan.memberIds));

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
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 12)),
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                  ),
                  const SizedBox(height: 24),
                  Text('Split among:', style: AppTextStyles.h2),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: plan.memberIds.length,
                    itemBuilder: (context, index) {
                      final memberId = plan.memberIds[index];
                      final isSelected = _splitAmong.contains(memberId);
                      return CheckboxListTile(
                        title: Text(memberLabel(memberId, members)),
                        value: isSelected,
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _splitAmong.add(memberId);
                            } else {
                              _splitAmong.remove(memberId);
                            }
                          });
                        },
                        activeColor: AppColors.accent,
                        contentPadding: EdgeInsets.zero,
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
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