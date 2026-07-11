//
//  UpdateCheck.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 20.12.25.
//

import OSLog

struct UpdateCheck {

    static let url = URL(string: "https://api.github.com/repos/Jegge/MacTris/releases/latest")!

    static var version: Version {
        let bundleVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "0.0"
        let parts = bundleVersion.split(separator: ".").map { Int(String($0)) ?? 0 }
        return Version(major: parts[0], minor: parts[1])
    }

    static var build: Int {
        return Int((Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "0") ?? 0
    }

    private static func getOnlineVersion() async throws -> (Version, URL?) {
        let (data, _) = try await URLSession.shared.data(from: url)
        let release = try JSONDecoder().decode(GithubRelease.self, from: data)
        let tag = String(release.tag_name.hasPrefix("Release/v") ? String(release.tag_name.dropFirst(9)) : "0.0.0")
        let parts = Array(tag.split(separator: ".").map { Int(String($0)) ?? 0 })
        #if DEBUG
        if #available(macOS 13.0, *) {
            try await Task.sleep(for: .seconds(3))
        }
        return (Version(major: version.major, minor: version.minor + 1), URL(string: "http://example.com/MacTris-0.0.dmg"))
        #else
        return (Version(major: parts[0], minor: parts[1]), URL(string: release.assets.first?.browser_download_url ?? ""))
        #endif
    }

    static func getUpdateUrl() async throws -> URL? {

        let (onlineVersion, onlineUrl) = try await getOnlineVersion()
        if onlineVersion > version, let url = onlineUrl {
            Logger.update.info("Update \(onlineVersion, privacy: .public) available at \(url.absoluteString, privacy: .public)")
            return url
        }

        Logger.update.info("Current version \(version, privacy: .public) is up to date.")
        return nil
    }

    // swiftlint:disable identifier_name
    private struct GithubAsset: Decodable {
        var browser_download_url: String
    }

    private struct GithubRelease: Decodable {
        var tag_name: String
        var assets: [GithubAsset]
    }
    // swiftlint:enable identifier_name

    struct Version: Equatable, Comparable, CustomStringConvertible {
        let major: Int
        let minor: Int

        static func < (lhs: UpdateCheck.Version, rhs: UpdateCheck.Version) -> Bool {
            if lhs.major < rhs.major {
                return true
            } else if lhs.major == rhs.major && lhs.minor < rhs.minor {
                return true
            }
            return false
        }

        var description: String {
            return "v\(major).\(minor)"
        }
    }
}
