import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:squad/core/providers.dart';
import 'package:squad/core/theme/app_colors.dart';
import 'package:squad/core/theme/app_text_styles.dart';
import 'package:squad/features/plan/models/itinerary_item.dart';
import 'package:squad/features/plan/models/plan.dart';
import 'package:squad/features/plan/providers/plan_provider.dart';

class AIItineraryDialog extends ConsumerStatefulWidget {
  final Plan plan;
  const AIItineraryDialog({super.key, required this.plan});

  static Future<void> show(BuildContext context, Plan plan) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AIItineraryDialog(plan: plan),
    );
  }

  @override
  ConsumerState<AIItineraryDialog> createState() => _AIItineraryDialogState();
}

class _AIItineraryDialogState extends ConsumerState<AIItineraryDialog> {
  List<ItineraryItem>? _suggestions;
  bool _isLoading = true;
  final Set<int> _selectedIndices = {};

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    setState(() => _isLoading = true);
    try {
      final suggestions = await ref.read(aiServiceProvider).generateItinerarySuggestions(widget.plan);
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _selectedIndices.clear();
          // Select all by default
          for (int i = 0; i < suggestions.length; i++) {
            _selectedIndices.add(i);
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildBody()),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Text('AI Itinerary Ideas', style: AppTextStyles.h1),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.accent),
            const SizedBox(height: 20),
            Text('Gemini is crafting your squad\'s day...', style: AppTextStyles.body),
          ],
        ),
      );
    }

    if (_suggestions == null || _suggestions!.isEmpty) {
      return Center(
        child: Text('No suggestions found. Try again?', style: AppTextStyles.body),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _suggestions!.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _suggestions![index];
        final isSelected = _selectedIndices.contains(index);

        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedIndices.remove(index);
              } else {
                _selectedIndices.add(index);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accent.withValues(alpha: 0.05) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.divider,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            DateFormat('h:mm a').format(item.time),
                            style: AppTextStyles.label.copyWith(color: AppColors.accent),
                          ),
                          const SizedBox(width: 8),
                          const Text('•', style: TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.location ?? 'Various',
                              style: AppTextStyles.label,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(item.title, style: AppTextStyles.h2),
                      if (item.description != null && item.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.description!,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? AppColors.accent : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    final selectedCount = _selectedIndices.length;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : _generate,
              child: const Text('Regenerate'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: selectedCount == 0 || _isLoading ? null : _addSelected,
              child: Text('Add $selectedCount Items'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addSelected() async {
    final itemsToAdd = _selectedIndices.map((i) => _suggestions![i]).toList();
    
    // Capture the notifier before popping to avoid using ref after disposal
    final notifier = ref.read(planNotifierProvider.notifier);
    
    Navigator.pop(context);
    
    // Add items one by one via notifier
    for (final item in itemsToAdd) {
      await notifier.addItineraryItem(widget.plan.planId, item);
    }
  }
}
