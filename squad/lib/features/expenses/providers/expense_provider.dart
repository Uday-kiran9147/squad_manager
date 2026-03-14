import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../../core/services/firestore_service.dart";
import "../../../core/models/expense_model.dart";

final firestoreServiceProvider4 = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

class ExpenseState {
  final bool isLoading;
  final String? error;

  ExpenseState({this.isLoading = false, this.error});

  ExpenseState copyWith({bool? isLoading, String? error}) {
    return ExpenseState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class CreateExpenseNotifier extends StateNotifier<ExpenseState> {
  CreateExpenseNotifier(this._firestoreService)
      : super(ExpenseState());

  final FirestoreService _firestoreService;

  Future<String?> addExpense(String planId, ExpenseModel expense) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final expenseId = await _firestoreService.addExpense(planId, expense);
      state = state.copyWith(isLoading: false);
      return expenseId;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }
}

final createExpenseProvider =
    StateNotifierProvider<CreateExpenseNotifier, ExpenseState>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider4);
  return CreateExpenseNotifier(firestoreService);
});

final planExpensesProvider =
    StreamProvider.family<List<ExpenseModel>, String>((ref, planId) {
  final firestoreService = ref.watch(firestoreServiceProvider4);
  return firestoreService.getPlanExpenses(planId);
});
