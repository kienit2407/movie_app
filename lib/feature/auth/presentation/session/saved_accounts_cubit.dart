import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/feature/auth/data/saved_account_store.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum SavedAccountsFailure { load, switchAccount, signOut }

class SavedAccountsState {
  const SavedAccountsState({
    this.accounts = const <SavedAccount>[],
    this.currentUserId,
    this.busyUserId,
    this.isLoading = false,
    this.failure,
  });

  final List<SavedAccount> accounts;
  final String? currentUserId;
  final String? busyUserId;
  final bool isLoading;
  final SavedAccountsFailure? failure;

  SavedAccount? get currentAccount {
    for (final account in accounts) {
      if (account.userId == currentUserId) return account;
    }
    return null;
  }

  SavedAccountsState copyWith({
    List<SavedAccount>? accounts,
    String? currentUserId,
    bool clearCurrentUser = false,
    String? busyUserId,
    bool clearBusyUser = false,
    bool? isLoading,
    SavedAccountsFailure? failure,
    bool clearFailure = false,
  }) {
    return SavedAccountsState(
      accounts: accounts ?? this.accounts,
      currentUserId: clearCurrentUser
          ? null
          : currentUserId ?? this.currentUserId,
      busyUserId: clearBusyUser ? null : busyUserId ?? this.busyUserId,
      isLoading: isLoading ?? this.isLoading,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}

class SavedAccountsCubit extends Cubit<SavedAccountsState> {
  SavedAccountsCubit({required SavedAccountStore store, SupabaseClient? client})
    : _store = store,
      _client = client ?? Supabase.instance.client,
      super(const SavedAccountsState()) {
    _authSubscription = _client.auth.onAuthStateChange.listen((event) {
      final session = event.session;
      if (session != null) {
        unawaited(_saveSessionAndRefresh(session));
      } else {
        unawaited(refresh());
      }
    });
    unawaited(_initialize());
  }

  final SavedAccountStore _store;
  final SupabaseClient _client;
  late final StreamSubscription<AuthState> _authSubscription;

  Future<void> _initialize() async {
    final session = _client.auth.currentSession;
    if (session != null) await _store.saveSession(session);
    await refresh();
  }

  Future<void> _saveSessionAndRefresh(Session session) async {
    try {
      await _store.saveSession(session);
      await refresh(showLoading: false);
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(failure: SavedAccountsFailure.load));
      }
    }
  }

  Future<bool> rememberCurrentSession() async {
    final session = _client.auth.currentSession;
    if (session == null) return true;
    try {
      await _store.saveSession(session);
      await refresh(showLoading: false);
      return true;
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(failure: SavedAccountsFailure.load));
      }
      return false;
    }
  }

  Future<void> refresh({
    bool showLoading = true,
    bool clearBusyUser = false,
  }) async {
    if (showLoading && !isClosed) {
      emit(state.copyWith(isLoading: true, clearFailure: true));
    }
    try {
      final accounts = await _store.readAccounts();
      if (isClosed) return;
      emit(
        state.copyWith(
          accounts: accounts,
          currentUserId: _client.auth.currentUser?.id,
          clearCurrentUser: _client.auth.currentUser == null,
          clearBusyUser: clearBusyUser,
          isLoading: false,
          clearFailure: true,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(isLoading: false, failure: SavedAccountsFailure.load),
      );
    }
  }

  Future<bool> switchAccount(String userId) async {
    if (userId == _client.auth.currentUser?.id) return true;

    SavedAccount? target;
    for (final account in state.accounts) {
      if (account.userId == userId) {
        target = account;
        break;
      }
    }
    if (target == null || state.busyUserId != null) return false;

    if (!await rememberCurrentSession()) return false;
    if (!isClosed) {
      emit(state.copyWith(busyUserId: userId, clearFailure: true));
    }
    try {
      final response = await _client.auth.setSession(
        target.refreshToken,
        accessToken: target.accessToken,
      );
      final session = response.session;
      if (session == null) throw StateError('Supabase returned no session.');
      await _store.saveSession(session);
      await refresh(showLoading: false, clearBusyUser: true);
      return true;
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            clearBusyUser: true,
            failure: SavedAccountsFailure.switchAccount,
          ),
        );
      }
      return false;
    }
  }

  Future<bool> signOutCurrent() async {
    if (state.busyUserId != null) return false;
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) return true;

    await rememberCurrentSession();
    final fallbackAccounts = state.accounts
        .where((account) => account.userId != currentUserId)
        .toList(growable: false);
    if (!isClosed) {
      emit(state.copyWith(busyUserId: currentUserId, clearFailure: true));
    }

    try {
      await _client.auth.signOut(scope: SignOutScope.local);
      await _store.removeAccount(currentUserId);

      for (final account in fallbackAccounts) {
        try {
          final response = await _client.auth.setSession(
            account.refreshToken,
            accessToken: account.accessToken,
          );
          final session = response.session;
          if (session != null) {
            await _store.saveSession(session);
            break;
          }
        } catch (_) {
          // A saved session can be expired or revoked. Try the next account.
        }
      }

      await refresh(showLoading: false, clearBusyUser: true);
      return true;
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            clearBusyUser: true,
            failure: SavedAccountsFailure.signOut,
          ),
        );
      }
      return false;
    }
  }

  void clearFailure() {
    if (!isClosed && state.failure != null) {
      emit(state.copyWith(clearFailure: true));
    }
  }

  @override
  Future<void> close() async {
    await _authSubscription.cancel();
    return super.close();
  }
}
