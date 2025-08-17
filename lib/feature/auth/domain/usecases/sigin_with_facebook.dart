import 'package:dartz/dartz.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/core/config/usecase/use_case.dart';
import 'package:movie_app/feature/auth/domain/repositories/auth_repository.dart';

class SiginWithFacebookUsecase extends UseCase <Either, dynamic> {
  @override
  Future<Either> call({params}) async {
    return await sl<AuthRepository>().signInWithFacebook();
  }
}