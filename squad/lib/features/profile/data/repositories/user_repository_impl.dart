import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'squadusers';

  @override
  Future<void> createUser(UserModel user) async {
    await _firestore.collection(_collection).doc(user.uid).set(user.toJson());
  }

  @override
  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection(_collection).doc(uid).get();
    final data = doc.data();
    if (doc.exists && data != null) {
      try {
        return UserModel.fromJson(data);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Stream<UserModel?> watchUser(String uid) {
    return _firestore.collection(_collection).doc(uid).snapshots().map((doc) {
      final data = doc.data();
      if (doc.exists && data != null) {
        try {
          return UserModel.fromJson(data);
        } catch (e) {
          return null;
        }
      }
      return null;
    });
  }

  @override
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection(_collection).doc(uid).update(data);
  }

  @override
  Future<List<UserModel>> getUsers(List<String> uids) async {
    if (uids.isEmpty) return [];

    final List<UserModel> users = [];
    for (int i = 0; i < uids.length; i += 10) {
      final chunk = uids.sublist(
        i,
        i + 10 > uids.length ? uids.length : i + 10,
      );
      final snapshot = await _firestore
          .collection(_collection)
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in snapshot.docs) {
        try {
          users.add(UserModel.fromJson(doc.data()));
        } catch (e) {
          // Skip malformed user data
        }
      }
    }
    return users;
  }
}
