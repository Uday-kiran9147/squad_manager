import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:squad/core/providers.dart';
import '../models/plan.dart';
import '../models/expense.dart';
import '../models/itinerary_item.dart';
import '../models/plan_balance.dart';
import 'package:squad/core/services/plan_service.dart';

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
      await _service.toggleVote(planId, optionId, userId);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Adds a new expense to the plan.
  Future<void> addExpense({
    required String planId,
    required String title,
    required double amount,
    required String paidBy,
    required List<String> splitAmong,
    required ExpenseCategory category,
  }) async {
    state = const AsyncLoading();
    try {
      await _service.addExpense(
          planId, title, amount, paidBy, splitAmong, category);
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

  // --- Itinerary Mutators ---

  Future<void> addItineraryItem(String planId, ItineraryItem item) async {
    state = const AsyncLoading();
    try {
      await _service.addItineraryItem(planId, item);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> updateItineraryItem(String planId, ItineraryItem item) async {
    state = const AsyncLoading();
    try {
      await _service.updateItineraryItem(planId, item);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> deleteItineraryItem(String planId, String itemId) async {
    state = const AsyncLoading();
    try {
      await _service.deleteItineraryItem(planId, itemId);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> toggleItineraryItemCompletion(
    String planId,
    String itemId,
    bool isCompleted,
  ) async {
    state = const AsyncLoading();
    try {
      await _service.toggleItineraryItemCompletion(planId, itemId, isCompleted);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final planNotifierProvider =
    AsyncNotifierProvider<PlanNotifier, void>(PlanNotifier.new);

final planBalanceProvider = Provider.family<PlanBalance, String>((ref, planId) {
  final expenses = ref.watch(expensesProvider(planId)).value ?? [];
  final currentUserId = ref.watch(currentUserIdProvider);

  if (currentUserId == null) return const PlanBalance();

  double totalOwed = 0.0;
  double totalOwing = 0.0;
  final peerBalances = <String, double>{};

  for (final expense in expenses) {
    if (expense.paidBy == currentUserId) {
      // Current user paid
      for (final memberId in expense.splitAmong) {
        if (memberId == currentUserId) continue;
        if (!expense.settledBy.contains(memberId)) {
          totalOwed += expense.perPersonAmount;
          peerBalances[memberId] =
              (peerBalances[memberId] ?? 0) + expense.perPersonAmount;
        }
      }
    } else if (expense.splitAmong.contains(currentUserId)) {
      // Someone else paid, current user owes
      if (!expense.settledBy.contains(currentUserId)) {
        totalOwing += expense.perPersonAmount;
        peerBalances[expense.paidBy] =
            (peerBalances[expense.paidBy] ?? 0) - expense.perPersonAmount;
      }
    }
  }

  return PlanBalance(
    totalOwed: totalOwed,
    totalOwing: totalOwing,
    peerBalances: peerBalances,
  );
});

