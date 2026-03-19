abstract class ResetPasswordState {}

class ResetPasswordInitial extends ResetPasswordState{}
class ResetPasswordLoading extends ResetPasswordState{}
class ResetPasswordSuccessfull extends ResetPasswordState{}
class ResetPasswordValidErrol extends ResetPasswordState{
  final Map<String, String> errolResetPassword;

  ResetPasswordValidErrol(this.errolResetPassword);
}
class ResetPasswordFailure extends ResetPasswordState{
  final String? messages;
  ResetPasswordFailure({this.messages});
}