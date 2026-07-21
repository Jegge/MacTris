//
//  GitHubApiReleaseReaderTests.swift
//  MacTrisTests
//
//  Created by Sebastian Boettcher on 13.07.26.
//

import Testing
import Foundation
@testable import MacTris

struct GitHubApiReleaseReaderTests {
    private let testUrl = URL(string: "https://example.com")!

    @Test func testReadLatestValidRelease() async throws {
        let session = MockURLSession(string: """
            {
                "tag_name": "Release/v1.23",
                "assets": [
                    { "browser_download_url": "https://example.com/MacTris-1.23.dmg" }
                ]
            }
            """)
        let reader = GitHubApiReleaseReader(baseUrl: testUrl, session: session)
        let result = try await reader.readLatestRelease()
        #expect(result != nil)
        #expect(result?.version == AppVersion(string: "1.23"))
        #expect(result?.downloadUrl.absoluteString == "https://example.com/MacTris-1.23.dmg")
    }

    @Test func testReadLatestReleaseRequestsLatestEndpoint() async throws {
        let session = MockURLSession(string: """
        {
            "tag_name": "Release/v1.23",
            "assets": []
        }
        """)
        let baseUrl = URL(string: "https://example.com/repos/MacTris")!
        let reader = GitHubApiReleaseReader(baseUrl: baseUrl, session: session)

        _ = try await reader.readLatestRelease()

        #expect(session.requestedURLs == [URL(string: "https://example.com/repos/MacTris/releases/latest")!])
    }

    @Test func testReadLatestMissingPrefix() async throws {
        let session = MockURLSession(string: """
            {
                "tag_name": "v1.23",
                "assets": [
                    { "browser_download_url": "https://example.com/MacTris-1.23.dmg" }
                ]
            }
            """)
        let reader = GitHubApiReleaseReader(baseUrl: testUrl, session: session)
        let result = try await reader.readLatestRelease()
        #expect(result == nil)
    }

    @Test func testReadLatestReleaseMissingTagThrows() async throws {
        let session = MockURLSession(string: """
        {
            "assets": []
        }
        """)
        let reader = GitHubApiReleaseReader(baseUrl: testUrl, session: session)
        await #expect(throws: DecodingError.self) {
            try await reader.readLatestRelease()
        }
    }

    @Test func testReadLatestReleaseMissingAssetsThrows() async throws {
        let session = MockURLSession(string: """
        {
            "tag_name": "Release/v1.23"
        }
        """)
        let reader = GitHubApiReleaseReader(baseUrl: testUrl, session: session)
        await #expect(throws: DecodingError.self) {
            try await reader.readLatestRelease()
        }
    }

    @Test func testReadLatestMalformedJsonThrows() async throws {
        let session = MockURLSession(string: "not json")
        let reader = GitHubApiReleaseReader(baseUrl: testUrl, session: session)
        await #expect(throws: DecodingError.self) {
            try await reader.readLatestRelease()
        }
    }

    @Test func testReadLatestReleaseNetworkError() async throws {
        enum TestError: Error { case networkFailure }
        let session = MockURLSession(error: TestError.networkFailure)
        let reader = GitHubApiReleaseReader(baseUrl: testUrl, session: session)
        await #expect(throws: TestError.self) {
            try await reader.readLatestRelease()
        }
    }

    @Test func testReadLatestReleaseHttpError() async throws {
        let session = MockURLSession(statusCode: 404, string: "Not found")
        let reader = GitHubApiReleaseReader(baseUrl: testUrl, session: session)
        await #expect(throws: URLError.self) {
            try await reader.readLatestRelease()
        }
    }

    @Test func testReadLatestReleaseEmptyAssetsReturnsNil() async throws {
        let session = MockURLSession(string: """
        {
            "tag_name": "Release/v3.0",
            "assets": []
        }
        """)
        let reader = GitHubApiReleaseReader(baseUrl: testUrl, session: session)
        let release = try await reader.readLatestRelease()
        #expect(release == nil)
    }

    @Test func testReadLatestReleaseInvalidTagReturnsNil() async throws {
        let session = MockURLSession(string: """
        {
            "tag_name": "something-else",
            "assets": [
                { "browser_download_url": "https://example.com/MacTris-1.23.dmg" }
            ]
        }
        """)
        let reader = GitHubApiReleaseReader(baseUrl: testUrl, session: session)
        let release = try await reader.readLatestRelease()
        #expect(release == nil)
    }
}
