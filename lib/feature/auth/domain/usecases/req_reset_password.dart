import 'package:dartz/dartz.dart';
import 'package:movie_app/core/config/usecase/use_case.dart';
import 'package:movie_app/feature/auth/domain/repositories/auth_repository.dart';

class ReqResetPasswordUsecase extends UseCaseLegacy<dynamic, dynamic, String> {
  final AuthRepository repository;

  ReqResetPasswordUsecase(this.repository);

  @override
  Future<Either<dynamic, dynamic>> call(String params) async {
    return await repository.sendReqResetPassword(params);
  }
}
