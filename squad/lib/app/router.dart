import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:squad/core/providers.dart';
import 'package:squad/features/auth/presentation/pages/email_auth_screen.dart';
import 'package:squad/features/home/presentation/pages/home_screen.dart';
import 'package:squad/features/plan/presentation/pages/create_plan_screen.dart';
import 'package:squad/features/plan/presentation/pages/add_expense_screen.dart';
import 'package:squad/features/plan/presentation/pages/confirm_plan_screen.dart';
import 'package:squad/features/invite/presentation/pages/invite_handler_screen.dart';
import 'package:squad/features/plan/presentation/pages/plan_detail_screen.dart';
import 'package:squad/features/profile/presentation/pages/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.read(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: authNotifier,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final user = authState.value;
      final isAuthPath = state.matchedLocation.startsWith('/auth');
      final isInvitePath = state.matchedLocation.startsWith('/invite');

      if (user != null && isAuthPath) return '/home';
      if (user == null && !isAuthPath && !isInvitePath) return '/auth/email';
      return null;
    },
    routes: [
      GoRoute(
        path: '/invite/:planId',
        builder: (context, state) {
          final planId = state.pathParameters['planId']!;
          return InviteHandlerScreen(planId: planId);
        },
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const SizedBox(),
        routes: [
          GoRoute(
            path: 'email',
            builder: (context, state) => const EmailAuthScreen(),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => child,
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'create-plan',
                pageBuilder: (context, state) =>
                    const MaterialPage(child: CreatePlanScreen()),
              ),
              GoRoute(
                path: 'plan/:planId',
                pageBuilder: (context, state) {
                  final planId = state.pathParameters['planId']!;
                  return MaterialPage(child: PlanDetailScreen(planId: planId));
                },
                routes: [
                  GoRoute(
                    path: 'confirm',
                    pageBuilder: (context, state) {
                      final planId = state.pathParameters['planId']!;
                      return MaterialPage(
                        child: ConfirmPlanScreen(planId: planId),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'add-expense',
                    pageBuilder: (context, state) {
                      final planId = state.pathParameters['planId']!;
                      return MaterialPage(
                        child: AddExpenseScreen(planId: planId),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

final routerNotifierProvider = ChangeNotifierProvider((ref) {
  return RouterNotifier(ref);
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}
