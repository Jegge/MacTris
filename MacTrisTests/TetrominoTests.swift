//
//  TetrominoTests.swift
//  MacTrisTests
//
//  Created by Sebastian Boettcher on 07.07.26.
//

import Testing
@testable import MacTris

struct TetrominoTests {
    @Test func testAllShapesHaveAtLeastOneRotation() async throws {
        for shape in Tetromino.Shape.allCases {
            #expect(shape.points.count > 0)
        }
    }

    @Test func testDefaultInit() async throws {
        for shape in Tetromino.Shape.allCases {
            let t = Tetromino(shape: shape)
            #expect(t.shape == shape)
            #expect(t.rotation == 0)
            #expect(t.position.x == 0)
            #expect(t.position.y == 0)
        }
    }

    @Test func testCustomInit() async throws {
        for shape in Tetromino.Shape.allCases {
            let t = Tetromino(shape: shape, rotation: 1, position: (5, 10))
            #expect(t.shape == shape)
            #expect(t.rotation == 1)
            #expect(t.position.x == 5)
            #expect(t.position.y == 10)
        }
    }

    @Test func testPointsIncludePosition() async throws {
        let t = Tetromino(shape: .o, position: (3, 4))
        for point in t.points {
            #expect(point.x - 3 == point.x - t.position.x)
            #expect(point.y - 4 == point.y - t.position.y)
        }
    }

    @Test func testRotateClockwise() async throws {
        let t = Tetromino(shape: .t, rotation: 0)
        let rotated = t.rotated(.clockwise)
        #expect(rotated.rotation == 3)
        #expect(rotated.position.x == t.position.x)
        #expect(rotated.position.y == t.position.y)
    }

    @Test func testRotateClockwiseWraps() async throws {
        // T piece has 4 rotation states, clockwise from last: (3 + 4 - 1) % 4 = 2
        let t = Tetromino(shape: .t, rotation: 3)
        let rotated = t.rotated(.clockwise)
        #expect(rotated.rotation == 2)
    }

    @Test func testRotateCounterClockwise() async throws {
        let t = Tetromino(shape: .t, rotation: 0)
        let rotated = t.rotated(.counterClockwise)
        // rotatedCounterClockwise increments: (0 + 1) % 4 = 1
        #expect(rotated.rotation == 1)
        #expect(rotated.position.x == t.position.x)
        #expect(rotated.position.y == t.position.y)
    }

    @Test func testRotateCounterClockwiseWraps() async throws {
        // T piece has 4 rotation states, counter-clockwise from last: (3 + 1) % 4 = 0
        let t = Tetromino(shape: .t, rotation: 3)
        let rotated = t.rotated(.counterClockwise)
        #expect(rotated.rotation == 0)
    }

    @Test func testShiftLeft() async throws {
        let t = Tetromino(shape: .o, position: (5, 5))
        let shifted = t.shifted(.left)
        #expect(shifted.position.x == 4)
        #expect(shifted.position.y == 5)
        #expect(shifted.shape == t.shape)
        #expect(shifted.rotation == t.rotation)
    }

    @Test func testShiftRight() async throws {
        let t = Tetromino(shape: .o, position: (5, 5))
        let shifted = t.shifted(.right)
        #expect(shifted.position.x == 6)
        #expect(shifted.position.y == 5)
    }

    @Test func testDrop() async throws {
        let t = Tetromino(shape: .o, position: (5, 5))
        let dropped = t.dropped()
        #expect(dropped.position.x == 5)
        #expect(dropped.position.y == 4)
    }

    @Test func testWithPosition() async throws {
        let t = Tetromino(shape: .i, rotation: 1, position: (0, 0))
        let moved = t.with(position: (7, 15))
        #expect(moved.shape == .i)
        #expect(moved.rotation == 1)
        #expect(moved.position.x == 7)
        #expect(moved.position.y == 15)
    }

    @Test func testAppearance() async throws {
        #expect(Tetromino.Shape.o.appearance == "Yellow")
        #expect(Tetromino.Shape.s.appearance == "Green")
        #expect(Tetromino.Shape.z.appearance == "Red")
        #expect(Tetromino.Shape.i.appearance == "Cyan")
        #expect(Tetromino.Shape.j.appearance == "Blue")
        #expect(Tetromino.Shape.l.appearance == "Orange")
        #expect(Tetromino.Shape.t.appearance == "Purple")
    }
}
