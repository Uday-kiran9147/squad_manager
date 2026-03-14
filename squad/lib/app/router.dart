import 'package:go_router/go_router.dart';
import '../features/auth/screens/phone_auth_screen.dart';
import '../features/auth/screens/otp_auth_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/plan/screens/create_plan_screen.dart';
import '../features/plan/screens/plan_detail_screen.dart';
import '../features/poll/screens/poll_screen.dart';
import '../features/expenses/screens/add_expense_screen.dart';
import '../features/expenses/screens/expense_detail_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/upgrade_screen.dart';

class AppRouter {
  static final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/auth/phone',
        name: 'phone-auth',
        builder: (context, state) => const PhoneAuthScreen(),
      ),
      GoRoute(
        path: '/auth/otp',
        name: 'otp-auth',
        builder: (context, state) => OtpAuthScreen(
          phoneNumber: state.extra as String? ?? '',
        ),
      ),
      GoRoute(
        path: '/plan/create',
        name: 'create-plan',
        builder: (context, state) => const CreatePlanScreen(),
      ),
      GoRoute(
        path: '/plan/:planId',
        name: 'plan-detail',
        builder: (context, state) => PlanDetailScreen(
          planId: state.pathParameters['planId']!,
        ),
      ),
      GoRoute(
        path: '/plan/:planId/poll',
        name: 'poll',
        builder: (context, state) => PollScreen(
          planId: state.pathParameters['planId']!,
        ),
      ),
      GoRoute(
        path: '/plan/:planId/expense/add',
        name: 'add-expense',
        builder: (context, state) => AddExpenseScreen(
          planId: state.pathParameters['planId']!,
        ),
      ),
      GoRoute(
        path: '/plan/:planId/expense/:expenseId',
        name: 'expense-detail',
        builder: (context, state) => ExpenseDetailScreen(
          planId: state.pathParameters['planId']!,
          expenseId: state.pathParameters['expenseId']!,
        ),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/upgrade',
        name: 'upgrade',
        builder: (context, state) => const UpgradeScreen(),
      ),
    ],
    redirect: (context, state) {
      // TODO: Add auth redirect logic
      return null;
    },
  );
}
