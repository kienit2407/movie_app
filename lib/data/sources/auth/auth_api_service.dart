import 'package:dartz/dartz.dart';

abstract class AuthApiService {
  
  Future<Either> signUp();
}

class AuthApiServiceImpl extends AuthApiService {
  @override
  Future<Either> signUp() {
    // TODO: implement signUp
    throw UnimplementedError();
  }

} 