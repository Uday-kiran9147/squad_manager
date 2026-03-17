import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:squad/core/providers.dart';
import 'package:squad/core/theme/app_colors.dart';
import 'package:squad/core/theme/app_text_styles.dart';

class FeedbackSheet extends ConsumerStatefulWidget {
  const FeedbackSheet({super.key});

  @override
  ConsumerState<FeedbackSheet> createState() => _FeedbackSheetState();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FeedbackSheet(),
    );
  }
}

class _FeedbackSheetState extends ConsumerState<FeedbackSheet> {
  int? _selectedVibe; // 0: Sad, 1: Meh, 2: Happy
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  final List<Map<String, dynamic>> _vibes = [
    {'emoji': '😢', 'label': 'Not great', 'color': Colors.blueAccent},
    {'emoji': '😐', 'label': 'It\'s okay', 'color': Colors.amber},
    {'emoji': '🔥', 'label': 'Loving it!', 'color': AppColors.accent},
  ];

  void _submitFeedback() async {
    if (_selectedVibe == null) return;

    setState(() => _isSubmitting = true);
    
    try {
      final userId = ref.read(currentUserIdProvider);
      final feedbackService = ref.read(feedbackServiceProvider);
      
      await feedbackService.submitFeedback(
        userId: userId,
        vibe: _vibes[_selectedVibe!]['label'],
        comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isSubmitted = true;
        });
        
        // Auto close after 2 seconds
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isSubmitted 
            ? _buildSuccessState() 
            : _buildFeedbackForm(),
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      key: const ValueKey('success'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 64,
          ),
        ),
        const SizedBox(height: 24),
        Text('Got it! 🤘', style: AppTextStyles.h1),
        const SizedBox(height: 8),
        Text(
          'Your feedback is safe with the Squad.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFeedbackForm() {
    return Column(
      key: const ValueKey('form'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 24),
        Text('Vibe Check', style: AppTextStyles.h1),
        const SizedBox(height: 8),
        Text(
          'How are we doing? Be honest, we can take it.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_vibes.length, (index) {
            final vibe = _vibes[index];
            final isSelected = _selectedVibe == index;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedVibe = index);
              },
              child: AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected 
                          ? vibe['color'].withValues(alpha: 0.2)
                          : AppColors.divider.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? vibe['color'] : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        vibe['emoji'],
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      vibe['label'],
                      style: AppTextStyles.label.copyWith(
                        color: isSelected ? vibe['color'] : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _selectedVibe != null 
            ? Column(
                children: [
                  TextField(
                    controller: _commentController,
                    maxLines: 2,
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      hintText: 'Want to spill some tea? (Optional)',
                      hintStyle: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary.withValues(alpha: 0.4),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: AppColors.background.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              )
            : const SizedBox.shrink(),
        ),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: (_selectedVibe == null || _isSubmitting) ? null : _submitFeedback,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.divider.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: _isSubmitting
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('Send to the Squad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
