import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../../core/services/firestore_service.dart";
import "../../../core/models/poll_option_model.dart";

final firestoreServiceProvider2 = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final planPollOptionsProvider =
    StreamProvider.family<List<PollOptionModel>, String>((ref, planId) {
  final firestoreService = ref.watch(firestoreServiceProvider2);
  return firestoreService.getPollOptions(planId);
});

class VotePollState {
  final bool isLoading;
  final String? error;

  VotePollState({this.isLoading = false, this.error});

  VotePollState copyWith({bool? isLoading, String? error}) {
    return VotePollState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class VotePollNotifier extends StateNotifier<VotePollState> {
  VotePollNotifier(this._firestoreService)
      : super(VotePollState());

  final FirestoreService _firestoreService;

  Future<void> votePoll({
    required String planId,
    required String optionId,
    required String userId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _firestoreService.votePoll(planId, optionId, userId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final votePollProvider =
    StateNotifierProvider<VotePollNotifier, VotePollState>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider2);
  return VotePollNotifier(firestoreService);
});
