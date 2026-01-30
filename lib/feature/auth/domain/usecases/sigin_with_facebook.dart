import 'package:dartz/dartz.dart';
import 'package:movie_app/core/config/usecase/use_case.dart';
import 'package:movie_app/feature/auth/domain/repositories/auth_repository.dart';

class SiginWithFacebookUsecase
    extends UseCaseLegacy<dynamic, dynamic, NoParams> {
  final AuthRepository repository;

  SiginWithFacebookUsecase(this.repository);

  @override
  Future<Either<dynamic, dynamic>> call(NoParams params) async {
    return await repository.signInWithFacebook();
  }
}
