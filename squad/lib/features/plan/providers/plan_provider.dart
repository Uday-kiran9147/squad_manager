import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../../core/services/firestore_service.dart";
import "../../../core/models/plan_model.dart";

final firestoreServiceProvider3 = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final planDetailProvider =
    StreamProvider.family<PlanModel?, String>((ref, planId) {
  final firestoreService = ref.watch(firestoreServiceProvider3);
  return firestoreService.getPlan(planId).asStream();
});

class UpdatePlanState {
  final bool isLoading;
  final String? error;

  UpdatePlanState({this.isLoading = false, this.error});

  UpdatePlanState copyWith({bool? isLoading, String? error}) {
    return UpdatePlanState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class UpdatePlanNotifier extends StateNotifier<UpdatePlanState> {
  UpdatePlanNotifier(this._firestoreService)
      : super(UpdatePlanState());

  final FirestoreService _firestoreService;

  Future<void> updatePlan(String planId, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _firestoreService.updatePlan(planId, data);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> confirmPlan(String planId, DateTime confirmedDate, String venue) async {
    await updatePlan(planId, {
      "status": "confirmed",
      "confirmedDate": confirmedDate,
      "confirmedVenue": venue,
      "updatedAt": DateTime.now(),
    });
  }
}

final updatePlanProvider =
    StateNotifierProvider<UpdatePlanNotifier, UpdatePlanState>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider3);
  return UpdatePlanNotifier(firestoreService);
});
