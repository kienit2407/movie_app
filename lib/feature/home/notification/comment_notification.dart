import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

enum CommentNotificationType {
  reply,
  reaction;

  static CommentNotificationType fromDatabase(Object? value) {
    return value == 'comment_reaction' ? reaction : reply;
  }
}

class CommentNotificationItem {
  const CommentNotificationItem({
    required this.id,
    required this.type,
    required this.movieSlug,
    required this.commentId,
    required this.actorName,
    required this.bodyPreview,
    required this.createdAt,
    this.actorAvatarUrl,
    this.readAt,
  });

  final String id;
  final CommentNotificationType type;
  final String movieSlug;
  final String commentId;
  final String actorName;
  final String? actorAvatarUrl;
  final String bodyPreview;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get isRead => readAt != null;

  CommentNotificationItem markRead(DateTime time) => CommentNotificationItem(
    id: id,
    type: type,
    movieSlug: movieSlug,
    commentId: commentId,
    actorName: actorName,
    actorAvatarUrl: actorAvatarUrl,
    bodyPreview: bodyPreview,
    createdAt: createdAt,
    readAt: time,
  );

  factory CommentNotificationItem.fromMap(Map<String, dynamic> map) {
    return CommentNotificationItem(
      id: map['id']?.toString() ?? '',
      type: CommentNotificationType.fromDatabase(map['type']),
      movieSlug: map['movie_slug']?.toString() ?? '',
      commentId: map['comment_id']?.toString() ?? '',
      actorName: map['actor_name']?.toString().trim().isNotEmpty == true
          ? map['actor_name'].toString()
          : 'Một người dùng',
      actorAvatarUrl: map['actor_avatar_url']?.toString(),
      bodyPreview: map['body_preview']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(map['created_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      readAt: DateTime.tryParse(map['read_at']?.toString() ?? '')?.toLocal(),
    );
  }
}

abstract interface class CommentNotificationRepository {
  Stream<void> watch();
  Future<List<CommentNotificationItem>> getItems();
  Future<void> markAllRead();
}

class SupabaseCommentNotificationRepository
    implements CommentNotificationRepository {
  SupabaseCommentNotificationRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Stream<void> watch() {
    late final StreamController<void> controller;
    StreamSubscription<AuthState>? authSubscription;
    RealtimeChannel? channel;
    String? subscribedUserId;
    var subscriptionVersion = 0;
    var cancelled = false;

    Future<void> subscribeFor(String? userId) async {
      if (subscribedUserId == userId) return;
      subscribedUserId = userId;
      final version = ++subscriptionVersion;

      final oldChannel = channel;
      channel = null;
      if (oldChannel != null) {
        await _client.removeChannel(oldChannel);
      }
      if (cancelled || version != subscriptionVersion) return;
      controller.add(null);
      if (userId == null) return;

      channel = _client
          .channel('comment-notifications-$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'comment_notifications',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'recipient_id',
              value: userId,
            ),
            callback: (_) {
              if (!cancelled) controller.add(null);
            },
          )
          .subscribe();
    }

    controller = StreamController<void>(
      onListen: () {
        unawaited(subscribeFor(_client.auth.currentUser?.id));
        authSubscription = _client.auth.onAuthStateChange.listen(
          (event) => unawaited(subscribeFor(event.session?.user.id)),
        );
      },
      onCancel: () async {
        cancelled = true;
        subscriptionVersion++;
        await authSubscription?.cancel();
        final currentChannel = channel;
        if (currentChannel != null) {
          await _client.removeChannel(currentChannel);
        }
      },
    );
    return controller.stream;
  }

  @override
  Future<List<CommentNotificationItem>> getItems() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const [];

    final response = await _client
        .from('comment_notifications')
        .select()
        .eq('recipient_id', userId)
        .order('created_at', ascending: false)
        .limit(100);

    return response
        .whereType<Map>()
        .map(
          (row) =>
              CommentNotificationItem.fromMap(Map<String, dynamic>.from(row)),
        )
        .where((item) => item.id.isNotEmpty && item.movieSlug.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<void> markAllRead() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client
        .from('comment_notifications')
        .update({'read_at': DateTime.now().toUtc().toIso8601String()})
        .eq('recipient_id', userId)
        .isFilter('read_at', null);
  }
}
