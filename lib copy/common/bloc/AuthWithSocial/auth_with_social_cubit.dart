import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/common/bloc/AuthWithSocial/auth_with_social_state.dart';
import 'package:movie_app/core/config/usecase/use_case.dart';
import 'package:movie_app/feature/auth/domain/usecases/sigin_with_facebook.dart';
import 'package:movie_app/feature/auth/domain/usecases/sigin_with_google.dart';

class AuthWithSocialCubit extends Cubit<AuthWithSocialState> {
  final SiginWithGoogleUsecase siginWithGoogleUsecase;
  final SiginWithFacebookUsecase siginWithFacebookUsecase;

  AuthWithSocialCubit(
    this.siginWithGoogleUsecase,
    this.siginWithFacebookUsecase,
  ) : super(AuthWithSocialInitial());

  Future<void> signInWithGoogle() async {
    emit(AuthWithSocialLoading());
    final result = await siginWithGoogleUsecase(const NoParams());
    result.fold(
      (haveError) {
        if (haveError == 'The user canceled login!') {
          emit(AuthWithSocialInitial());
        } else {
          emit(AuthWithSocialFailure(messages: haveError));
        }
      },
      (succesesfull) {
        emit(AuthWithSocialSuccessfull());
      },
    );
  }

  Future<void> signInWithFacebook() async {
    emit(AuthWithSocialLoading());
    final result = await siginWithFacebookUsecase(const NoParams());
    result.fold(
      (haveError) {
        if (haveError == 'The user canceled login!') {
          emit(AuthWithSocialInitial());
        } else {
          emit(AuthWithSocialFailure(messages: haveError));
        }
      },
      (succesesfull) {
        emit(AuthWithSocialSuccessfull());
      },
    );
  }
}
