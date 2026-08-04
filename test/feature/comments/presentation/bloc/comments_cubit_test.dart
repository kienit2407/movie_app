import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/feature/comments/domain/entities/comment.dart';
import 'package:movie_app/feature/comments/domain/repositories/comment_repository.dart';
import 'package:movie_app/feature/comments/presentation/bloc/comments_cubit.dart';
import 'package:movie_app/feature/comments/presentation/bloc/comments_state.dart';

void main() {
  group('CommentsCubit', () {
    test('loads and paginates top-level comments', () async {
      final repository = _FakeCommentRepository()
        ..commentPages = [
          CommentPage(
            items: [_comment('1'), _comment('2')],
            hasMore: true,
            totalCount: 3,
          ),
          CommentPage(items: [_comment('3')], hasMore: false, totalCount: 3),
        ];
      final cubit = CommentsCubit(repository: repository, movieSlug: 'dune');

      await cubit.loadInitial();
      await cubit.loadMoreComments();

      expect(cubit.state.status, CommentsStatus.success);
      expect(cubit.state.comments.map((item) => item.id), ['1', '2', '3']);
      expect(cubit.state.totalCount, 3);
      expect(cubit.state.hasMoreComments, isFalse);
      expect(repository.commentOffsets, [0, 2]);
      await cubit.close();
    });

    test('changes sort and reloads from the first page', () async {
      final repository = _FakeCommentRepository()
        ..commentPages = [
          CommentPage(
            items: [_comment('popular')],
            hasMore: false,
            totalCount: 1,
          ),
          CommentPage(
            items: [_comment('newest')],
            hasMore: false,
            totalCount: 1,
          ),
        ];
      final cubit = CommentsCubit(repository: repository, movieSlug: 'dune');

      await cubit.loadInitial();
      await cubit.changeSort(CommentSort.newest);

      expect(cubit.state.sort, CommentSort.newest);
      expect(cubit.state.comments.single.id, 'newest');
      expect(repository.sorts, [CommentSort.popular, CommentSort.newest]);
      await cubit.close();
    });

    test('opens a reply thread and paginates replies', () async {
      final root = _comment('root', replyCount: 2);
      final repository = _FakeCommentRepository()
        ..replyPages = [
          CommentPage(
            items: [_comment('reply-1', parentId: root.id)],
            hasMore: true,
            totalCount: 2,
          ),
          CommentPage(
            items: [_comment('reply-2', parentId: root.id)],
            hasMore: false,
            totalCount: 2,
          ),
        ];
      final cubit = CommentsCubit(repository: repository, movieSlug: 'dune');

      await cubit.openThread(root);
      await cubit.loadMoreReplies();

      expect(cubit.state.threadRoot, root);
      expect(cubit.state.replies.map((item) => item.id), [
        'reply-1',
        'reply-2',
      ]);
      expect(repository.replyOffsets, [0, 1]);
      await cubit.close();
    });

    test('orders a reply directly below the comment it targets', () async {
      final root = _comment('root', replyCount: 3);
      final first = _comment(
        'first',
        parentId: root.id,
        replyToCommentId: root.id,
      );
      final second = _comment(
        'second',
        parentId: root.id,
        replyToCommentId: root.id,
      );
      final childOfFirst = _comment(
        'child-of-first',
        parentId: root.id,
        replyToCommentId: first.id,
      );
      final repository = _FakeCommentRepository()
        ..replyPages = [
          CommentPage(
            items: [first, second, childOfFirst],
            hasMore: false,
            totalCount: 3,
          ),
        ];
      final cubit = CommentsCubit(repository: repository, movieSlug: 'dune');

      await cubit.openThread(root);

      expect(cubit.state.replies.map((reply) => reply.id), [
        first.id,
        childOfFirst.id,
        second.id,
      ]);
      await cubit.close();
    });

    test(
      'optimistically reacts and rolls back when repository fails',
      () async {
        final comment = _comment('1', likeCount: 4);
        final completer = Completer<void>();
        final repository = _FakeCommentRepository()
          ..commentPages = [
            CommentPage(items: [comment], hasMore: false, totalCount: 1),
          ]
          ..reactionCompleter = completer;
        final cubit = CommentsCubit(repository: repository, movieSlug: 'dune');
        await cubit.loadInitial();

        final mutation = cubit.toggleReaction(comment, CommentReaction.like);
        await Future<void>.delayed(Duration.zero);
        expect(cubit.state.comments.single.likeCount, 5);
        expect(
          cubit.state.comments.single.viewerReaction,
          CommentReaction.like,
        );

        completer.completeError(Exception('network'));
        await mutation;
        expect(cubit.state.comments.single.likeCount, 4);
        expect(cubit.state.comments.single.viewerReaction, isNull);
        await cubit.close();
      },
    );

    test('keeps the draft when sending fails', () async {
      final repository = _FakeCommentRepository()..failCreate = true;
      final cubit = CommentsCubit(repository: repository, movieSlug: 'dune');

      final success = await cubit.submit(body: 'Nội dung vẫn còn');

      expect(success, isFalse);
      expect(cubit.state.draftAfterFailure, 'Nội dung vẫn còn');
      await cubit.close();
    });

    test(
      'keeps nested reply draft when thread persistence is unavailable',
      () async {
        final root = _comment('root', replyCount: 1);
        final target = _comment('target', parentId: root.id);
        final repository = _FakeCommentRepository()
          ..replyPages = [
            CommentPage(items: [target], hasMore: false, totalCount: 1),
          ]
          ..failThreadPersistence = true;
        final cubit = CommentsCubit(repository: repository, movieSlug: 'dune');
        await cubit.openThread(root);

        final success = await cubit.submit(
          body: 'Không mất draft',
          replyingTo: target,
        );

        expect(success, isFalse);
        expect(cubit.state.draftAfterFailure, 'Không mất draft');
        expect(cubit.state.errorMessage, contains('migration'));
        expect(cubit.state.replies.map((reply) => reply.id), [target.id]);
        await cubit.close();
      },
    );

    test('submits a top-level comment', () async {
      final repository = _FakeCommentRepository();
      final cubit = CommentsCubit(repository: repository, movieSlug: 'dune');

      final success = await cubit.submit(body: 'Bình luận mới');

      expect(success, isTrue);
      expect(cubit.state.comments.single.body, 'Bình luận mới');
      expect(cubit.state.totalCount, 1);
      expect(repository.createdMovieSlug, 'dune');
      expect(repository.createdRootCommentId, isNull);
      expect(repository.createdReplyToUserId, isNull);
      expect(repository.createdReplyToCommentId, isNull);
      await cubit.close();
    });

    test(
      'submits a reply under the root and targets the selected user',
      () async {
        final root = _comment('root', replyCount: 2);
        final target = _comment('reply-target', parentId: root.id);
        final repository = _FakeCommentRepository()
          ..replyPages = [
            CommentPage(items: [target], hasMore: false, totalCount: 1),
          ];
        final cubit = CommentsCubit(repository: repository, movieSlug: 'dune');
        await cubit.openThread(root);

        final success = await cubit.submit(
          body: 'Phản hồi mới',
          replyingTo: target,
        );

        expect(success, isTrue);
        expect(cubit.state.replies.map((reply) => reply.id), [
          target.id,
          'created',
        ]);
        expect(cubit.state.replies.first.replyCount, 1);
        expect(cubit.state.replies.last.body, 'Phản hồi mới');
        expect(cubit.state.replies.last.parentId, root.id);
        expect(cubit.state.threadRoot!.replyCount, 3);
        expect(repository.createdRootCommentId, root.id);
        expect(repository.createdReplyToUserId, target.userId);
        expect(repository.createdReplyToCommentId, target.id);
        expect(repository.createdReplyToName, target.authorName);
        await cubit.close();
      },
    );

    test('edit and soft delete update the local item', () async {
      final original = _comment('mine', body: 'Cũ');
      final repository = _FakeCommentRepository()
        ..commentPages = [
          CommentPage(items: [original], hasMore: false, totalCount: 1),
        ];
      final cubit = CommentsCubit(repository: repository, movieSlug: 'dune');
      await cubit.loadInitial();

      expect(await cubit.edit(original, 'Mới'), isTrue);
      expect(cubit.state.comments.single.body, 'Mới');
      expect(cubit.state.comments.single.wasEdited, isTrue);

      await cubit.softDelete(cubit.state.comments.single);
      expect(cubit.state.comments.single.isDeleted, isTrue);
      await cubit.close();
    });

    test('surfaces duplicate report failure', () async {
      final repository = _FakeCommentRepository()..failReport = true;
      final cubit = CommentsCubit(repository: repository, movieSlug: 'dune');

      final sent = await cubit.report(
        _comment('other'),
        CommentReportReason.spam,
      );

      expect(sent, isFalse);
      expect(cubit.state.errorMessage, contains('đã được báo cáo'));
      await cubit.close();
    });
  });
}

class _FakeCommentRepository implements CommentRepository {
  List<CommentPage> commentPages = [];
  List<CommentPage> replyPages = [];
  final List<int> commentOffsets = [];
  final List<int> replyOffsets = [];
  final List<CommentSort> sorts = [];
  Completer<void>? reactionCompleter;
  bool failCreate = false;
  bool failThreadPersistence = false;
  bool failReport = false;
  String? createdMovieSlug;
  String? createdRootCommentId;
  String? createdReplyToUserId;
  String? createdReplyToCommentId;
  String? createdReplyToName;

  @override
  String? get currentUserId => 'user-1';

  @override
  Future<CommentPage> fetchComments({
    required String movieSlug,
    required CommentSort sort,
    required int offset,
    int limit = 20,
  }) async {
    commentOffsets.add(offset);
    sorts.add(sort);
    return commentPages.removeAt(0);
  }

  @override
  Future<CommentPage> fetchReplies({
    required String rootCommentId,
    required int offset,
    int limit = 30,
  }) async {
    replyOffsets.add(offset);
    return replyPages.removeAt(0);
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
    if (failCreate) throw Exception('network');
    if (failThreadPersistence) {
      throw const CommentThreadPersistenceException(
        'Cần chạy migration comments mới nhất.',
      );
    }
    createdMovieSlug = movieSlug;
    createdRootCommentId = rootCommentId;
    createdReplyToUserId = replyToUserId;
    createdReplyToCommentId = replyToCommentId;
    createdReplyToName = replyToName;
    return _comment(
      'created',
      body: body,
      parentId: rootCommentId,
      replyToCommentId: replyToCommentId,
    );
  }

  @override
  Future<void> editComment({
    required String commentId,
    required String body,
  }) async {}

  @override
  Future<void> softDeleteComment(String commentId) async {}

  @override
  Future<void> setReaction({
    required String commentId,
    required CommentReaction? reaction,
  }) async {
    if (reactionCompleter != null) return reactionCompleter!.future;
  }

  @override
  Future<void> reportComment({
    required String commentId,
    required CommentReportReason reason,
  }) async {
    if (failReport) throw Exception('duplicate');
  }
}

Comment _comment(
  String id, {
  String body = 'Bình luận',
  String? parentId,
  String? replyToCommentId,
  int likeCount = 0,
  int replyCount = 0,
}) {
  final now = DateTime(2026, 7, 29);
  return Comment(
    id: id,
    movieSlug: 'dune',
    userId: 'user-1',
    parentId: parentId,
    replyToCommentId: replyToCommentId,
    authorName: 'Kinit',
    body: body,
    createdAt: now,
    updatedAt: now,
    likeCount: likeCount,
    dislikeCount: 0,
    replyCount: replyCount,
    isDeleted: false,
  );
}
