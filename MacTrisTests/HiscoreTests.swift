//
//  HiscoreTests.swift
//  MacTrisTests
//
//  Created by Sebastian Boettcher on 07.07.26.
//

import Testing
import Foundation
import CryptoKit
@testable import MacTris

struct HiscoreTests {
    private let key = "!deadbeefc0ffee@"

    @Test func testDefaultScores() async throws {
        let hiscore = Hiscore(key: key)
        #expect(hiscore.scores.count == 10)
    }

    @Test func testDefaultScoresSorted() async throws {
        let hiscore = Hiscore(key: key)
        for i in 0..<(hiscore.scores.count - 1) {
            #expect(hiscore.scores[i].value >= hiscore.scores[i + 1].value)
        }
    }

    @Test func testInsertTopScore() async throws {
        let hiscore = Hiscore(key: key)
        let index = hiscore.insert(score: Hiscore.Score(name: "Test", value: 999999))
        #expect(index == 0)
    }

    @Test func testInsertMidScore() async throws {
        let hiscore = Hiscore(key: key)
        let index = hiscore.insert(score: Hiscore.Score(name: "Mid", value: hiscore.scores[4].value + 1))
        #expect(index == 4)
    }

    @Test func testInsertLowScoreNotListed() async throws {
        let hiscore = Hiscore(key: key)
        let index = hiscore.insert(score: Hiscore.Score(name: "Low", value: 1))
        #expect(index == nil)
    }

    @Test func testIsHighscoreTrue() async throws {
        let hiscore = Hiscore(key: key)
        let isHigh = hiscore.isHighscore(score: Hiscore.Score(name: "New", value: 200000))
        #expect(isHigh)
    }

    @Test func testIsHighscoreFalse() async throws {
        let hiscore = Hiscore(key: key)
        let isHigh = hiscore.isHighscore(score: Hiscore.Score(name: "Low", value: 1))
        #expect(!isHigh)
    }

    @Test func testRename() async throws {
        let hiscore = Hiscore(key: key)
        hiscore.rename(at: 0, to: "Alice")
        #expect(hiscore.name(at: 0) == "Alice")
    }

    @Test func testRenamePreservesScore() async throws {
        let hiscore = Hiscore(key: key)
        let originalScore = hiscore.scores[0].value
        hiscore.rename(at: 0, to: "Bob")
        #expect(hiscore.scores[0].value == originalScore)
    }

    @Test func testRenameTruncates() async throws {
        let hiscore = Hiscore(key: key)
        let longName = String(repeating: "A", count: Hiscore.nameLength + 1)
        hiscore.rename(at: 0, to: longName)
        #expect(hiscore.name(at: 0).count == Hiscore.nameLength)
    }

    @Test func testWriteReadRoundTrip() async throws {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_hiscore.json")
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let original = Hiscore(key: key)
        let score = Hiscore.Score(name: "TestPlayer", value: 75000)
        _ = original.insert(score: score)
        try original.write(to: tempURL)

        let loaded = try Hiscore(contentsOfUrl: tempURL, key: key)
        #expect(loaded.scores.count == 10)
        #expect(loaded.scores.contains { $0.name == score.name && $0.value == score.value })
    }

    @Test func testWriteReadPreservesOrder() async throws {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_order.json")
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let original = Hiscore(key: key)
        try original.write(to: tempURL)

        let loaded = try Hiscore(contentsOfUrl: tempURL, key: key)
        for i in 0..<loaded.scores.count {
            #expect(loaded.scores[i].name == original.scores[i].name)
            #expect(loaded.scores[i].value == original.scores[i].value)
        }
    }

    @Test func testReadFailsWithWrongKey() async throws {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_badkey.json")
        defer { try? FileManager.default.removeItem(at: tempURL) }

        try? Hiscore(key: key).write(to: tempURL)

        #expect(throws: CryptoKitError.authenticationFailure) {
            _ = try Hiscore(contentsOfUrl: tempURL, key: key.uppercased())
        }
    }

    @Test func testInsertMaintainsLimit() async throws {
        let hiscore = Hiscore(key: key)
        for i in 0..<(Hiscore.numberOfEntries * 2) {
            _ = hiscore.insert(score: Hiscore.Score(name: "P\(i)", value: 100000 + i))
        }
        #expect(hiscore.scores.count == 10)
    }

    @Test func testNameAt() async throws {
        let hiscore = Hiscore(key: key)
        #expect(hiscore.name(at: 0) == hiscore.scores[0].name)
    }

    @Test func testNameAtIndexOutOfRangeReturnsEmptyString() async throws {
        let hiscore = Hiscore(key: key)
        #expect(hiscore.name(at: -1).isEmpty)
        #expect(hiscore.name(at: Hiscore.numberOfEntries * 2).isEmpty)
    }

    @Test func testScoreComparable() async throws {
        let low = Hiscore.Score(name: "A", value: 100)
        let high = Hiscore.Score(name: "B", value: 200)
        #expect(low < high)
        #expect(!(high < low))
        #expect(low == Hiscore.Score(name: "A", value: 100))
        #expect(low != Hiscore.Score(name: "C", value: 100))
    }
}
