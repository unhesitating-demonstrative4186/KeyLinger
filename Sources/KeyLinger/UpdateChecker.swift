import Foundation

@MainActor
final class UpdateChecker: ObservableObject {
    enum Status: Equatable {
        case idle
        case checking
        case upToDate(version: String)
        case updateAvailable(version: String, url: URL)
        case noReleases
        case failed
    }

    @Published private(set) var status: Status = .idle

    private struct GitHubRelease: Decodable, Sendable {
        let tagName: String
        let htmlURL: URL

        enum CodingKeys: String, CodingKey {
            case tagName = "tag_name"
            case htmlURL = "html_url"
        }
    }

    private let latestReleaseURL = URL(
        string: "https://api.github.com/repos/myweihp/KeyLinger/releases/latest"
    )!

    func check(currentVersion: String) {
        guard status != .checking else { return }
        status = .checking

        Task {
            do {
                var request = URLRequest(url: latestReleaseURL)
                request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
                request.setValue("KeyLinger", forHTTPHeaderField: "User-Agent")

                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else {
                    status = .failed
                    return
                }

                if httpResponse.statusCode == 404 {
                    status = .noReleases
                    return
                }

                guard (200..<300).contains(httpResponse.statusCode) else {
                    status = .failed
                    return
                }

                let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
                let latestVersion = normalizedVersion(release.tagName)
                if isNewer(latestVersion, than: currentVersion) {
                    status = .updateAvailable(version: latestVersion, url: release.htmlURL)
                } else {
                    status = .upToDate(version: currentVersion)
                }
            } catch {
                status = .failed
            }
        }
    }

    private func normalizedVersion(_ version: String) -> String {
        version.trimmingCharacters(in: CharacterSet(charactersIn: "vV"))
    }

    private func isNewer(_ candidate: String, than current: String) -> Bool {
        let candidateParts = versionParts(candidate)
        let currentParts = versionParts(current)
        let count = max(candidateParts.count, currentParts.count)

        for index in 0..<count {
            let candidatePart = index < candidateParts.count ? candidateParts[index] : 0
            let currentPart = index < currentParts.count ? currentParts[index] : 0
            if candidatePart != currentPart {
                return candidatePart > currentPart
            }
        }
        return false
    }

    private func versionParts(_ version: String) -> [Int] {
        normalizedVersion(version)
            .split(separator: ".")
            .map { component in
                let digits = component.prefix(while: \.isNumber)
                return Int(digits) ?? 0
            }
    }
}
