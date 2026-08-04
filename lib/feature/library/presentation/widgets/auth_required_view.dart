import 'package:flutter/material.dart';
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
              child: const Icon(
                Icons.person_outline_rounded,
                size: 44,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .62),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: () async {
                final signedIn = await SignInPage.showSheet(context);
                if (signedIn && context.mounted) onSignedIn?.call();
              },
              icon: const Icon(Icons.login_rounded),
              label: const Text('Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}
