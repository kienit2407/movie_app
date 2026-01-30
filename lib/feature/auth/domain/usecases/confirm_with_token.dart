import 'package:dartz/dartz.dart';
import 'package:movie_app/core/config/usecase/use_case.dart';
import 'package:movie_app/feature/auth/data/models/confirm_token.dart';
import 'package:movie_app/feature/auth/domain/repositories/auth_repository.dart';

class ConfirmWithTokenUsecase
    extends UseCaseLegacy<dynamic, dynamic, ConfirmToken> {
  final AuthRepository repository;

  ConfirmWithTokenUsecase(this.repository);

  @override
  Future<Either<dynamic, dynamic>> call(ConfirmToken params) async {
    return await repository.confirmTokenOtpEmail(params);
  }
}
