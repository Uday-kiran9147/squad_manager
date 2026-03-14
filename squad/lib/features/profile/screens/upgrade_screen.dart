import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../../core/theme/app_text_styles.dart";
import "../../../core/theme/app_colors.dart";

class UpgradeScreen extends ConsumerWidget {
  const UpgradeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upgrade to Pro"),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Unlock Premium Features", style: AppTextStyles.display),
              const SizedBox(height: 32),
              _PlanCard(
                title: "Pro",
                price: "?299",
                duration: "One-time",
                features: const [
                  "Unlimited active plans",
                  "Custom bill splits",
                  "Memory feed (photo dump)",
                  "Plan templates",
                  "Up to 20 members per plan",
                ],
                onTap: () {},
              ),
              const SizedBox(height: 24),
              _PlanCard(
                title: "Squad Pack",
                price: "?799",
                duration: "One-time for 5 friends",
                features: const [
                  "Pro for you + 4 friends",
                  "Gift Pro to 5 people total",
                  "Perfect for group hangouts",
                ],
                onTap: () {},
                isHighlighted: true,
              ),
              const SizedBox(height: 32),
              Text("Free Tier Features", style: AppTextStyles.h2),
              const SizedBox(height: 16),
              const _FeatureList([
                "Up to 3 active plans",
                "Equal bill split only",
                "Up to 8 members per plan",
                "Basic invite sharing",
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String duration;
  final List<String> features;
  final VoidCallback onTap;
  final bool isHighlighted;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.duration,
    required this.features,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.accent.withValues(alpha: 0.1) : AppColors.surface,
        border: isHighlighted
            ? Border.all(color: AppColors.accent, width: 2)
            : Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h1),
          const SizedBox(height: 8),
          Text(price, style: AppTextStyles.display.copyWith(color: AppColors.accent)),
          Text(duration, style: AppTextStyles.label),
          const SizedBox(height: 16),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(f, style: AppTextStyles.body)),
              ],
            ),
          )),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onTap,
            child: Text("Get $title"),
          ),
        ],
      ),
    );
  }
}

class _FeatureList extends StatelessWidget {
  final List<String> features;

  const _FeatureList(this.features);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: features.map((f) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            const Icon(Icons.check, color: AppColors.textSecondary, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(f, style: AppTextStyles.body)),
          ],
        ),
      )).toList(),
    );
  }
}
