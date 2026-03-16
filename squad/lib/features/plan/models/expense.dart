import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:squad/core/utils/converters.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

@freezed
class Expense with _$Expense {
  const factory Expense({
    required String expenseId,
    required String title,
    required double amount,
    required String paidBy,
    required List<String> splitAmong,
    required double perPersonAmount,
    required List<String> settledBy,
    @TimestampConverter() required DateTime createdAt,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);
}