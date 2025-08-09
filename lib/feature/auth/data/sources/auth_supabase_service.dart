import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:movie_app/core/errol/failure.dart';
import 'package:movie_app/feature/auth/data/models/sign_in_req.dart';
import 'package:movie_app/feature/auth/data/models/sign_up_req.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthSupabaseService {
  Future<Either> signUp(SignUpReq signUpReq);
  Future<Either> signIn(SignInReq signInReq);
  Future<Either> signInWithGoogle();
}

class AuthSupabaseServiceImpl extends AuthSupabaseService {
  final supaBaseAuth = Supabase.instance.client; // tạo instance

  @override
  Future<Either> signUp(SignUpReq signUpReq) async {
    try {
      final response = await supaBaseAuth.auth.signUp(
        email: signUpReq.email,
        password: signUpReq.password,
      );
      if (response.user == null) {
        Left('Sign up was failded. Please try again!');
      }
      return Right("Sign up successefull");
    } on AuthException catch (e) {
      return Left(AuthFailure.mapErrol(e.message));
    } catch (e) {
      print('Lỗi không xác định: $e');
      return Left(AuthFailure.mapErrol(e.toString()));
    }
  }

  @override
  Future<Either> signIn(SignInReq signInReq) async {
    try {
      final response = await supaBaseAuth.auth.signInWithPassword(
        email: signInReq.email,
        password: signInReq.password,
      );
      if (response.user == null) {
        Left('Sign in was failded. Please try again!');
      }
      return Right("Sign in successefull");
    } on AuthException catch (e) {
      return Left(AuthFailure.mapErrol(e.message));
    } catch (e) {
      print('Lỗi không xác định: $e');
      return Left(AuthFailure.mapErrol(e.toString()));
    }
  }

  @override
  Future<Either> signInWithGoogle() async {
    try {
      final webClientId = dotenv.env['WEB_CLIENT_ID'];
      final iosClientId = dotenv.env['IOS_CLIENT_ID'];

      final googleSignin = GoogleSignIn.instance; //khởi tại instacne cho gg
      await googleSignin.initialize(
        // bắt đầu khởi động gg
        clientId: iosClientId,
        serverClientId: webClientId,
      );

      final googleAccount = await googleSignin.authenticate();
      final idToken = googleAccount.authentication.idToken;

      if (idToken == null) {
        return Left('The token is failed!');
      } else {
        print('Retrive token successfully');
      }
      final response = await supaBaseAuth.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      if (response.user == null) {
        Left('Sign in was failded. Please try again!');
      }
      return Right('Sign in successfull');
    } on GoogleSignInException catch (e) {
      return Left(
        'Cancel',
      );
    } catch (e) {
      print('Lỗi không xác định: $e');
      return Left(
        'Have an errol occured. Please try again or contact with me:  0971161803',
      );
    }
  }
}

/*
- client_id chỉ là id để định danh ứng dụng vớim áy chủ OAuth của gg 
- Supabase đóng vai tro fnhuw một backend, tin tưởng các token được cung cấp từ gg SDK 
- Luồng hoạt động như sau;
  + Khi người dùng agree and authorization thì gg sẽ trả về mọt mã uỷ quyền cho sever của mình (trường hợp tự build) sao đó sever sẽ gửi cái mã đén g đẻ lấy được mã id_token <- nơi chứa thông tin người dùng và id_access
  + Và client secret trong lúc này là yêu cần trong bước trao đổi token để xác thực phía server của mình. đảm bảo chỉ có server đáng tin cậy mới thực hiện được trao đổt này (bởi nếu chỉ có client id mà không có supabase(1 sever is reliabled absolutlly) còn nếu người kahc hoặc hacker sử dụng một một server kach cần phải là người sở hữu của phía gg)
 */
