import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/plan/models/plan.dart';
import '../../features/plan/models/poll_option.dart';
import '../../features/plan/models/expense.dart';
import '../../features/plan/models/itinerary_item.dart';

class PlanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _plansCollection = 'plans';
  final String _pollOptionsSubcollection = 'pollOptions';
  final String _expensesSubcollection = 'expenses';
  final String _itinerarySubcollection = 'itinerary';

  // Create Plan
  Future<String> createPlan(Plan plan) async {
    final docRef = _firestore.collection(_plansCollection).doc();
    final newPlan = plan.copyWith(
      planId: docRef.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      pollClosesAt: DateTime.now().add(const Duration(hours: 48)),
    );
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
            .map((doc) {
              try {
                final data = doc.data();
                return Plan.fromJson(data);
              } catch (e, stack) {
                debugPrint('Plan parsing error: $e\n$stack');
                return null;
              }
            })
            .whereType<Plan>()
            .toList());
  }

  // Get Plan by ID
  Future<Plan?> getPlanById(String planId) async {
    final doc = await _firestore.collection(_plansCollection).doc(planId).get();
    final data = doc.data();
    if (doc.exists && data != null) {
      try {
        return Plan.fromJson(data);
      } catch (e, stack) {
        debugPrint('Plan fetch error: $e\n$stack');
        return null;
      }
    }
    return null;
  }

  Stream<Plan?> watchPlanById(String planId) {
    return _firestore
        .collection(_plansCollection)
        .doc(planId)
        .snapshots()
        .map((doc) {
          final data = doc.data();
          if (doc.exists && data != null) {
            try {
              return Plan.fromJson(data);
            } catch (e, stack) {
              debugPrint('Plan watch error: $e\n$stack');
              return null;
            }
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
            .map((doc) {
              try {
                return PollOption.fromJson(doc.data());
              } catch (e) {
                return null;
              }
            })
            .whereType<PollOption>()
            .toList());
  }

  // Vote on Poll Option
  Future<void> toggleVote(String planId, String optionId, String userId) async {
    final optionRef = _firestore
        .collection(_plansCollection)
        .doc(planId)
        .collection(_pollOptionsSubcollection)
        .doc(optionId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(optionRef);
      final data = doc.data();
      if (doc.exists && data != null) {
        final option = PollOption.fromJson(data);
        final voterIds = List<String>.from(option.voterIds);

        if (voterIds.contains(userId)) {
          voterIds.remove(userId);
        } else {
          voterIds.add(userId);
        }
        
        transaction.update(optionRef, {
          'voterIds': voterIds,
          'voteCount': voterIds.length,
        });
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
          'status': PlanStatus.confirmed.name,
          'confirmedDate': Timestamp.fromDate(confirmedDate),
          'confirmedVenue': confirmedVenue,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  // Add Expense
  Future<String> addExpense({
    required String planId,
    required String title,
    required double amount,
    required String paidBy,
    required List<String> splitAmong,
    required ExpenseCategory category,
    Map<String, double>? splitAmounts,
  }) async {
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
      splitAmounts: splitAmounts ?? {},
      settledBy: [],
      category: category,
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
            .map((doc) {
              try {
                return Expense.fromJson(doc.data());
              } catch (e) {
                return null;
              }
            })
            .whereType<Expense>()
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
      final data = doc.data();
      if (doc.exists && data != null) {
        final expense = Expense.fromJson(data);
        final settledBy = List<String>.from(expense.settledBy);

        if (!settledBy.contains(userId)) {
          settledBy.add(userId);
          transaction.update(expenseRef, {'settledBy': settledBy});
        }
      }
    });
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

  // Delete Poll Option
  Future<void> deletePollOption(String planId, String optionId) async {
    await _firestore
        .collection(_plansCollection)
        .doc(planId)
        .collection(_pollOptionsSubcollection)
        .doc(optionId)
        .delete();
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
          'status': PlanStatus.completed.name,
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

  // --- Itinerary Methods ---

  Stream<List<ItineraryItem>> getItineraryForPlan(String planId) {
    return _firestore
        .collection(_plansCollection)
        .doc(planId)
        .collection(_itinerarySubcollection)
        .orderBy('time', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              try {
                return ItineraryItem.fromJson(doc.data());
              } catch (e) {
                return null;
              }
            })
            .whereType<ItineraryItem>()
            .toList());
  }

  Future<String> addItineraryItem(String planId, ItineraryItem item) async {
    final docRef = _firestore
        .collection(_plansCollection)
        .doc(planId)
        .collection(_itinerarySubcollection)
        .doc();

    final newItem = item.copyWith(itemId: docRef.id);
    await docRef.set(newItem.toJson());
    return docRef.id;
  }

  Future<void> updateItineraryItem(String planId, ItineraryItem item) async {
    await _firestore
        .collection(_plansCollection)
        .doc(planId)
        .collection(_itinerarySubcollection)
        .doc(item.itemId)
        .update(item.toJson());
  }

  Future<void> deleteItineraryItem(String planId, String itemId) async {
    await _firestore
        .collection(_plansCollection)
        .doc(planId)
        .collection(_itinerarySubcollection)
        .doc(itemId)
        .delete();
  }

  Future<void> toggleItineraryItemCompletion(
    String planId,
    String itemId,
    bool isCompleted,
  ) async {
    await _firestore
        .collection(_plansCollection)
        .doc(planId)
        .collection(_itinerarySubcollection)
        .doc(itemId)
        .update({'isCompleted': isCompleted});
  }

  // Update RSVP Status
  Future<void> updateRSVP(String planId, String userId, String status) async {
    await _firestore.collection(_plansCollection).doc(planId).update({
      'rsvps.$userId': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete Plan
  Future<void> deletePlan(String planId) async {
    await _firestore.collection(_plansCollection).doc(planId).delete();
  }
}
