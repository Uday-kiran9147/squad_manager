import '../../models/plan.dart';
import '../../models/poll_option.dart';
import '../../models/expense.dart';
import '../../models/itinerary_item.dart';

abstract class PlanRepository {
  Future<String> createPlan(Plan plan);
  Stream<List<Plan>> getPlansForUser(String userId);
  Future<Plan?> getPlanById(String planId);
  Stream<Plan?> watchPlanById(String planId);
  Future<void> updatePlan(String planId, {String? title, String? description, String? location});
  Future<void> confirmPlan(String planId, DateTime confirmedDate, String confirmedVenue);
  Future<void> completePlan(String planId);
  Future<void> deletePlan(String planId);
  Future<void> addMemberToPlan(String planId, String userId);
  Future<void> updateRSVP(String planId, String userId, String status);

  Future<String> addPollOption(String planId, DateTime dateTime);
  Stream<List<PollOption>> getPollOptionsForPlan(String planId);
  Future<void> toggleVote(String planId, String optionId, String userId);
  Future<void> deletePollOption(String planId, String optionId);

  Future<String> addExpense({
    required String planId,
    required String title,
    required double amount,
    required String paidBy,
    required List<String> splitAmong,
    required ExpenseCategory category,
    Map<String, double>? splitAmounts,
  });
  Stream<List<Expense>> getExpensesForPlan(String planId);
  Future<void> markExpenseSettled(String planId, String expenseId, String userId);
  Future<void> deleteExpense(String planId, String expenseId);

  Stream<List<ItineraryItem>> getItineraryForPlan(String planId);
  Future<String> addItineraryItem(String planId, ItineraryItem item);
  Future<void> updateItineraryItem(String planId, ItineraryItem item);
  Future<void> deleteItineraryItem(String planId, String itemId);
  Future<void> toggleItineraryItemCompletion(String planId, String itemId, bool isCompleted);
}
