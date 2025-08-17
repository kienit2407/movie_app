import 'package:email_validator/email_validator.dart';
import 'package:movie_app/feature/auth/data/models/sign_in_req.dart';
import 'package:movie_app/feature/auth/data/models/sign_up_req.dart';

abstract class AuthValidator <Params> {
  Map<String, String> validate (Params params);
}

class SignUpValidator extends AuthValidator <SignUpReq> {
  @override
  Map<String, String> validate(SignUpReq params) {
    final errols = <String, String>{};

    final fullName = params.fullname;
    final email = params.email;
    final password = params.password;

    //Full Name
    if(fullName.isEmpty){
      errols['fullname'] = 'Fullname can not be blank!';
      return errols;
    } 
    else if (fullName.length < 3) {
      errols['fullname'] = 'Display name must from 3-15 character!';
      return errols;
    }
    //email
    if(email.isEmpty){
      errols['email'] = 'Email can not be blank!';
      return errols;
    }
    else if (!EmailValidator.validate(email)) {
      errols['email'] = 'Email is incorrected format!';
      return errols;
    }
    //password
    if(password.isEmpty){
      errols['password'] = 'Password can not be blank!';
      return errols;
    }
    if(password.length < 6) {
      errols['password'] = 'Password must from 6-15 character!';
      return errols;
    }
    return errols;
  }
  
}
class SignInValidator extends AuthValidator <SignInReq> {
  @override
  Map<String, String> validate(SignInReq params) {
    final errols = <String, String>{};

    final email = params.email;
    final password = params.password;
    //email
    if(email.isEmpty){
      errols['email'] = 'Email can not be blank!';
      return errols;
    }
    else if (!EmailValidator.validate(email)) {
      errols['email'] = 'Email is incorrected format!';
      return errols;
    }
    //password
    if(password.isEmpty){
      errols['password'] = 'Password can not be blank!';
      return errols;
    }
    if(password.length < 6) {
      errols['password'] = 'Password must from 6-15 character!';
      return errols;
    }
    return errols;
  }
  
}
class ResetPasswordValidator extends AuthValidator <String> {
  @override
  Map<String, String> validate(String params) {
    final errols = <String, String>{};
    //email
    if(params.isEmpty){
      errols['email'] = 'Email can not be blank!';
      return errols;
    }
    else if (!EmailValidator.validate(params)) {
      errols['email'] = 'Email is incorrected format!';
      return errols;
    }
    return errols;
  }
}