import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../../core/services/firestore_service.dart";
import "../../../core/models/user_model.dart";

final firestoreServiceProvider5 = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final currentUserProvider = StreamProvider<UserModel?>((ref) {
  const userId = "user123";
  final firestoreService = ref.watch(firestoreServiceProvider5);
  return firestoreService.getUserStream(userId);
});

class ProfileState {
  final bool isLoading;
  final String? error;

  ProfileState({this.isLoading = false, this.error});

  ProfileState copyWith({bool? isLoading, String? error}) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class UpdateProfileNotifier extends StateNotifier<ProfileState> {
  UpdateProfileNotifier(this._firestoreService)
      : super(ProfileState());

  final FirestoreService _firestoreService;

  Future<void> updateProfile(String uid, String displayName, String? avatarUrl) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _firestoreService.updateUser(uid, {
        "displayName": displayName,
        if (avatarUrl != null) "avatarUrl": avatarUrl,
      });
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> upgradeToPro(String uid) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _firestoreService.updateUser(uid, {
        "isPro": true,
        "proUnlockedAt": DateTime.now(),
      });
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final updateProfileProvider =
    StateNotifierProvider<UpdateProfileNotifier, ProfileState>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider5);
  return UpdateProfileNotifier(firestoreService);
});
