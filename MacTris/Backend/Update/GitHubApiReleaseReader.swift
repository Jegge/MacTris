//
//  GitHubApiReleaseReader.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 20.12.25.
//

import OSLog

protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

struct GitHubApiReleaseReader {

    let baseUrl: URL
    let session: URLSessionProtocol

    struct Release {
        let version: AppVersion
        let downloadUrl: URL
    }

    init(baseUrl: URL, session: URLSessionProtocol = URLSession.shared) {
        self.baseUrl = baseUrl
        self.session = session
    }

    func readLatestRelease() async throws -> Release? {
        let url: URL
        if #available(macOS 13.0, *) {
            url = baseUrl.appending(path: "releases/latest")
        } else {
            url = baseUrl.appendingPathComponent("releases/latest")
        }
        let (data, _) = try await self.session.data(from: url)
        let release = try JSONDecoder().decode(GithubRelease.self, from: data)
        let version = String(release.tag_name.hasPrefix("Release/v") ? String(release.tag_name.dropFirst(9)) : "0.0.0")
        if let downloadUrl = URL(string: release.assets.first?.browser_download_url ?? "") {
            return Release(version: AppVersion(string: version), downloadUrl: downloadUrl)
        }
        return nil
    }

    func parseRelease(from data: Data) throws -> (version: String, downloadUrl: String?) {
        let release = try JSONDecoder().decode(GithubRelease.self, from: data)
        let version = String(release.tag_name.hasPrefix("Release/v") ? String(release.tag_name.dropFirst(9)) : "0.0.0")
        return (version, release.assets.first?.browser_download_url)
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
