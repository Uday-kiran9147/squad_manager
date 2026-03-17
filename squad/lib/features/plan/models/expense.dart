import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:squad/core/utils/converters.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

enum ExpenseCategory { food, transport, tickets, stay, other }

@freezed
class Expense with _$Expense {
  const factory Expense({
    required String expenseId,
    required String title,
    required double amount,
    required String paidBy,
    required List<String> splitAmong,
    required double perPersonAmount,
    @Default({}) Map<String, double> splitAmounts,
    required List<String> settledBy,
    @Default(ExpenseCategory.other) ExpenseCategory category,
    @TimestampConverter() required DateTime createdAt,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);
}