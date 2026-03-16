import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'squadusers';

  Future<void> createUser(UserModel user) async {
    await _firestore.collection(_collection).doc(user.uid).set(user.toJson());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection(_collection).doc(uid).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  Stream<UserModel?> watchUser(String uid) {
    return _firestore
        .collection(_collection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromJson(doc.data()!) : null);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection(_collection).doc(uid).update(data);
  }

  Future<List<UserModel>> getUsers(List<String> uids) async {
    if (uids.isEmpty) return [];
    
    // Firestore "in" query limited to 10. For now, we'll fetch one by one or chunk if needed.
    // For Squad, usually member count is small.
    final List<UserModel> users = [];
    for (int i = 0; i < uids.length; i += 10) {
      final chunk = uids.sublist(i, i + 10 > uids.length ? uids.length : i + 10);
      final snapshot = await _firestore
          .collection(_collection)
          .where('uid', whereIn: chunk)
          .get();
      users.addAll(snapshot.docs.map((doc) => UserModel.fromJson(doc.data())));
    }
    return users;
  }
}