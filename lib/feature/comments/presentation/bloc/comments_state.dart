import 'package:movie_app/feature/comments/domain/entities/comment.dart';

enum CommentsStatus { initial, loading, success, failure }

class CommentsState {
  const CommentsState({
    this.status = CommentsStatus.initial,
    this.comments = const [],
    this.replies = const [],
    this.sort = CommentSort.popular,
    this.totalCount = 0,
    this.hasMoreComments = true,
    this.hasMoreReplies = true,
    this.threadRoot,
    this.isLoadingMore = false,
    this.pendingCommentIds = const {},
    this.errorMessage,
    this.draftAfterFailure,
  });

  final CommentsStatus status;
  final List<Comment> comments;
  final List<Comment> replies;
  final CommentSort sort;
  final int totalCount;
  final bool hasMoreComments;
  final bool hasMoreReplies;
  final Comment? threadRoot;
  final bool isLoadingMore;
  final Set<String> pendingCommentIds;
  final String? errorMessage;
  final String? draftAfterFailure;

  bool get isThreadOpen => threadRoot != null;

  CommentsState copyWith({
    CommentsStatus? status,
    List<Comment>? comments,
    List<Comment>? replies,
    CommentSort? sort,
    int? totalCount,
    bool? hasMoreComments,
    bool? hasMoreReplies,
    Comment? threadRoot,
    bool clearThreadRoot = false,
    bool? isLoadingMore,
    Set<String>? pendingCommentIds,
    String? errorMessage,
    bool clearError = false,
    String? draftAfterFailure,
    bool clearDraft = false,
  }) {
    return CommentsState(
      status: status ?? this.status,
      comments: comments ?? this.comments,
      replies: replies ?? this.replies,
      sort: sort ?? this.sort,
      totalCount: totalCount ?? this.totalCount,
      hasMoreComments: hasMoreComments ?? this.hasMoreComments,
      hasMoreReplies: hasMoreReplies ?? this.hasMoreReplies,
      threadRoot: clearThreadRoot ? null : threadRoot ?? this.threadRoot,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      pendingCommentIds: pendingCommentIds ?? this.pendingCommentIds,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      draftAfterFailure: clearDraft
          ? null
          : draftAfterFailure ?? this.draftAfterFailure,
    );
  }
}
