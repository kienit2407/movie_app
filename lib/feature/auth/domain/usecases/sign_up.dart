import 'package:dartz/dartz.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/core/config/usecase/use_case.dart';
import 'package:movie_app/feature/auth/data/models/sign_up_req.dart';
import 'package:movie_app/feature/auth/domain/repositories/auth_repository.dart';
//usecase là nơi thực hiện các logic thuần, để thực hiện 1 chức năng duy nhất
class SignUpUsecase extends UseCase <Either, SignUpReq> {
  @override
  Future<Either> call({required SignUpReq params}) async {
    return await sl<AuthRepository>().signUp(params);
  }
}