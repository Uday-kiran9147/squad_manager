import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:squad/core/utils/converters.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    String? email,
    String? displayName,
    String? phone,
    String? photoURL,
    String? upiId,
    String? fcmToken,
    @Default(false) bool isPro,
    @TimestampConverter() DateTime? proUnlockedAt,
    @TimestampConverter() required DateTime createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
