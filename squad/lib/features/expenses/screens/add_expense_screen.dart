import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_text_styles.dart';


class AddExpenseScreen extends ConsumerWidget {
  final String planId;

  const AddExpenseScreen({super.key, required this.planId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Expense Title', style: AppTextStyles.label),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'e.g., Cab fare',
                ),
              ),
              const SizedBox(height: 24),
              Text('Amount (?)', style: AppTextStyles.label),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  hintText: '0.00',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              Text('Paid By', style: AppTextStyles.label),
              const SizedBox(height: 8),
              // TODO: Dropdown to select payer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Select member', style: AppTextStyles.body),
              ),
              const SizedBox(height: 24),
              Text('Split Among', style: AppTextStyles.label),
              const SizedBox(height: 8),
              // TODO: Multi-select members
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // TODO: Add expense
                },
                child: const Text('Add Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
