import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final InitSupabase supaBaseInit = InitSupabase();

class InitSupabase {
  Future<void> initSupabase() async {
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
      throw StateError(
        'Thiếu SUPABASE_URL hoặc SUPABASE_ANON_KEY trong assets/.env',
      );
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
  }
}
