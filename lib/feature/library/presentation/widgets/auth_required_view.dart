import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/feature/auth/presentation/sign_in/pages/sign_in.dart';

class AuthRequiredView extends StatelessWidget {
  const AuthRequiredView({
    super.key,
    required this.title,
    required this.description,
    this.onSignedIn,
  });

  final String title;
  final String description;
  final VoidCallback? onSignedIn;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .07),
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(Iconsax.user, size: 44, color: Colors.white70),
            ),
            const SizedBox(height: 22),

            Container(
              decoration: BoxDecoration(
                color: AppColor.secondColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final signedIn = await SignInPage.showSheet(context);
                  if (signedIn && context.mounted) onSignedIn?.call();
                },
                icon: const Icon(Iconsax.login_1_copy),
                label: const Text(
                  'Tham gia thành viên',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
