import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/plan_model.dart';
import '../models/expense_model.dart';
import '../models/poll_option_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // User operations
  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toJson());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Stream<UserModel?> getUserStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) return UserModel.fromJson(doc.data()!);
      return null;
    });
  }

  // Plan operations
  Future<String> createPlan(PlanModel plan) async {
    final ref = await _db.collection('plans').add(plan.toJson());
    return ref.id;
  }

  Future<PlanModel?> getPlan(String planId) async {
    final doc = await _db.collection('plans').doc(planId).get();
    if (doc.exists) {
      return PlanModel.fromJson({...doc.data()!, 'planId': doc.id});
    }
    return null;
  }

  Stream<List<PlanModel>> getUserPlans(String userId) {
    return _db
        .collection('plans')
        .where('memberIds', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PlanModel.fromJson({...doc.data(), 'planId': doc.id});
      }).toList();
    });
  }

  Future<void> updatePlan(String planId, Map<String, dynamic> data) async {
    await _db.collection('plans').doc(planId).update(data);
  }

  Future<void> addPlanMember(String planId, String userId) async {
    await _db.collection('plans').doc(planId).update({
      'memberIds': FieldValue.arrayUnion([userId])
    });
  }

  // Poll operations
  Future<void> createPollOption(String planId, PollOptionModel option) async {
    await _db
        .collection('plans')
        .doc(planId)
        .collection('pollOptions')
        .add(option.toJson());
  }

  Stream<List<PollOptionModel>> getPollOptions(String planId) {
    return _db
        .collection('plans')
        .doc(planId)
        .collection('pollOptions')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PollOptionModel.fromJson({...doc.data(), 'optionId': doc.id});
      }).toList();
    });
  }

  Future<void> votePoll(
    String planId,
    String optionId,
    String userId,
  ) async {
    await _db
        .collection('plans')
        .doc(planId)
        .collection('pollOptions')
        .doc(optionId)
        .update({
      'voterIds': FieldValue.arrayUnion([userId]),
      'voteCount': FieldValue.increment(1),
    });
  }

  // Expense operations
  Future<String> addExpense(String planId, ExpenseModel expense) async {
    final ref = await _db
        .collection('plans')
        .doc(planId)
        .collection('expenses')
        .add(expense.toJson());
    return ref.id;
  }

  Stream<List<ExpenseModel>> getPlanExpenses(String planId) {
    return _db
        .collection('plans')
        .doc(planId)
        .collection('expenses')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ExpenseModel.fromJson({...doc.data(), 'expenseId': doc.id});
      }).toList();
    });
  }

  Future<void> updateExpense(
    String planId,
    String expenseId,
    Map<String, dynamic> data,
  ) async {
    await _db
        .collection('plans')
        .doc(planId)
        .collection('expenses')
        .doc(expenseId)
        .update(data);
  }
}
