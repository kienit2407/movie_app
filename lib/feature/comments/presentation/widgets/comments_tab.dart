import 'dart:ui';

import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:movie_app/common/components/app_toast.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/extension/build_context_extension.dart';
import 'package:movie_app/feature/auth/presentation/session/auth_session_cubit.dart';
import 'package:movie_app/feature/auth/presentation/sign_in/pages/sign_in.dart';
import 'package:movie_app/feature/comments/domain/entities/comment.dart';
import 'package:movie_app/feature/comments/presentation/bloc/comments_cubit.dart';
import 'package:movie_app/feature/comments/presentation/bloc/comments_state.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CommentsTab extends StatefulWidget {
  const CommentsTab({
    super.key,
    this.onComposerWillFocus,
    this.composerVisibilityListenable,
    this.isComposerOverlayVisible,
  });

  final Future<void> Function()? onComposerWillFocus;
  final Listenable? composerVisibilityListenable;
  final bool Function()? isComposerOverlayVisible;

  @override
  State<CommentsTab> createState() => _CommentsTabState();
}

class _CommentsTabState extends State<CommentsTab> with WidgetsBindingObserver {
  static const _emojis = ['❤️', '😂', '🎉', '😢', '😮', '😅', '😊'];
  static const int _maxVisualDepth = 2;

  // Đầu nhánh 3 phải có ít nhất 3 bình luận phía dưới
  // mới hiện nút mở/thu gọn.
  static const int _collapseThreshold = 3;
  final _EmojiComposerController _composerController = _EmojiComposerController(
    emojiFontSize: 19,
  );
  final FocusNode _composerFocus = FocusNode();
  final ScrollController _listController = ScrollController();
  final OverlayPortalController _composerOverlayController =
      OverlayPortalController(debugLabel: 'comments-composer');
  final Key _visibilityKey = UniqueKey();
  final Set<String> _collapsedReplyIds = <String>{};

  Comment? _replyingTo;
  Comment? _editing;
  bool _composerFocused = false;
  bool _isPreparingComposerFocus = false;
  bool _isSubmitting = false;
  bool _isVisibleInViewport = false;
  double _keyboardInset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _composerFocus.addListener(_onComposerFocusChanged);
    _listController.addListener(_onListScroll);
    widget.composerVisibilityListenable?.addListener(
      _syncComposerOverlayVisibility,
    );
  }

  @override
  void didUpdateWidget(CommentsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(
      oldWidget.composerVisibilityListenable,
      widget.composerVisibilityListenable,
    )) {
      oldWidget.composerVisibilityListenable?.removeListener(
        _syncComposerOverlayVisibility,
      );
      widget.composerVisibilityListenable?.addListener(
        _syncComposerOverlayVisibility,
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncComposerOverlayVisibility();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _keyboardInset = _readKeyboardInset();
  }

  @override
  void didChangeMetrics() {
    if (!mounted) return;
    final nextInset = _readKeyboardInset();
    if ((nextInset - _keyboardInset).abs() < 0.5) return;
    setState(() => _keyboardInset = nextInset);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.composerVisibilityListenable?.removeListener(
      _syncComposerOverlayVisibility,
    );
    if (_composerOverlayController.isShowing) {
      _composerOverlayController.hide();
    }
    _composerController.dispose();
    _composerFocus
      ..removeListener(_onComposerFocusChanged)
      ..dispose();
    _listController
      ..removeListener(_onListScroll)
      ..dispose();
    super.dispose();
  }

  double _readKeyboardInset() {
    final view = View.of(context);
    return view.viewInsets.bottom / view.devicePixelRatio;
  }

  void _onComposerFocusChanged() {
    if (!mounted) return;
    final hasFocus = _composerFocus.hasFocus;
    if (_composerFocused == hasFocus) return;
    setState(() => _composerFocused = hasFocus);
  }

  void _onListScroll() {
    if (!_listController.hasClients) return;
    final position = _listController.position;
    if (position.pixels < position.maxScrollExtent - 260) return;
    final cubit = context.read<CommentsCubit>();
    cubit.state.isThreadOpen
        ? cubit.loadMoreReplies()
        : cubit.loadMoreComments();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    _isVisibleInViewport = info.visibleBounds.height >= 48;
    _syncComposerOverlayVisibility();
  }

  void _syncComposerOverlayVisibility() {
    if (!mounted) return;
    final allowedByOwner = widget.isComposerOverlayVisible?.call() ?? true;
    final shouldShow = _isVisibleInViewport && allowedByOwner;
    if (shouldShow == _composerOverlayController.isShowing) return;

    if (shouldShow) {
      _composerOverlayController.show();
    } else {
      _composerFocus.unfocus();
      _composerOverlayController.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return BlocConsumer<CommentsCubit, CommentsState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          !identical(previous.comments, current.comments) ||
          !identical(previous.replies, current.replies) ||
          previous.sort != current.sort ||
          previous.totalCount != current.totalCount ||
          previous.hasMoreComments != current.hasMoreComments ||
          previous.hasMoreReplies != current.hasMoreReplies ||
          previous.threadRoot != current.threadRoot ||
          previous.isLoadingMore != current.isLoadingMore ||
          !identical(previous.pendingCommentIds, current.pendingCommentIds) ||
          previous.draftAfterFailure != current.draftAfterFailure,
      listener: (context, state) {
        AppToast.show(
          context,
          _localizedCommentError(context, state.errorMessage!),
        );
      },
      builder: (context, state) {
        return VisibilityDetector(
          key: _visibilityKey,
          onVisibilityChanged: _onVisibilityChanged,
          child: OverlayPortal(
            controller: _composerOverlayController,
            overlayLocation: OverlayChildLocation.rootOverlay,
            overlayChildBuilder: (overlayContext) {
              return Positioned(
                left: 0,
                right: 0,
                bottom: _keyboardInset,
                child: Material(
                  color: Colors.transparent,
                  child: _buildComposer(state),
                ),
              );
            },
            child: ColoredBox(
              color: const Color(0xff191A24),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: reduceMotion ? 90 : 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  if (reduceMotion) {
                    return FadeTransition(opacity: animation, child: child);
                  }
                  final isThread =
                      child.key == const ValueKey<String>('thread');
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(isThread ? 0.08 : -0.08, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: state.isThreadOpen
                    ? _buildThread(state)
                    : _buildComments(state),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildComments(CommentsState state) {
    return Column(
      key: const ValueKey<String>('comments'),
      children: [
        _CommentsHeader(
          count: state.totalCount,
          sort: state.sort,
          onSortChanged: context.read<CommentsCubit>().changeSort,
        ),
        const Divider(height: 1, color: Colors.white12),
        Expanded(child: _buildCommentList(state)),
      ],
    );
  }

  void _initializeThreadCollapse(CommentsState state) {
    final root = state.threadRoot;
    if (root == null) return;

    final repliesById = <String, Comment>{
      for (final reply in state.replies) reply.id: reply,
    };

    final childrenByParentId = <String, List<Comment>>{};

    for (final reply in state.replies) {
      final parentId = reply.replyToCommentId;
      if (parentId == null) continue;

      childrenByParentId.putIfAbsent(parentId, () => <Comment>[]).add(reply);
    }

    final depthCache = <String, int>{};

    int actualDepthOf(Comment reply) {
      final cached = depthCache[reply.id];
      if (cached != null) return cached;

      var depth = 0;
      var parentId = reply.replyToCommentId;
      final visited = <String>{reply.id};

      while (parentId != null && parentId != root.id) {
        if (!visited.add(parentId)) break;

        final parent = repliesById[parentId];
        if (parent == null) break;

        depth++;
        parentId = parent.replyToCommentId;
      }

      depthCache[reply.id] = depth;
      return depth;
    }

    final descendantCache = <String, int>{};

    int descendantCount(String commentId, [Set<String>? ancestorPath]) {
      final cached = descendantCache[commentId];
      if (cached != null) return cached;

      final path = <String>{...?ancestorPath};

      if (!path.add(commentId)) return 0;

      var count = 0;

      for (final child in childrenByParentId[commentId] ?? const <Comment>[]) {
        count += 1 + descendantCount(child.id, path);
      }

      descendantCache[commentId] = count;
      return count;
    }

    final initiallyCollapsedIds = <String>{};

    for (final reply in state.replies) {
      final actualDepth = actualDepthOf(reply);
      final totalDescendants = descendantCount(reply.id);

      // Nhánh 2 luôn thu gọn phần từ nhánh 3 trở xuống
      // khi vừa mở thread.
      // Chỉ đóng nhánh 2 khi bên dưới có từ 3 bình luận trở lên.
      final shouldInitiallyCollapse =
          actualDepth == 1 && totalDescendants >= _collapseThreshold;

      if (shouldInitiallyCollapse) {
        initiallyCollapsedIds.add(reply.id);
      }
    }

    setState(() {
      _collapsedReplyIds
        ..clear()
        ..addAll(initiallyCollapsedIds);
    });
  }

  Widget _buildThread(CommentsState state) {
    final root = state.threadRoot!;
    final repliesById = {for (final reply in state.replies) reply.id: reply};
    final childrenByParentId = <String, List<Comment>>{};

    for (final reply in state.replies) {
      final parentId = reply.replyToCommentId;
      if (parentId == null) continue;

      childrenByParentId.putIfAbsent(parentId, () => <Comment>[]).add(reply);
    }

    final descendantCountCache = <String, int>{};

    int descendantCount(String commentId, [Set<String>? ancestorPath]) {
      final cached = descendantCountCache[commentId];
      if (cached != null) return cached;

      final path = <String>{...?ancestorPath};

      // Tránh dữ liệu lỗi tạo vòng lặp vô hạn.
      if (!path.add(commentId)) return 0;

      var total = 0;

      for (final child in childrenByParentId[commentId] ?? const <Comment>[]) {
        total += 1 + descendantCount(child.id, path);
      }

      descendantCountCache[commentId] = total;
      return total;
    }

    bool isHiddenByCollapsedParent(Comment reply) {
      var targetId = reply.replyToCommentId;
      final visited = <String>{reply.id};
      while (targetId != null && targetId != root.id) {
        if (!visited.add(targetId)) break;
        if (_collapsedReplyIds.contains(targetId)) return true;
        targetId = repliesById[targetId]?.replyToCommentId;
      }
      return false;
    }

    final visibleReplies = state.replies
        .where((reply) => !isHiddenByCollapsedParent(reply))
        .toList(growable: false);
    // Root nằm riêng, nên:
    // reply depth 0 = nhánh 1
    // reply depth 1 = nhánh 2
    // reply depth 2 = nhánh 3

    int findActualDepth(Comment reply) {
      var depth = 0;
      var targetId = reply.replyToCommentId;
      final visited = <String>{reply.id};

      while (targetId != null && targetId != root.id) {
        if (!visited.add(targetId)) break;

        final parent = repliesById[targetId];
        if (parent == null) break;

        depth++;
        targetId = parent.replyToCommentId;
      }

      return depth;
    }

    final actualDepthById = <String, int>{
      for (final reply in visibleReplies) reply.id: findActualDepth(reply),
    };

    final replyIndexById = <String, int>{
      for (var index = 0; index < visibleReplies.length; index++)
        visibleReplies[index].id: index,
    };

    int visualDepthOf(Comment reply) {
      final actualDepth = actualDepthById[reply.id] ?? 0;

      return actualDepth > _maxVisualDepth ? _maxVisualDepth : actualDepth;
    }

    /// Tìm nhánh cấp 2 chứa toàn bộ các bình luận từ cấp 3 trở xuống.
    ///
    /// Ví dụ:
    /// Root → A → B → C → D → E
    ///
    /// A: nhánh 1
    /// B: nhánh 2
    /// C, D, E: cùng cột nhánh 3
    ///
    /// Hàm sẽ trả về ID của B cho C, D và E.
    String cappedBranchHeadId(Comment reply) {
      var current = reply;
      var currentDepth =
          actualDepthById[current.id] ?? findActualDepth(current);

      final visited = <String>{};

      // Đi ngược lên cho tới đúng đầu nhánh 3, tức actualDepth = 2.
      while (currentDepth > _maxVisualDepth && visited.add(current.id)) {
        final parentId = current.replyToCommentId;
        if (parentId == null) break;

        final parent = repliesById[parentId];
        if (parent == null) break;

        current = parent;
        currentDepth = actualDepthById[current.id] ?? findActualDepth(current);
      }

      return current.id;
    }

    /// Kiểm tra đường dọc hiện tại có cần kéo tiếp xuống hay không.
    bool hasLaterVisualPeerFor(int currentIndex) {
      final current = visibleReplies[currentIndex];
      final currentActualDepth = actualDepthById[current.id] ?? 0;

      // Từ nhánh 3 trở đi: tất cả bình luận thuộc cùng nhánh cấp 2
      // sẽ dùng chung một cột dọc.
      if (currentActualDepth >= _maxVisualDepth) {
        final currentBranchHeadId = cappedBranchHeadId(current);

        for (
          var index = currentIndex + 1;
          index < visibleReplies.length;
          index++
        ) {
          final candidate = visibleReplies[index];
          final candidateActualDepth = actualDepthById[candidate.id] ?? 0;

          // Đã thoát ra khỏi vùng nhánh 3.
          if (candidateActualDepth < _maxVisualDepth) {
            return false;
          }

          final candidateBranchHeadId = cappedBranchHeadId(candidate);

          // Bình luận tiếp theo vẫn thuộc cùng đầu nhánh 3.
          if (candidateBranchHeadId == currentBranchHeadId) {
            return true;
          }

          // Đã chuyển sang một nhánh 3 khác.
          return false;
        }

        return false;
      }

      // Nhánh 1 và nhánh 2 vẫn dùng quan hệ sibling thật:
      // phải trả lời cùng một parent.
      final currentParentId = current.replyToCommentId ?? root.id;

      for (
        var index = currentIndex + 1;
        index < visibleReplies.length;
        index++
      ) {
        final candidate = visibleReplies[index];
        final candidateActualDepth = actualDepthById[candidate.id] ?? 0;

        if (candidateActualDepth < currentActualDepth) {
          return false;
        }

        if (candidateActualDepth == currentActualDepth) {
          final candidateParentId = candidate.replyToCommentId ?? root.id;

          return candidateParentId == currentParentId;
        }
      }

      return false;
    }

    return Column(
      key: const ValueKey<String>('thread'),
      children: [
        SizedBox(
          height: 58,
          child: Row(
            children: [
              IconButton(
                tooltip: context.l10n.commonBack,
                onPressed: () {
                  _cancelComposerMode();
                  _collapsedReplyIds.clear();
                  context.read<CommentsCubit>().closeThread();
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              Text(
                context.l10n.commentsReply,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                context.l10n.commentsReplyCount(root.replyCount),
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.white12),
        Expanded(
          child: ListView.builder(
            controller: _listController,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 200),
            itemCount:
                1 + visibleReplies.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == 0) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.055),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: CommentTile(
                    comment: root,
                    isPending: state.pendingCommentIds.contains(root.id),

                    onLongPressStart: (_) {
                      _showCopyCommentPreview(root);
                    },

                    continueThreadConnector:
                        state.replies.isNotEmpty || root.replyCount > 0,
                    onLike: () => _react(root, CommentReaction.like),
                    onDislike: () => _react(root, CommentReaction.dislike),
                    onReply: () => _startReply(root),
                    onMenu: () => _showCommentMenu(root),
                  ),
                );
              }
              final replyIndex = index - 1;
              if (replyIndex >= visibleReplies.length) {
                return const Padding(
                  padding: EdgeInsets.all(22),
                  child: Center(
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                  ),
                );
              }
              final reply = visibleReplies[replyIndex];
              final actualDepth = actualDepthById[reply.id] ?? 0;

              // Tổng toàn bộ bình luận con, cháu, chắt...
              final totalDescendantCount = descendantCount(reply.id);

              // Những dòng sâu hơn đầu nhánh 3 đã được gom chung.
              // Các dòng này không được hiện nút “x phản hồi”.
              final isFlattenedContinuation = actualDepth > _maxVisualDepth;

              // Root nhánh 1, nhánh 2 và đầu nhánh 3 được hiện tổng.
              // Cấp sâu hơn thì ép replyCount về 0.
              final visibleReplyCount = isFlattenedContinuation
                  ? 0
                  : totalDescendantCount;

              final displayReply = reply.copyWith(
                replyCount: visibleReplyCount,
              );

              final displayDepth = visualDepthOf(reply);

              final nextReply = replyIndex + 1 < visibleReplies.length
                  ? visibleReplies[replyIndex + 1]
                  : null;

              // Chỉ nhánh 1 và nhánh 2 mới được mở thêm một cột mới.
              //
              // Khi đã tới nhánh 3, mọi reply sâu hơn đều nhập vào
              // cùng cột nhánh 3, không tạo nhánh 4.
              final hasVisibleChildren =
                  actualDepth < _maxVisualDepth &&
                  !_collapsedReplyIds.contains(reply.id) &&
                  nextReply?.replyToCommentId == reply.id;

              // Đường dọc của cột hiện tại có cần kéo xuống hay không.
              final continuesVisualColumn = hasLaterVisualPeerFor(replyIndex);

              // Những đường dọc của nhánh cha vẫn cần đi xuyên qua tile hiện tại.
              final continuingAncestorDepths = <int>{};

              var ancestorId = reply.replyToCommentId;

              while (ancestorId != null && ancestorId != root.id) {
                final ancestorIndex = replyIndexById[ancestorId];

                if (ancestorIndex == null) break;

                final ancestor = visibleReplies[ancestorIndex];
                final ancestorActualDepth = actualDepthById[ancestor.id] ?? 0;

                // Không thêm đường tổ tiên từ depth 2 trở đi,
                // vì tất cả đã được nhập vào cùng cột nhánh 3.
                if (ancestorActualDepth < _maxVisualDepth &&
                    hasLaterVisualPeerFor(ancestorIndex)) {
                  continuingAncestorDepths.add(visualDepthOf(ancestor));
                }

                ancestorId = ancestor.replyToCommentId;
              }
              return _ThreadReplyBranch(
                key: ValueKey<String>('thread-reply-${reply.id}'),

                // Dùng depth đã giới hạn, không dùng actualDepth.
                depth: displayDepth,

                hasLaterSibling: continuesVisualColumn,
                continuingAncestorDepths: continuingAncestorDepths,
                hasVisibleChildren: hasVisibleChildren,
                child: CommentTile(
                  comment: displayReply,
                  isPending: state.pendingCommentIds.contains(reply.id),

                  onLongPressStart: (_) {
                    _showCopyCommentPreview(reply);
                  },

                  onLike: () => _react(reply, CommentReaction.like),
                  onDislike: () => _react(reply, CommentReaction.dislike),
                  onReply: () => _startReply(reply),
                  onMenu: () => _showCommentMenu(reply),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCommentList(CommentsState state) {
    if (state.status == CommentsStatus.loading ||
        state.status == CommentsStatus.initial) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
        itemCount: 5,
        itemBuilder: (_, __) => const _CommentSkeleton(),
      );
    }
    if (state.status == CommentsStatus.failure) {
      return _CenteredMessage(
        icon: Icons.cloud_off_rounded,
        title: context.l10n.commentsLoadFailedTitle,
        actionLabel: context.l10n.commonRetry,
        onAction: context.read<CommentsCubit>().retry,
      );
    }
    if (state.comments.isEmpty) {
      return _CenteredMessage(
        icon: Iconsax.message_copy,
        title: context.l10n.commentsEmptyTitle,
        subtitle: context.l10n.commentsEmptySubtitle,
      );
    }

    return RefreshIndicator.adaptive(
      onRefresh: context.read<CommentsCubit>().retry,
      color: const Color(0xffC77DFF),
      child: ListView.builder(
        controller: _listController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 200),
        itemCount: state.comments.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.comments.length) {
            return const Padding(
              padding: EdgeInsets.all(22),
              child: Center(
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              ),
            );
          }
          final comment = state.comments[index];
          return CommentTile(
            key: ValueKey<String>('comment-${comment.id}'),
            comment: comment,
            isPending: state.pendingCommentIds.contains(comment.id),
            onLongPressStart: (_) {
              _showCopyCommentPreview(comment);
            },
            showReplyConnector: comment.replyCount > 0,
            onLike: () => _react(comment, CommentReaction.like),
            onDislike: () => _react(comment, CommentReaction.dislike),
            onReply: () async {
              final cubit = context.read<CommentsCubit>();
              final allowed = await _ensureSignedIn();
              if (!allowed || !mounted) return;
              setState(_collapsedReplyIds.clear);

              await cubit.openThread(comment);

              if (!mounted) return;

              _initializeThreadCollapse(cubit.state);

              await _startReply(comment, authChecked: true);
            },
            onOpenReplies: comment.replyCount == 0
                ? null
                : () async {
                    final cubit = context.read<CommentsCubit>();

                    setState(_collapsedReplyIds.clear);

                    await cubit.openThread(comment);

                    if (!mounted) return;

                    _initializeThreadCollapse(cubit.state);
                  },
            onMenu: () => _showCommentMenu(comment),
          );
        },
      ),
    );
  }

  Widget _buildComposer(CommentsState state) {
    final session = context.watch<AuthSessionCubit>().state;
    final hint = _editing != null
        ? context.l10n.commentsEditHint
        : _replyingTo != null
        ? context.l10n.commentsReplyToHint(_replyingTo!.authorName)
        : state.isThreadOpen
        ? context.l10n.commentsAddReplyHint
        : context.l10n.commentsComposerHint;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xff20212A),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_editing != null || _replyingTo != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _editing != null
                            ? context.l10n.commentsEditingStatus
                            : context.l10n.commentsReplyingStatus(
                                _replyingTo!.authorName,
                              ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: CupertinoColors.systemCyan,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: context.l10n.commonCancel,
                      visualDensity: VisualDensity.compact,
                      onPressed: _cancelComposerMode,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white54,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _ComposerAvatar(
                    avatarUrl:
                        session.user?.userMetadata?['avatar_url'] as String?,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Stack(
                      children: [
                        TextField(
                          controller: _composerController,
                          focusNode: _composerFocus,
                          readOnly: !session.isAuthenticated,
                          minLines: 1,
                          maxLines: 5,
                          maxLength: 2000,
                          textInputAction: TextInputAction.newline,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: hint,
                            counterText: '',
                            hintStyle: const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.07),
                            isDense:
                                true, // isDense: true → bỏ bớt khoảng trống mặc định của InputDecoration.
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            // Bình thường, chưa focus
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.12),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: const BorderSide(
                                color: AppColor.secondColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        if (!_composerFocused)
                          Positioned.fill(
                            child: Semantics(
                              button: true,
                              label: context.l10n.commentsWrite,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: _focusComposer,
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ),
                        if (_isPreparingComposerFocus)
                          const Positioned.fill(
                            child: IgnorePointer(
                              child: Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _composerController,
                    builder: (_, value, __) {
                      final enabled =
                          value.text.trim().isNotEmpty && !_isSubmitting;
                      return IconButton.filled(
                        tooltip: _editing == null
                            ? context.l10n.commentsSend
                            : context.l10n.commonSave,
                        onPressed: enabled ? _submit : null,
                        style: IconButton.styleFrom(
                          backgroundColor: enabled
                              ? AppColor.secondColor
                              : Colors.white.withValues(alpha: 0.08),
                          disabledForegroundColor: Colors.white30,
                        ),
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                _editing == null
                                    ? Icons.send_rounded
                                    : Icons.check_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              child: _composerFocused && session.isAuthenticated
                  ? SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: _emojis.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 50),
                        itemBuilder: (_, index) => InkResponse(
                          onTap: () {
                            final emoji = _emojis[index];
                            final selection = _composerController.selection;
                            final start = selection.isValid
                                ? selection.start
                                : _composerController.text.length;
                            final text = _composerController.text;
                            _composerController.value = TextEditingValue(
                              text: text.replaceRange(start, start, emoji),
                              selection: TextSelection.collapsed(
                                offset: start + emoji.length,
                              ),
                            );
                          },
                          child: Text(
                            _emojis[index],
                            style: const TextStyle(
                              inherit: false,
                              fontSize: 25,
                              fontFamily: 'Apple Color Emoji',
                              fontFamilyFallback: [
                                'Apple Color Emoji',
                                'Noto Color Emoji',
                                'Segoe UI Emoji',
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _ensureSignedIn() async {
    if (context.read<AuthSessionCubit>().state.isAuthenticated) return true;
    return SignInPage.showSheet(context);
  }

  Future<void> _focusComposer({bool authChecked = false}) async {
    if (_composerFocus.hasFocus || _isPreparingComposerFocus) return;
    setState(() => _isPreparingComposerFocus = true);
    try {
      if (!authChecked && !await _ensureSignedIn()) return;
      if (!mounted) return;

      await widget.onComposerWillFocus?.call();
      if (!mounted) return;

      _composerFocus.requestFocus();
    } finally {
      if (mounted) setState(() => _isPreparingComposerFocus = false);
    }
  }

  Future<void> _react(Comment comment, CommentReaction reaction) async {
    final allowed = await _ensureSignedIn();
    if (!allowed || !mounted) return;
    context.read<CommentsCubit>().toggleReaction(comment, reaction);
  }

  Future<void> _startReply(Comment comment, {bool authChecked = false}) async {
    if (!authChecked && !await _ensureSignedIn()) return;
    if (!mounted) return;
    setState(() {
      _editing = null;
      _replyingTo = comment;
    });
    await _focusComposer(authChecked: true);
  }

  Future<void> _submit() async {
    if (!await _ensureSignedIn() || !mounted) return;
    setState(() => _isSubmitting = true);
    final cubit = context.read<CommentsCubit>();
    final success = _editing != null
        ? await cubit.edit(_editing!, _composerController.text)
        : await cubit.submit(
            body: _composerController.text,
            replyingTo: _replyingTo,
          );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (success) {
      _composerController.clear();
      setState(() {
        _editing = null;
        _replyingTo = null;
      });
      _composerFocus.unfocus();
    }
  }

  void _cancelComposerMode() {
    _composerController.clear();
    _composerFocus.unfocus();
    setState(() {
      _editing = null;
      _replyingTo = null;
    });
  }

  Future<void> _showCopyCommentPreview(Comment comment) async {
    if (comment.isDeleted || comment.body.trim().isEmpty) return;

    await HapticFeedback.mediumImpact();

    if (!mounted) return;

    final shouldCopy = await showGeneralDialog<bool>(
      context: context,

      // CommentsTab đang nằm trong bottom sheet nên dùng root navigator
      // để lớp mờ phủ lên toàn bộ màn hình.
      useRootNavigator: true,

      barrierDismissible: true,
      barrierLabel: context.l10n.commentsCloseMenu,
      barrierColor: Colors.transparent,

      transitionDuration: const Duration(milliseconds: 180),

      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return _CommentCopyOverlay(comment: comment);
      },

      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(curvedAnimation),
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
    );

    if (shouldCopy != true || !mounted) return;

    await Clipboard.setData(ClipboardData(text: comment.body));

    if (!mounted) return;

    AppToast.show(
      context,
      context.l10n.commentsCopied,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _showCommentMenu(Comment comment) async {
    final cubit = context.read<CommentsCubit>();
    final isOwner = comment.isOwnedBy(cubit.currentUserId);
    if (!isOwner && !await _ensureSignedIn()) return;
    if (!mounted) return;

    final action = await _showActionPicker(
      title: isOwner ? context.l10n.commentsYourComment : comment.authorName,
      actions: isOwner
          ? [
              _MenuAction('edit', context.l10n.commonEdit, Icons.edit_rounded),
              _MenuAction(
                'delete',
                context.l10n.commonDelete,
                Icons.delete_outline_rounded,
                destructive: true,
              ),
            ]
          : [
              _MenuAction(
                'report',
                context.l10n.commonReport,
                Icons.flag_outlined,
                destructive: true,
              ),
            ],
    );
    if (!mounted || action == null) return;
    if (action == 'edit') {
      setState(() {
        _replyingTo = null;
        _editing = comment;
        _composerController.text = comment.body;
        _composerController.selection = TextSelection.collapsed(
          offset: comment.body.length,
        );
      });
      await _focusComposer(authChecked: true);
    } else if (action == 'delete') {
      final confirmed = await _confirmDelete();
      if (confirmed && mounted) cubit.softDelete(comment);
    } else if (action == 'report') {
      await _showReportReasons(comment);
    }
  }

  Future<void> _showReportReasons(Comment comment) async {
    final action = await _showActionPicker(
      title: context.l10n.commentsReportReasonTitle,
      actions: CommentReportReason.values
          .map(
            (reason) => _MenuAction(
              reason.databaseValue,
              _reportReasonLabel(context, reason),
              Icons.flag_outlined,
            ),
          )
          .toList(),
    );
    if (!mounted || action == null) return;
    final reason = CommentReportReason.values.firstWhere(
      (item) => item.databaseValue == action,
    );
    final sent = await context.read<CommentsCubit>().report(comment, reason);
    if (sent && mounted) {
      AppToast.show(context, context.l10n.commentsReportSent);
    }
  }

  Future<bool> _confirmDelete() async {
    final result = await _showActionPicker(
      title: context.l10n.commentsDeleteTitle,
      message: context.l10n.commentsRepliesPreserved,
      actions: [
        _MenuAction(
          'confirm',
          context.l10n.commentsDeleteAction,
          Icons.delete_outline_rounded,
          destructive: true,
        ),
      ],
    );
    return result == 'confirm';
  }

  Future<void> _showSortPicker(CommentSort currentSort) async {
    final action = await _showActionPicker(
      title: context.l10n.commentsSortTitle,
      actions: [
        _MenuAction(
          CommentSort.popular.name,
          context.l10n.commentsPopular,
          currentSort == CommentSort.popular
              ? Icons.check_rounded
              : Icons.local_fire_department_outlined,
        ),
        _MenuAction(
          CommentSort.newest.name,
          context.l10n.commentsNewest,
          currentSort == CommentSort.newest
              ? Icons.check_rounded
              : Icons.schedule_rounded,
        ),
      ],
    );
    if (!mounted || action == null) return;

    final selectedSort = CommentSort.values.firstWhere(
      (sort) => sort.name == action,
    );
    await context.read<CommentsCubit>().changeSort(selectedSort);
  }

  Future<String?> _showActionPicker({
    required String title,
    String? message,
    required List<_MenuAction> actions,
  }) async {
    if (PlatformVersion.isIOS26OrLater) {
      String? selectedAction;
      await showGlassActionSheet<void>(
        context: context,
        title: title,
        message: message,
        cancelLabel: context.l10n.commonCancel,
        actions: actions
            .map(
              (action) => GlassActionSheetAction(
                label: action.label,
                icon: Icon(action.icon),
                style: action.destructive
                    ? GlassActionSheetStyle.destructive
                    : GlassActionSheetStyle.defaultStyle,
                onPressed: () => selectedAction = action.value,
              ),
            )
            .toList(),
      );
      return selectedAction;
    }

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (sheetContext) => _BlurActionSheet(
        title: title,
        message: message,
        actions: actions,
        onSelected: (value) => Navigator.of(sheetContext).pop(value),
      ),
    );
  }
}

class _CommentsHeader extends StatelessWidget {
  const _CommentsHeader({
    required this.count,
    required this.sort,
    required this.onSortChanged,
  });

  final int count;
  final CommentSort sort;
  final ValueChanged<CommentSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 13, 10, 12),
      child: Row(
        children: [
          Text(
            context.l10n.commentsCount(count),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          if (PlatformVersion.isIOS26OrLater)
            GlassMenu(
              menuWidth: 160,
              menuBorderRadius: 30,
              itemBorderRadius: 22,
              autoAdjustToScreen: true,
              menuPadding: const EdgeInsets.all(10),
              selectionColor: AppColor.secondColor,
              glassSettings: const LiquidGlassSettings(
                blur: 10,
                thickness: 12,
                visibility: 0.3,
                glassColor: Colors.white10,
                lightIntensity: 0.7,
                ambientStrength: 0.45,
                saturation: 1.2,
                refractiveIndex: 0.8,
                chromaticAberration: 0,
              ),
              triggerBuilder: (context, toggleMenu) =>
                  _SortTrigger(sort: sort, onTap: toggleMenu),
              items: [
                _glassSortItem(
                  sort: CommentSort.popular,
                  currentSort: sort,
                  label: context.l10n.commentsPopular,
                  icon: Icons.local_fire_department_outlined,
                ),
                _glassSortItem(
                  sort: CommentSort.newest,
                  currentSort: sort,
                  label: context.l10n.commentsNewest,
                  icon: Icons.schedule_rounded,
                ),
              ],
            )
          else
            _AndroidSortMenu(sort: sort, onSortChanged: onSortChanged),
        ],
      ),
    );
  }

  GlassMenuItem _glassSortItem({
    required CommentSort sort,
    required CommentSort currentSort,
    required String label,
    required IconData icon,
  }) {
    final selected = sort == currentSort;
    return GlassMenuItem(
      title: label,
      height: 58,
      onTap: () => onSortChanged(sort),
      trailing: selected
          ? const Icon(
              Icons.check_rounded,
              color: AppColor.secondColor,
              size: 21,
            )
          : null,
      titleStyle: TextStyle(
        color: selected ? AppColor.secondColor : Colors.white,
        fontSize: 16,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }
}

class _SortTrigger extends StatelessWidget {
  const _SortTrigger({required this.sort, this.onTap});

  final CommentSort sort;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const Icon(Icons.tune_rounded, color: Colors.white70, size: 20),

          const SizedBox(width: 6),

          Text(
            sort == CommentSort.popular
                ? context.l10n.commentsPopular
                : context.l10n.commentsNewest,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );

    return Semantics(
      button: true,
      label: context.l10n.commentsSortTitle,
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(14),
                child: content,
              ),
            ),
    );
  }
}

class _CommentCopyOverlay extends StatelessWidget {
  const _CommentCopyOverlay({required this.comment});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Nền blur phủ toàn màn hình
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.32),
                    ),
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: SafeArea(
                minimum: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Bình luận phóng to
                      Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minHeight: 104,
                            maxWidth: 430,
                            maxHeight: 290,
                          ),
                          child: Material(
                            elevation: 24,
                            shadowColor: Colors.black87,
                            color: const Color(0xff272832),
                            borderRadius: BorderRadius.circular(18),
                            clipBehavior: Clip.antiAlias,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 18,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _Avatar(
                                    name: comment.authorName,
                                    avatarUrl: comment.authorAvatarUrl,
                                  ),

                                  const SizedBox(width: 11),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${comment.authorName} · '
                                          '${_relativeTime(context, comment.createdAt)}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white60,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),

                                        const SizedBox(height: 7),

                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              if (comment.replyToName != null)
                                                TextSpan(
                                                  text:
                                                      '@${comment.replyToName} ',
                                                  style: const TextStyle(
                                                    color: CupertinoColors
                                                        .activeBlue,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),

                                              ..._commentBodySpans(
                                                comment.body,
                                                emojiFontSize: 21,
                                              ),
                                            ],
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            height: 1.45,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Menu chỉ có sao chép
                      Align(
                        alignment: Alignment.centerRight,
                        child: Material(
                          elevation: 24,
                          shadowColor: Colors.black87,
                          color: const Color(0xff272832),
                          borderRadius: BorderRadius.circular(16),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.of(context).pop(true);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 15,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.copy_rounded,
                                    color: Colors.white,
                                    size: 21,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    context.l10n.commentsCopy,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AndroidSortMenu extends StatelessWidget {
  const _AndroidSortMenu({required this.sort, required this.onSortChanged});

  final CommentSort sort;
  final ValueChanged<CommentSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<CommentSort>(
      // initialValue: sort,
      tooltip: context.l10n.commentsSortTitle,

      // Hiện menu phía dưới nút
      position: PopupMenuPosition.under,
      offset: const Offset(-45, 4),

      // Background
      color: const Color(0xff272832),
      surfaceTintColor: Colors.transparent,

      elevation: 14,
      shadowColor: Colors.black.withValues(alpha: 0.45),

      constraints: const BoxConstraints(minWidth: 175, maxWidth: 190),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),

      menuPadding: const EdgeInsets.all(8),

      // Flutter của bạn nếu hỗ trợ property này
      // thì animation sẽ mềm hơn nữa.
      popUpAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 220),
        reverseDuration: Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),

      onSelected: onSortChanged,

      itemBuilder: (_) => [
        _buildItem(
          value: CommentSort.popular,
          current: sort,
          label: context.l10n.commentsPopular,
          icon: Icons.local_fire_department_outlined,
        ),
        _buildItem(
          value: CommentSort.newest,
          current: sort,
          label: context.l10n.commentsNewest,
          icon: Icons.schedule_rounded,
        ),
      ],

      // Không truyền onTap.
      // PopupMenuButton tự nhận tap và mở menu.
      child: _SortTrigger(sort: sort),
    );
  }

  PopupMenuItem<CommentSort> _buildItem({
    required CommentSort value,
    required CommentSort current,
    required String label,
    required IconData icon,
  }) {
    final selected = value == current;

    return PopupMenuItem<CommentSort>(
      value: value,
      height: 54,
      padding: EdgeInsets.zero,

      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColor.secondColor.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? AppColor.secondColor : Colors.white70,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? AppColor.secondColor : Colors.white,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),

            if (selected)
              const Icon(
                Icons.check_rounded,
                size: 20,
                color: AppColor.secondColor,
              ),
          ],
        ),
      ),
    );
  }
}

class CommentTile extends StatelessWidget {
  const CommentTile({
    super.key,
    required this.comment,
    required this.isPending,
    required this.onLike,
    required this.onDislike,
    required this.onReply,
    required this.onMenu,
    this.onLongPressStart,
    this.onOpenReplies,
    this.repliesExpanded,
    this.showReplyConnector = false,
    this.continueThreadConnector = false,
  });

  final Comment comment;
  final bool isPending;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onReply;
  final VoidCallback onMenu;

  final GestureLongPressStartCallback? onLongPressStart;

  final VoidCallback? onOpenReplies;
  final bool? repliesExpanded;
  final bool showReplyConnector;
  final bool continueThreadConnector;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      onLongPressStart: comment.isDeleted ? null : onLongPressStart,

      child: CustomPaint(
        painter: showReplyConnector || continueThreadConnector
            ? _RootThreadConnectorPainter(
                curveToReplyButton: showReplyConnector,
              )
            : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 160),
          opacity: isPending ? 0.58 : 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(
                  name: comment.authorName,
                  avatarUrl: comment.authorAvatarUrl,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${comment.authorName} · ${_relativeTime(context, comment.createdAt)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          InkResponse(
                            onTap: onMenu,
                            radius: 20,
                            child: const Padding(
                              padding: EdgeInsets.all(5),
                              child: Icon(
                                Icons.more_vert_rounded,
                                color: Colors.white70,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      _ExpandableCommentText(comment: comment),
                      if (comment.wasEdited)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            context.l10n.commentsEdited,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      if (!comment.isDeleted) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _ReactionButton(
                              icon: Iconsax.like_1_copy,
                              selectedIcon: Iconsax.like_1,
                              selected:
                                  comment.viewerReaction ==
                                  CommentReaction.like,
                              count: comment.likeCount,
                              onTap: onLike,
                            ),
                            const SizedBox(width: 12),
                            _ReactionButton(
                              icon: Iconsax.dislike_copy,
                              selectedIcon: Iconsax.dislike,
                              selected:
                                  comment.viewerReaction ==
                                  CommentReaction.dislike,
                              onTap: onDislike,
                            ),
                            const SizedBox(width: 12),
                            TextButton.icon(
                              onPressed: onReply,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white70,
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                              ),
                              icon: const Icon(Iconsax.message_copy, size: 19),
                              label: Text(
                                context.l10n.commentsReply,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (comment.replyCount > 0 && onOpenReplies != null)
                        TextButton(
                          onPressed: onOpenReplies,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white.withValues(
                              alpha: 0.86,
                            ),
                            padding: const EdgeInsets.fromLTRB(5, 3, 8, 3),
                            visualDensity: VisualDensity.compact,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.l10n.commentsReplyCount(
                                  comment.replyCount,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Icon(
                                repliesExpanded == null
                                    ? Icons.chevron_right_rounded
                                    : repliesExpanded!
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpandableCommentText extends StatefulWidget {
  const _ExpandableCommentText({required this.comment});

  final Comment comment;

  @override
  State<_ExpandableCommentText> createState() => _ExpandableCommentTextState();
}

class _ExpandableCommentTextState extends State<_ExpandableCommentText> {
  static const int _collapsedLines = 5;

  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;

    final textStyle = TextStyle(
      color: comment.isDeleted
          ? Colors.white38
          : Colors.white.withValues(alpha: 0.9),
      fontSize: 12.5,
      height: 1.42,
      fontStyle: comment.isDeleted ? FontStyle.italic : FontStyle.normal,
    );

    final textSpan = TextSpan(
      style: textStyle,
      children: [
        if (!comment.isDeleted && comment.replyToName != null)
          TextSpan(
            text: '@${comment.replyToName} ',
            style: const TextStyle(
              color: CupertinoColors.activeBlue,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),

        if (comment.isDeleted)
          TextSpan(text: context.l10n.commentsDeleted)
        else
          ..._commentBodySpans(comment.body, emojiFontSize: 18),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Đo nội dung để biết có vượt quá 5 dòng không.
        final textPainter = TextPainter(
          text: textSpan,
          maxLines: _collapsedLines,
          ellipsis: '…',
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          locale: Localizations.localeOf(context),
        )..layout(maxWidth: constraints.maxWidth);

        final needsExpandButton = textPainter.didExceedMaxLines;

        return AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                textSpan,
                maxLines: _isExpanded ? null : _collapsedLines,
                overflow: _isExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
              ),

              if (needsExpandButton)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: AppColor.secondColor,
                    ),
                    child: Text(
                      _isExpanded
                          ? context.l10n.commonCollapse
                          : context.l10n.commonSeeMore,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

List<InlineSpan> _commentBodySpans(
  String text, {
  required double emojiFontSize,
}) {
  if (text.isEmpty) return const <InlineSpan>[];

  final runes = text.runes.toList(growable: false);
  final spans = <InlineSpan>[];
  final textRunes = <int>[];
  final emojiRunes = <int>[];

  void flushText() {
    if (textRunes.isEmpty) return;
    spans.add(TextSpan(text: String.fromCharCodes(textRunes)));
    textRunes.clear();
  }

  void flushEmoji() {
    if (emojiRunes.isEmpty) return;
    spans.add(
      TextSpan(
        text: String.fromCharCodes(emojiRunes),
        style: TextStyle(
          fontSize: emojiFontSize,
          height: 1,
          fontFamilyFallback: const [
            'Apple Color Emoji',
            'Noto Color Emoji',
            'Segoe UI Emoji',
          ],
        ),
      ),
    );
    emojiRunes.clear();
  }

  for (var index = 0; index < runes.length; index++) {
    final rune = runes[index];
    final previousRune = index > 0 ? runes[index - 1] : null;

    if (emojiRunes.isNotEmpty &&
        (_isEmojiModifierRune(rune) || rune == 0x200D)) {
      emojiRunes.add(rune);
      continue;
    }

    final isKeycapStart =
        _isKeycapBase(rune) &&
        index + 1 < runes.length &&
        (runes[index + 1] == 0xFE0F || runes[index + 1] == 0x20E3);
    final isEmojiBase = _isEmojiBaseRune(rune) || isKeycapStart;

    if (isEmojiBase) {
      flushText();

      final joinsPrevious = previousRune == 0x200D;
      final joinsRegionalFlag =
          emojiRunes.isNotEmpty &&
          _isRegionalIndicator(emojiRunes.last) &&
          _isRegionalIndicator(rune);
      if (emojiRunes.isNotEmpty && !joinsPrevious && !joinsRegionalFlag) {
        flushEmoji();
      }

      emojiRunes.add(rune);
      continue;
    }

    flushEmoji();
    textRunes.add(rune);
  }

  flushEmoji();
  flushText();
  return spans;
}

bool _isEmojiBaseRune(int rune) {
  return (rune >= 0x1F000 && rune <= 0x1FAFF) ||
      (rune >= 0x2600 && rune <= 0x27BF) ||
      (rune >= 0x2300 && rune <= 0x23FF) ||
      _isRegionalIndicator(rune) ||
      const <int>{
        0x00A9,
        0x00AE,
        0x203C,
        0x2049,
        0x2122,
        0x2139,
        0x2B50,
        0x2B55,
        0x3030,
        0x303D,
        0x3297,
        0x3299,
      }.contains(rune);
}

bool _isRegionalIndicator(int rune) => rune >= 0x1F1E6 && rune <= 0x1F1FF;

bool _isEmojiModifierRune(int rune) {
  return rune == 0xFE0E ||
      rune == 0xFE0F ||
      rune == 0x20E3 ||
      (rune >= 0x1F3FB && rune <= 0x1F3FF);
}

bool _isKeycapBase(int rune) =>
    rune == 0x23 || rune == 0x2A || (rune >= 0x30 && rune <= 0x39);

class _ThreadReplyBranch extends StatelessWidget {
  const _ThreadReplyBranch({
    super.key,
    required this.depth,
    required this.hasLaterSibling,
    required this.continuingAncestorDepths,
    required this.hasVisibleChildren,
    required this.child,
  });

  final int depth;

  /// Bình luận hiện tại còn một bình luận cùng cấp ở phía dưới.
  final bool hasLaterSibling;

  /// Các cấp cha cần tiếp tục vẽ đường dọc qua tile hiện tại.
  final Set<int> continuingAncestorDepths;

  /// Bình luận hiện tại có ít nhất một con đang hiển thị.
  final bool hasVisibleChildren;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final safeDepth = depth < 0 ? 0 : depth;

    return CustomPaint(
      painter: _ReplyThreadConnectorPainter(
        depth: safeDepth,
        hasLaterSibling: hasLaterSibling,
        continuingAncestorDepths: continuingAncestorDepths,
        hasVisibleChildren: hasVisibleChildren,
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 28.0 * (safeDepth + 1)),
        child: child,
      ),
    );
  }
}

class _RootThreadConnectorPainter extends CustomPainter {
  const _RootThreadConnectorPainter({required this.curveToReplyButton});

  final bool curveToReplyButton;

  @override
  void paint(Canvas canvas, Size size) {
    const spineX = 23.0;
    const startY = 50.0;
    final paint = _threadLinePaint();
    if (size.height <= startY) return;

    if (!curveToReplyButton) {
      canvas.drawLine(
        const Offset(spineX, startY),
        Offset(spineX, size.height),
        paint,
      );
      return;
    }

    // TextButton compact cao khoảng 40px và tile có padding đáy 11px.
    // Trừ 31 để nét ngang đi đúng qua tâm của dòng "n phản hồi".
    final branchY = (size.height - 31).clamp(startY + 8, size.height);
    final path = Path()
      ..moveTo(spineX, startY)
      ..lineTo(spineX, branchY - 15)
      ..quadraticBezierTo(spineX, branchY, spineX + 15, branchY)
      // Cột nội dung bắt đầu tại x=52; dừng trước nhãn 5px.
      ..lineTo(spineX + 29, branchY);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RootThreadConnectorPainter oldDelegate) =>
      oldDelegate.curveToReplyButton != curveToReplyButton;
}

class _ReplyThreadConnectorPainter extends CustomPainter {
  const _ReplyThreadConnectorPainter({
    required this.depth,
    required this.hasLaterSibling,
    required this.continuingAncestorDepths,
    required this.hasVisibleChildren,
  });

  final int depth;
  final bool hasLaterSibling;
  final Set<int> continuingAncestorDepths;
  final bool hasVisibleChildren;

  static const double _baseSpineX = 23;
  static const double _indent = 28;
  static const double _branchY = 30;
  static const double _turnStartY = 15;

  double _spineX(int level) {
    return _baseSpineX + level * _indent;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = _threadLinePaint();

    // Vẽ các đường của cấp cha chỉ khi cấp đó thật sự
    // còn một nhánh cùng cấp ở phía dưới.
    for (final ancestorDepth in continuingAncestorDepths) {
      final ancestorSpineX = _spineX(ancestorDepth);

      canvas.drawLine(
        Offset(ancestorSpineX, 0),
        Offset(ancestorSpineX, size.height),
        paint,
      );
    }

    final currentSpineX = _spineX(depth);
    final avatarX = currentSpineX + _indent;

    // Đường đi vào bình luận hiện tại.
    // Chỉ kéo hết tile khi còn sibling cùng cấp.
    canvas.drawLine(
      Offset(currentSpineX, 0),
      Offset(currentSpineX, hasLaterSibling ? size.height : _turnStartY),
      paint,
    );

    // Đường cong nối vào avatar.
    final branchPath = Path()
      ..moveTo(currentSpineX, _turnStartY)
      ..quadraticBezierTo(currentSpineX, _branchY, currentSpineX + 15, _branchY)
      ..lineTo(avatarX, _branchY);

    canvas.drawPath(branchPath, paint);

    // Mở đường cho cấp con.
    if (hasVisibleChildren) {
      final childSpineX = _spineX(depth + 1);

      canvas.drawLine(
        Offset(childSpineX, 50),
        Offset(childSpineX, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ReplyThreadConnectorPainter oldDelegate) {
    final ancestorsChanged =
        oldDelegate.continuingAncestorDepths.length !=
            continuingAncestorDepths.length ||
        !oldDelegate.continuingAncestorDepths.containsAll(
          continuingAncestorDepths,
        );

    return oldDelegate.depth != depth ||
        oldDelegate.hasLaterSibling != hasLaterSibling ||
        oldDelegate.hasVisibleChildren != hasVisibleChildren ||
        ancestorsChanged;
  }
}

Paint _threadLinePaint() => Paint()
  ..color = Colors.white.withValues(alpha: 0.22)
  ..strokeWidth = 1.35
  ..strokeCap = StrokeCap.round
  ..style = PaintingStyle.stroke;

class _ReactionButton extends StatelessWidget {
  const _ReactionButton({
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? AppColor.secondColor.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          children: [
            AnimatedScale(
              scale: selected ? 1.1 : 1,
              duration: const Duration(milliseconds: 140),
              child: Icon(
                selected ? selectedIcon : icon,
                size: 20,
                color: selected ? AppColor.secondColor : Colors.white70,
              ),
            ),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 5),
              Text(
                '$count',
                style: TextStyle(
                  color: selected ? AppColor.secondColor : Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.avatarUrl});

  final String name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final validUrl = avatarUrl != null && avatarUrl!.trim().isNotEmpty;
    return CircleAvatar(
      radius: 19,
      backgroundColor: const Color(0xff6155A6),
      backgroundImage: validUrl
          ? ResizeImage.resizeIfNeeded(144, null, NetworkImage(avatarUrl!))
          : null,
      child: validUrl
          ? null
          : Text(
              name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}

class _ComposerAvatar extends StatelessWidget {
  const _ComposerAvatar({this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final validUrl = avatarUrl != null && avatarUrl!.trim().isNotEmpty;
    return CircleAvatar(
      radius: 17,
      backgroundColor: Colors.white10,
      backgroundImage: validUrl
          ? ResizeImage.resizeIfNeeded(144, null, NetworkImage(avatarUrl!))
          : null,
      child: validUrl
          ? null
          : const Icon(Icons.person_rounded, color: Colors.white54, size: 20),
    );
  }
}

class _MenuAction {
  const _MenuAction(
    this.value,
    this.label,
    this.icon, {
    this.destructive = false,
  });

  final String value;
  final String label;
  final IconData icon;
  final bool destructive;
}

class _BlurActionSheet extends StatelessWidget {
  const _BlurActionSheet({
    required this.title,
    required this.actions,
    required this.onSelected,
    this.message,
  });

  final String title;
  final String? message;
  final List<_MenuAction> actions;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xff252431).withValues(alpha: 0.94),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.13)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      message!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ],
                  const SizedBox(height: 12),
                  for (final action in actions)
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      leading: Icon(
                        action.icon,
                        color: action.destructive
                            ? const Color(0xffFF758F)
                            : const Color(0xffD6B4FC),
                      ),
                      title: Text(
                        action.label,
                        style: TextStyle(
                          color: action.destructive
                              ? const Color(0xffFF9CAD)
                              : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () => onSelected(action.value),
                    ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        context.l10n.commonCancel,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CommentSkeleton extends StatelessWidget {
  const _CommentSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 19, backgroundColor: Colors.white10),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bar(120),
                const SizedBox(height: 10),
                _bar(double.infinity),
                const SizedBox(height: 7),
                _bar(220),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(double width) {
    return Container(
      width: width,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - 32).clamp(
                0.0,
                double.infinity,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white24, size: 44),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white38),
                    ),
                  ],
                  if (onAction != null) ...[
                    const SizedBox(height: 8),
                    TextButton(onPressed: onAction, child: Text(actionLabel!)),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

String _relativeTime(BuildContext context, DateTime dateTime) {
  final difference = DateTime.now().difference(dateTime);
  if (difference.inMinutes < 1) return context.l10n.commentsJustNow;
  if (difference.inHours < 1) {
    return context.l10n.commentsMinutesAgo(difference.inMinutes);
  }
  if (difference.inDays < 1) {
    return context.l10n.commentsHoursAgo(difference.inHours);
  }
  if (difference.inDays < 7) {
    return context.l10n.commentsDaysAgo(difference.inDays);
  }
  if (difference.inDays < 30) {
    return context.l10n.commentsWeeksAgo((difference.inDays / 7).floor());
  }
  if (difference.inDays < 365) {
    return context.l10n.commentsMonthsAgo((difference.inDays / 30).floor());
  }
  return context.l10n.commentsYearsAgo((difference.inDays / 365).floor());
}

String _reportReasonLabel(BuildContext context, CommentReportReason reason) {
  return switch (reason) {
    CommentReportReason.spam => context.l10n.commentsSpamReason,
    CommentReportReason.harassment => context.l10n.commentsHarassmentReason,
    CommentReportReason.spoiler => context.l10n.commentsSpoilerReason,
    CommentReportReason.inappropriate =>
      context.l10n.commentsInappropriateReason,
    CommentReportReason.other => context.l10n.commentsOtherReason,
  };
}

String _localizedCommentError(BuildContext context, String error) {
  return switch (error) {
    'Không tải được bình luận. Hãy thử lại.' => context.l10n.commentsLoadFailed,
    'Chưa tải thêm được bình luận.' => context.l10n.commentsLoadMoreFailed,
    'Không tải được phần trả lời.' => context.l10n.commentsRepliesLoadFailed,
    'Chưa tải thêm được phần trả lời.' =>
      context.l10n.commentsRepliesLoadMoreFailed,
    'Chưa gửi được bình luận. Nội dung vẫn được giữ lại.' =>
      context.l10n.commentsSendFailed,
    'Không thể chỉnh sửa bình luận.' => context.l10n.commentsEditFailed,
    'Không thể xóa bình luận.' => context.l10n.commentsDeleteFailed,
    'Không thể cập nhật cảm xúc.' => context.l10n.commentsReactionFailed,
    'Bình luận này đã được báo cáo hoặc chưa thể gửi.' =>
      context.l10n.commentsReportFailed,
    'Thao tác này đang được xử lý.' => context.l10n.commentsOperationInProgress,
    _ => context.l10n.commentsLoadFailed,
  };
}

class _EmojiComposerController extends TextEditingController {
  _EmojiComposerController({this.emojiFontSize = 19});

  final double emojiFontSize;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final baseStyle = style ?? const TextStyle();
    final currentText = text;
    final composing = value.composing;

    final hasValidComposing =
        withComposing &&
        composing.isValid &&
        !composing.isCollapsed &&
        composing.start >= 0 &&
        composing.end <= currentText.length;

    // Không có composing region:
    // render toàn bộ bằng đúng helper emoji mà list comment đang dùng.
    if (!hasValidComposing) {
      return TextSpan(
        style: baseStyle,
        children: _commentBodySpans(currentText, emojiFontSize: emojiFontSize),
      );
    }

    // Giữ composing region để bàn phím,
    // đặc biệt bàn phím tiếng Việt, hoạt động bình thường.
    final before = currentText.substring(0, composing.start);

    final composingText = currentText.substring(composing.start, composing.end);

    final after = currentText.substring(composing.end);

    return TextSpan(
      style: baseStyle,
      children: [
        ..._commentBodySpans(before, emojiFontSize: emojiFontSize),

        TextSpan(
          style: baseStyle.copyWith(decoration: TextDecoration.underline),
          children: _commentBodySpans(
            composingText,
            emojiFontSize: emojiFontSize,
          ),
        ),

        ..._commentBodySpans(after, emojiFontSize: emojiFontSize),
      ],
    );
  }
}
