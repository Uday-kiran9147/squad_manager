import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:squad/core/services/auth_service.dart';
import 'package:squad/core/services/user_service.dart';
import 'package:squad/core/models/user_model.dart';

import 'package:squad/core/services/plan_service.dart';
import 'package:squad/features/plan/models/plan.dart';
import 'package:squad/features/plan/models/poll_option.dart';
import 'package:squad/features/plan/models/expense.dart';
import 'package:squad/features/plan/models/itinerary_item.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).value?.uid;
});

final userServiceProvider = Provider<UserService>((ref) => UserService());

final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(userServiceProvider).watchUser(uid);
});

final userProvider = FutureProvider.family<UserModel?, String>((ref, uid) {
  return ref.watch(userServiceProvider).getUser(uid);
});

/// Batch-fetches UserModel list for a given list of UIDs.
/// Used for resolving member display names on plan screens.
final planMembersProvider =
    FutureProvider.autoDispose.family<List<UserModel>, List<String>>(
  (ref, memberIds) => ref.watch(userServiceProvider).getUsers(memberIds),
);

// Plan related providers
final planServiceProvider = Provider<PlanService>((ref) => PlanService());

final userPlansProvider = StreamProvider<List<Plan>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value([]);
  return ref.watch(planServiceProvider).getPlansForUser(uid);
});

final planStreamProvider = StreamProvider.family<Plan?, String>((ref, planId) {
  return ref.watch(planServiceProvider).watchPlanById(planId);
});

final planProvider = FutureProvider.family<Plan?, String>((ref, planId) {
  return ref.watch(planServiceProvider).getPlanById(planId);
});

final pollOptionsProvider =
    StreamProvider.family<List<PollOption>, String>((ref, planId) {
  return ref.watch(planServiceProvider).getPollOptionsForPlan(planId);
});

final expensesProvider =
    StreamProvider.family<List<Expense>, String>((ref, planId) {
  return ref.watch(planServiceProvider).getExpensesForPlan(planId);
});

final itineraryProvider =
    StreamProvider.family<List<ItineraryItem>, String>((ref, planId) {
  return ref.watch(planServiceProvider).getItineraryForPlan(planId);
});