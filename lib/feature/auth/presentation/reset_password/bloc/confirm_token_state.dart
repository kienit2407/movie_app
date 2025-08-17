abstract class ConfirmTokenState {}

class ConfirmTokenInitial extends ConfirmTokenState{}
class ConfirmTokenLoading extends ConfirmTokenState{}
class ConfirmTokenSuccessfull extends ConfirmTokenState{}
class ConfirmTokenValidErrol extends ConfirmTokenState{
  final Map<String, String> errolConfirmToken;

  ConfirmTokenValidErrol(this.errolConfirmToken);
}
class ConfirmTokenFailure extends ConfirmTokenState{
  final String? messages;
  ConfirmTokenFailure({this.messages});
}