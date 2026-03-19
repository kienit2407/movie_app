import 'package:dartz/dartz.dart';
import 'package:movie_app/core/config/usecase/use_case.dart';
import 'package:movie_app/feature/auth/data/models/sign_in_req.dart';
import 'package:movie_app/feature/auth/domain/repositories/auth_repository.dart';

class SignInUsecase extends UseCaseLegacy<dynamic, dynamic, SignInReq> {
  final AuthRepository repository;

  SignInUsecase(this.repository);

  @override
  Future<Either<dynamic, dynamic>> call(SignInReq params) async {
    return await repository.signIn(params);
  }
}
