import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/common/bloc/AuthWithSocial/auth_with_social_cubit.dart';
import 'package:movie_app/feature/auth/data/models/confirm_token.dart';
import 'package:movie_app/feature/auth/data/models/sign_in_req.dart';
import 'package:movie_app/feature/auth/data/models/sign_up_req.dart';
import 'package:movie_app/feature/auth/domain/repositories/auth_repository.dart';
import 'package:movie_app/feature/auth/domain/usecases/sigin_with_facebook.dart';
import 'package:movie_app/feature/auth/domain/usecases/sigin_with_google.dart';
import 'package:movie_app/feature/auth/presentation/sign_in/pages/sign_in.dart';

void main() {
  testWidgets('page presentation only exposes Google sign in', (tester) async {
    await tester.pumpWidget(_testApp(const SignInPage()));

    expect(find.text('Đăng nhập Liquid Phim'), findsOneWidget);
    expect(find.text('Tiếp tục với Google'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.textContaining('Quên mật khẩu'), findsNothing);
    expect(find.textContaining('Đăng ký'), findsNothing);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
  });

  testWidgets('sheet presentation has a close action and shared content', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(const SignInPage(presentation: SignInPresentation.sheet)),
    );

    expect(find.text('Đăng nhập Liquid Phim'), findsOneWidget);
    expect(find.text('Tiếp tục với Google'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsNothing);
  });
}

Widget _testApp(Widget child) {
  final repository = _FakeAuthRepository();
  return BlocProvider(
    create: (_) => AuthWithSocialCubit(
      SiginWithGoogleUsecase(repository),
      SiginWithFacebookUsecase(repository),
    ),
    child: MaterialApp(theme: ThemeData.dark(), home: child),
  );
}

class _FakeAuthRepository implements AuthRepository {
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
  Future<Either> signInWithGoogle() async => const Right('ok');

  @override
  Future<Either> signOut() async => const Right('ok');

  @override
  Future<Either> signUp(SignUpReq signUpRep) async => const Right('ok');
}
