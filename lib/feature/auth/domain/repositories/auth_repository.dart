import 'package:dartz/dartz.dart';
import 'package:movie_app/feature/auth/data/models/sign_in_req.dart';
import 'package:movie_app/feature/auth/data/models/sign_up_req.dart';

abstract class AuthRepository {
  Future <Either> signUp(SignUpReq signUpRep);
  Future <Either> signIn(SignInReq signInRep);
  Future <Either> signInWithGoogle();
}
