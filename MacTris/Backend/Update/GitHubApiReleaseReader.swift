//
//  GitHubApiReleaseReader.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 20.12.25.
//
import Foundation

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
        guard release.tag_name.hasPrefix("Release/v"),
              let version = AppVersion(string: release.tag_name.dropFirst(9)),
              let downloadUrl = URL(string: release.assets.first?.browser_download_url ?? "")
        else {
            return nil
        }

        return Release(version: version, downloadUrl: downloadUrl)
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
