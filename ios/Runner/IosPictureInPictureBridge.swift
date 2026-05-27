import AVFoundation
import AVKit
import Flutter
import UIKit

final class IosPictureInPictureBridge: NSObject, AVPictureInPictureControllerDelegate {
    private var pictureInPictureController: AVPictureInPictureController?
    private var attachedPlayerLayer: AVPlayerLayer?
    private let rootViewProvider: () -> UIView?

    init(binaryMessenger: FlutterBinaryMessenger, rootViewProvider: @escaping () -> UIView?) {
        self.rootViewProvider = rootViewProvider
        super.init()

        let channel = FlutterMethodChannel(
            name: "movie_player/pip",
            binaryMessenger: binaryMessenger
        )

        channel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call: call, result: result)
        }
    }

    private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            switch call.method {
            case "isAvailable":
                result(AVPictureInPictureController.isPictureInPictureSupported())
            case "attach":
                self.attachWithRetry(result: result)
            case "start":
                result(self.start())
            case "stop":
                self.stop()
                result(nil)
            case "detach":
                self.detach()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func attachWithRetry(result: @escaping FlutterResult) {
        if attachToCurrentPlayerLayer() {
            result(true)
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            result(self?.attachToCurrentPlayerLayer() ?? false)
        }
    }

    @discardableResult
    private func attachToCurrentPlayerLayer() -> Bool {
        guard AVPictureInPictureController.isPictureInPictureSupported(),
              let rootView = rootViewProvider(),
              let playerLayer = bestPlayerLayer(in: rootView.layer)
        else {
            return false
        }

        if attachedPlayerLayer === playerLayer, pictureInPictureController != nil {
            return true
        }

        detach()

        guard let controller = AVPictureInPictureController(playerLayer: playerLayer) else {
            return false
        }

        controller.delegate = self

        if #available(iOS 14.2, *) {
            controller.canStartPictureInPictureAutomaticallyFromInline = true
        }

        if #available(iOS 14.0, *) {
            controller.requiresLinearPlayback = false
        }
        attachedPlayerLayer = playerLayer
        pictureInPictureController = controller
        return controller.isPictureInPicturePossible
    }

    private func start() -> Bool {
        guard let controller = pictureInPictureController else {
            return attachToCurrentPlayerLayer() && start()
        }

        if controller.isPictureInPictureActive {
            return true
        }

        guard controller.isPictureInPicturePossible else {
            return false
        }

        controller.startPictureInPicture()
        return true
    }

    private func stop() {
        guard let controller = pictureInPictureController,
              controller.isPictureInPictureActive
        else {
            return
        }

        controller.stopPictureInPicture()
    }

    private func detach() {
        stop()
        pictureInPictureController?.delegate = nil
        pictureInPictureController = nil
        attachedPlayerLayer = nil
    }

    private func bestPlayerLayer(in rootLayer: CALayer) -> AVPlayerLayer? {
        var layers: [AVPlayerLayer] = []
        collectPlayerLayers(from: rootLayer, into: &layers)

        return layers
            .filter { $0.player?.currentItem != nil }
            .sorted { layerScore($0) > layerScore($1) }
            .first
    }

    private func collectPlayerLayers(from layer: CALayer, into layers: inout [AVPlayerLayer]) {
        if let playerLayer = layer as? AVPlayerLayer {
            layers.append(playerLayer)
        }

        layer.sublayers?.forEach { collectPlayerLayers(from: $0, into: &layers) }
    }

    private func layerScore(_ layer: AVPlayerLayer) -> CGFloat {
        let area = layer.bounds.width * layer.bounds.height
        let playingScore: CGFloat = (layer.player?.rate ?? 0) > 0 ? 10_000 : 0
        let readyScore: CGFloat = layer.isReadyForDisplay ? 1_000 : 0
        let visibleScore: CGFloat = layer.isHidden ? -500 : 0
        return playingScore + readyScore + visibleScore + area
    }
}
