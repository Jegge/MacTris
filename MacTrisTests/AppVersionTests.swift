//
//  AppVersionTests.swift
//  MacTrisTests
//
//  Created by Sebastian Boettcher on 13.07.26.
//

import Testing
@testable import MacTris

struct AppVersionTests {

    @Test func testInitFromMajorMinor() async throws {
        let version = AppVersion(major: 1, minor: 10)
        #expect(version.major == 1)
        #expect(version.minor == 10)
    }

    @Test func testInitFromString() async throws {
        let version = AppVersion(string: "1.10")
        #expect(version?.major == 1)
        #expect(version?.minor == 10)
    }

    @Test func testInitFromStringSinglePart() async throws {
        let version = AppVersion(string: "3")
        #expect(version?.major == 3)
        #expect(version?.minor == 0)
    }

    @Test func testInitFromStringEmpty() async throws {
        let version = AppVersion(string: "")
        #expect(version == nil)
    }

    @Test func testInitFromStringInvalid() async throws {
        let version = AppVersion(string: "abc")
        #expect(version == nil)
    }

    @Test func testInitFromStringThreeParts() async throws {
        let version = AppVersion(string: "2.5.3")
        #expect(version?.major == 2)
        #expect(version?.minor == 5)
    }

    @Test func testEqualVersions() async throws {
        let lhs = AppVersion(major: 1, minor: 0)
        let rhs = AppVersion(major: 1, minor: 0)
        #expect(lhs == rhs)
    }

    @Test func testMajorLessThan() async throws {
        let lhs = AppVersion(major: 1, minor: 0)
        let rhs = AppVersion(major: 2, minor: 0)
        #expect(lhs < rhs)
    }

    @Test func testMinorLessThan() async throws {
        let lhs = AppVersion(major: 1, minor: 9)
        let rhs = AppVersion(major: 1, minor: 10)
        #expect(lhs < rhs)
    }

    @Test func testGreaterDoesNotImplyLess() async throws {
        let lhs = AppVersion(major: 2, minor: 0)
        let rhs = AppVersion(major: 1, minor: 0)
        #expect(!(lhs < rhs))
    }

    @Test func testEqualDoesNotImplyLess() async throws {
        let lhs = AppVersion(major: 1, minor: 0)
        let rhs = AppVersion(major: 1, minor: 0)
        #expect(!(lhs < rhs))
    }

    @Test func testMajorGreaterIgnoresMinor() async throws {
        let lhs = AppVersion(major: 2, minor: 0)
        let rhs = AppVersion(major: 1, minor: 99)
        #expect(lhs > rhs)
    }

    @Test func testDescription() async throws {
        let version = AppVersion(major: 2, minor: 3)
        #expect(version.description == "v2.3")
    }
}
