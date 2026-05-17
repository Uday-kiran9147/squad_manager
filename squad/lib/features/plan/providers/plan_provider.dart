import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:squad/core/providers.dart';
import '../models/plan.dart';
import '../models/expense.dart';
import '../models/itinerary_item.dart';
import '../models/plan_balance.dart';
import '../domain/repositories/plan_repository.dart';

// ─── PlanNotifier — centralised mutation controller ──────────────────────────

/// Wraps all write operations with AsyncValue loading/error state so screens
/// never need local [setState] booleans for plan mutations.
class PlanNotifier extends AsyncNotifier<void> {
  PlanRepository get _service => ref.read(planRepositoryProvider);

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

  /// Creates a rich sample plan for users to explore all features.
  Future<void> createSamplePlan(String userId) async {
    state = const AsyncLoading();
    try {
      final now = DateTime.now();
      final plan = Plan(
        planId: '',
        title: 'Sample: Goa Trip 🌴',
        description:
            'A sample plan to show you how Squad works. Explore the polls, expenses, and itinerary!',
        createdBy: userId,
        status: PlanStatus.confirmed,
        location: 'Goa, India',
        confirmedDate: now.add(const Duration(days: 30)),
        confirmedVenue: 'Calangute Beach',
        // Only use the real userId — no fake member IDs that would cause
        // Firestore lookup failures and ghost "Friend" entries in the UI.
        memberIds: [userId],
        createdAt: now,
        updatedAt: now,
      );

      final planId = await _service.createPlan(plan);

      // Add Poll Options
      await _service.addPollOption(planId, now.add(const Duration(days: 30)));
      await _service.addPollOption(planId, now.add(const Duration(days: 37)));

      // Add Itinerary
      await _service.addItineraryItem(
        planId,
        ItineraryItem(
          itemId: '',
          title: 'Flight Arrival',
          location: 'GOX Airport',
          time: now.add(const Duration(days: 30, hours: 10)),
        ),
      );
      await _service.addItineraryItem(
        planId,
        ItineraryItem(
          itemId: '',
          title: 'Check-in @ Resort',
          location: 'Taj Exotica',
          time: now.add(const Duration(days: 30, hours: 14)),
        ),
      );

      // Add Expenses — all paid by & split among the guest only.
      await _service.addExpense(
        planId: planId,
        title: 'Resort Booking',
        amount: 15000,
        paidBy: userId,
        splitAmong: [userId],
        category: ExpenseCategory.stay,
      );
      await _service.addExpense(
        planId: planId,
        title: 'Car Rental',
        amount: 4500,
        paidBy: userId,
        splitAmong: [userId],
        category: ExpenseCategory.transport,
      );

      state = const AsyncData(null);
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
      await _service.updatePlan(
        planId,
        title: title,
        description: description,
        location: location,
      );
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
    String planId,
    DateTime confirmedDate,
    String confirmedVenue,
  ) async {
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
    String planId,
    String optionId,
    String userId,
  ) async {
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
    Map<String, double>? splitAmounts,
  }) async {
    state = const AsyncLoading();
    try {
      await _service.addExpense(
        planId: planId,
        title: title,
        amount: amount,
        paidBy: paidBy,
        splitAmong: splitAmong,
        category: category,
        splitAmounts: splitAmounts,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Marks an expense as settled by the current user and optionally launches UPI.
  Future<void> markExpenseSettled(
    String planId,
    String expenseId,
    String userId,
  ) async {
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

  Future<void> updateRSVP(String planId, String userId, String status) async {
    state = const AsyncLoading();
    try {
      await _service.updateRSVP(planId, userId, status);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final planNotifierProvider = AsyncNotifierProvider<PlanNotifier, void>(
  PlanNotifier.new,
);

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
          final share =
              expense.splitAmounts[memberId] ?? expense.perPersonAmount;
          totalOwed += share;
          peerBalances[memberId] = (peerBalances[memberId] ?? 0) + share;
        }
      }
    } else if (expense.splitAmong.contains(currentUserId)) {
      // Someone else paid, current user owes
      if (!expense.settledBy.contains(currentUserId)) {
        final share =
            expense.splitAmounts[currentUserId] ?? expense.perPersonAmount;
        totalOwing += share;
        peerBalances[expense.paidBy] =
            (peerBalances[expense.paidBy] ?? 0) - share;
      }
    }
  }

  return PlanBalance(
    totalOwed: totalOwed,
    totalOwing: totalOwing,
    peerBalances: peerBalances,
  );
});
