import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/common/bloc/AuthWithSocial/auth_with_social_cubit.dart';
import 'package:movie_app/common/bloc/AuthWithSocial/auth_with_social_state.dart';
import 'package:movie_app/feature/auth/data/models/confirm_token.dart';
import 'package:movie_app/feature/auth/data/models/sign_in_req.dart';
import 'package:movie_app/feature/auth/data/models/sign_up_req.dart';
import 'package:movie_app/feature/auth/domain/repositories/auth_repository.dart';
import 'package:movie_app/feature/auth/domain/usecases/sigin_with_facebook.dart';
import 'package:movie_app/feature/auth/domain/usecases/sigin_with_google.dart';

void main() {
  group('AuthWithSocialCubit Google', () {
    test('emits loading then success', () async {
      final completer = Completer<Either>();
      final cubit = _buildCubit(() => completer.future);
      final states = <AuthWithSocialState>[];
      final subscription = cubit.stream.listen(states.add);

      final signIn = cubit.signInWithGoogle();
      await Future<void>.delayed(Duration.zero);
      expect(states.single, isA<AuthWithSocialLoading>());

      completer.complete(const Right('ok'));
      await signIn;
      expect(cubit.state, isA<AuthWithSocialSuccessfull>());

      await subscription.cancel();
      await cubit.close();
    });

    test('a user cancellation returns to initial without an error', () async {
      final cubit = _buildCubit(
        () async => const Left('The user canceled login!'),
      );

      await cubit.signInWithGoogle();

      expect(cubit.state, isA<AuthWithSocialInitial>());
      await cubit.close();
    });

    test('a real Google error remains retryable', () async {
      final cubit = _buildCubit(
        () async => const Left('Không thể kết nối Google'),
      );

      await cubit.signInWithGoogle();

      expect(cubit.state, isA<AuthWithSocialFailure>());
      expect(
        (cubit.state as AuthWithSocialFailure).messages,
        'Không thể kết nối Google',
      );
      cubit.reset();
      expect(cubit.state, isA<AuthWithSocialInitial>());
      await cubit.close();
    });
  });
}

AuthWithSocialCubit _buildCubit(Future<Either> Function() googleSignIn) {
  final repository = _ConfigurableAuthRepository(googleSignIn);
  return AuthWithSocialCubit(
    SiginWithGoogleUsecase(repository),
    SiginWithFacebookUsecase(repository),
  );
}

class _ConfigurableAuthRepository implements AuthRepository {
  _ConfigurableAuthRepository(this._googleSignIn);

  final Future<Either> Function() _googleSignIn;

  @override
  Future<Either> signInWithGoogle() => _googleSignIn();

  @override
  Future<Either> confirmTokenOtpEmail(ConfirmToken confirmToken) async =>
      const Right('ok');

  @override
  Future<Either> sendReqResetPassword(String email) async => const Right('ok');

  @override
  Future<Either> signIn(SignInReq signInRep) async => const Right('ok');

  @override
  Future<Either> signInWithFacebook() async => const Right('ok');

  @override
  Future<Either> signOut() async => const Right('ok');

  @override
  Future<Either> signUp(SignUpReq signUpRep) async => const Right('ok');
}
