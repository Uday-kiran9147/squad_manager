import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_balance.freezed.dart';

@freezed
class PlanBalance with _$PlanBalance {
  const factory PlanBalance({
    @Default(0.0) double totalOwed,
    @Default(0.0) double totalOwing,
    @Default({}) Map<String, double> peerBalances,
  }) = _PlanBalance;

  const PlanBalance._();

  double get netBalance => totalOwed - totalOwing;
}
