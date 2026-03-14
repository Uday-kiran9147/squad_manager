import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:firebase_auth/firebase_auth.dart";
import "../../../core/services/auth_service.dart";

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges();
});

class AuthState {
  final bool isLoading;
  final String? error;
  final String? verificationId;

  AuthState({this.isLoading = false, this.error, this.verificationId});

  AuthState copyWith({bool? isLoading, String? error, String? verificationId}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      verificationId: verificationId ?? this.verificationId,
    );
  }
}

class PhoneAuthNotifier extends StateNotifier<AuthState> {
  PhoneAuthNotifier(this._authService) : super(AuthState());

  final AuthService _authService;

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    await _authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        state = state.copyWith(isLoading: false, verificationId: verificationId);
      },
      onError: (e) {
        state = state.copyWith(isLoading: false, error: e.message);
      },
    );
  }
}

final phoneAuthNotifierProvider =
    StateNotifierProvider<PhoneAuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return PhoneAuthNotifier(authService);
});
