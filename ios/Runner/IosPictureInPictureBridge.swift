import AVFoundation
import AVKit
import Flutter
import MediaPlayer
import UIKit

final class IosPictureInPictureBridge: NSObject, AVPictureInPictureControllerDelegate {
    private var pictureInPictureController: AVPictureInPictureController?
    private var attachedPlayerLayer: AVPlayerLayer?
    private weak var preparedTexturePlayerLayer: AVPlayerLayer?
    private var preparedTexturePlayerLayerFrame: CGRect?
    private var preparedTexturePlayerLayerOpacity: Float?
    private let rootViewProvider: () -> UIView?
    private var remoteCommandsConfigured = false
    private let readinessRetryDelay: TimeInterval = 0.1
    private let readinessRetryCount = 10

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
                self.startWithRetry(result: result)
            case "stop":
                self.stop()
                result(nil)
            case "configureMediaSession":
                self.configureMediaSession()
                result(nil)
            case "updateNowPlaying":
                self.updateNowPlaying(arguments: call.arguments)
                result(nil)
            case "clearNowPlaying":
                self.clearNowPlaying()
                result(nil)
            case "detach":
                self.detach()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func configureMediaSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .moviePlayback, options: [])
            try session.setActive(true)
            UIApplication.shared.beginReceivingRemoteControlEvents()
            configureRemoteCommandsIfNeeded()
        } catch {
            print("[PiP] Failed to configure media session: \(error.localizedDescription)")
        }
    }

    private func configureRemoteCommandsIfNeeded() {
        guard !remoteCommandsConfigured else { return }
        remoteCommandsConfigured = true

        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.isEnabled = true

        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let player = self?.currentPlayer() else { return .commandFailed }
            player.play()
            self?.refreshNowPlayingRate(isPlaying: true)
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let player = self?.currentPlayer() else { return .commandFailed }
            player.pause()
            self?.refreshNowPlayingRate(isPlaying: false)
            return .success
        }

        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            guard let player = self?.currentPlayer() else { return .commandFailed }
            if player.rate == 0 {
                player.play()
                self?.refreshNowPlayingRate(isPlaying: true)
            } else {
                player.pause()
                self?.refreshNowPlayingRate(isPlaying: false)
            }
            return .success
        }

        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard
                let player = self?.currentPlayer(),
                let seekEvent = event as? MPChangePlaybackPositionCommandEvent
            else {
                return .commandFailed
            }

            let target = CMTime(seconds: seekEvent.positionTime, preferredTimescale: 600)
            player.seek(to: target)
            self?.refreshNowPlayingPosition(seekEvent.positionTime)
            return .success
        }
    }

    private func currentPlayer() -> AVPlayer? {
        if let player = attachedPlayerLayer?.player {
            return player
        }

        guard let rootView = rootViewProvider(),
              let playerLayer = bestPlayerLayer(in: rootView.layer)
        else {
            return nil
        }

        attachedPlayerLayer = playerLayer
        return playerLayer.player
    }

    private func updateNowPlaying(arguments: Any?) {
        configureMediaSession()

        guard let args = arguments as? [String: Any] else { return }

        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        let title = args["title"] as? String ?? ""
        let subtitle = args["subtitle"] as? String ?? ""
        let duration = args["duration"] as? Double ?? 0
        let position = args["position"] as? Double ?? 0
        let isPlaying = args["isPlaying"] as? Bool ?? false

        info[MPMediaItemPropertyTitle] = title
        info[MPMediaItemPropertyArtist] = subtitle
        info[MPMediaItemPropertyPlaybackDuration] = max(duration, 0)
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = max(position, 0)
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        info[MPNowPlayingInfoPropertyDefaultPlaybackRate] = 1.0

        if #available(iOS 10.0, *) {
            info[MPNowPlayingInfoPropertyMediaType] = MPNowPlayingInfoMediaType.video.rawValue
        }

        if let assetUrl = args["assetUrl"] as? String,
           let url = URL(string: assetUrl) {
            info[MPNowPlayingInfoPropertyAssetURL] = url
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func refreshNowPlayingRate(isPlaying: Bool) {
        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func refreshNowPlayingPosition(_ position: TimeInterval) {
        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = max(position, 0)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func clearNowPlaying() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        UIApplication.shared.endReceivingRemoteControlEvents()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func attachWithRetry(result: @escaping FlutterResult) {
        attachWithRetry(remainingAttempts: readinessRetryCount, result: result)
    }

    private func attachWithRetry(
        remainingAttempts: Int,
        result: @escaping FlutterResult
    ) {
        if attachToCurrentPlayerLayer() {
            result(true)
            return
        }

        guard remainingAttempts > 1 else {
            print("[PiP] AVPlayerLayer was found but PiP did not become possible in time.")
            result(false)
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + readinessRetryDelay) { [weak self] in
            guard let self else {
                result(false)
                return
            }
            self.attachWithRetry(
                remainingAttempts: remainingAttempts - 1,
                result: result
            )
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

        if attachedPlayerLayer === playerLayer,
           let controller = pictureInPictureController {
            return controller.isPictureInPicturePossible
        }

        detach()
        prepareTexturePlayerLayerIfNeeded(playerLayer, in: rootView)

        guard let controller = AVPictureInPictureController(playerLayer: playerLayer) else {
            restorePreparedTexturePlayerLayer()
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

    private func startWithRetry(result: @escaping FlutterResult) {
        startWithRetry(remainingAttempts: readinessRetryCount, result: result)
    }

    private func startWithRetry(
        remainingAttempts: Int,
        result: @escaping FlutterResult
    ) {
        if start() {
            result(true)
            return
        }

        guard remainingAttempts > 1 else {
            print("[PiP] startPictureInPicture was rejected because PiP is not possible.")
            result(false)
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + readinessRetryDelay) { [weak self] in
            guard let self else {
                result(false)
                return
            }
            self.startWithRetry(
                remainingAttempts: remainingAttempts - 1,
                result: result
            )
        }
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
        restorePreparedTexturePlayerLayer()
    }

    private func prepareTexturePlayerLayerIfNeeded(
        _ playerLayer: AVPlayerLayer,
        in rootView: UIView
    ) {
        guard playerLayer.bounds.width < 1 || playerLayer.bounds.height < 1 else {
            return
        }

        preparedTexturePlayerLayer = playerLayer
        preparedTexturePlayerLayerFrame = playerLayer.frame
        preparedTexturePlayerLayerOpacity = playerLayer.opacity

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        // video_player_avfoundation keeps a zero-sized helper AVPlayerLayer
        // for texture playback. PiP needs a layer with a valid presentation
        // rect, so keep it attached and practically invisible without changing
        // the Flutter texture that the user sees.
        playerLayer.frame = rootView.bounds
        playerLayer.opacity = 0.001
        CATransaction.commit()
    }

    private func restorePreparedTexturePlayerLayer() {
        guard let playerLayer = preparedTexturePlayerLayer else {
            preparedTexturePlayerLayerFrame = nil
            preparedTexturePlayerLayerOpacity = nil
            return
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if let frame = preparedTexturePlayerLayerFrame {
            playerLayer.frame = frame
        }
        if let opacity = preparedTexturePlayerLayerOpacity {
            playerLayer.opacity = opacity
        }
        CATransaction.commit()

        preparedTexturePlayerLayer = nil
        preparedTexturePlayerLayerFrame = nil
        preparedTexturePlayerLayerOpacity = nil
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

    func pictureInPictureControllerDidStartPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
        print("[PiP] Picture in Picture started.")
    }

    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        failedToStartPictureInPictureWithError error: Error
    ) {
        print("[PiP] Failed to start Picture in Picture: \(error.localizedDescription)")
    }

    func pictureInPictureControllerDidStopPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
        print("[PiP] Picture in Picture stopped.")
    }
}
