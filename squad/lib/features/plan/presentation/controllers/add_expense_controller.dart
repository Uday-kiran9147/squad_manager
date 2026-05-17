import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:squad/features/auth/domain/models/user_model.dart';
import 'package:squad/features/plan/providers/plan_provider.dart';
import 'package:squad/features/plan/models/expense.dart';
import 'package:squad/core/providers.dart';

enum SplitMode { equal, exact }

class AddExpenseState {
  final String title;
  final String amount;
  final String? paidBy;
  final List<String> splitAmong;
  final ExpenseCategory category;
  final SplitMode splitMode;
  final Map<String, String> exactAmounts;

  const AddExpenseState({
    this.title = '',
    this.amount = '',
    this.paidBy,
    this.splitAmong = const [],
    this.category = ExpenseCategory.other,
    this.splitMode = SplitMode.equal,
    this.exactAmounts = const {},
  });

  AddExpenseState copyWith({
    String? title,
    String? amount,
    String? paidBy,
    List<String>? splitAmong,
    ExpenseCategory? category,
    SplitMode? splitMode,
    Map<String, String>? exactAmounts,
  }) {
    return AddExpenseState(
      title: title ?? this.title,
      amount: amount ?? this.amount,
      paidBy: paidBy ?? this.paidBy,
      splitAmong: splitAmong ?? this.splitAmong,
      category: category ?? this.category,
      splitMode: splitMode ?? this.splitMode,
      exactAmounts: exactAmounts ?? this.exactAmounts,
    );
  }
}

class AddExpenseController extends AutoDisposeNotifier<AddExpenseState> {
  @override
  AddExpenseState build() {
    return const AddExpenseState();
  }

  void initDefaults(List<String> memberIds) {
    final currentUid = ref.read(currentUserIdProvider);
    final paidBy = memberIds.contains(currentUid) ? currentUid : memberIds.firstOrNull;
    final exactAmounts = {for (var id in memberIds) id: ''};
    
    state = state.copyWith(
      splitAmong: List.from(memberIds),
      paidBy: paidBy,
      exactAmounts: exactAmounts,
    );
  }

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void updateAmount(String amount) {
    state = state.copyWith(amount: amount);
    if (state.splitMode == SplitMode.equal) {
      distributeEqually();
    }
  }

  void updatePaidBy(String? paidBy) {
    state = state.copyWith(paidBy: paidBy);
  }

  void updateCategory(ExpenseCategory category) {
    state = state.copyWith(category: category);
  }

  void updateSplitMode(SplitMode splitMode) {
    state = state.copyWith(splitMode: splitMode);
    if (splitMode == SplitMode.equal) {
      distributeEqually();
    }
  }

  void toggleSplitMember(String memberId) {
    final splitAmong = List<String>.from(state.splitAmong);
    if (splitAmong.contains(memberId)) {
      splitAmong.remove(memberId);
    } else {
      splitAmong.add(memberId);
    }
    state = state.copyWith(splitAmong: splitAmong);
    
    if (state.splitMode == SplitMode.equal) {
      distributeEqually();
    }
  }

  void selectAllMembers(List<String> memberIds) {
    state = state.copyWith(splitAmong: List.from(memberIds));
    if (state.splitMode == SplitMode.equal) {
      distributeEqually();
    }
  }

  void updateExactAmount(String memberId, String amount) {
    final exactAmounts = Map<String, String>.from(state.exactAmounts);
    exactAmounts[memberId] = amount;
    state = state.copyWith(exactAmounts: exactAmounts);
  }

  void distributeEqually() {
    final total = double.tryParse(state.amount) ?? 0.0;
    if (total <= 0 || state.splitAmong.isEmpty) return;
    
    final share = total / state.splitAmong.length;
    final exactAmounts = Map<String, String>.from(state.exactAmounts);
    
    for (var id in state.splitAmong) {
      exactAmounts[id] = share.toStringAsFixed(2);
    }
    
    state = state.copyWith(exactAmounts: exactAmounts);
  }

  Future<String?> submit(String planId, List<UserModel>? members) async {
    if (state.paidBy == null) {
      return 'Please select who paid';
    }

    final payer = members?.where((m) => m.uid == state.paidBy).firstOrNull;
    final isCurrentUserAnonymous = ref.read(authStateProvider).value?.isAnonymous ?? false;

    if (!isCurrentUserAnonymous && (payer == null || payer.upiId == null || payer.upiId!.trim().isEmpty)) {
      final isCurrentUser = payer?.uid == ref.read(currentUserIdProvider);
      return isCurrentUser
          ? 'You must add a UPI ID in your profile before adding an expense.'
          : '${payer?.displayName ?? 'The selected user'} must have a UPI ID to be added as a payer.';
    }

    if (state.splitAmong.isEmpty) {
      return 'Please select at least one person to split with';
    }

    final totalAmount = double.tryParse(state.amount.trim());
    if (totalAmount == null || totalAmount <= 0) {
      return 'Please enter a valid amount';
    }

    Map<String, double>? splitAmounts;
    if (state.splitMode == SplitMode.exact) {
      splitAmounts = {};
      double runningTotal = 0;
      for (var id in state.splitAmong) {
        final val = double.tryParse(state.exactAmounts[id] ?? '0') ?? 0;
        splitAmounts[id] = val;
        runningTotal += val;
      }

      if ((runningTotal - totalAmount).abs() > 0.1) {
        return 'Individual shares (Rs.${runningTotal.toStringAsFixed(2)}) must sum up to the total (Rs.${totalAmount.toStringAsFixed(2)})';
      }
    }

    try {
      await ref.read(planNotifierProvider.notifier).addExpense(
            planId: planId,
            title: state.title.trim(),
            amount: totalAmount,
            paidBy: state.paidBy!,
            splitAmong: state.splitAmong,
            category: state.category,
            splitAmounts: splitAmounts,
          );
      return null; // Success
    } catch (e) {
      return 'Error adding expense: $e';
    }
  }
}

final addExpenseControllerProvider =
    NotifierProvider.autoDispose<AddExpenseController, AddExpenseState>(() {
  return AddExpenseController();
});
