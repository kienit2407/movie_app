import Foundation
import AVFoundation
import UIKit

final class StoryboardGenerator {
    private let queue = DispatchQueue(label: "movie_player.storyboard.queue", qos: .userInitiated)
    private let parser = HLSPlaylistParser()

    func thumbnailAt(
        urlString: String,
        timeMs: Int,
        maxWidth: Int,
        maxHeight: Int,
        completion: @escaping (Result<String?, Error>) -> Void
    ) {
        print("[Storyboard iOS] request url=\(urlString)")
        print("[Storyboard iOS] timeMs=\(timeMs)")

        parser.loadMediaPlaylist(from: urlString) { [weak self] result in
            switch result {
            case .failure(let error):
                print("[Storyboard iOS] parser failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }

            case .success(let playlist):
                guard let self else { return }

                if playlist.isEncrypted {
                    let err = NSError(
                        domain: "StoryboardGenerator",
                        code: -100,
                        userInfo: [NSLocalizedDescriptionKey: "Encrypted HLS is not supported by this thumbnail path"]
                    )
                    DispatchQueue.main.async {
                        completion(.failure(err))
                    }
                    return
                }

                guard !playlist.segments.isEmpty else {
                    let err = NSError(
                        domain: "StoryboardGenerator",
                        code: -101,
                        userInfo: [NSLocalizedDescriptionKey: "No segments found in media playlist"]
                    )
                    DispatchQueue.main.async {
                        completion(.failure(err))
                    }
                    return
                }

                let selection = self.pickSegment(for: Double(timeMs) / 1000.0, playlist: playlist)

                self.prepareLocalAsset(for: selection.segment, playlistHash: urlString.hashValue.magnitude) { prepResult in
                    switch prepResult {
                    case .failure(let error):
                        print("[Storyboard iOS] prepareLocalAsset failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }

                    case .success(let localURL):
                        self.generateThumbnail(
                            from: localURL,
                            outputGroupHash: urlString.hashValue.magnitude,
                            timeMs: timeMs,
                            offsetSeconds: selection.offsetSeconds,
                            maxWidth: maxWidth,
                            maxHeight: maxHeight,
                            completion: completion
                        )
                    }
                }
            }
        }
    }

    private func pickSegment(for requestedSeconds: Double, playlist: HLSMediaPlaylist) -> (segment: HLSSegment, offsetSeconds: Double) {
        for segment in playlist.segments {
            let end = segment.startTime + segment.duration
            if requestedSeconds >= segment.startTime && requestedSeconds < end {
                let offset = max(0, requestedSeconds - segment.startTime)
                return (segment, offset)
            }
        }

        let last = playlist.segments.last!
        let safeOffset = max(0, last.duration - 0.2)
        return (last, safeOffset)
    }

    private func prepareLocalAsset(
        for segment: HLSSegment,
        playlistHash: UInt,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let folder = cachesDir
            .appendingPathComponent("storyboard_segments", isDirectory: true)
            .appendingPathComponent(String(playlistHash), isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        } catch {
            completion(.failure(error))
            return
        }

        let segmentExt = segment.url.pathExtension.isEmpty ? "bin" : segment.url.pathExtension

        // fMP4/CMAF đơn giản: gộp init + segment thành một file local
        if let mapURL = segment.mapURL {
            let mergedURL = folder.appendingPathComponent("merged_\(abs(segment.url.absoluteString.hashValue)).mp4")

            if FileManager.default.fileExists(atPath: mergedURL.path) {
                completion(.success(mergedURL))
                return
            }

            downloadData(from: mapURL) { mapResult in
                switch mapResult {
                case .failure(let error):
                    completion(.failure(error))

                case .success(let mapData):
                    self.downloadData(from: segment.url) { segResult in
                        switch segResult {
                        case .failure(let error):
                            completion(.failure(error))

                        case .success(let segData):
                            var merged = Data()
                            merged.append(mapData)
                            merged.append(segData)

                            do {
                                try merged.write(to: mergedURL, options: .atomic)
                                completion(.success(mergedURL))
                            } catch {
                                completion(.failure(error))
                            }
                        }
                    }
                }
            }

            return
        }

        // TS / segment đơn
        let localURL = folder.appendingPathComponent("segment_\(abs(segment.url.absoluteString.hashValue)).\(segmentExt)")

        if FileManager.default.fileExists(atPath: localURL.path) {
            completion(.success(localURL))
            return
        }

        downloadData(from: segment.url) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))

            case .success(let data):
                do {
                    try data.write(to: localURL, options: .atomic)
                    completion(.success(localURL))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }

    private func downloadData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(
            url: url,
            cachePolicy: .returnCacheDataElseLoad,
            timeoutInterval: 20
        )

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let data else {
                completion(.failure(NSError(
                    domain: "StoryboardGenerator",
                    code: -200,
                    userInfo: [NSLocalizedDescriptionKey: "Downloaded data is nil"]
                )))
                return
            }

            completion(.success(data))
        }.resume()
    }

    private func generateThumbnail(
        from localURL: URL,
        outputGroupHash: UInt,
        timeMs: Int,
        offsetSeconds: Double,
        maxWidth: Int,
        maxHeight: Int,
        completion: @escaping (Result<String?, Error>) -> Void
    ) {
        let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let outFolder = cachesDir
            .appendingPathComponent("storyboards", isDirectory: true)
            .appendingPathComponent(String(outputGroupHash), isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: outFolder, withIntermediateDirectories: true)
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }

        let outputURL = outFolder.appendingPathComponent("thumb_\(timeMs)_\(maxWidth)x\(maxHeight).jpg")

        if FileManager.default.fileExists(atPath: outputURL.path) {
            DispatchQueue.main.async {
                completion(.success(outputURL.path))
            }
            return
        }

        queue.async {
            let asset = AVURLAsset(url: localURL)
            let keys = ["playable", "tracks", "duration"]

            asset.loadValuesAsynchronously(forKeys: keys) {
                for key in keys {
                    var nsError: NSError?
                    let status = asset.statusOfValue(forKey: key, error: &nsError)
                    if status == .failed || status == .cancelled {
                        DispatchQueue.main.async {
                            completion(.failure(nsError ?? NSError(
                                domain: "StoryboardGenerator",
                                code: -300,
                                userInfo: [NSLocalizedDescriptionKey: "Failed loading local asset key: \(key)"]
                            )))
                        }
                        return
                    }
                }

                let durationSeconds = CMTimeGetSeconds(asset.duration)
                let safeDuration = durationSeconds.isFinite && durationSeconds > 0 ? durationSeconds : 0
                let safeOffset = min(max(0, offsetSeconds), max(0, safeDuration - 0.05))

                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true
                generator.maximumSize = CGSize(width: maxWidth, height: maxHeight)

                // cho phép lấy frame gần keyframe gần nhất
                generator.requestedTimeToleranceBefore = CMTime(seconds: 1, preferredTimescale: 600)
                generator.requestedTimeToleranceAfter = CMTime(seconds: 1, preferredTimescale: 600)

                let requestedTime = CMTime(seconds: safeOffset, preferredTimescale: 600)

                do {
                    var actualTime = CMTime.zero
                    let cgImage = try generator.copyCGImage(at: requestedTime, actualTime: &actualTime)
                    let image = UIImage(cgImage: cgImage)

                    guard let data = image.jpegData(compressionQuality: 0.72) else {
                        throw NSError(
                            domain: "StoryboardGenerator",
                            code: -301,
                            userInfo: [NSLocalizedDescriptionKey: "Failed to encode JPEG"]
                        )
                    }

                    try data.write(to: outputURL, options: .atomic)
                    print("[Storyboard iOS] success path=\(outputURL.path)")
                    print("[Storyboard iOS] local asset=\(localURL.lastPathComponent)")
                    print("[Storyboard iOS] actualTime=\(CMTimeGetSeconds(actualTime))")

                    DispatchQueue.main.async {
                        completion(.success(outputURL.path))
                    }
                } catch {
                    let nsError = error as NSError
                    print("[Storyboard iOS] copyCGImage error domain=\(nsError.domain) code=\(nsError.code)")
                    print("[Storyboard iOS] userInfo=\(nsError.userInfo)")

                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}
