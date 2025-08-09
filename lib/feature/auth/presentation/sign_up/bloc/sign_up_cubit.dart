import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/common/helpers/validator/auth_validator.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/feature/auth/data/models/sign_up_req.dart';
import 'package:movie_app/feature/auth/domain/usecases/sign_up.dart';
import 'package:movie_app/feature/auth/presentation/sign_up/bloc/sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit() : super(SignUpInitial());

  Future<void> signUp(SignUpReq signUpReq) async {
    final errolSignUp = SignUpValidator().validate(signUpReq);

    if (errolSignUp.isNotEmpty) {
      emit(SignUpValidErrol(errolSignUp));
      return;
    }

    //load api
    emit(SignUpLoading());

    final result = await sl<SignUpUsecase>().call(params: signUpReq);
    result.fold(
      (haveError) {
        emit(SignUpFailure(messages: haveError));
      },
      (succesesfull) {
        emit(SignUpSuccessfull());
      },
    );
  }
}
