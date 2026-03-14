import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../../core/theme/app_text_styles.dart";
import "../../../core/theme/app_colors.dart";

class ExpenseDetailScreen extends ConsumerWidget {
  final String planId;
  final String expenseId;

  const ExpenseDetailScreen({
    super.key,
    required this.planId,
    required this.expenseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Split Details"),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Cab fare", style: AppTextStyles.h1),
              const SizedBox(height: 8),
              Text("Total: ?500", style: AppTextStyles.h2),
              const SizedBox(height: 24),
              Text("Who paid", style: AppTextStyles.h2),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Alice", style: AppTextStyles.body),
                    Text("?500", style: AppTextStyles.body),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text("Who owes", style: AppTextStyles.h2),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Person ${index + 1}", style: AppTextStyles.body),
                          Text("?250", style: AppTextStyles.body),
                        ],
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Open UPI link
                },
                child: const Text("Pay via UPI"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
