import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense_model.freezed.dart';
part 'expense_model.g.dart';

@freezed
class ExpenseModel with _\ {
  const factory ExpenseModel({
    required String expenseId,
    required String title,
    required double amount,
    required String paidBy,
    required List<String> splitAmong,
    required double perPersonAmount,
    required List<String> settledBy,
    required DateTime createdAt,
  }) = _ExpenseModel;

  factory ExpenseModel.fromJson(Map<String, dynamic> json) =>
      _\(json);
}
