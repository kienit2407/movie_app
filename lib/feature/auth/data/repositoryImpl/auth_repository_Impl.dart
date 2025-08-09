import 'package:dartz/dartz.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/feature/auth/data/models/sign_in_req.dart';
import 'package:movie_app/feature/auth/data/models/sign_up_req.dart';
import 'package:movie_app/feature/auth/data/sources/auth_supabase_service.dart';
import 'package:movie_app/feature/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  @override
  Future<Either> signUp(SignUpReq signUpRep) async {
    return await sl<AuthSupabaseService>().signUp(signUpRep);
  }

  @override
  Future<Either> signIn(SignInReq signInRep) async {
    return await sl<AuthSupabaseService>().signIn(signInRep);
  }
  
  @override
  Future<Either> signInWithGoogle() async {
    return await sl<AuthSupabaseService>().signInWithGoogle();
  }
}