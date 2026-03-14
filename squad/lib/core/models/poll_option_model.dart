import 'package:freezed_annotation/freezed_annotation.dart';

part 'poll_option_model.freezed.dart';
part 'poll_option_model.g.dart';

@freezed
class PollOptionModel with _\ {
  const factory PollOptionModel({
    required String optionId,
    required DateTime dateTime,
    required int voteCount,
    required List<String> voterIds,
  }) = _PollOptionModel;

  factory PollOptionModel.fromJson(Map<String, dynamic> json) =>
      _\(json);
}
