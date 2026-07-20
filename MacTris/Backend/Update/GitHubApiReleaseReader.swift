//
//  GitHubApiReleaseReader.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 20.12.25.
//
import Foundation

/// Abstraction for URLSession to enable mocking in tests.
protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

/// Fetches the latest release metadata from a GitHub repository's releases API.
struct GitHubApiReleaseReader {

    /// The base URL of the GitHub repository API endpoint.
    let baseUrl: URL
    /// The URL session used for network requests.
    let session: URLSessionProtocol

    /// A parsed GitHub release with its version and download URL.
    struct Release {
        /// The release version.
        let version: AppVersion
        /// The URL to download the release asset.
        let downloadUrl: URL
    }

    /// Creates a reader with the given base URL and URL session.
    init(baseUrl: URL, session: URLSessionProtocol = URLSession.shared) {
        self.baseUrl = baseUrl
        self.session = session
    }

    /// Fetches the latest release from the GitHub API. Returns `nil` if no valid release is found.
    func readLatestRelease() async throws -> Release? {
        let url: URL
        if #available(macOS 13.0, *) {
            url = baseUrl.appending(path: "releases/latest")
        } else {
            url = baseUrl.appendingPathComponent("releases/latest")
        }
        let (data, _) = try await self.session.data(from: url)
        let release = try JSONDecoder().decode(GithubRelease.self, from: data)
        guard release.tagName.hasPrefix("Release/v"),
              let version = AppVersion(string: release.tagName.dropFirst(9)),
              let downloadUrl = URL(string: release.assets.first?.browserDownloadUrl ?? "")
        else {
            return nil
        }

        return Release(version: version, downloadUrl: downloadUrl)
    }

    private struct GithubAsset: Decodable {
        var browserDownloadUrl: String

        enum CodingKeys: String, CodingKey {
            case browserDownloadUrl = "browser_download_url"
        }
    }

    private struct GithubRelease: Decodable {
        var tagName: String
        var assets: [GithubAsset]

        enum CodingKeys: String, CodingKey {
            case tagName = "tag_name"
            case assets
        }
    }
}
