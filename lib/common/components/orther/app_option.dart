import 'package:flutter/material.dart';
import 'package:movie_app/core/config/assets/app_icon.dart';

class AppOption extends StatelessWidget {
  const AppOption({
    super.key,
    required this.onGooglePressed,
    this.isLoading = false,
  });

  final VoidCallback? onGooglePressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Tiếp tục với Google',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onGooglePressed,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: isLoading
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Color(0xff7C4DFF),
                        ),
                      )
                    : Row(
                        key: const ValueKey('label'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(AppIcon.appIconGoogle, width: 24),
                          const SizedBox(width: 12),
                          const Text(
                            'Tiếp tục với Google',
                            style: TextStyle(
                              color: Color(0xff202124),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
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
