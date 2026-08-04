import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/feature/auth/presentation/session/auth_session_cubit.dart';
import 'package:movie_app/feature/comments/domain/entities/comment.dart';
import 'package:movie_app/feature/comments/domain/repositories/comment_repository.dart';
import 'package:movie_app/feature/comments/presentation/bloc/comments_cubit.dart';
import 'package:movie_app/feature/comments/presentation/widgets/comments_tab.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() {
  testWidgets('error state does not overflow a compact comments viewport', (
    tester,
  ) async {
    final previousUpdateInterval =
        VisibilityDetectorController.instance.updateInterval;
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    addTearDown(() {
      VisibilityDetectorController.instance.updateInterval =
          previousUpdateInterval;
      tester.view.resetViewInsets();
    });

    final repository = _FailingCommentRepository();
    final commentsCubit = CommentsCubit(
      repository: repository,
      movieSlug: 'test-movie',
    );
    await commentsCubit.loadInitial();

    final authClient = SupabaseClient(
      'http://127.0.0.1:54321',
      'test-anon-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: commentsCubit),
          BlocProvider(create: (_) => AuthSessionCubit(client: authClient)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              key: ValueKey('detail-scroll'),
              child: Column(
                children: [
                  SizedBox(height: 650),
                  SizedBox(height: 320, child: CommentsTab()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(TextField), findsNothing);

    await tester.drag(
      find.byKey(const ValueKey('detail-scroll')),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chưa tải được bình luận'), findsOneWidget);
    final composerBottom = tester.getRect(find.byType(TextField)).bottom;
    final viewportHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(composerBottom, lessThanOrEqualTo(viewportHeight));
    expect(composerBottom, greaterThan(viewportHeight - 140));

    const physicalKeyboardHeight = 240.0;
    tester.view.viewInsets = const FakeViewPadding(
      bottom: physicalKeyboardHeight,
    );
    await tester.pump();

    final logicalKeyboardHeight =
        physicalKeyboardHeight / tester.view.devicePixelRatio;
    final keyboardTop = viewportHeight - logicalKeyboardHeight;
    final liftedComposerBottom = tester.getRect(find.byType(TextField)).bottom;
    expect(liftedComposerBottom, lessThanOrEqualTo(keyboardTop));
    expect(liftedComposerBottom, greaterThan(keyboardTop - 140));
    expect(tester.takeException(), isNull);

    tester.view.resetViewInsets();
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await commentsCubit.close();
    authClient.dispose();
  });

  testWidgets('nested replies can be collapsed under their direct parent', (
    tester,
  ) async {
    final previousUpdateInterval =
        VisibilityDetectorController.instance.updateInterval;
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    addTearDown(() {
      VisibilityDetectorController.instance.updateInterval =
          previousUpdateInterval;
    });

    final root = _comment('root', body: 'Root', replyCount: 2);
    final parentReply = _comment(
      'parent',
      body: 'Parent reply',
      parentId: root.id,
      replyToCommentId: root.id,
      replyCount: 1,
    );
    final childReply = _comment(
      'child',
      body: 'Child reply',
      parentId: root.id,
      replyToCommentId: parentReply.id,
    );
    final repository = _ThreadCommentRepository(
      replies: [parentReply, childReply],
    );
    final commentsCubit = CommentsCubit(
      repository: repository,
      movieSlug: 'test-movie',
    );
    await commentsCubit.openThread(root);

    final authClient = SupabaseClient(
      'http://127.0.0.1:54321',
      'test-anon-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: commentsCubit),
          BlocProvider(create: (_) => AuthSessionCubit(client: authClient)),
        ],
        child: const MaterialApp(
          home: Scaffold(body: SizedBox(height: 760, child: CommentsTab())),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Parent reply'), findsOneWidget);
    expect(find.text('Child reply'), findsOneWidget);
    expect(find.text('1 phản hồi'), findsOneWidget);

    await tester.tap(find.text('1 phản hồi'));
    await tester.pumpAndSettle();
    expect(find.text('Child reply'), findsNothing);

    await tester.tap(find.text('1 phản hồi'));
    await tester.pumpAndSettle();
    expect(find.text('Child reply'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await commentsCubit.close();
    authClient.dispose();
  });
}

class _FailingCommentRepository implements CommentRepository {
  @override
  String? get currentUserId => null;

  @override
  Future<CommentPage> fetchComments({
    required String movieSlug,
    required CommentSort sort,
    required int offset,
    int limit = 20,
  }) {
    throw Exception('offline');
  }

  @override
  Future<CommentPage> fetchReplies({
    required String rootCommentId,
    required int offset,
    int limit = 30,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Comment> createComment({
    required String movieSlug,
    required String body,
    String? rootCommentId,
    String? replyToUserId,
    String? replyToCommentId,
    String? replyToName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> editComment({required String commentId, required String body}) {
    throw UnimplementedError();
  }

  @override
  Future<void> reportComment({
    required String commentId,
    required CommentReportReason reason,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> setReaction({
    required String commentId,
    required CommentReaction? reaction,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> softDeleteComment(String commentId) {
    throw UnimplementedError();
  }
}

class _ThreadCommentRepository implements CommentRepository {
  const _ThreadCommentRepository({required this.replies});

  final List<Comment> replies;

  @override
  String? get currentUserId => null;

  @override
  Future<CommentPage> fetchReplies({
    required String rootCommentId,
    required int offset,
    int limit = 30,
  }) async {
    return CommentPage(
      items: replies,
      hasMore: false,
      totalCount: replies.length,
    );
  }

  @override
  Future<CommentPage> fetchComments({
    required String movieSlug,
    required CommentSort sort,
    required int offset,
    int limit = 20,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Comment> createComment({
    required String movieSlug,
    required String body,
    String? rootCommentId,
    String? replyToUserId,
    String? replyToCommentId,
    String? replyToName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> editComment({required String commentId, required String body}) {
    throw UnimplementedError();
  }

  @override
  Future<void> reportComment({
    required String commentId,
    required CommentReportReason reason,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> setReaction({
    required String commentId,
    required CommentReaction? reaction,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> softDeleteComment(String commentId) {
    throw UnimplementedError();
  }
}

Comment _comment(
  String id, {
  required String body,
  String? parentId,
  String? replyToCommentId,
  int replyCount = 0,
}) {
  final now = DateTime(2026, 7, 30);
  return Comment(
    id: id,
    movieSlug: 'test-movie',
    userId: 'user-$id',
    parentId: parentId,
    replyToCommentId: replyToCommentId,
    authorName: 'User $id',
    body: body,
    createdAt: now,
    updatedAt: now,
    likeCount: 0,
    dislikeCount: 0,
    replyCount: replyCount,
    isDeleted: false,
  );
}
