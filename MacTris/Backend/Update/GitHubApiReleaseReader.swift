//
//  UpdateCheck.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 20.12.25.
//

import OSLog

struct GitHubApiReleaseReader {

    let baseUrl: URL

    public func readLatestRelease() async throws -> (MacTrisVersion, URL?) {
        let url: URL
        if #available(macOS 13.0, *) {
            url = baseUrl.appending(path: "releases/latest")
        } else {
            url = baseUrl.appendingPathComponent("releases/latest")
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let release = try JSONDecoder().decode(GithubRelease.self, from: data)
        let tag = String(release.tag_name.hasPrefix("Release/v") ? String(release.tag_name.dropFirst(9)) : "0.0.0")
        let parts = Array(tag.split(separator: ".").map { Int(String($0)) ?? 0 })
        #if DEBUG
        // fake an available update for development purposes
        if #available(macOS 13.0, *) {
            try await Task.sleep(for: .seconds(3))
        }
        return (MacTrisVersion(major: Bundle.main.version.major, minor: Bundle.main.version.minor + 1), URL(string: "http://example.com/MacTris-0.0.dmg"))
        #else
        return (MacTrisVersion(major: parts[0], minor: parts[1]), URL(string: release.assets.first?.browser_download_url ?? ""))
        #endif
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
}
