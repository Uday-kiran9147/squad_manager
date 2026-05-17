import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:squad/core/providers.dart';

/// Manages profile update and account deletion.
class ProfileNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> updateProfile({
    String? displayName,
    String? upiId,
    String? phone,
  }) async {
    state = const AsyncLoading();
    try {
      final uid = ref.read(currentUserIdProvider);
      if (uid == null) throw Exception('Not authenticated');
      final data = <String, dynamic>{};
      if (displayName != null) data['displayName'] = displayName;
      if (upiId != null) data['upiId'] = upiId;
      if (phone != null) data['phone'] = phone;
      await ref.read(userRepositoryProvider).updateUser(uid, data);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).deleteAccount();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final profileNotifierProvider = AsyncNotifierProvider<ProfileNotifier, void>(
  ProfileNotifier.new,
);
