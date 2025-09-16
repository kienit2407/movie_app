import 'package:flutter_bloc/flutter_bloc.dart';

mixin PaginationMixin <State, Item> on Cubit<State> { // làm như vạy thì cso thể tái sử dụng lại khi tất cả đều cần phân trang
  final List<Item> _allItems = [];
  bool _hasRechedMax = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;

  List<Item> get allItems => _allItems; // hàm chứa tổng các item 
  bool get hasRechedMax => _hasRechedMax;
  int get currentPage => _currentPage;
  bool get isLoadingMore => _isLoadingMore;
 
  void resetLoadMore () {
    _allItems.clear();
    _hasRechedMax = false;
    _isLoadingMore = false;
    _currentPage = 1;
  }
  void mergeList (List<Item> newItems, int totalPage) {
    _allItems.addAll(newItems);
    _hasRechedMax = currentPage <= totalPage; //-> vẫn đúng khi mà trang hiện tại vẫn nhỏ hơn tổng số trang
  }
  void incrementPage () {
    _currentPage++;
  }
}