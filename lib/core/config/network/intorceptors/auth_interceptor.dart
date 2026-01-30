import 'dart:async';

import 'package:dio/dio.dart';
import 'package:movie_app/common/helpers/contants/app_url.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final Future<String?> Function() getAccessToken;
  final Future<String?> Function() getRefreshToken;
  final Future<void> Function(String access, String refresh) saveToken;
  bool _isRefreshing = false;
  final List<QueuedRequest> _queue = [];
  AuthInterceptor({required this.dio, required this.getAccessToken, required this.getRefreshToken, required this.saveToken});
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // lấy access Token ra để đưa vào Beaber
    final accessToken = await getAccessToken();
    if(accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Beaber ${accessToken}';
    }
    handler.next(options);
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if(err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;

      final refreshToken = await getRefreshToken();
      if(refreshToken == null) return handler.reject(err);
      try {
        final res = await dio.post(AppUrl.postRefreshToken, options: Options(
          headers: {
            'Authorization' : 'Beaber ${refreshToken}'
          }
        ));

        final newRefresh = res.data['refreshToken'];
        final newAccess = res.data['accessToken'];
        await saveToken(newAccess, newRefresh);

        for(final req in _queue) {
          req.resolve(
            dio.fetch(req.options..headers['Authorization'] = 'Beaber ${newAccess}')
          );
        }
        _queue.clear();
        _isRefreshing = false;
      } catch (_) {
        _isRefreshing = false;
        handler.reject(err);
      }
    } else if (_isRefreshing) {
      final completer =  QueuedRequestCompleted();
      _queue.add(QueuedRequest(options: err.requestOptions, resolve: completer.resolve));
      return completer.future.then((r) => handler.resolve(r)).catchError((e) => handler.reject(e));
    } else {
      handler.next(err);
    }
    super.onError(err, handler);
  }
}
// Giả sử như là 10 call api hết cùng hết hạn assessToken đi. Thì nếu k có hàng đợi đó thì cả 10 req đó gọi cùng lúc refresh Token gây ra lỗi crashh Server
// Cái này sẽ lưu lại các req bị lỗi 401 -> hết token thì nó sẽ gọi lại lần lượt các req bị lỗi đó mà tránh bị cresh app server

class QueuedRequest {
  final RequestOptions options; // chứa toàn bộ dữ liệu của request đó
  final void Function(Future<Response> response) resolve; // đùng dể chạy lại các request đó

  QueuedRequest({required this.options, required this.resolve});
}

class QueuedRequestCompleted {
  late final Completer<Response> _completer = Completer<Response>();
  Future<Response> get future => _completer.future;

  void resolve(Future<Response> response) async {
    _completer.complete(await response);
  }
}