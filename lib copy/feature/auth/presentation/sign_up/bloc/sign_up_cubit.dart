import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/common/helpers/validator/auth_validator.dart';
import 'package:movie_app/feature/auth/data/models/sign_up_req.dart';
import 'package:movie_app/feature/auth/domain/usecases/sign_up.dart';
import 'package:movie_app/feature/auth/presentation/sign_up/bloc/sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final SignUpUsecase signUpUsecase;

  SignUpCubit(this.signUpUsecase) : super(SignUpInitial());

  Future<void> signUp(SignUpReq signUpReq) async {
    final errolSignUp = SignUpValidator().validate(signUpReq);

    if (errolSignUp.isNotEmpty) {
      emit(SignUpValidErrol(errolSignUp));
      return;
    }

    emit(SignUpLoading());

    final result = await signUpUsecase(signUpReq);
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
