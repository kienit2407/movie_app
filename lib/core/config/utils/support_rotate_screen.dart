import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SupportRotateScreen {
  static Future<void> _orientationQueue = Future<void>.value();
  static int _orientationRequestVersion = 0;

  static Future<void> _setPreferredOrientations(
    List<DeviceOrientation> orientations,
  ) {
    final requestVersion = ++_orientationRequestVersion;
    final request = _orientationQueue.then((_) async {
      // Nếu một yêu cầu mới hơn đã tới trước khi yêu cầu này bắt đầu thì bỏ
      // yêu cầu cũ. Quan trọng trên iOS vì hai requestGeometryUpdate chạy
      // đồng thời có thể tạo cặp lỗi supported/requested orientation ngược nhau.
      if (requestVersion != _orientationRequestVersion) return;

      if (defaultTargetPlatform == TargetPlatform.iOS &&
          orientations.length < 3) {
        // Flutter iOS hiện gọi requestGeometryUpdate trước
        // setNeedsUpdateOfSupportedInterfaceOrientations. Mở mask của player
        // trước một run-loop để UIViewController kịp nhận cả dọc lẫn ngang,
        // sau đó mới khóa vào hướng đích; nếu khóa thẳng iOS có thể báo Code 101.
        await SystemChrome.setPreferredOrientations(const [
          DeviceOrientation.portraitUp,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        await Future<void>.delayed(const Duration(milliseconds: 16));
        if (requestVersion != _orientationRequestVersion) return;
      }

      await SystemChrome.setPreferredOrientations(orientations);
    });

    // Giữ queue luôn tiếp tục được kể cả khi platform từ chối một lần xoay;
    // Future trả về vẫn giữ nguyên lỗi để nơi gọi có thể log/xử lý.
    _orientationQueue = request.then<void>(
      (_) {},
      onError: (Object _, StackTrace __) {},
    );
    return request;
  }

  static Future<void> onlyPotrait() {
    return _setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  static Future<void> onlyLandscape() {
    return _setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  static Future<void> allowPlayer() {
    return _setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  static Future<void> allowAll() {
    return _setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
    ]);
  }
}
