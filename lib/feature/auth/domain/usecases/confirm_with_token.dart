import 'package:dartz/dartz.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/core/config/usecase/use_case.dart';
import 'package:movie_app/feature/auth/data/models/confirm_token.dart';
import 'package:movie_app/feature/auth/domain/repositories/auth_repository.dart';

class ConfirmWithTokenUsecase extends UseCase <Either, ConfirmToken> {
  @override
  Future<Either> call({required ConfirmToken params}) async {
    return await sl<AuthRepository>().confirmTokenOtpEmail(params);
  }
}