abstract class UseCase <Type, Params> {
  //Type <- là kiểu trả về cua rhafm đó
  // Params <- chứa thông tin mật khẩu model 
  Future<Type> call({required Params params});
}