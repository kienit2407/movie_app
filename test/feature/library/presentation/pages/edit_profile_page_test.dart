import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/feature/library/data/user_library_repository.dart';
import 'package:movie_app/feature/library/presentation/cubit/user_library_cubit.dart';
import 'package:movie_app/feature/library/presentation/pages/edit_profile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  testWidgets('shows email as read-only profile information', (tester) async {
    final cubit = _createCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(_TestApp(cubit: cubit));
    await tester.pumpAndSettle();

    expect(find.text('Sửa hồ sơ'), findsOneWidget);
    expect(find.text('Liquid User'), findsOneWidget);
    expect(find.text('user@example.com'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
  });

  testWidgets('opens avatar actions and the separate name editor', (
    tester,
  ) async {
    final cubit = _createCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(_TestApp(cubit: cubit));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Thay đổi ảnh'));
    await tester.pumpAndSettle();
    expect(find.text('Chụp ảnh'), findsOneWidget);
    expect(find.text('Tải ảnh lên'), findsOneWidget);
    expect(find.text('Xem ảnh'), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Liquid User'));
    await tester.pumpAndSettle();

    expect(find.text('Hủy'), findsOneWidget);
    expect(find.text('Lưu'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}

UserLibraryCubit _createCubit() {
  final client = SupabaseClient(
    'https://example.supabase.co',
    'anon-key',
    authOptions: const AuthClientOptions(autoRefreshToken: false),
  );
  return UserLibraryCubit(
    repository: _EditProfileRepository(),
    client: client,
    authChanges: const Stream<AuthState>.empty(),
  );
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.cubit});

  final UserLibraryCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(),
        home: const EditProfilePage(),
      ),
    );
  }
}

class _EditProfileRepository implements UserLibraryRepository {
  final User _user = User(
    id: 'user-1',
    appMetadata: const {},
    userMetadata: const {'full_name': 'Liquid User'},
    aud: 'authenticated',
    email: 'user@example.com',
    createdAt: '2026-08-11T00:00:00Z',
  );

  @override
  User get currentUser => _user;

  @override
  Future<UserProfile> getProfile() async => UserProfile.fromUser(_user);

  @override
  Future<void> addFavorite(UserFavorite favorite) async {}

  @override
  Future<List<UserFavorite>> getFavorites() async => const [];

  @override
  Future<List<UserWatchHistory>> getWatchHistory() async => const [];

  @override
  Future<void> removeFavorite(String slug) async {}

  @override
  Future<void> removeFavorites(Iterable<String> slugs) async {}

  @override
  Future<void> removeWatchHistory(String slug) async {}

  @override
  Future<void> removeWatchHistoryItems(Iterable<String> slugs) async {}

  @override
  Future<UserProfile> updateProfile({
    required String displayName,
    String? avatarUrl,
  }) async => UserProfile(displayName: displayName, avatarUrl: avatarUrl ?? '');

  @override
  Future<String> uploadAvatar(
    Uint8List bytes, {
    required String extension,
  }) async => 'https://example.com/avatar.$extension';

  @override
  Future<void> upsertWatchHistory(UserWatchHistory history) async {}
}
