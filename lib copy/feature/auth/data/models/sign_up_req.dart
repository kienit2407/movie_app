// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class SignUpReq {
  final String fullname;
  final String email;
  final String password;

  SignUpReq({
    required this.fullname,
    required this.email,
    required this.password,
  });
}
