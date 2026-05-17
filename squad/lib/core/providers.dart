import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:squad/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:squad/features/profile/data/repositories/user_repository_impl.dart';
import 'package:squad/features/profile/domain/repositories/user_repository.dart';
import 'package:squad/features/auth/domain/models/user_model.dart';
import 'package:squad/features/auth/domain/repositories/auth_repository.dart';

import 'package:squad/features/plan/models/plan.dart';
import 'package:squad/features/plan/models/poll_option.dart';
import 'package:squad/features/plan/models/expense.dart';
import 'package:squad/features/plan/models/itinerary_item.dart';
import 'package:squad/features/plan/data/repositories/plan_repository_impl.dart';
import 'package:squad/features/plan/domain/repositories/plan_repository.dart';
import 'package:squad/features/plan/data/services/ai_service.dart';
import 'package:squad/core/services/feedback_service.dart';

// -- Firebase Services --
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final planRepositoryProvider = Provider<PlanRepository>((ref) => PlanRepositoryImpl());

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepositoryImpl());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).value?.uid;
});

final userRepositoryProvider = Provider<UserRepository>((ref) => UserRepositoryImpl());

final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).watchUser(uid);
});

final userProvider = FutureProvider.family<UserModel?, String>((ref, uid) {
  return ref.watch(userRepositoryProvider).getUser(uid);
});

/// Batch-fetches UserModel list for a given list of UIDs.
/// Used for resolving member display names on plan screens.
final planMembersProvider = FutureProvider.autoDispose
    .family<List<UserModel>, List<String>>(
      (ref, memberIds) => ref.watch(userRepositoryProvider).getUsers(memberIds),
    );

// Plan related providers

final userPlansProvider = StreamProvider<List<Plan>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value([]);
  return ref.watch(planRepositoryProvider).getPlansForUser(uid);
});

final planStreamProvider = StreamProvider.family<Plan?, String>((ref, planId) {
  return ref.watch(planRepositoryProvider).watchPlanById(planId);
});

final planProvider = FutureProvider.family<Plan?, String>((ref, planId) {
  return ref.watch(planRepositoryProvider).getPlanById(planId);
});

final pollOptionsProvider = StreamProvider.family<List<PollOption>, String>((
  ref,
  planId,
) {
  return ref.watch(planRepositoryProvider).getPollOptionsForPlan(planId);
});

final expensesProvider = StreamProvider.family<List<Expense>, String>((
  ref,
  planId,
) {
  return ref.watch(planRepositoryProvider).getExpensesForPlan(planId);
});

final itineraryProvider = StreamProvider.family<List<ItineraryItem>, String>((
  ref,
  planId,
) {
  return ref.watch(planRepositoryProvider).getItineraryForPlan(planId);
});

final feedbackServiceProvider = Provider<FeedbackService>(
  (ref) => FeedbackService(),
);

// --- AI Service ---
final aiServiceProvider = Provider<AIService>((ref) {
  final apiKey = dotenv.get('GEMINI_API_KEY', fallback: '');
  return AIService(apiKey);
});
