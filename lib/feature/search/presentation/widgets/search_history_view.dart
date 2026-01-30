import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/feature/search/presentation/bloc/search_cubit.dart';

class SearchHistoryView extends StatelessWidget {
  final List<String> history;
  final Function(String) onSelect;

  const SearchHistoryView({
    super.key,
    required this.history,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Center(
        child: Text(
          'Hãy nhập tên phim để tìm kiếm',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Tìm kiếm gần đây',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: history.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: Colors.white.withValues(alpha: 0.05),
            ),
            itemBuilder: (context, index) {
              final keyword = history[index];
              return ListTile(
                leading: const Icon(Icons.history, color: Colors.white54, size: 20,),
                title: Text(keyword, style: const TextStyle(color: Colors.white, fontSize: 12)),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white24, size: 18),
                  onPressed: () =>
                      context.read<SearchCubit>().deleteHistoryItem(index),
                ),
                onTap: () => onSelect(keyword),
              );
            },
          ),
        ),
      ],
    );
  }
}
