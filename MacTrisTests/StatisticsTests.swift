//
//  StatisticsTests.swift
//  MacTrisTests
//
//  Created by Sebastian Boettcher on 13.07.26.
//

import Testing
@testable import MacTris

struct StatisticsTests {
    @Test func testInitialTotalIsZero() async throws {
        let stats = Statistics()
        #expect(stats.total == 0)
    }

    @Test func testInitialCountIsZero() async throws {
        let stats = Statistics()
        #expect(stats.count(.t) == 0)
        #expect(stats.count(.i) == 0)
        #expect(stats.count(.o) == 0)
    }

    @Test func testInitialPercentIsZero() async throws {
        let stats = Statistics()
        #expect(stats.percent(.t) == 0.0)
    }

    @Test func testAddSingleShape() async throws {
        var stats = Statistics()
        stats.add(.t)
        #expect(stats.count(.t) == 1)
        #expect(stats.total == 1)
    }

    @Test func testAddMultipleOfSameShape() async throws {
        var stats = Statistics()
        stats.add(.i)
        stats.add(.i)
        stats.add(.i)
        #expect(stats.count(.i) == 3)
        #expect(stats.total == 3)
    }

    @Test func testAddDifferentShapes() async throws {
        var stats = Statistics()
        stats.add(.t)
        stats.add(.i)
        stats.add(.o)
        #expect(stats.count(.t) == 1)
        #expect(stats.count(.i) == 1)
        #expect(stats.count(.o) == 1)
        #expect(stats.total == 3)
    }

    @Test func testCountReturnsZeroForUnaddedShape() async throws {
        var stats = Statistics()
        stats.add(.t)
        #expect(stats.count(.i) == 0)
        #expect(stats.count(.s) == 0)
    }

    @Test func testPercentSingleShape() async throws {
        var stats = Statistics()
        stats.add(.t)
        #expect(stats.percent(.t) == 100.0)
    }

    @Test func testPercentOfTwoShapes() async throws {
        var stats = Statistics()
        stats.add(.t)
        stats.add(.i)
        #expect(stats.percent(.t) == 50.0)
        #expect(stats.percent(.i) == 50.0)
    }

    @Test func testPercentUnevenDistribution() async throws {
        var stats = Statistics()
        stats.add(.t)
        stats.add(.t)
        stats.add(.t)
        stats.add(.i)
        #expect(stats.percent(.t) == 75.0)
        #expect(stats.percent(.i) == 25.0)
    }

    @Test func testPercentOfUnaddedShape() async throws {
        var stats = Statistics()
        stats.add(.t)
        #expect(stats.percent(.i) == 0.0)
    }

    @Test func testAddIncrementsCorrectly() async throws {
        var stats = Statistics()
        stats.add(.o)
        stats.add(.o)
        stats.add(.o)
        stats.add(.o)
        stats.add(.o)
        #expect(stats.count(.o) == 5)
        #expect(stats.total == 5)
        #expect(stats.percent(.o) == 100.0)
    }

    @Test func testTotalAcrossAllShapes() async throws {
        var stats = Statistics()
        for shape in Tetromino.Shape.allCases {
            stats.add(shape)
        }
        #expect(stats.total == Tetromino.Shape.allCases.count)
        for shape in Tetromino.Shape.allCases {
            #expect(stats.count(shape) == 1)
        }
    }

    @Test func testDescriptionContainsAllShapes() async throws {
        var stats = Statistics()
        stats.add(.t)
        let desc = stats.description
        for shape in Tetromino.Shape.allCases {
            #expect(desc.contains(String(describing: shape).uppercased()))
        }
    }

    @Test func testDescriptionContainsCounts() async throws {
        var stats = Statistics()
        stats.add(.t)
        stats.add(.t)
        let desc = stats.description
        #expect(desc.contains("2/2"))
    }

    @Test func testDescriptionPercentFormatting() async throws {
        var stats = Statistics()
        stats.add(.t)
        let desc = stats.description
        #expect(desc.contains("100.0000%"))
    }
}
