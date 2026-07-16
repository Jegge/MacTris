//
//  StatisticsTests.swift
//  MacTrisTests
//
//  Created by Sebastian Boettcher on 13.07.26.
//

import Testing
@testable import MacTris

struct StatisticsTests {
    @Test func testInitialIsEmpty() async throws {
        let stats = Statistics()
        #expect(stats.total == 0)

        for shape in Tetromino.Shape.allCases {
            #expect(stats.count(shape) == 0)
            #expect(stats.percent(shape) == 0)
        }
    }

    @Test func testAddSingleShape() async throws {
        var stats = Statistics()
        stats.add(.t)
        for shape in Tetromino.Shape.allCases where shape != .t {
            #expect(stats.count(shape) == 0)
            #expect(stats.percent(shape) == 0)
        }
        #expect(stats.count(.t) == 1)
        #expect(stats.percent(.t) == 100.0)
        #expect(stats.total == 1)
    }

    @Test func testAddMultipleOfSameShape() async throws {
        var stats = Statistics()
        stats.add(.i)
        stats.add(.i)
        stats.add(.i)
        stats.add(.i)
        #expect(stats.count(.i) == 4)
        #expect(stats.percent(.i) == 100.0)
        #expect(stats.total == 4)
    }

    @Test func testAddDifferentShapes() async throws {
        var stats = Statistics()
        stats.add(.t)
        stats.add(.i)
        stats.add(.o)
        stats.add(.z)
        #expect(stats.count(.t) == 1)
        #expect(stats.count(.i) == 1)
        #expect(stats.count(.o) == 1)
        #expect(stats.count(.z) == 1)
        #expect(stats.percent(.t) == 25.0)
        #expect(stats.percent(.i) == 25.0)
        #expect(stats.percent(.o) == 25.0)
        #expect(stats.percent(.z) == 25.0)
        #expect(stats.total == 4)
    }

    @Test func testPercentUnevenDistribution() async throws {
        var stats = Statistics()
        stats.add(.t)
        stats.add(.t)
        stats.add(.t)
        stats.add(.i)
        #expect(stats.count(.t) == 3)
        #expect(stats.count(.i) == 1)
        #expect(stats.percent(.t) == 75.0)
        #expect(stats.percent(.i) == 25.0)
        #expect(stats.total == 4)
    }
}
