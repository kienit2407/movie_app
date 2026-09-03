import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/common/bloc/AuthWithSocial/auth_with_social_cubit.dart';
import 'package:movie_app/common/bloc/AuthWithSocial/auth_with_social_state.dart';
import 'package:movie_app/common/components/orther/app_option.dart';
import 'package:movie_app/core/config/assets/app_image.dart';
import 'package:movie_app/core/config/routes/app_router.dart';
import 'package:movie_app/core/extension/build_context_extension.dart';
import 'package:movie_app/feature/auth/presentation/session/auth_session_cubit.dart';

enum SignInPresentation { page, sheet }

class SignInPage extends StatefulWidget {
  const SignInPage({
    super.key,
    this.presentation = SignInPresentation.page,
    this.forceGoogleAccountPicker = false,
  });

  final SignInPresentation presentation;
  final bool forceGoogleAccountPicker;

  static Future<bool> showSheet(
    BuildContext context, {
    bool forceGoogleAccountPicker = false,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.62),
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 320),
        reverseDuration: Duration(milliseconds: 240),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<AuthWithSocialCubit>(),
        child: SignInPage(
          presentation: SignInPresentation.sheet,
          forceGoogleAccountPicker: forceGoogleAccountPicker,
        ),
      ),
    );
    return result == true;
  }

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  String? _errorMessage;

  bool get _isSheet => widget.presentation == SignInPresentation.sheet;

  @override
  void initState() {
    super.initState();
    context.read<AuthWithSocialCubit>().reset();
  }

  @override
  Widget build(BuildContext context) {
    final content = BlocConsumer<AuthWithSocialCubit, AuthWithSocialState>(
      listener: (context, state) {
        if (state is AuthWithSocialFailure) {
          setState(() {
            _errorMessage = context.l10n.authGoogleSignInFailed;
          });
        }
        if (state is AuthWithSocialSuccessfull) {
          context.read<AuthSessionCubit>().refresh();
          if (_isSheet) {
            Navigator.of(context).pop(true);
          } else if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(true);
          } else {
            context.go(AppRoutes.home);
          }
        }
      },
      builder: (context, state) {
        return _SignInContent(
          isSheet: _isSheet,
          isLoading: state is AuthWithSocialLoading,
          errorMessage: _errorMessage,
          onClose: () => Navigator.of(context).maybePop(false),
          onGooglePressed: () {
            setState(() => _errorMessage = null);
            context.read<AuthWithSocialCubit>().signInWithGoogle(
              forceAccountPicker: widget.forceGoogleAccountPicker,
            );
          },
        );
      },
    );

    if (_isSheet) {
      return content;
    }

    return Scaffold(backgroundColor: const Color(0xff111119), body: content);
  }
}

class _SignInContent extends StatelessWidget {
  const _SignInContent({
    required this.isSheet,
    required this.isLoading,
    required this.errorMessage,
    required this.onClose,
    required this.onGooglePressed,
  });

  final bool isSheet;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onClose;
  final VoidCallback onGooglePressed;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return ClipRRect(
      borderRadius: isSheet
          ? const BorderRadius.vertical(top: Radius.circular(30))
          : BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xff251A38), Color(0xff15151E), Color(0xff0E0E14)],
            ),
          ),
          child: SafeArea(
            top: !isSheet,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                isSheet ? 10 : 18,
                24,
                28 + bottomInset,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: isSheet
                      ? 400
                      : MediaQuery.sizeOf(context).height - 80,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Header(isSheet: isSheet, onClose: onClose),
                    SizedBox(height: isSheet ? 22 : 46),
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        image: DecorationImage(
                          image: AssetImage(AppImage.splashIcon),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      context.l10n.authSignInTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isSheet
                          ? context.l10n.authSignInToComment
                          : context.l10n.authGoogleSyncDescription,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.66),
                        fontSize: 14.5,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 30),
                    AppOption(
                      isLoading: isLoading,
                      onGooglePressed: onGooglePressed,
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      child: errorMessage == null
                          ? const SizedBox(height: 18)
                          : Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xffFF6B81,
                                  ).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(
                                      0xffFF6B81,
                                    ).withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Text(
                                  errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xffFFB3BE),
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    Text(
                      context.l10n.authGoogleConsent,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.38),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isSheet, required this.onClose});

  final bool isSheet;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    if (isSheet) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: context.l10n.commonClose,
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded, color: Colors.white),
            ),
          ),
        ],
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton.filledTonal(
        tooltip: context.l10n.commonBack,
        onPressed: onClose,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.08),
          foregroundColor: Colors.white,
        ),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
      ),
    );
  }
}
