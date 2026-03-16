import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:squad/core/utils/converters.dart';

part 'poll_option.freezed.dart';
part 'poll_option.g.dart';

@freezed
class PollOption with _$PollOption {
  const factory PollOption({
    required String optionId,
    @TimestampConverter() required DateTime dateTime,
    required int voteCount,
    required List<String> voterIds,
  }) = _PollOption;

  factory PollOption.fromJson(Map<String, dynamic> json) =>
      _$PollOptionFromJson(json);
}