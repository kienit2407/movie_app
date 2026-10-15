import UIKit
import Flutter
import UserNotifications
import flutter_local_notifications
import path_provider_foundation
import workmanager_apple
import AVKit
import AudioToolbox

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let storyboardGenerator = StoryboardGenerator()
    private var pictureInPictureBridge: IosPictureInPictureBridge?
    private var airPlayRoutePicker: AVRoutePickerView?
    private var castingChannel: FlutterMethodChannel?
    private var appBadgeChannel: FlutterMethodChannel?
    private var uiSoundChannel: FlutterMethodChannel?
    private var appStorageChannel: FlutterMethodChannel?
    private var quickActionIconsChannel: FlutterMethodChannel?
    private var uiSoundIDs: [String: SystemSoundID] = [:]
    private var deviceOrientationChannel: FlutterEventChannel?
    private var deviceOrientationStreamHandler: DeviceOrientationStreamHandler?
    private var lastAirPlayActive: Bool?

    override func applicationProtectedDataWillBecomeUnavailable(
        _ application: UIApplication
    ) {
        pictureInPictureBridge?.handleDeviceLocked()
        super.applicationProtectedDataWillBecomeUnavailable(application)
    }

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        UNUserNotificationCenter.current().delegate = self
        WorkmanagerPlugin.setPluginRegistrantCallback { registry in
            if let notificationsRegistrar = registry.registrar(
                forPlugin: "FlutterLocalNotificationsPlugin"
            ) {
                FlutterLocalNotificationsPlugin.register(
                    with: notificationsRegistrar
                )
            }
            if let pathProviderRegistrar = registry.registrar(
                forPlugin: "PathProviderPlugin"
            ) {
                PathProviderPlugin.register(with: pathProviderRegistrar)
            }
        }
        WorkmanagerPlugin.registerPeriodicTask(
            withIdentifier: "com.kinit.movieapp.newMovieRefresh",
            // Temporary debug interval. Restore to 20 * 60 after testing.
            frequency: NSNumber(value: 20 * 60)
        )

        guard let controller = window?.rootViewController as? FlutterViewController else {
            print("[Storyboard iOS] rootViewController is not FlutterViewController")
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }

        configureUISoundChannel(binaryMessenger: controller.binaryMessenger)
        configureAppStorageChannel(binaryMessenger: controller.binaryMessenger)
        configureQuickActionIconsChannel(binaryMessenger: controller.binaryMessenger)

        let deviceOrientationStreamHandler = DeviceOrientationStreamHandler()
        let deviceOrientationChannel = FlutterEventChannel(
            name: "com.kinit.movieapp/device_orientation",
            binaryMessenger: controller.binaryMessenger
        )
        deviceOrientationChannel.setStreamHandler(deviceOrientationStreamHandler)
        self.deviceOrientationStreamHandler = deviceOrientationStreamHandler
        self.deviceOrientationChannel = deviceOrientationChannel

        let appBadgeChannel = FlutterMethodChannel(
            name: "com.kinit.movieapp/app_badge",
            binaryMessenger: controller.binaryMessenger
        )
        self.appBadgeChannel = appBadgeChannel
        appBadgeChannel.setMethodCallHandler { call, result in
            guard call.method == "setBadgeCount" else {
                result(FlutterMethodNotImplemented)
                return
            }
            guard
                let arguments = call.arguments as? [String: Any],
                let count = arguments["count"] as? Int
            else {
                result(FlutterError(
                    code: "bad_args",
                    message: "Badge count is missing.",
                    details: nil
                ))
                return
            }

            let normalizedCount = max(0, count)
            if #available(iOS 16.0, *) {
                UNUserNotificationCenter.current().setBadgeCount(normalizedCount) { error in
                    DispatchQueue.main.async {
                        if let error {
                            result(FlutterError(
                                code: "badge_failed",
                                message: error.localizedDescription,
                                details: nil
                            ))
                        } else {
                            result(nil)
                        }
                    }
                }
            } else {
                UIApplication.shared.applicationIconBadgeNumber = normalizedCount
                result(nil)
            }
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

        pictureInPictureBridge = IosPictureInPictureBridge(
            binaryMessenger: controller.binaryMessenger,
            rootViewProvider: { [weak self] in
                self?.window?.rootViewController?.view
            }
        )

        let castingChannel = FlutterMethodChannel(
            name: "com.example.movie_app/casting",
            binaryMessenger: controller.binaryMessenger
        )
        self.castingChannel = castingChannel
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAirPlayRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: AVAudioSession.sharedInstance()
        )
        castingChannel.setMethodCallHandler { [weak self, weak controller] call, result in
            guard let self else {
                result(false)
                return
            }

            if call.method == "isAirPlayActive" {
                result(self.isAirPlayActive)
                return
            }

            guard call.method == "showAirPlayPicker" else {
                result(FlutterMethodNotImplemented)
                return
            }
            guard let controller else {
                result(false)
                return
            }

            let picker = AVRoutePickerView(frame: CGRect(x: -80, y: -80, width: 44, height: 44))
            picker.prioritizesVideoDevices = true
            controller.view.addSubview(picker)
            self.airPlayRoutePicker = picker

            guard let button = picker.subviews.compactMap({ $0 as? UIButton }).first else {
                picker.removeFromSuperview()
                self.airPlayRoutePicker = nil
                result(false)
                return
            }
            button.sendActions(for: .touchUpInside)
            result(true)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self, weak picker] in
                picker?.removeFromSuperview()
                self?.airPlayRoutePicker = nil
            }
        }
        publishAirPlayState(force: true)

        print("[Storyboard iOS] channel registered successfully")
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func configureQuickActionIconsChannel(binaryMessenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "com.kinit.movieapp/quick_actions_icons",
            binaryMessenger: binaryMessenger
        )
        quickActionIconsChannel = channel
        channel.setMethodCallHandler { call, result in
            guard call.method == "applySystemIcons" else {
                result(FlutterMethodNotImplemented)
                return
            }
            guard let symbols = call.arguments as? [String: String] else {
                result(FlutterError(
                    code: "quick_action_icons_bad_args",
                    message: "Expected shortcut types mapped to SF Symbol names.",
                    details: nil
                ))
                return
            }
            guard let items = UIApplication.shared.shortcutItems, !items.isEmpty else {
                result(FlutterError(
                    code: "quick_action_icons_not_registered",
                    message: "Register quick actions before applying system icons.",
                    details: nil
                ))
                return
            }

            UIApplication.shared.shortcutItems = items.map { item in
                guard let symbol = symbols[item.type] else { return item }
                return UIApplicationShortcutItem(
                    type: item.type,
                    localizedTitle: item.localizedTitle,
                    localizedSubtitle: item.localizedSubtitle,
                    icon: UIApplicationShortcutIcon(systemImageName: symbol),
                    userInfo: item.userInfo
                )
            }
            result(nil)
        }
    }

    private func configureUISoundChannel(binaryMessenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "com.kinit.movieapp/ui_sfx",
            binaryMessenger: binaryMessenger
        )
        uiSoundChannel = channel

        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else {
                result(FlutterError(
                    code: "ui_sfx_unavailable",
                    message: "UI sound service is unavailable.",
                    details: nil
                ))
                return
            }

            switch call.method {
            case "initialize":
                guard
                    let arguments = call.arguments as? [String: Any],
                    let sounds = arguments["sounds"] as? [String: Any]
                else {
                    result(FlutterError(
                        code: "ui_sfx_bad_args",
                        message: "Sound asset map is missing.",
                        details: nil
                    ))
                    return
                }

                self.initializeUISounds(sounds, result: result)

            case "play":
                guard
                    let arguments = call.arguments as? [String: Any],
                    let soundName = arguments["sound"] as? String,
                    let soundID = self.uiSoundIDs[soundName]
                else {
                    result(FlutterError(
                        code: "ui_sfx_not_loaded",
                        message: "Requested UI sound has not been loaded.",
                        details: nil
                    ))
                    return
                }

                AudioServicesPlaySystemSound(soundID)
                result(nil)

            case "dispose":
                self.disposeUISounds()
                result(nil)

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func configureAppStorageChannel(binaryMessenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "com.kinit.movieapp/app_storage",
            binaryMessenger: binaryMessenger
        )
        appStorageChannel = channel

        channel.setMethodCallHandler { call, result in
            guard call.method == "getAppDataSizeBytes" else {
                result(FlutterMethodNotImplemented)
                return
            }

            DispatchQueue.global(qos: .utility).async {
                let bytes = Self.appDataSizeBytes()
                DispatchQueue.main.async {
                    result(bytes)
                }
            }
        }
    }

    private static func appDataSizeBytes() -> Int64 {
        let homeURL = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
        let resourceKeys: Set<URLResourceKey> = [
            .isRegularFileKey,
            .totalFileAllocatedSizeKey,
            .fileAllocatedSizeKey,
            .fileSizeKey,
        ]
        guard let enumerator = FileManager.default.enumerator(
            at: homeURL,
            includingPropertiesForKeys: Array(resourceKeys),
            options: [],
            errorHandler: { _, _ in true }
        ) else {
            return 0
        }

        var total: Int64 = 0
        for case let fileURL as URL in enumerator {
            guard
                let values = try? fileURL.resourceValues(forKeys: resourceKeys),
                values.isRegularFile == true
            else {
                continue
            }

            let bytes = values.totalFileAllocatedSize
                ?? values.fileAllocatedSize
                ?? values.fileSize
                ?? 0
            total += Int64(max(0, bytes))
        }
        return total
    }

    private func initializeUISounds(
        _ sounds: [String: Any],
        result: @escaping FlutterResult
    ) {
        disposeUISounds()
        var loadedSoundIDs: [String: SystemSoundID] = [:]

        for (soundName, rawAssetPath) in sounds {
            guard let assetPath = rawAssetPath as? String else {
                disposeUISounds(loadedSoundIDs)
                result(FlutterError(
                    code: "ui_sfx_bad_asset",
                    message: "Invalid asset path for \(soundName).",
                    details: nil
                ))
                return
            }

            let assetKey = FlutterDartProject.lookupKey(forAsset: assetPath)
            guard let assetURL = Bundle.main.url(
                forResource: assetKey,
                withExtension: nil
            ) else {
                disposeUISounds(loadedSoundIDs)
                result(FlutterError(
                    code: "ui_sfx_asset_missing",
                    message: "UI sound asset was not found: \(assetPath)",
                    details: nil
                ))
                return
            }

            var soundID: SystemSoundID = 0
            let status = AudioServicesCreateSystemSoundID(
                assetURL as CFURL,
                &soundID
            )
            guard status == kAudioServicesNoError else {
                disposeUISounds(loadedSoundIDs)
                result(FlutterError(
                    code: "ui_sfx_load_failed",
                    message: "Failed to load UI sound: \(assetPath)",
                    details: status
                ))
                return
            }

            loadedSoundIDs[soundName] = soundID
        }

        uiSoundIDs = loadedSoundIDs
        result(nil)
    }

    private func disposeUISounds(_ soundIDs: [String: SystemSoundID]? = nil) {
        let soundIDsToDispose = soundIDs ?? uiSoundIDs
        soundIDsToDispose.values.forEach {
            AudioServicesDisposeSystemSoundID($0)
        }
        if soundIDs == nil {
            uiSoundIDs.removeAll()
        }
    }

    private var isAirPlayActive: Bool {
        AVAudioSession.sharedInstance().currentRoute.outputs.contains {
            $0.portType == .airPlay
        }
    }

    @objc private func handleAirPlayRouteChange(_ notification: Notification) {
        publishAirPlayState()
    }

    private func publishAirPlayState(force: Bool = false) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.publishAirPlayState(force: force)
            }
            return
        }

        let active = isAirPlayActive
        guard force || lastAirPlayActive != active else { return }
        lastAirPlayActive = active
        castingChannel?.invokeMethod(
            "airPlayStateChanged",
            arguments: [
                "state": active ? "connected" : "disconnected",
                "type": "airPlay",
            ]
        )
    }
}

private final class DeviceOrientationStreamHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var orientationObserver: NSObjectProtocol?

    func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        eventSink = events
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        orientationObserver = NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: UIDevice.current,
            queue: .main
        ) { [weak self] _ in
            self?.publishCurrentOrientation()
        }
        publishCurrentOrientation()
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if let orientationObserver {
            NotificationCenter.default.removeObserver(orientationObserver)
        }
        orientationObserver = nil
        eventSink = nil
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        return nil
    }

    private func publishCurrentOrientation() {
        let value: String?
        switch UIDevice.current.orientation {
        case .portrait:
            value = "portraitUp"
        case .landscapeLeft:
            value = "landscapeLeft"
        case .landscapeRight:
            value = "landscapeRight"
        default:
            value = nil
        }

        if let value {
            eventSink?(value)
        }
    }
}
