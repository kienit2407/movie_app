import 'package:dartz/dartz.dart';
import 'package:movie_app/core/errol/failure.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

abstract class UseCaseLegacy<Error, Type, Params> {
  Future<Either<Error, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
