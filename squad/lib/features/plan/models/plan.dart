import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:squad/core/utils/converters.dart';

part 'plan.freezed.dart';
part 'plan.g.dart';

enum PlanStatus { draft, polling, confirmed, completed }

@freezed
class Plan with _$Plan {
  const factory Plan({
    required String planId,
    required String title,
    String? description,
    required String createdBy,
    required PlanStatus status,
    String? location,
    @TimestampConverter() DateTime? confirmedDate,
    String? confirmedVenue,
    String? inviteLink,
    required List<String> memberIds,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _Plan;

  factory Plan.fromJson(Map<String, dynamic> json) => _$PlanFromJson(json);
}