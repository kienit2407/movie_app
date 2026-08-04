import 'package:movie_app/feature/comments/domain/entities/comment.dart';
import 'package:movie_app/feature/comments/domain/repositories/comment_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentSupabaseRepository implements CommentRepository {
  CommentSupabaseRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  final Set<String> _pendingMutations = <String>{};

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  @override
  Future<CommentPage> fetchComments({
    required String movieSlug,
    required CommentSort sort,
    required int offset,
    int limit = 20,
  }) async {
    final responses = await Future.wait<Object?>([
      _client.rpc(
        'get_movie_comments',
        params: {
          'p_movie_slug': movieSlug,
          'p_sort': sort == CommentSort.popular ? 'popular' : 'newest',
          'p_limit': limit,
          'p_offset': offset,
        },
      ),
      if (offset == 0)
        _client.rpc(
          'get_movie_comment_count',
          params: {'p_movie_slug': movieSlug},
        )
      else
        Future<Object?>.value(null),
    ]);

    final items = _mapRows(responses.first);
    final count = offset == 0
        ? _asInt(responses.last)
        : offset + items.length + (items.length == limit ? 1 : 0);

    return CommentPage(
      items: items,
      hasMore: items.length == limit,
      totalCount: count,
    );
  }

  @override
  Future<CommentPage> fetchReplies({
    required String rootCommentId,
    required int offset,
    int limit = 30,
  }) async {
    final params = {
      'p_root_comment_id': rootCommentId,
      'p_limit': limit,
      'p_offset': offset,
    };
    Object? response;
    try {
      response = await _client.rpc('get_comment_replies_v2', params: params);
    } on PostgrestException catch (error) {
      if (error.code != 'PGRST202') rethrow;
      response = await _client.rpc('get_comment_replies', params: params);
    }
    final items = _mapRows(response);
    return CommentPage(
      items: items,
      hasMore: items.length == limit,
      totalCount: offset + items.length,
    );
  }

  @override
  Future<Comment> createComment({
    required String movieSlug,
    required String body,
    String? rootCommentId,
    String? replyToUserId,
    String? replyToCommentId,
    String? replyToName,
  }) async {
    final user = _requireUser();
    final normalized = body.trim();
    return _guard('create:$movieSlug:$rootCommentId', () async {
      final values = <String, Object?>{
        'movie_slug': movieSlug,
        'user_id': user.id,
        'parent_id': rootCommentId,
        'reply_to_user_id': replyToUserId,
        'body': normalized,
      };
      if (replyToCommentId != null) {
        values['reply_to_comment_id'] = replyToCommentId;
      }
      Map<String, dynamic> row;
      try {
        row = await _insertComment(values);
      } on PostgrestException catch (error) {
        if (replyToCommentId == null || !_isMissingReplyTargetColumn(error)) {
          rethrow;
        }
        if (rootCommentId != null && replyToCommentId != rootCommentId) {
          throw const CommentThreadPersistenceException(
            'Database chưa lưu được nhánh trả lời. Hãy chạy migration comments mới nhất.',
          );
        }

        // Direct replies still render correctly with the old schema. Nested
        // replies must not fall back, otherwise they look correct only until
        // the next reload because their target is not persisted.
        final legacyValues = Map<String, Object?>.of(values)
          ..remove('reply_to_comment_id');
        row = await _insertComment(legacyValues);
      }

      final metadata = user.userMetadata ?? const <String, dynamic>{};
      return Comment(
        id: row['id'] as String,
        movieSlug: row['movie_slug'] as String,
        userId: user.id,
        parentId: row['parent_id'] as String?,
        replyToUserId: row['reply_to_user_id'] as String?,
        // Giữ đúng nhánh ngay trong phiên hiện tại cả khi server vẫn đang dùng
        // schema cũ. Sau migration, giá trị này được lưu bền vững từ database.
        replyToCommentId:
            row['reply_to_comment_id'] as String? ?? replyToCommentId,
        replyToName: replyToName,
        authorName: _displayName(user),
        authorAvatarUrl:
            metadata['avatar_url'] as String? ?? metadata['picture'] as String?,
        body: row['body'] as String,
        createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
        updatedAt: DateTime.parse(row['updated_at'] as String).toLocal(),
        likeCount: 0,
        dislikeCount: 0,
        replyCount: 0,
        isDeleted: false,
      );
    });
  }

  Future<Map<String, dynamic>> _insertComment(
    Map<String, Object?> values,
  ) async {
    return _client.from('movie_comments').insert(values).select().single();
  }

  bool _isMissingReplyTargetColumn(PostgrestException error) {
    final message = error.message.toLowerCase();
    return (error.code == '42703' || error.code == 'PGRST204') &&
        message.contains('reply_to_comment_id');
  }

  @override
  Future<void> editComment({required String commentId, required String body}) {
    _requireUser();
    return _guard('edit:$commentId', () async {
      await _client
          .from('movie_comments')
          .update({'body': body.trim()})
          .eq('id', commentId);
    });
  }

  @override
  Future<void> softDeleteComment(String commentId) {
    _requireUser();
    return _guard('delete:$commentId', () async {
      await _client
          .from('movie_comments')
          .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
          .eq('id', commentId);
    });
  }

  @override
  Future<void> setReaction({
    required String commentId,
    required CommentReaction? reaction,
  }) {
    _requireUser();
    return _guard('reaction:$commentId', () async {
      await _client.rpc(
        'set_comment_reaction',
        params: {
          'p_comment_id': commentId,
          'p_reaction': reaction?.databaseValue ?? 0,
        },
      );
    });
  }

  @override
  Future<void> reportComment({
    required String commentId,
    required CommentReportReason reason,
  }) {
    final user = _requireUser();
    return _guard('report:$commentId', () async {
      await _client.from('comment_reports').insert({
        'comment_id': commentId,
        'reporter_id': user.id,
        'reason': reason.databaseValue,
      });
    });
  }

  User _requireUser() {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Bạn cần đăng nhập để thực hiện thao tác này.');
    }
    return user;
  }

  Future<T> _guard<T>(String key, Future<T> Function() action) async {
    if (!_pendingMutations.add(key)) {
      throw StateError('Thao tác này đang được xử lý.');
    }
    try {
      return await action();
    } finally {
      _pendingMutations.remove(key);
    }
  }

  List<Comment> _mapRows(Object? response) {
    final rows = response is List ? response : const <Object?>[];
    return rows
        .whereType<Map>()
        .map((row) => Comment.fromJson(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  int _asInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _displayName(User user) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    return (metadata['full_name'] as String?) ??
        (metadata['name'] as String?) ??
        user.email?.split('@').first ??
        'Người dùng';
  }
}
