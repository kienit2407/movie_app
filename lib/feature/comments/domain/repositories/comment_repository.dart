import 'package:movie_app/feature/comments/domain/entities/comment.dart';

class CommentThreadPersistenceException implements Exception {
  const CommentThreadPersistenceException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract interface class CommentRepository {
  String? get currentUserId;

  Future<CommentPage> fetchComments({
    required String movieSlug,
    required CommentSort sort,
    required int offset,
    int limit = 20,
  });

  Future<CommentPage> fetchReplies({
    required String rootCommentId,
    required int offset,
    int limit = 30,
  });

  Future<Comment> createComment({
    required String movieSlug,
    required String body,
    String? rootCommentId,
    String? replyToUserId,
    String? replyToCommentId,
    String? replyToName,
  });

  Future<void> editComment({required String commentId, required String body});

  Future<void> softDeleteComment(String commentId);

  Future<void> setReaction({
    required String commentId,
    required CommentReaction? reaction,
  });

  Future<void> reportComment({
    required String commentId,
    required CommentReportReason reason,
  });
}
