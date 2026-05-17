import '../../../auth/domain/models/user_model.dart';

abstract class UserRepository {
  Future<void> createUser(UserModel user);
  Future<UserModel?> getUser(String uid);
  Stream<UserModel?> watchUser(String uid);
  Future<void> updateUser(String uid, Map<String, dynamic> data);
  Future<List<UserModel>> getUsers(List<String> uids);
}
