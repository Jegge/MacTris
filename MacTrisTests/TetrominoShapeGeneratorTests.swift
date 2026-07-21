//
//  TetrominoShapeGeneratorTests.swift
//  MacTrisTests
//
//  Created by Sebastian Boettcher on 09.07.26.
//

import Testing
@testable import MacTris

struct TetrominoShapeGeneratorTests {

    struct SevenBagTests {
        @Test func testEachBagHasEachSevenShapes() async throws {
            let generator = SevenBagTetrominoShapeGenerator()
            var first: [Tetromino.Shape] = []
            var second: [Tetromino.Shape] = []

            for _ in 0..<7 {
                first.append(generator.next())
            }
            for _ in 0..<7 {
                second.append(generator.next())
            }

            for shape in Tetromino.Shape.allCases {
                #expect(first.filter { $0 == shape }.count == 1)
                #expect(second.filter { $0 == shape }.count == 1)
            }
        }

        @Test func testDeterministicWithSeededGenerator() async throws {
            let gen1 = SevenBagTetrominoShapeGenerator(random: SeededRandomNumberGenerator(seed: 123))
            let gen2 = SevenBagTetrominoShapeGenerator(random: SeededRandomNumberGenerator(seed: 123))

            var shapes1: [Tetromino.Shape] = []
            var shapes2: [Tetromino.Shape] = []

            for _ in 0..<14 {
                shapes1.append(gen1.next())
                shapes2.append(gen2.next())
            }

            #expect(shapes1 == shapes2)
        }
    }

    struct NesTests {

        @Test func testShapeDistributionRoughlyUniform() async throws {
            let generator = NesTetrominoShapeGenerator(random: SeededRandomNumberGenerator(seed: 12345))
            var counts: [Tetromino.Shape: Int] = [:]

            let total = 7000
            for _ in 0..<total {
                let shape = generator.next()
                counts[shape, default: 0] += 1
            }

            let expectedPerShape = Double(total) / 7.0

            for shape in Tetromino.Shape.allCases {
                let count = Double(counts[shape, default: 0])
                // Allow ±10% deviation from uniform
                #expect(count > expectedPerShape * 0.9)
                #expect(count < expectedPerShape * 1.1)
            }
        }

        @Test func testDeterministicWithSeededGenerator() async throws {
            let gen1 = NesTetrominoShapeGenerator(random: SeededRandomNumberGenerator(seed: 777))
            let gen2 = NesTetrominoShapeGenerator(random: SeededRandomNumberGenerator(seed: 777))

            var shapes1: [Tetromino.Shape] = []
            var shapes2: [Tetromino.Shape] = []

            for _ in 0..<200 {
                shapes1.append(gen1.next())
                shapes2.append(gen2.next())
            }

            #expect(shapes1 == shapes2)
        }
    }
}
