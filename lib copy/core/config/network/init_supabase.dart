import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//tạo instance thay thế cách khai báo hàm static thông thường
InitSupabase supaBaseInit = InitSupabase(); //cách 2
// InitSupabase get supaBaseInit => InitSupabase(); //cách 1
class InitSupabase {
  Future<void> initSupabase () async {
    //dùng try catch tránh crash app khi api bị sai 
  try {
    await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!, //<- tránh trường hợp null và bị crash app
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    
  );
    print('Khởi tạo thành công');
  } catch (e) {
    print('Lỗi khi khởi tạo env: $e');
  }
  }
}