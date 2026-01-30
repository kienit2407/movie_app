import 'package:dartz/dartz.dart';
import 'package:movie_app/feature/auth/data/models/confirm_token.dart';
import 'package:movie_app/feature/auth/data/models/sign_in_req.dart';
import 'package:movie_app/feature/auth/data/models/sign_up_req.dart';
import 'package:movie_app/feature/auth/data/sources/auth_supabase_service.dart';
import 'package:movie_app/feature/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;

  AuthRepositoryImpl(this.authService);

  @override
  Future<Either> signUp(SignUpReq signUpRep) async {
    return await authService.signUp(signUpRep);
  }

  @override
  Future<Either> signIn(SignInReq signInRep) async {
    return await authService.signIn(signInRep);
  }

  @override
  Future<Either> signInWithGoogle() async {
    return await authService.signInWithGoogle();
  }

  @override
  Future<Either> signInWithFacebook() async {
    return await authService.signInWithFaceBook();
  }

  @override
  Future<Either> signOut() async {
    return await authService.signOut();
  }

  @override
  Future<Either> sendReqResetPassword(String email) async {
    return await authService.sendReqResetPassword(email);
  }

  @override
  Future<Either> confirmTokenOtpEmail(ConfirmToken confirmToken) async {
    return await authService.confirmTokenOtpEmail(confirmToken);
  }
}
