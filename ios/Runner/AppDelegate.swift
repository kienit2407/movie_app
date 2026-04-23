import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let storyboardGenerator = StoryboardGenerator()

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        guard let controller = window?.rootViewController as? FlutterViewController else {
            print("[Storyboard iOS] rootViewController is not FlutterViewController")
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }

        let channel = FlutterMethodChannel(
            name: "movie_player/storyboard",
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { [weak self] call, result in
            guard call.method == "thumbnailAt" else {
                result(FlutterMethodNotImplemented)
                return
            }

            guard
                let args = call.arguments as? [String: Any],
                let url = args["url"] as? String,
                let timeMs = args["timeMs"] as? Int,
                let maxWidth = args["maxWidth"] as? Int,
                let maxHeight = args["maxHeight"] as? Int
            else {
                result(FlutterError(code: "bad_args", message: "Invalid arguments", details: nil))
                return
            }

            self?.storyboardGenerator.thumbnailAt(
                urlString: url,
                timeMs: timeMs,
                maxWidth: maxWidth,
                maxHeight: maxHeight
            ) { nativeResult in
                switch nativeResult {
                case .success(let path):
                    result(path)
                case .failure(let error):
                    result(FlutterError(
                        code: "thumbnail_failed",
                        message: error.localizedDescription,
                        details: nil
                    ))
                }
            }
        }

        print("[Storyboard iOS] channel registered successfully")
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
