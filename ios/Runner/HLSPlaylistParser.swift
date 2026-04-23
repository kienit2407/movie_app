import Foundation

struct HLSSegment {
    let url: URL
    let duration: Double
    let startTime: Double
    let mapURL: URL?
}

struct HLSMediaPlaylist {
    let playlistURL: URL
    let segments: [HLSSegment]
    let isEncrypted: Bool
}

final class HLSPlaylistParser {
    func loadMediaPlaylist(
        from urlString: String,
        completion: @escaping (Result<HLSMediaPlaylist, Error>) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(
                domain: "HLSPlaylistParser",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid playlist URL"]
            )))
            return
        }

        loadPlaylist(from: url, completion: completion)
    }

    private func loadPlaylist(
        from url: URL,
        completion: @escaping (Result<HLSMediaPlaylist, Error>) -> Void
    ) {
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

            guard let data,
                  let text = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii)
            else {
                completion(.failure(NSError(
                    domain: "HLSPlaylistParser",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "Playlist is not valid text"]
                )))
                return
            }

            if self.isMasterPlaylist(text) {
                guard let variantURL = self.selectVariantURL(from: text, playlistURL: url) else {
                    completion(.failure(NSError(
                        domain: "HLSPlaylistParser",
                        code: -3,
                        userInfo: [NSLocalizedDescriptionKey: "No variant found in master playlist"]
                    )))
                    return
                }

                self.loadPlaylist(from: variantURL, completion: completion)
                return
            }

            let media = self.parseMediaPlaylist(text: text, playlistURL: url)
            completion(.success(media))
        }.resume()
    }

    private func isMasterPlaylist(_ text: String) -> Bool {
        text.contains("#EXT-X-STREAM-INF")
    }

    private func selectVariantURL(from text: String, playlistURL: URL) -> URL? {
        let lines = normalizedLines(text)
        var bestURL: URL?
        var bestBandwidth: Int = -1

        for i in 0..<lines.count {
            let line = lines[i]
            guard line.hasPrefix("#EXT-X-STREAM-INF:") else { continue }

            let bandwidth = parseBandwidth(from: line) ?? 0

            var j = i + 1
            while j < lines.count {
                let next = lines[j]
                if next.isEmpty {
                    j += 1
                    continue
                }
                if next.hasPrefix("#") {
                    break
                }

                if let resolved = resolveURL(next, relativeTo: playlistURL), bandwidth >= bestBandwidth {
                    bestBandwidth = bandwidth
                    bestURL = resolved
                }
                break
            }
        }

        return bestURL
    }

    private func parseBandwidth(from line: String) -> Int? {
        let prefix = "BANDWIDTH="
        guard let range = line.range(of: prefix) else { return nil }

        let tail = line[range.upperBound...]
        let value = tail.split(separator: ",").first.map(String.init) ?? ""
        return Int(value)
    }

    private func parseMediaPlaylist(text: String, playlistURL: URL) -> HLSMediaPlaylist {
        let lines = normalizedLines(text)

        var segments: [HLSSegment] = []
        var accumulatedTime: Double = 0
        var pendingDuration: Double?
        var currentMapURL: URL?
        var isEncrypted = false

        for rawLine in lines {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            if line.isEmpty { continue }

            if line.hasPrefix("#EXT-X-KEY:") {
                if !line.contains("METHOD=NONE") {
                    isEncrypted = true
                }
                continue
            }

            if line.hasPrefix("#EXT-X-MAP:") {
                if let mapURI = parseQuotedAttribute(named: "URI", from: line),
                   let resolved = resolveURL(mapURI, relativeTo: playlistURL) {
                    currentMapURL = resolved
                }
                continue
            }

            if line.hasPrefix("#EXTINF:") {
                let value = line
                    .replacingOccurrences(of: "#EXTINF:", with: "")
                    .split(separator: ",")
                    .first
                    .map(String.init) ?? "0"
                pendingDuration = Double(value) ?? 0
                continue
            }

            if line.hasPrefix("#") {
                continue
            }

            if let duration = pendingDuration,
               let resolved = resolveURL(line, relativeTo: playlistURL) {
                segments.append(
                    HLSSegment(
                        url: resolved,
                        duration: duration,
                        startTime: accumulatedTime,
                        mapURL: currentMapURL
                    )
                )
                accumulatedTime += duration
                pendingDuration = nil
            }
        }

        return HLSMediaPlaylist(
            playlistURL: playlistURL,
            segments: segments,
            isEncrypted: isEncrypted
        )
    }

    private func parseQuotedAttribute(named name: String, from line: String) -> String? {
        let pattern = "\(name)=\""
        guard let startRange = line.range(of: pattern) else { return nil }

        let tail = line[startRange.upperBound...]
        guard let endQuote = tail.firstIndex(of: "\"") else { return nil }

        return String(tail[..<endQuote])
    }

    private func resolveURL(_ uri: String, relativeTo baseURL: URL) -> URL? {
        URL(string: uri, relativeTo: baseURL)?.absoluteURL
    }

    private func normalizedLines(_ text: String) -> [String] {
        text.replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .components(separatedBy: "\n")
    }
}
