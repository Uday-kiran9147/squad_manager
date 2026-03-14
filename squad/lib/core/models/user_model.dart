import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _\ {
  const factory UserModel({
    required String uid,
    required String phone,
    required String displayName,
    String? avatarUrl,
    required bool isPro,
    DateTime? proUnlockedAt,
    required DateTime createdAt,
    required String fcmToken,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _\(json);
}
