abstract class SignInState {}

class SignInInitial extends SignInState{}
class SignInLoading extends SignInState{}
class SignInSuccessfull extends SignInState{}
class SignInValidErrol extends SignInState{
  final Map<String, String> errolSignIn;

  SignInValidErrol(this.errolSignIn);
}
class SignInFailure extends SignInState{
  final String? messages;
  SignInFailure({this.messages});
}