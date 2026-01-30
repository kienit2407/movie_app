import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/common/helpers/validator/auth_validator.dart';
import 'package:movie_app/feature/auth/data/models/sign_in_req.dart';
import 'package:movie_app/feature/auth/domain/usecases/sign_in.dart';
import 'package:movie_app/feature/auth/presentation/sign_in/bloc/sign_in_state.dart';

class SignInCubit extends Cubit<SignInState> {
  final SignInUsecase signInUsecase;

  SignInCubit(this.signInUsecase) : super(SignInInitial());

  Future<void> signIn(SignInReq signInReq) async {
    final errolSignIn = SignInValidator().validate(signInReq);

    if (errolSignIn.isNotEmpty) {
      emit(SignInValidErrol(errolSignIn));
      return;
    }

    emit(SignInLoading());
    final result = await signInUsecase(signInReq);
    result.fold(
      (messageSigIn) {
        emit(SignInFailure(messages: messageSigIn));
      },
      (r) {
        emit(SignInSuccessfull());
      },
    );
  }
}
