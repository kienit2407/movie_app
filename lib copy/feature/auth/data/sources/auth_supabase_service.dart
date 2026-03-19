import 'package:dartz/dartz.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:movie_app/core/errol/failure.dart';
import 'package:movie_app/feature/auth/data/models/confirm_token.dart';
import 'package:movie_app/feature/auth/data/models/sign_in_req.dart';
import 'package:movie_app/feature/auth/data/models/sign_up_req.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthService {
  Future<Either> signUp(SignUpReq signUpReq);
  Future<Either> signIn(SignInReq signInReq);
  Future<Either> signInWithGoogle();
  Future<Either> signInWithFaceBook();
  Future<Either> sendReqResetPassword(String email);
  Future<Either> signOut();
  Future<Either> confirmTokenOtpEmail(ConfirmToken confirmToken);
}
// class AuthFirebaeServiceImpl extends AuthService{
//   //init intance firebase
//   final firebaseAuth = FirebaseAuth.instance;
//   final firebaseFireStore = Fire;

//   @override
//   Future<Either> sendReqResetPassword(Object email) {
//     // TODO: implement sendReqResetPassword
//     throw UnimplementedError();
//   }

//   @override
//   Future<Either> signIn(SignInReq signInReq) {
//     // TODO: implement signIn
//     throw UnimplementedError();
//   }

//   @override
//   Future<Either> signInWithFaceBook() {
//     // TODO: implement signInWithFaceBook
//     throw UnimplementedError();
//   }

//   @override
//   Future<Either> signInWithGoogle() {
//     // TODO: implement signInWithGoogle
//     throw UnimplementedError();
//   }

//   @override
//   Future<Either> signOut() {
//     // TODO: implement signOut
//     throw UnimplementedError();
//   }

//   @override
//   Future<Either> signUp(SignUpReq signUpReq) {
//     // TODO: implement signUp
//     throw UnimplementedError();
//   }
// }

class AuthSupabaseServiceImpl implements AuthService {
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
      return Left(AuthFailure.mapError(e.message));
    } catch (e) {
      print('Lỗi không xác định: $e');
      return Left(AuthFailure.mapError(e.toString()));
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
      return Left(AuthFailure.mapError(e.message));
    } catch (e) {
      print('Lỗi không xác định: $e');
      return Left(AuthFailure.mapError(e.toString()));
    }
  }

  @override
  Future<Either> signInWithGoogle() async {
    try {
      final webClientId = dotenv.env['WEB_CLIENT_ID'];
      final iosClientId =
          dotenv.env['IOS_CLIENT_ID']; //<- mã định danh ứng dụng mobile

      final googleSignin =
          GoogleSignIn.instance; //khởi tại instacne cho gg (một singleton)

      await googleSignin.initialize(
        // bắt đầu khởi động gg
        clientId: iosClientId,
        serverClientId: webClientId, //<- để lấy idtoken
      );

      final googleAccount = await googleSignin
          .authenticate(); //<- mở trình đăng nhập, để cho người dùng uỷ quyền, và gửi đi để yêu cầu token
      final idToken =
          googleAccount.authentication.idToken; //<- yêu càu token và trả về
      if (idToken == null) {
        return Left('The user canceled login!');
      }

      final response = await supaBaseAuth.auth.signInWithIdToken(
        //gửi token sang cho supabase để supa xác nhận chữ ký
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      if (response.user == null) {
        return Left('Sign in was failded. Please try again!');
      }
      return Right('Sign in successfull');
    } on GoogleSignInException {
      return Left('The user canceled login!');
    } catch (e) {
      print('Lỗi không xác định: $e');
      return Left(
        'Have an errol occured. Please try again or contact with me:  0971161803',
      );
    }
  }

  @override
  Future<Either> signInWithFaceBook() async {
    final status = await Permission.appTrackingTransparency.request();
    print('Permission Status: $status'); // Debug trạng thái quyền

    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile'],
      ); // by default we

      final accessToken = result.accessToken;
      print('Access Token: ${accessToken}');
      if (accessToken == null) {
        return Left('The user canceled login!');
      }

      final response = await supaBaseAuth.auth.signInWithIdToken(
        //gửi token sang cho supabase để supa xác nhận chữ ký
        provider: OAuthProvider.facebook,
        idToken: accessToken.toString(),
      );

      if (response.user == null) {
        return Left('Sign in was failded. Please try again!');
      }
      return Right('Sign in successfull');
    } catch (e) {
      print('Lỗi chi tiết: $e');
      return Left('An error occurred. Please try again or contact: 0971161803');
    }
  }

  @override
  Future<Either> signOut() async {
    try {
      await supaBaseAuth.auth.signOut();
      return Right('Sign out successfull');
    } catch (e) {
      print('Lỗi không xác định: $e');
      return Left(
        'Have an errol occured. Please try again or contact with me:  0971161803',
      );
    }
  }

  @override
  Future<Either> sendReqResetPassword(String email) async {
    // reset password cần email để có thể gửi mail về
    try {
      await supaBaseAuth.auth.resetPasswordForEmail(email);
      return Right(
        'Password for reseting email sent to your email. Pls check now',
      );
    } catch (e) {
      print('Lỗi không xác định: $e');
      return Left(
        'Have an errol occured. Please try again or contact with me:  0971161803',
      );
    }
  }

  @override
  Future<Either> confirmTokenOtpEmail(ConfirmToken confirmToken) async {
    try {
      await supaBaseAuth.auth.verifyOTP(
        token: confirmToken.token,
        email: confirmToken.email,
        type: OtpType.recovery,
      );
      return Right('Xác nhận đúng token');
    } catch (e) {
      print(e);
      return Left('Token nhập sai');
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
