import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce/hive.dart';

class TokenStorage {
  static const _boxName = 'authToken';
  static const _refreshKey= 'refreshToken';
  static const _accessKey= 'accessToken';
  final String _hiveKey = dotenv.env['HIVE_KEY']!;
  
  final _secureFluter = FlutterSecureStorage();
  // Go ahead create amount of methods for using from other class
  Future<Box> _openBox  () async {
    String? encryptionKey = await _secureFluter.read(key: _hiveKey); // kiểm tra key của hive trong flutter secure xem có hay không
    if(encryptionKey == null) {
      final newKey = Hive.generateSecureKey(); 
      await _secureFluter.write(key: _hiveKey, value: base64UrlEncode(newKey));
      encryptionKey = base64UrlEncode(newKey);
    }
    final key = base64Url.decode(encryptionKey);
    return await Hive.openBox(_boxName, encryptionCipher: HiveAesCipher(key));
  }

  Future<String?> getAccessToken () async {
    final box = await _openBox();
    return box.get(_accessKey);
  }
  Future<String?> getRefreshToken () async {
    final box = await _openBox();
    return box.get(_refreshKey);
  }
  Future<void> saveToken (String accessToken, String refreshToken) async {
    final box = await _openBox();
    box.put(_accessKey, accessToken);
    box.put(_refreshKey, refreshToken);
  }

  Future<void> clearToken () async {
    final box = await _openBox();
    box.clear();
  }
}