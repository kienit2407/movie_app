class SearchFilterParams {
  final String sortField;
  final String sortType;
  final String? sortLang;
  final String? category;
  final String? country;
  final String? year;
  final int limit;

  const SearchFilterParams({
    this.sortField = 'modified.time',
    this.sortType = 'desc',
    this.sortLang,
    this.category,
    this.country,
    this.year,
    this.limit = 21,
  });

  static const defaults = SearchFilterParams();

  bool get isActive =>
      sortField != defaults.sortField ||
      sortType != defaults.sortType ||
      sortLang != null ||
      category != null ||
      country != null ||
      year != null ||
      limit != defaults.limit;

  String get signature =>
      '$sortField|$sortType|${sortLang ?? ''}|${category ?? ''}|${country ?? ''}|${year ?? ''}|$limit';

  SearchFilterParams copyWith({
    String? sortField,
    String? sortType,
    String? sortLang,
    String? category,
    String? country,
    String? year,
    int? limit,
    bool clearSortLang = false,
    bool clearCategory = false,
    bool clearCountry = false,
    bool clearYear = false,
  }) {
    return SearchFilterParams(
      sortField: sortField ?? this.sortField,
      sortType: sortType ?? this.sortType,
      sortLang: clearSortLang ? null : sortLang ?? this.sortLang,
      category: clearCategory ? null : category ?? this.category,
      country: clearCountry ? null : country ?? this.country,
      year: clearYear ? null : year ?? this.year,
      limit: limit ?? this.limit,
    );
  }

  Map<String, dynamic> toQueryParameters({
    required String keyword,
    required int page,
  }) {
    final query = <String, dynamic>{
      'keyword': keyword,
      'page': page,
      'limit': limit,
      'sort_field': sortField,
      'sort_type': sortType,
    };

    if (sortLang != null && sortLang!.isNotEmpty) {
      query['sort_lang'] = sortLang;
    }
    if (category != null && category!.isNotEmpty) {
      query['category'] = category;
    }
    if (country != null && country!.isNotEmpty) {
      query['country'] = country;
    }
    if (year != null && year!.isNotEmpty) {
      query['year'] = year;
    }

    return query;
  }
}
