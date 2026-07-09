//
//  TetrominoShapeGeneratorTests.swift
//  MacTrisTests
//
//  Created by Sebastian Boettcher on 09.07.26.
//

import Testing
@testable import MacTris

struct TetrominoShapeGeneratorTests {

    // MARK: - SevenBagTetrominoShapeGenerator

    struct SevenBagTests {

        @Test func testFirstBagContainsAllSevenShapes() async throws {
            let generator = SevenBagTetrominoShapeGenerator()
            var shapes: [Tetromino.Shape] = []

            for _ in 0..<7 {
                shapes.append(generator.next())
            }

            for shape in Tetromino.Shape.allCases {
                #expect(shapes.filter { $0 == shape }.count == 1)
            }
        }

        @Test func testSecondBagAlsoContainsAllSevenShapes() async throws {
            let generator = SevenBagTetrominoShapeGenerator()
            var shapes: [Tetromino.Shape] = []

            for _ in 0..<14 {
                shapes.append(generator.next())
            }

            let firstBag = Array(shapes.prefix(7))
            let secondBag = Array(shapes.suffix(7))

            for shape in Tetromino.Shape.allCases {
                #expect(firstBag.filter { $0 == shape }.count == 1)
                #expect(secondBag.filter { $0 == shape }.count == 1)
            }
        }

        @Test func testBagsAreShuffled() async throws {
            let generator = SevenBagTetrominoShapeGenerator(random: SeededRandomNumberGenerator(seed: 42))
            var shapes: [Tetromino.Shape] = []

            for _ in 0..<7 {
                shapes.append(generator.next())
            }

            // The bag should be shuffled — at least one position should differ from the default order
            let defaultOrder: [Tetromino.Shape] = [.t, .j, .z, .o, .s, .l, .i]
            #expect(shapes != defaultOrder)
        }

        @Test func testSingleBagCallsRelyOnAllCasesExactlyOnce() async throws {
            let generator = SevenBagTetrominoShapeGenerator()
            var counts: [Tetromino.Shape: Int] = [:]

            for _ in 0..<7 {
                let shape = generator.next()
                counts[shape, default: 0] += 1
            }

            #expect(counts.count == 7)
            for (_, count) in counts {
                #expect(count == 1)
            }
        }

        @Test func testConsecutiveBagsHaveNoOverlap() async throws {
            let generator = SevenBagTetrominoShapeGenerator()
            var allShapes: [Tetromino.Shape] = []

            for _ in 0..<21 {
                allShapes.append(generator.next())
            }

            // 3 bags of 7 = 21 shapes, each shape should appear exactly 3 times
            for shape in Tetromino.Shape.allCases {
                #expect(allShapes.filter { $0 == shape }.count == 3)
            }
        }

        @Test func testDeterministicWithSeededGenerator() async throws {
            let xorshift1 = SeededRandomNumberGenerator(seed: 123)
            let xorshift2 = SeededRandomNumberGenerator(seed: 123)

            let gen1 = SevenBagTetrominoShapeGenerator(random: xorshift1)
            let gen2 = SevenBagTetrominoShapeGenerator(random: xorshift2)

            var shapes1: [Tetromino.Shape] = []
            var shapes2: [Tetromino.Shape] = []

            for _ in 0..<14 {
                shapes1.append(gen1.next())
                shapes2.append(gen2.next())
            }

            #expect(shapes1 == shapes2)
        }

        @Test func testEmptyBagTriggersRefill() async throws {
            let generator = SevenBagTetrominoShapeGenerator()

            // Drain one bag completely
            for _ in 0..<7 {
                _ = generator.next()
            }

            // Next call should start a new bag — should produce a valid shape
            let shape = generator.next()
            #expect(Tetromino.Shape.allCases.contains(shape))
        }
    }

    // MARK: - NesTetrominoShapeGenerator

    struct NesTests {

        @Test func testReturnsValidShapes() async throws {
            let generator = NesTetrominoShapeGenerator(random: SeededRandomNumberGenerator(seed: 99))

            for _ in 0..<100 {
                let shape = generator.next()
                #expect(Tetromino.Shape.allCases.contains(shape))
            }
        }

        @Test func testAllShapesAppearOverManyIterations() async throws {
            let generator = NesTetrominoShapeGenerator(random: SeededRandomNumberGenerator(seed: 42))
            var seen: Set<Tetromino.Shape> = []

            for _ in 0..<1000 {
                seen.insert(generator.next())
            }

            #expect(seen.count == 7)
        }

        @Test func testDeterministicWithSeededGenerator() async throws {
            let xorshift1 = SeededRandomNumberGenerator(seed: 777)
            let xorshift2 = SeededRandomNumberGenerator(seed: 777)

            let gen1 = NesTetrominoShapeGenerator(random: xorshift1)
            let gen2 = NesTetrominoShapeGenerator(random: xorshift2)

            var shapes1: [Tetromino.Shape] = []
            var shapes2: [Tetromino.Shape] = []

            for _ in 0..<200 {
                shapes1.append(gen1.next())
                shapes2.append(gen2.next())
            }

            #expect(shapes1 == shapes2)
        }

        @Test func testShapeDistributionRoughlyUniform() async throws {
            let generator = NesTetrominoShapeGenerator(random: SeededRandomNumberGenerator(seed: 55))
            var counts: [Tetromino.Shape: Int] = [:]

            let total = 7000
            for _ in 0..<total {
                let shape = generator.next()
                counts[shape, default: 0] += 1
            }

            let expectedPerShape = Double(total) / 7.0
            for shape in Tetromino.Shape.allCases {
                let count = Double(counts[shape, default: 0])
                // Allow ±20% deviation from uniform
                #expect(count > expectedPerShape * 0.8)
                #expect(count < expectedPerShape * 1.2)
            }
        }

        @Test func testDoesNotCrashOnLongSequence() async throws {
            let generator = NesTetrominoShapeGenerator(random: SeededRandomNumberGenerator(seed: 1))

            // Should not fatalError or crash
            for _ in 0..<10_000 {
                _ = generator.next()
            }
        }
    }
}
