import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/search/data/repositories/search_history_repository.dart';
import 'package:movie_app/feature/search/domain/entities/search_filter_params.dart';
import 'package:movie_app/feature/search/domain/repositories/search_repository.dart';
import 'package:movie_app/feature/search/domain/usecases/search_movies_usecase.dart';
import 'package:movie_app/feature/search/presentation/bloc/search_cubit.dart';
import 'package:movie_app/feature/search/presentation/bloc/search_state.dart';

void main() {
  test('loads search history from the current account', () async {
    final historyRepository = _FakeSearchHistoryRepository()
      ..userId = 'user-1'
      ..historyByUser['user-1'] = ['Dune', 'Batman'];
    final cubit = _buildCubit(historyRepository);
    addTearDown(cubit.close);
    addTearDown(historyRepository.close);

    await _waitForAsyncWork();

    expect((cubit.state as SearchInitial).history, ['Dune', 'Batman']);
  });

  test(
    'reloads a different history after the signed-in account changes',
    () async {
      final historyRepository = _FakeSearchHistoryRepository()
        ..userId = 'user-1'
        ..historyByUser['user-1'] = ['Dune']
        ..historyByUser['user-2'] = ['Avatar'];
      final cubit = _buildCubit(historyRepository);
      addTearDown(cubit.close);
      addTearDown(historyRepository.close);
      await _waitForAsyncWork();

      historyRepository.changeUser('user-2');
      await _waitForAsyncWork();

      expect((cubit.state as SearchInitial).history, ['Avatar']);
    },
  );

  test('saves a keyword through the account repository only', () async {
    final historyRepository = _FakeSearchHistoryRepository()..userId = 'user-1';
    final cubit = _buildCubit(historyRepository);
    addTearDown(cubit.close);
    addTearDown(historyRepository.close);
    await _waitForAsyncWork();

    await cubit.addToHistory('  Dune  ');

    expect((cubit.state as SearchInitial).history, ['Dune']);
    expect(historyRepository.savedKeywords, ['Dune']);
  });

  test('does not retain search history while signed out', () async {
    final historyRepository = _FakeSearchHistoryRepository();
    final cubit = _buildCubit(historyRepository);
    addTearDown(cubit.close);
    addTearDown(historyRepository.close);
    await _waitForAsyncWork();

    await cubit.addToHistory('Dune');

    expect((cubit.state as SearchInitial).history, isEmpty);
    expect(historyRepository.savedKeywords, isEmpty);
  });
}

SearchCubit _buildCubit(SearchHistoryRepository historyRepository) =>
    SearchCubit(
      searchUseCase: SearchMoviesUseCase(_FakeSearchRepository()),
      historyRepository: historyRepository,
    );

Future<void> _waitForAsyncWork() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

class _FakeSearchRepository implements SearchRepository {
  @override
  Future<Either<String, List<MovieModel>>> searchMovies(
    String keyword,
    SearchFilterParams filters,
    int page,
  ) async => const Right([]);
}

class _FakeSearchHistoryRepository implements SearchHistoryRepository {
  final StreamController<String?> _userChanges =
      StreamController<String?>.broadcast();
  final Map<String, List<String>> historyByUser = {};
  final List<String> savedKeywords = [];
  String? userId;

  @override
  String? get currentUserId => userId;

  @override
  Stream<String?> get userChanges => _userChanges.stream;

  void changeUser(String? nextUserId) {
    userId = nextUserId;
    _userChanges.add(nextUserId);
  }

  Future<void> close() => _userChanges.close();

  @override
  Future<List<String>> getHistory() async =>
      List<String>.from(historyByUser[userId] ?? const []);

  @override
  Future<void> saveKeyword(String keyword) async {
    savedKeywords.add(keyword);
  }

  @override
  Future<void> deleteKeyword(String keyword) async {}
}
