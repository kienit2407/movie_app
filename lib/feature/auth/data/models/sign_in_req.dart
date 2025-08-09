// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class SignInReq {
  final String email;
  final String password;

  SignInReq({
    required this.email,
    required this.password,
  });
}
