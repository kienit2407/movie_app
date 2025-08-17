import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/common/helpers/validator/auth_validator.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/feature/auth/domain/usecases/req_reset_password.dart';
import 'package:movie_app/feature/auth/presentation/reset_password/bloc/reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit() : super (ResetPasswordInitial());
  Future<void> reqSendCodeReserPassword (String email) async {
    final errolEmail = ResetPasswordValidator().validate(email);
    if(errolEmail.isNotEmpty){
      emit(ResetPasswordValidErrol(errolEmail));
      return;
    }
    emit(ResetPasswordLoading());
    final result = await sl<ReqResetPasswordUsecase>().call(params: email);
    result.fold(
      (l){
        emit(ResetPasswordFailure(messages: l));
      }, 
      (r){
        emit(ResetPasswordSuccessfull());
      }
    );
  }
}