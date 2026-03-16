import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:squad/features/auth/screens/email_auth_screen.dart';
import 'package:squad/features/home/screens/home_screen.dart';
import 'package:squad/features/plan/screens/create_plan_screen.dart';

import 'package:squad/features/plan/screens/add_expense_screen.dart';
import 'package:squad/features/plan/screens/confirm_plan_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:squad/features/invite/screens/invite_handler_screen.dart';
import 'package:squad/features/plan/screens/plan_detail_screen.dart';
import 'package:squad/features/profile/screens/profile_screen.dart';

final router = GoRouter(
  initialLocation: '/home',
  debugLogDiagnostics: true,
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
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
              pageBuilder: (context, state) => const MaterialPage(child: CreatePlanScreen()),
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
                    return MaterialPage(child: ConfirmPlanScreen(planId: planId));
                  },
                ),
                GoRoute(
                  path: 'add-expense',
                  pageBuilder: (context, state) {
                    final planId = state.pathParameters['planId']!;
                    return MaterialPage(child: AddExpenseScreen(planId: planId));
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
