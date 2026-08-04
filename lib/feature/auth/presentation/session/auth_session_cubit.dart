import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthSessionState {
  const AuthSessionState({required this.user, this.errorMessage});

  final User? user;
  final String? errorMessage;

  bool get isAuthenticated => user != null;
}

class AuthSessionCubit extends Cubit<AuthSessionState> {
  AuthSessionCubit({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client,
      super(
        AuthSessionState(
          user: (client ?? Supabase.instance.client).auth.currentUser,
        ),
      ) {
    _subscription = _client.auth.onAuthStateChange.listen(
      (event) => emit(AuthSessionState(user: event.session?.user)),
      onError: (Object error, StackTrace stackTrace) {
        emit(
          AuthSessionState(
            user: _client.auth.currentUser,
            errorMessage: 'Không thể cập nhật phiên đăng nhập.',
          ),
        );
      },
    );
  }

  final SupabaseClient _client;
  late final StreamSubscription<AuthState> _subscription;

  void refresh() {
    emit(AuthSessionState(user: _client.auth.currentUser));
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
