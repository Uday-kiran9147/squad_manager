import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:squad/features/auth/data/repositories/auth_repository_impl.dart";
import "package:squad/features/auth/domain/repositories/auth_repository.dart";

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges();
});

class AuthState {
  final bool isLoading;
  final String? error;

  AuthState({this.isLoading = false, this.error});

  AuthState copyWith({bool? isLoading, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authRepository) : super(AuthState());

  final AuthRepository _authRepository;

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.signInWithGoogle();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.signInWithEmail(email, password);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signUp(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.signUpWithEmail(email, password);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signInAnonymously(String displayName) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.signInAnonymously(displayName);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.signOut();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});
