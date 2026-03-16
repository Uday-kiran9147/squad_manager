import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plan.dart';
import '../models/poll_option.dart';
import '../models/expense.dart';
import '../services/plan_service.dart';

final planServiceProvider = Provider((ref) => PlanService());

// ─── Read-only stream/future providers ───────────────────────────────────────

/// Live list of plans for the current user.
final plansProvider =
    StreamProvider.autoDispose.family<List<Plan>, String>((ref, userId) {
  return ref.watch(planServiceProvider).getPlansForUser(userId);
});

/// Live single plan (used in detail screen).
final planStreamProvider =
    StreamProvider.autoDispose.family<Plan?, String>((ref, planId) {
  return ref.watch(planServiceProvider).watchPlanById(planId);
});

/// One-shot plan fetch (used in invite/add-expense screens).
final planProvider =
    FutureProvider.autoDispose.family<Plan?, String>((ref, planId) {
  return ref.watch(planServiceProvider).getPlanById(planId);
});

/// Live poll options for a plan.
final pollOptionsProvider =
    StreamProvider.autoDispose.family<List<PollOption>, String>((ref, planId) {
  return ref.watch(planServiceProvider).getPollOptionsForPlan(planId);
});

/// Live expenses for a plan.
final expensesProvider =
    StreamProvider.autoDispose.family<List<Expense>, String>((ref, planId) {
  return ref.watch(planServiceProvider).getExpensesForPlan(planId);
});

// ─── PlanNotifier — centralised mutation controller ──────────────────────────

/// Wraps all write operations with AsyncValue loading/error state so screens
/// never need local [setState] booleans for plan mutations.
class PlanNotifier extends AsyncNotifier<void> {
  PlanService get _service => ref.read(planServiceProvider);

  @override
  Future<void> build() async {}

  /// Creates a plan and all its poll-option date choices atomically.
  Future<String> createPlan(Plan plan, List<DateTime> dateOptions) async {
    state = const AsyncLoading();
    try {
      final planId = await _service.createPlan(plan);
      for (final date in dateOptions) {
        await _service.addPollOption(planId, date);
      }
      state = const AsyncData(null);
      return planId;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Partial update for plan metadata (title / description / location).
  Future<void> updatePlan(
    String planId, {
    String? title,
    String? description,
    String? location,
  }) async {
    state = const AsyncLoading();
    try {
      await _service.updatePlan(planId,
          title: title, description: description, location: location);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Deletes the plan and all its sub-collections.
  Future<void> deletePlan(String planId) async {
    state = const AsyncLoading();
    try {
      await _service.deletePlan(planId);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Confirms the plan with a final date and venue.
  Future<void> confirmPlan(
      String planId, DateTime confirmedDate, String confirmedVenue) async {
    state = const AsyncLoading();
    try {
      await _service.confirmPlan(planId, confirmedDate, confirmedVenue);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Marks the plan as completed.
  Future<void> completePlan(String planId) async {
    state = const AsyncLoading();
    try {
      await _service.completePlan(planId);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Records a vote for a poll option (idempotent — one vote per user).
  Future<void> voteOnOption(
      String planId, String optionId, String userId) async {
    state = const AsyncLoading();
    try {
      await _service.voteOnOption(planId, optionId, userId);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Adds a new expense to the plan.
  Future<void> addExpense(
    String planId,
    String title,
    double amount,
    String paidBy,
    List<String> splitAmong,
  ) async {
    state = const AsyncLoading();
    try {
      await _service.addExpense(planId, title, amount, paidBy, splitAmong);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Marks an expense as settled by the current user and optionally launches UPI.
  Future<void> markExpenseSettled(
      String planId, String expenseId, String userId) async {
    state = const AsyncLoading();
    try {
      await _service.markExpenseSettled(planId, expenseId, userId);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Deletes an expense from a plan.
  Future<void> deleteExpense(String planId, String expenseId) async {
    state = const AsyncLoading();
    try {
      await _service.deleteExpense(planId, expenseId);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Adds the current user as a member of the given plan.
  Future<void> addMemberToPlan(String planId, String userId) async {
    state = const AsyncLoading();
    try {
      await _service.addMemberToPlan(planId, userId);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final planNotifierProvider =
    AsyncNotifierProvider<PlanNotifier, void>(PlanNotifier.new);

