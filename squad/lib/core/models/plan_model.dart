import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_model.freezed.dart';
part 'plan_model.g.dart';

enum PlanStatus { draft, polling, confirmed, completed }

@freezed
class PlanModel with _\ {
  const factory PlanModel({
    required String planId,
    required String title,
    String? description,
    required String createdBy,
    required PlanStatus status,
    String? location,
    DateTime? confirmedDate,
    String? confirmedVenue,
    required String inviteLink,
    required List<String> memberIds,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PlanModel;

  factory PlanModel.fromJson(Map<String, dynamic> json) =>
      _\(json);
}
