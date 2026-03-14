import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_text_styles.dart';


class CreatePlanScreen extends ConsumerWidget {
  const CreatePlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Plan'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Plan Title\$', style: AppTextStyles.label),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'e.g., Trip to Banjara Hills',
                ),
              ),
              const SizedBox(height: 24),
              Text('Location', style: AppTextStyles.label),
              const SizedBox(height: 8),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  hintText: 'Optional',
                ),
              ),
              const SizedBox(height: 24),
              Text('Description', style: AppTextStyles.label),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: 'What are you planning?',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement plan creation
                },
                child: const Text('Create Plan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
