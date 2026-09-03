import 'package:dartz/dartz.dart';
import 'package:movie_app/core/config/usecase/use_case.dart';
import 'package:movie_app/feature/auth/domain/repositories/auth_repository.dart';

class GoogleSignInParams {
  const GoogleSignInParams({this.forceAccountPicker = false});

  final bool forceAccountPicker;
}

class SiginWithGoogleUsecase
    extends UseCaseLegacy<dynamic, dynamic, GoogleSignInParams> {
  final AuthRepository repository;

  SiginWithGoogleUsecase(this.repository);

  @override
  Future<Either<dynamic, dynamic>> call(GoogleSignInParams params) async {
    return await repository.signInWithGoogle(
      forceAccountPicker: params.forceAccountPicker,
    );
  }
}
