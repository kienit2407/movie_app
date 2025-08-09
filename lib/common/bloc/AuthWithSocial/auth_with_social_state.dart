abstract class AuthWithSocialState {}

class AuthWithSocialInitial extends AuthWithSocialState {}

class AuthWithSocialLoading extends AuthWithSocialState {}

class AuthWithSocialSuccessfull extends AuthWithSocialState {
}

class AuthWithSocialFailure extends AuthWithSocialState {
  final String? messages;
  AuthWithSocialFailure({this.messages});
}
