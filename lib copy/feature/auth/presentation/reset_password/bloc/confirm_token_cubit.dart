import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/common/helpers/validator/auth_validator.dart';
import 'package:movie_app/feature/auth/data/models/confirm_token.dart';
import 'package:movie_app/feature/auth/domain/usecases/confirm_with_token.dart';
import 'package:movie_app/feature/auth/presentation/reset_password/bloc/confirm_token_state.dart';

class ConfirmTokenCubit extends Cubit<ConfirmTokenState> {
  final ConfirmWithTokenUsecase confirmWithTokenUsecase;

  ConfirmTokenCubit(this.confirmWithTokenUsecase)
    : super(ConfirmTokenInitial());

  Future<void> confirmWithTokenToResetPassword(
    ConfirmToken confirmToken,
  ) async {
    final errolEmail = ResetPasswordValidator().validate(confirmToken.email);
    if (errolEmail.isNotEmpty) {
      emit(ConfirmTokenValidErrol(errolEmail));
      return;
    }
    emit(ConfirmTokenLoading());
    final result = await confirmWithTokenUsecase(confirmToken);
    result.fold(
      (l) {
        emit(ConfirmTokenFailure(messages: l));
      },
      (r) {
        emit(ConfirmTokenSuccessfull());
      },
    );
  }
}
