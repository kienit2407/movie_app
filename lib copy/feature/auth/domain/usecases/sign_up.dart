import 'package:dartz/dartz.dart';
import 'package:movie_app/core/config/usecase/use_case.dart';
import 'package:movie_app/feature/auth/data/models/sign_up_req.dart';
import 'package:movie_app/feature/auth/domain/repositories/auth_repository.dart';

class SignUpUsecase extends UseCaseLegacy<dynamic, dynamic, SignUpReq> {
  final AuthRepository repository;

  SignUpUsecase(this.repository);

  @override
  Future<Either<dynamic, dynamic>> call(SignUpReq params) async {
    return await repository.signUp(params);
  }
}
