import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../../core/services/firestore_service.dart";
import "../../../core/models/plan_model.dart";

final firestoreServiceProvider6 = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final userPlansProvider = StreamProvider.family<List<PlanModel>, String>((ref, userId) {
  final firestoreService = ref.watch(firestoreServiceProvider6);
  return firestoreService.getUserPlans(userId);
});

class CreatePlanState {
  final bool isLoading;
  final String? error;

  CreatePlanState({this.isLoading = false, this.error});

  CreatePlanState copyWith({bool? isLoading, String? error}) {
    return CreatePlanState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class CreatePlanNotifier extends StateNotifier<CreatePlanState> {
  CreatePlanNotifier(this._firestoreService)
      : super(CreatePlanState());

  final FirestoreService _firestoreService;

  Future<String?> createPlan(PlanModel plan) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final planId = await _firestoreService.createPlan(plan);
      state = state.copyWith(isLoading: false);
      return planId;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }
}

final createPlanProvider =
    StateNotifierProvider<CreatePlanNotifier, CreatePlanState>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider6);
  return CreatePlanNotifier(firestoreService);
});
