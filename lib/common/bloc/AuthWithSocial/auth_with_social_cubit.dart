import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/common/bloc/AuthWithSocial/auth_with_social_state.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/feature/auth/domain/usecases/sigin_with_google.dart';

class AuthWithSocialCubit extends Cubit<AuthWithSocialState> {
  AuthWithSocialCubit() : super(AuthWithSocialInitial());
  Future<void> signInWithGoogle() async {
    //load api
    emit(AuthWithSocialLoading());
    final result = await sl<SiginWithGoogleUsecase>().call();
    result.fold(
      (haveError) {
        if(haveError != 'Cancel'){
          emit(AuthWithSocialFailure(messages: haveError));
        }else {
          emit(AuthWithSocialInitial()); // Huỷ bỏ
        }
      },
      (succesesfull) {
        emit(AuthWithSocialSuccessfull());
      },
    );
  }
}
