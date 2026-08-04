import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/feature/comments/domain/entities/comment.dart';
import 'package:movie_app/feature/comments/domain/repositories/comment_repository.dart';
import 'package:movie_app/feature/comments/presentation/bloc/comments_state.dart';

class CommentsCubit extends Cubit<CommentsState> {
  CommentsCubit({
    required CommentRepository repository,
    required this.movieSlug,
  }) : _repository = repository,
       super(const CommentsState());

  final CommentRepository _repository;
  final String movieSlug;

  String? get currentUserId => _repository.currentUserId;

  Future<void> loadInitial() async {
    if (state.status == CommentsStatus.loading ||
        state.status == CommentsStatus.success) {
      return;
    }
    await _loadFirstPage();
  }

  Future<void> retry() => _loadFirstPage();

  Future<void> _loadFirstPage() async {
    emit(
      state.copyWith(
        status: CommentsStatus.loading,
        clearError: true,
        clearThreadRoot: true,
        replies: const [],
      ),
    );
    try {
      final page = await _repository.fetchComments(
        movieSlug: movieSlug,
        sort: state.sort,
        offset: 0,
      );
      emit(
        state.copyWith(
          status: CommentsStatus.success,
          comments: page.items,
          totalCount: page.totalCount,
          hasMoreComments: page.hasMore,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: CommentsStatus.failure,
          errorMessage: 'Không tải được bình luận. Hãy thử lại.',
        ),
      );
    }
  }

  Future<void> changeSort(CommentSort sort) async {
    if (sort == state.sort) return;
    emit(
      state.copyWith(
        sort: sort,
        status: CommentsStatus.initial,
        comments: const [],
        totalCount: 0,
        clearThreadRoot: true,
      ),
    );
    await _loadFirstPage();
  }

  Future<void> loadMoreComments() async {
    if (state.isLoadingMore || !state.hasMoreComments) return;
    emit(state.copyWith(isLoadingMore: true, clearError: true));
    try {
      final page = await _repository.fetchComments(
        movieSlug: movieSlug,
        sort: state.sort,
        offset: state.comments.length,
      );
      emit(
        state.copyWith(
          comments: [...state.comments, ...page.items],
          hasMoreComments: page.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: 'Chưa tải thêm được bình luận.',
        ),
      );
    }
  }

  Future<void> openThread(Comment root) async {
    emit(
      state.copyWith(
        threadRoot: root,
        replies: const [],
        hasMoreReplies: true,
        isLoadingMore: true,
        clearError: true,
      ),
    );
    try {
      final page = await _repository.fetchReplies(
        rootCommentId: root.id,
        offset: 0,
      );
      emit(
        state.copyWith(
          replies: _orderReplies(page.items, root.id),
          hasMoreReplies: page.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: 'Không tải được phần trả lời.',
        ),
      );
    }
  }

  void closeThread() {
    emit(
      state.copyWith(
        clearThreadRoot: true,
        replies: const [],
        hasMoreReplies: true,
        clearError: true,
      ),
    );
  }

  Future<void> loadMoreReplies() async {
    final root = state.threadRoot;
    if (root == null || state.isLoadingMore || !state.hasMoreReplies) return;
    emit(state.copyWith(isLoadingMore: true, clearError: true));
    try {
      final page = await _repository.fetchReplies(
        rootCommentId: root.id,
        offset: state.replies.length,
      );
      emit(
        state.copyWith(
          replies: _orderReplies([...state.replies, ...page.items], root.id),
          hasMoreReplies: page.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: 'Chưa tải thêm được phần trả lời.',
        ),
      );
    }
  }

  Future<bool> submit({required String body, Comment? replyingTo}) async {
    final normalized = body.trim();
    if (normalized.isEmpty || normalized.length > 2000) return false;

    final root = state.threadRoot;
    try {
      final comment = await _repository.createComment(
        movieSlug: movieSlug,
        body: normalized,
        rootCommentId: root?.id,
        replyToUserId: replyingTo?.userId,
        replyToCommentId: replyingTo?.id,
        replyToName: replyingTo?.authorName,
      );
      if (root == null) {
        emit(
          state.copyWith(
            comments: [comment, ...state.comments],
            totalCount: state.totalCount + 1,
            clearDraft: true,
            clearError: true,
          ),
        );
      } else {
        final updatedRoot = root.copyWith(replyCount: root.replyCount + 1);
        final repliesWithUpdatedTarget =
            replyingTo != null && replyingTo.id != root.id
            ? _replace(
                state.replies,
                replyingTo.copyWith(replyCount: replyingTo.replyCount + 1),
              )
            : state.replies;
        emit(
          state.copyWith(
            replies: _orderReplies([
              ...repliesWithUpdatedTarget,
              comment,
            ], root.id),
            threadRoot: updatedRoot,
            comments: _replace(state.comments, updatedRoot),
            clearDraft: true,
            clearError: true,
          ),
        );
      }
      return true;
    } on CommentThreadPersistenceException catch (error) {
      emit(
        state.copyWith(
          errorMessage: error.message,
          draftAfterFailure: normalized,
        ),
      );
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          errorMessage: 'Chưa gửi được bình luận. Nội dung vẫn được giữ lại.',
          draftAfterFailure: normalized,
        ),
      );
      return false;
    }
  }

  Future<bool> edit(Comment comment, String body) async {
    final normalized = body.trim();
    if (normalized.isEmpty || normalized == comment.body) return false;
    final optimistic = comment.copyWith(
      body: normalized,
      editedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _replaceEverywhere(optimistic);
    _setPending(comment.id, true);
    try {
      await _repository.editComment(commentId: comment.id, body: normalized);
      _setPending(comment.id, false);
      return true;
    } catch (_) {
      _replaceEverywhere(comment);
      _setPending(comment.id, false);
      emit(state.copyWith(errorMessage: 'Không thể chỉnh sửa bình luận.'));
      return false;
    }
  }

  Future<void> softDelete(Comment comment) async {
    final optimistic = comment.copyWith(body: '', isDeleted: true);
    _replaceEverywhere(optimistic);
    _setPending(comment.id, true);
    try {
      await _repository.softDeleteComment(comment.id);
      _setPending(comment.id, false);
    } catch (_) {
      _replaceEverywhere(comment);
      _setPending(comment.id, false);
      emit(state.copyWith(errorMessage: 'Không thể xóa bình luận.'));
    }
  }

  Future<void> toggleReaction(
    Comment comment,
    CommentReaction requested,
  ) async {
    if (state.pendingCommentIds.contains(comment.id)) return;
    final next = comment.viewerReaction == requested ? null : requested;
    final optimistic = _withReaction(comment, next);
    _replaceEverywhere(optimistic);
    _setPending(comment.id, true);
    try {
      await _repository.setReaction(commentId: comment.id, reaction: next);
      _setPending(comment.id, false);
    } catch (_) {
      _replaceEverywhere(comment);
      _setPending(comment.id, false);
      emit(state.copyWith(errorMessage: 'Không thể cập nhật cảm xúc.'));
    }
  }

  Future<bool> report(Comment comment, CommentReportReason reason) async {
    try {
      await _repository.reportComment(commentId: comment.id, reason: reason);
      return true;
    } catch (_) {
      emit(
        state.copyWith(
          errorMessage: 'Bình luận này đã được báo cáo hoặc chưa thể gửi.',
        ),
      );
      return false;
    }
  }

  Comment _withReaction(Comment comment, CommentReaction? next) {
    var likes = comment.likeCount;
    var dislikes = comment.dislikeCount;
    if (comment.viewerReaction == CommentReaction.like) likes--;
    if (comment.viewerReaction == CommentReaction.dislike) dislikes--;
    if (next == CommentReaction.like) likes++;
    if (next == CommentReaction.dislike) dislikes++;
    return comment.copyWith(
      likeCount: likes.clamp(0, 1 << 30),
      dislikeCount: dislikes.clamp(0, 1 << 30),
      viewerReaction: next,
      clearViewerReaction: next == null,
    );
  }

  void _replaceEverywhere(Comment comment) {
    emit(
      state.copyWith(
        comments: _replace(state.comments, comment),
        replies: _replace(state.replies, comment),
        threadRoot: state.threadRoot?.id == comment.id
            ? comment
            : state.threadRoot,
      ),
    );
  }

  List<Comment> _replace(List<Comment> source, Comment value) {
    return source
        .map((item) => item.id == value.id ? value : item)
        .toList(growable: false);
  }

  List<Comment> _orderReplies(List<Comment> source, String rootId) {
    if (source.length < 2) return List<Comment>.of(source);

    final byId = {for (final reply in source) reply.id: reply};
    final children = <String, List<Comment>>{};
    final roots = <Comment>[];

    for (final reply in source) {
      final targetId = reply.replyToCommentId;
      if (targetId == null ||
          targetId == rootId ||
          targetId == reply.id ||
          !byId.containsKey(targetId)) {
        roots.add(reply);
      } else {
        children.putIfAbsent(targetId, () => <Comment>[]).add(reply);
      }
    }

    final ordered = <Comment>[];
    final visited = <String>{};

    void appendBranch(Comment reply) {
      if (!visited.add(reply.id)) return;
      ordered.add(reply);
      for (final child in children[reply.id] ?? const <Comment>[]) {
        appendBranch(child);
      }
    }

    for (final rootReply in roots) {
      appendBranch(rootReply);
    }
    for (final reply in source) {
      appendBranch(reply);
    }
    return ordered;
  }

  void _setPending(String id, bool pending) {
    final ids = <String>{...state.pendingCommentIds};
    pending ? ids.add(id) : ids.remove(id);
    emit(state.copyWith(pendingCommentIds: ids, clearError: true));
  }
}
