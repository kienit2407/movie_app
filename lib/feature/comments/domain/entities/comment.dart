enum CommentSort { popular, newest }

enum CommentReaction {
  like(1),
  dislike(-1);

  const CommentReaction(this.databaseValue);
  final int databaseValue;

  static CommentReaction? fromDatabase(Object? value) {
    return switch (value) {
      1 => CommentReaction.like,
      -1 => CommentReaction.dislike,
      _ => null,
    };
  }
}

enum CommentReportReason {
  spam('spam', 'Nội dung rác'),
  harassment('harassment', 'Quấy rối hoặc công kích'),
  spoiler('spoiler', 'Tiết lộ nội dung phim'),
  inappropriate('inappropriate', 'Nội dung không phù hợp'),
  other('other', 'Lý do khác');

  const CommentReportReason(this.databaseValue, this.label);
  final String databaseValue;
  final String label;
}

class Comment {
  const Comment({
    required this.id,
    required this.movieSlug,
    required this.userId,
    required this.authorName,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    required this.likeCount,
    required this.dislikeCount,
    required this.replyCount,
    required this.isDeleted,
    this.parentId,
    this.replyToUserId,
    this.replyToCommentId,
    this.replyToName,
    this.authorAvatarUrl,
    this.editedAt,
    this.viewerReaction,
  });

  final String id;
  final String movieSlug;
  final String userId;
  final String? parentId;
  final String? replyToUserId;
  final String? replyToCommentId;
  final String? replyToName;
  final String authorName;
  final String? authorAvatarUrl;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? editedAt;
  final int likeCount;
  final int dislikeCount;
  final int replyCount;
  final CommentReaction? viewerReaction;
  final bool isDeleted;

  bool isOwnedBy(String? currentUserId) =>
      currentUserId != null && userId == currentUserId;

  bool get wasEdited => editedAt != null && !isDeleted;

  Comment copyWith({
    String? body,
    DateTime? updatedAt,
    DateTime? editedAt,
    int? likeCount,
    int? dislikeCount,
    int? replyCount,
    CommentReaction? viewerReaction,
    String? replyToName,
    bool clearViewerReaction = false,
    bool? isDeleted,
  }) {
    return Comment(
      id: id,
      movieSlug: movieSlug,
      userId: userId,
      parentId: parentId,
      replyToUserId: replyToUserId,
      replyToCommentId: replyToCommentId,
      replyToName: replyToName ?? this.replyToName,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      body: body ?? this.body,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      editedAt: editedAt ?? this.editedAt,
      likeCount: likeCount ?? this.likeCount,
      dislikeCount: dislikeCount ?? this.dislikeCount,
      replyCount: replyCount ?? this.replyCount,
      viewerReaction: clearViewerReaction
          ? null
          : viewerReaction ?? this.viewerReaction,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      movieSlug: json['movie_slug'] as String,
      userId: json['user_id'] as String,
      parentId: json['parent_id'] as String?,
      replyToUserId: json['reply_to_user_id'] as String?,
      replyToCommentId: json['reply_to_comment_id'] as String?,
      replyToName: json['reply_to_name'] as String?,
      authorName: (json['author_name'] as String?) ?? 'Người dùng',
      authorAvatarUrl: json['author_avatar_url'] as String?,
      body: (json['body'] as String?) ?? '',
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
      editedAt: _parseDate(json['edited_at']),
      likeCount: _parseInt(json['like_count']),
      dislikeCount: _parseInt(json['dislike_count']),
      replyCount: _parseInt(json['reply_count']),
      viewerReaction: CommentReaction.fromDatabase(json['viewer_reaction']),
      isDeleted: json['is_deleted'] == true || json['deleted_at'] != null,
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value)?.toLocal();
  }

  static int _parseInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class CommentPage {
  const CommentPage({
    required this.items,
    required this.hasMore,
    required this.totalCount,
  });

  final List<Comment> items;
  final bool hasMore;
  final int totalCount;
}
