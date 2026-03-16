import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plan.dart';
import '../models/poll_option.dart';
import '../models/expense.dart';

class PlanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _plansCollection = 'plans';
  final String _pollOptionsSubcollection = 'pollOptions';
  final String _expensesSubcollection = 'expenses';

  // Create Plan
  Future<String> createPlan(Plan plan) async {
    final docRef = _firestore.collection(_plansCollection).doc();
    final newPlan = plan.copyWith(planId: docRef.id);
    await docRef.set(newPlan.toJson());
    return docRef.id;
  }

  // Get Plans for User
  Stream<List<Plan>> getPlansForUser(String userId) {
    return _firestore
        .collection(_plansCollection)
        .where('memberIds', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Plan.fromJson(doc.data()))
            .toList());
  }

  // Get Plan by ID
  Future<Plan?> getPlanById(String planId) async {
    final doc = await _firestore.collection(_plansCollection).doc(planId).get();
    if (doc.exists) {
      return Plan.fromJson(doc.data()!);
    }
    return null;
  }

  Stream<Plan?> watchPlanById(String planId) {
    return _firestore
        .collection(_plansCollection)
        .doc(planId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return Plan.fromJson(doc.data()!);
          }
          return null;
        });
  }

  // Add Poll Option
  Future<String> addPollOption(String planId, DateTime dateTime) async {
    final optionsRef = _firestore
        .collection(_plansCollection)
        .doc(planId)
        .collection(_pollOptionsSubcollection);

    final docRef = optionsRef.doc();
    final option = PollOption(
      optionId: docRef.id,
      dateTime: dateTime,
      voteCount: 0,
      voterIds: [],
    );
    await docRef.set(option.toJson());
    return docRef.id;
  }

  // Get Poll Options for Plan
  Stream<List<PollOption>> getPollOptionsForPlan(String planId) {
    return _firestore
        .collection(_plansCollection)
        .doc(planId)
        .collection(_pollOptionsSubcollection)
        .orderBy('dateTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PollOption.fromJson(doc.data()))
            .toList());
  }

  // Vote on Poll Option
  Future<void> voteOnOption(
    String planId,
    String optionId,
    String userId,
  ) async {
    final optionRef = _firestore
        .collection(_plansCollection)
        .doc(planId)
        .collection(_pollOptionsSubcollection)
        .doc(optionId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(optionRef);
      if (doc.exists) {
        final option = PollOption.fromJson(doc.data() as Map<String, dynamic>);
        final voterIds = List<String>.from(option.voterIds);

        if (!voterIds.contains(userId)) {
          voterIds.add(userId);
          transaction.update(optionRef, {
            'voterIds': voterIds,
            'voteCount': voterIds.length,
          });
        }
      }
    });
  }

  // Confirm Plan
  Future<void> confirmPlan(
    String planId,
    DateTime confirmedDate,
    String confirmedVenue,
  ) async {
    await _firestore
        .collection(_plansCollection)
        .doc(planId)
        .update({
          'status': PlanStatus.confirmed.toString().split('.').last,
          'confirmedDate': Timestamp.fromDate(confirmedDate),
          'confirmedVenue': confirmedVenue,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  // Add Expense
  Future<String> addExpense(
    String planId,
    String title,
    double amount,
    String paidBy,
    List<String> splitAmong,
  ) async {
    final expensesRef = _firestore
        .collection(_plansCollection)
        .doc(planId)
        .collection(_expensesSubcollection);

    final docRef = expensesRef.doc();
    final perPersonAmount = amount / splitAmong.length;

    final expense = Expense(
      expenseId: docRef.id,
      title: title,
      amount: amount,
      paidBy: paidBy,
      splitAmong: splitAmong,
      perPersonAmount: perPersonAmount,
      settledBy: [],
      createdAt: DateTime.now(),
    );

    await docRef.set(expense.toJson());
    return docRef.id;
  }

  // Get Expenses for Plan
  Stream<List<Expense>> getExpensesForPlan(String planId) {
    return _firestore
        .collection(_plansCollection)
        .doc(planId)
        .collection(_expensesSubcollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromJson(doc.data()))
            .toList());
  }

  // Mark Expense as Settled
  Future<void> markExpenseSettled(
    String planId,
    String expenseId,
    String userId,
  ) async {
    final expenseRef = _firestore
        .collection(_plansCollection)
        .doc(planId)
        .collection(_expensesSubcollection)
        .doc(expenseId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(expenseRef);
      if (doc.exists) {
        final expense = Expense.fromJson(doc.data() as Map<String, dynamic>);
        final settledBy = List<String>.from(expense.settledBy);

        if (!settledBy.contains(userId)) {
          settledBy.add(userId);
          transaction.update(expenseRef, {'settledBy': settledBy});
        }
      }
    });
  }

  // Add Member to Plan
  Future<void> addMemberToPlan(String planId, String userId) async {
    await _firestore
        .collection(_plansCollection)
        .doc(planId)
        .update({
          'memberIds': FieldValue.arrayUnion([userId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  // Mark Plan as Completed
  Future<void> completePlan(String planId) async {
    await _firestore
        .collection(_plansCollection)
        .doc(planId)
        .update({
          'status': PlanStatus.completed.toString().split('.').last,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  // Update Plan (partial update of editable fields)
  Future<void> updatePlan(
    String planId, {
    String? title,
    String? description,
    String? location,
  }) async {
    final data = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (location != null) data['location'] = location;
    await _firestore.collection(_plansCollection).doc(planId).update(data);
  }

  // Delete Plan (removes plan document; sub-collections handled separately)
  Future<void> deletePlan(String planId) async {
    // Delete poll options sub-collection
    final pollOptionsSnap = await _firestore
        .collection(_plansCollection)
        .doc(planId)
        .collection(_pollOptionsSubcollection)
        .get();
    for (final doc in pollOptionsSnap.docs) {
      await doc.reference.delete();
    }

    // Delete expenses sub-collection
    final expensesSnap = await _firestore
        .collection(_plansCollection)
        .doc(planId)
        .collection(_expensesSubcollection)
        .get();
    for (final doc in expensesSnap.docs) {
      await doc.reference.delete();
    }

    // Delete the plan document itself
    await _firestore.collection(_plansCollection).doc(planId).delete();
  }

  // Delete Expense
  Future<void> deleteExpense(String planId, String expenseId) async {
    await _firestore
        .collection(_plansCollection)
        .doc(planId)
        .collection(_expensesSubcollection)
        .doc(expenseId)
        .delete();
  }

  // Update Expense (editable fields: title and amount)
  Future<void> updateExpense(
    String planId,
    String expenseId, {
    String? title,
    double? amount,
    List<String>? splitAmong,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (amount != null) {
      data['amount'] = amount;
      // Recalculate per-person amount if splitAmong provided
      if (splitAmong != null && splitAmong.isNotEmpty) {
        data['splitAmong'] = splitAmong;
        data['perPersonAmount'] = amount / splitAmong.length;
      }
    }
    if (data.isEmpty) return;
    await _firestore
        .collection(_plansCollection)
        .doc(planId)
        .collection(_expensesSubcollection)
        .doc(expenseId)
        .update(data);
  }

  // Delete Poll Option
  Future<void> deletePollOption(String planId, String optionId) async {
    await _firestore
        .collection(_plansCollection)
        .doc(planId)
        .collection(_pollOptionsSubcollection)
        .doc(optionId)
        .delete();
  }
}
