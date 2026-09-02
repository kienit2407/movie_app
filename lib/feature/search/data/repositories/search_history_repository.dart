import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class SearchHistoryRepository {
  String? get currentUserId;
  Stream<String?> get userChanges;

  Future<List<String>> getHistory();
  Future<void> saveKeyword(String keyword);
  Future<void> deleteKeyword(String keyword);
}

class SupabaseSearchHistoryRepository implements SearchHistoryRepository {
  SupabaseSearchHistoryRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  @override
  Stream<String?> get userChanges => _client.auth.onAuthStateChange
      .map((_) => _client.auth.currentUser?.id)
      .distinct();

  @override
  Future<List<String>> getHistory() async {
    final userId = currentUserId;
    if (userId == null) return const [];
    final response = await _client
        .from('user_search_history')
        .select('keyword')
        .eq('user_id', userId)
        .order('searched_at', ascending: false)
        .limit(30);
    return response
        .map((row) => row['keyword']?.toString().trim() ?? '')
        .where((keyword) => keyword.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<void> saveKeyword(String keyword) async {
    final userId = currentUserId;
    final value = keyword.trim();
    if (userId == null || value.isEmpty) return;
    await _client.from('user_search_history').upsert({
      'user_id': userId,
      'keyword': value,
      'normalized_keyword': value.toLowerCase(),
      'searched_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id,normalized_keyword');
  }

  @override
  Future<void> deleteKeyword(String keyword) async {
    final userId = currentUserId;
    final value = keyword.trim().toLowerCase();
    if (userId == null || value.isEmpty) return;
    await _client
        .from('user_search_history')
        .delete()
        .eq('user_id', userId)
        .eq('normalized_keyword', value);
  }
}
