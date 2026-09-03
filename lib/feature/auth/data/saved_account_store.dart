import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SavedAccount {
  const SavedAccount({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.avatarUrl,
    required this.accessToken,
    required this.refreshToken,
    required this.updatedAt,
  });

  final String userId;
  final String email;
  final String displayName;
  final String avatarUrl;
  final String accessToken;
  final String refreshToken;
  final DateTime updatedAt;

  factory SavedAccount.fromSession(Session session) {
    final user = session.user;
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final email = user.email?.trim() ?? '';
    final displayName = _firstNonEmpty(<Object?>[
      metadata['full_name'],
      metadata['name'],
      metadata['user_name'],
      email.isEmpty ? null : email.split('@').first,
    ]);

    return SavedAccount(
      userId: user.id,
      email: email,
      displayName: displayName,
      avatarUrl: _firstNonEmpty(<Object?>[
        metadata['avatar_url'],
        metadata['picture'],
      ]),
      accessToken: session.accessToken,
      refreshToken: session.refreshToken ?? '',
      updatedAt: DateTime.now().toUtc(),
    );
  }

  factory SavedAccount.fromJson(Map<String, dynamic> json) {
    return SavedAccount(
      userId: json['userId']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString() ?? '',
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  bool get canRestore =>
      userId.isNotEmpty && accessToken.isNotEmpty && refreshToken.isNotEmpty;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'userId': userId,
    'email': email,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'updatedAt': updatedAt.toIso8601String(),
  };
}

class SavedAccountStore {
  SavedAccountStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.unlocked_this_device,
            ),
          );

  static const _storageKey = 'liquid_phim_saved_accounts_v1';

  final FlutterSecureStorage _storage;
  Future<void> _pendingOperation = Future<void>.value();

  Future<List<SavedAccount>> readAccounts() {
    return _serialized(_readAccountsUnlocked);
  }

  Future<void> saveSession(Session session) {
    return _serialized(() async {
      final account = SavedAccount.fromSession(session);
      if (!account.canRestore) return;

      final accounts = await _readAccountsUnlocked();
      accounts.removeWhere((item) => item.userId == account.userId);
      accounts.insert(0, account);
      await _writeAccountsUnlocked(accounts);
    });
  }

  Future<void> removeAccount(String userId) {
    return _serialized(() async {
      final accounts = await _readAccountsUnlocked();
      accounts.removeWhere((account) => account.userId == userId);
      await _writeAccountsUnlocked(accounts);
    });
  }

  Future<List<SavedAccount>> _readAccountsUnlocked() async {
    final encoded = await _storage.read(key: _storageKey);
    if (encoded == null || encoded.isEmpty) return <SavedAccount>[];

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! List) return <SavedAccount>[];
      final accounts = decoded
          .whereType<Map>()
          .map((item) => SavedAccount.fromJson(item.cast<String, dynamic>()))
          .where((account) => account.canRestore)
          .toList(growable: true);
      accounts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return accounts;
    } on Object {
      // Treat malformed local data as an empty account list. Storage plugin
      // failures still surface because the platform read happens above.
      return <SavedAccount>[];
    }
  }

  Future<void> _writeAccountsUnlocked(List<SavedAccount> accounts) {
    return _storage.write(
      key: _storageKey,
      value: jsonEncode(
        accounts.map((account) => account.toJson()).toList(growable: false),
      ),
    );
  }

  Future<T> _serialized<T>(Future<T> Function() operation) {
    final completer = Completer<T>();
    _pendingOperation = _pendingOperation.then((_) async {
      try {
        completer.complete(await operation());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }
}

String _firstNonEmpty(Iterable<Object?> values) {
  for (final value in values) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
  }
  return '';
}
