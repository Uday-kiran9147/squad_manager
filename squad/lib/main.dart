import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:squad/app/router.dart';
import 'package:squad/core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: SquadApp(),
    ),
  );
}

class SquadApp extends ConsumerWidget {
  const SquadApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Squad',
      theme: AppTheme.buildTheme(),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
