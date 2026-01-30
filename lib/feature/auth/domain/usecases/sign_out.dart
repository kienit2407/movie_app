import 'package:dartz/dartz.dart';
import 'package:movie_app/core/config/usecase/use_case.dart';
import 'package:movie_app/feature/auth/domain/repositories/auth_repository.dart';

class SignOutUsecase extends UseCaseLegacy<dynamic, dynamic, NoParams> {
  final AuthRepository repository;

  SignOutUsecase(this.repository);

  @override
  Future<Either<dynamic, dynamic>> call(NoParams params) async {
    return await repository.signOut();
  }
}
