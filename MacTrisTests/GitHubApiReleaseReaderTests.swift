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

    private func createSession(tag: String, url: String) -> MockURLSession {
        MockURLSession(string: """
        {
            "tag_name": "\(tag)",
            "assets": [
                { "browser_download_url": "\(url)" }
            ]
        }
        """)
    }

    @Test func testParseValidRelease() async throws {
        let reader = GitHubApiReleaseReader(baseUrl: testUrl, session: createSession(tag: "Release/v1.10", url: "https://example.com/MacTris-1.10.dmg"))
        let result = try await reader.readLatestRelease()
        #expect(result?.version == AppVersion(string: "1.10"))
        #expect(result?.downloadUrl.absoluteString == "https://example.com/MacTris-1.10.dmg")
    }

    @Test func testParseReleaseInvalidTag() async throws {
        let reader = GitHubApiReleaseReader(baseUrl: testUrl, session: createSession(tag: "invalid", url: "https://example.com/dmg"))
        let result = try await reader.readLatestRelease()
        #expect(result?.version == AppVersion(string: "0.0.0"))
    }

    @Test func testParseReleaseTagMissingPrefix() async throws {
        let reader = GitHubApiReleaseReader(baseUrl: testUrl, session: createSession(tag: "v1.5", url: "https://example.com/dmg"))
        let result = try await reader.readLatestRelease()
        #expect(result?.version == AppVersion(string: "0.0.0"))
    }

    @Test func testParseReleaseEmptyAssets() async throws {
        let mockSession = MockURLSession(string: """
        {
            "tag_name": "Release/v2.0",
            "assets": []
        }
        """)
        let reader = GitHubApiReleaseReader(baseUrl: testUrl, session: mockSession)
        let result = try await reader.readLatestRelease()
        #expect(result == nil)
    }

    @Test func testParseReleaseMalformedJson() async throws {
        let reader = GitHubApiReleaseReader(baseUrl: testUrl, session: MockURLSession(string: "not json"))
        await #expect(throws: DecodingError.self) {
            try await reader.readLatestRelease()
        }
    }

    @Test func testParseReleaseMissingTag() async throws {
        let reader = GitHubApiReleaseReader(baseUrl: testUrl, session: MockURLSession(string: """
        {
            "assets": []
        }
        """))
        await #expect(throws: DecodingError.self) {
            try await reader.readLatestRelease()
        }
    }

    @Test func testReadLatestReleaseMalformedJsonThrows() async throws {
        let reader = GitHubApiReleaseReader(baseUrl: testUrl, session: MockURLSession(string: "not json"))
        await #expect(throws: DecodingError.self) {
            try await reader.readLatestRelease()
        }
    }

    @Test func testReadLatestReleaseSuccess() async throws {
        let reader = GitHubApiReleaseReader(baseUrl: testUrl, session: createSession(tag: "Release/v2.5", url: "https://example.com/MacTris-2.5.dmg"))
        let release = try await reader.readLatestRelease()
        #expect(release?.version == AppVersion(string: "2.5"))
        #expect(release?.downloadUrl.absoluteString == "https://example.com/MacTris-2.5.dmg")
    }

    @Test func testReadLatestReleaseNetworkError() async throws {
        enum TestError: Error { case networkFailure }
        let reader = GitHubApiReleaseReader(baseUrl: testUrl, session: MockURLSession(error: TestError.networkFailure))
        await #expect(throws: TestError.self) {
            try await reader.readLatestRelease()
        }
    }

    @Test func testReadLatestReleaseEmptyAssetsReturnsNil() async throws {
        let mockSession = MockURLSession(string: """
        {
            "tag_name": "Release/v3.0",
            "assets": []
        }
        """)
        let reader = GitHubApiReleaseReader(baseUrl: testUrl, session: mockSession)
        let release = try await reader.readLatestRelease()
        #expect(release == nil)
    }

    @Test func testReadLatestReleaseInvalidTagReturnsZeroVersion() async throws {
        let reader = GitHubApiReleaseReader(baseUrl: testUrl, session: createSession(tag: "something-else", url: "https://example.com/dmg"))
        let release = try await reader.readLatestRelease()
        #expect(release?.version == AppVersion(string: "0.0.0"))
    }
}
