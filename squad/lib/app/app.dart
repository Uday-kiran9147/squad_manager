import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:squad/app/router.dart";
import "package:squad/core/theme/app_theme.dart";

class SquadApp extends ConsumerWidget {
  const SquadApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: "Squad",
      theme: AppTheme.buildTheme(),
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
