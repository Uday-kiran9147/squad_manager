import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:squad/app/router.dart';
import 'package:squad/core/theme/app_theme.dart';
import 'package:squad/core/services/notification_service.dart';
import 'package:squad/core/providers.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final container = ProviderContainer();
  await container.read(notificationServiceProvider).initialize();

  runApp(
    UncontrolledProviderScope(container: container, child: const SquadApp()),
  );
}

class SquadApp extends ConsumerWidget {
  const SquadApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Listen to auth changes to update FCM token
    ref.listen(currentUserIdProvider, (previous, next) {
      if (next != null) {
        ref.read(notificationServiceProvider).updateToken(next);
      }
    });

    return MaterialApp.router(
      title: 'Squad',
      theme: AppTheme.buildTheme(),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      builder: (context, child) {
        return child!;
      },
    );
  }
}
