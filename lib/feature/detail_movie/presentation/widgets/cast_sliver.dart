import 'package:flutter/material.dart';
import 'package:movie_app/core/extension/build_context_extension.dart';

class CastSliver extends StatelessWidget {
  final List<String> actors;

  const CastSliver({super.key, required this.actors});

  @override
  Widget build(BuildContext context) {
    if (actors.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 100,
          child: Center(
            child: Text(
              context.l10n.detailCastUnavailable,
              style: const TextStyle(color: Colors.white54),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final actorName = actors[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white10,
                child: const Icon(
                  Icons.person,
                  color: Colors.white54,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  actorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                context.l10n.detailCast,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        );
      }, childCount: actors.length),
    );
  }
}
