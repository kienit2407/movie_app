abstract class SignUpState {}

class SignUpInitial extends SignUpState{}
class SignUpLoading extends SignUpState{}
class SignUpSuccessfull extends SignUpState{}
class SignUpValidErrol extends SignUpState{
  final Map<String, String> errolSignUp;

  SignUpValidErrol(this.errolSignUp);
}
class SignUpFailure extends SignUpState{
  final String? messages;
  SignUpFailure({this.messages});
}