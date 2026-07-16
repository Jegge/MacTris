//
//  TetrisTests.swift
//  MacTrisTests
//
//  Created by Sebastian Boettcher on 07.07.26.
//

import Testing
@testable import MacTris

struct TetrisBoardTests {

    @Test func testInitialState() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]), startingLevel: 0, allowWallKick: false)
        #expect(tetris.score == 0)
        #expect(tetris.lines == 0)
        #expect(tetris.level == 0)
        #expect(tetris.current != nil)
        #expect(tetris.current?.shape == .i)
        #expect(tetris.next.shape == .o)
        #expect(tetris.grid.count == Tetris.numberOfColumns)
        #expect(tetris.grid[0].count == Tetris.numberOfRows)
        #expect(tetris.stackHeight == 0)
        #expect(tetris.lowestCompletedLines == nil)

        for (col, row) in tetris.current?.points ?? [] {
            if row >= 0, row < Tetris.numberOfRows, col >= 0, col < Tetris.numberOfColumns {
                #expect(tetris.grid[col][row] == tetris.current?.shape)
            }
        }
    }

    @Test func testConvenienceInitWithOptions() async throws {
        let options = TetrisOptions(
            startingLevel: 3,
            appearance: .plain,
            animations: false,
            autoShift: .nes,
            randomGeneratorMode: .nes,
            wallKick: true,
            hardDrop: true
        )
        let tetris = Tetris(options: options)
        #expect(tetris.level == 3)
        #expect(tetris.current != nil)
        #expect(tetris.score == 0)
    }

    @Test func testshiftLeft() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]), startingLevel: 0, allowWallKick: false)
        let before = tetris.current?.position.x
        #expect(tetris.shift(.left))
        #expect(tetris.current?.position.x == (before ?? 0) - 1)
    }

    @Test func testshiftRight() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]), startingLevel: 0, allowWallKick: false)
        let before = tetris.current?.position.x
        #expect(tetris.shift(.right))
        #expect(tetris.current?.position.x == (before ?? 0) + 1)
    }

    @Test func testRotateClockwise() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: [.t]), startingLevel: 0, allowWallKick: false)
        let before = tetris.current?.rotation
        #expect(tetris.rotate(.clockwise))
        let expected = ((before ?? 0) + Tetromino.Shape.t.points.count - 1) % Tetromino.Shape.t.points.count
        #expect(tetris.current?.rotation == expected)
    }

    @Test func testRotateCounterClockwise() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: [.t]), startingLevel: 0, allowWallKick: false)
        let before = tetris.current?.rotation
        #expect(tetris.rotate(.counterClockwise))
        let expected = ((before ?? 0) + 1) % Tetromino.Shape.t.points.count
        #expect(tetris.current?.rotation == expected)
    }

    @Test func testSoftDropManual() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]), startingLevel: 0, allowWallKick: false)
        let before = tetris.current?.position.y
        #expect(tetris.softDrop(manual: true))
        #expect(tetris.current?.position.y == (before ?? 0) - 1)
    }

    @Test func testSoftDropAuto() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]), startingLevel: 0, allowWallKick: false)
        let before = tetris.current?.position.y
        #expect(tetris.softDrop(manual: false))
        #expect(tetris.current?.position.y == (before ?? 0) - 1)
    }

    @Test func testSoftDropManualScoresOnLock() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]), startingLevel: 0, allowWallKick: false)
        #expect(tetris.score == 0)
        while tetris.current != nil {
            if tetris.softDrop(manual: true) {
                continue
            }
        }
        #expect(tetris.score > 0)
    }

    @Test func testLockAndSpawn() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]), startingLevel: 0, allowWallKick: false)
        while tetris.current != nil {
            _ = tetris.softDrop(manual: false)
        }
        #expect(tetris.spawn())
        #expect(tetris.current != nil)
    }

    @Test func testGameOver() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: Array(repeating: .o, count: 100)), startingLevel: 0, allowWallKick: false)
        while tetris.softDrop(manual: false) { }
        while tetris.spawn() {
            while tetris.softDrop(manual: false) {}
        }

        #expect(tetris.current == nil)
        #expect(!tetris.shift(.left))
        #expect(!tetris.shift(.right))
        #expect(!tetris.rotate(.clockwise))
        #expect(!tetris.rotate(.counterClockwise))
    }

    @Test func testScoreNoLines() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]), startingLevel: 0, allowWallKick: false)
        tetris.clear(lines: 0..<0)
        #expect(tetris.score == 0)
        #expect(tetris.lines == 0)
    }

    @Test func testScoreOneLine() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]), startingLevel: 0, allowWallKick: false)
        tetris.clear(lines: 3..<4)
        #expect(tetris.score == 40)
        #expect(tetris.lines == 1)
    }

    @Test func testScoreTwoLines() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]), startingLevel: 0, allowWallKick: false)
        tetris.clear(lines: 3..<5)
        #expect(tetris.score == 100)
        #expect(tetris.lines == 2)
    }

    @Test func testScoreThreeLines() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]), startingLevel: 0, allowWallKick: false)
        tetris.clear(lines: 2..<5)
        #expect(tetris.score == 300)
        #expect(tetris.lines == 3)
    }

    @Test func testScoreFourLines() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]), startingLevel: 0, allowWallKick: false)
        tetris.clear(lines: 2..<6)
        #expect(tetris.score == 1200)
        #expect(tetris.lines == 4)
    }

    @Test func testScoreScalesWithLevel() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]), startingLevel: 5, allowWallKick: false)
        tetris.clear(lines: 0..<1)
        #expect(tetris.score == 40 * (5 + 1))
    }

    @Test func testLevelUp() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]), startingLevel: 0, allowWallKick: false)
        #expect(tetris.level == 0)
        for _ in 0..<10 {
            tetris.clear(lines: 0..<1)
        }
        #expect(tetris.level >= 1)
    }

    @Test func testCollidesAtLeftWall() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]), startingLevel: 0, allowWallKick: false)
        let piece = tetris.current
        for _ in 0..<Tetris.numberOfColumns where tetris.shift(.left) {
        }
        let moved = tetris.current
        #expect(piece != nil)
        #expect(moved != nil)
        #expect(piece?.position.x != moved?.position.x)
        #expect(!tetris.shift(.left))
    }

    @Test func testCollidesAtRightWall() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]), startingLevel: 0, allowWallKick: false)
        let piece = tetris.current
        for _ in 0..<Tetris.numberOfColumns where tetris.shift(.right) { }
        let moved = tetris.current
        #expect(piece != nil)
        #expect(moved != nil)
        #expect(piece?.position.x != moved?.position.x)
        #expect(!tetris.shift(.right))
    }

    @Test func testRotationCannotSlideThroughLeftWall() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: [.l]), startingLevel: 0, allowWallKick: false)
        #expect(tetris.rotate(.clockwise))
        #expect(tetris.current?.rotation == 3)

        while tetris.shift(.left) { }

        #expect(tetris.current?.position.x == 1)
        #expect(tetris.current?.position.y == 19)
    }

    @Test func testRotationCannotSlideThroughRightWall() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: [.l]), startingLevel: 0, allowWallKick: false)
        #expect(tetris.rotate(.counterClockwise))
        #expect(tetris.current?.rotation == 1)

        while tetris.shift(.right) { }

        #expect(tetris.current?.position.x == 8)
        #expect(tetris.current?.position.y == 19)
    }

    @Test func testClearLinesClearsRowShiftsDownAndScores() async throws {
        // Played order from the stub is index1, index0, index2.
        // Two I pieces (1 cell tall) cover cols 0..7; an O at the far right covers cols 8..9.
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: [.i, .i, .o]), startingLevel: 0, allowWallKick: false)
        // first I: cols 0..3 at row 0
        for _ in 0..<3 where tetris.shift(.left) {}
        tetris.hardDrop()
        #expect(tetris.spawn())
        // second I: cols 4..7 at row 0
        for _ in 0..<1 where tetris.shift(.right) {}
        tetris.hardDrop()
        #expect(tetris.spawn())
        // O: cols 8..9 at row 0 -> row 0 now complete
        for _ in 0..<4 where tetris.shift(.right) {}
        tetris.hardDrop()

        #expect(tetris.lowestCompletedLines == 0..<1)
        let linesBefore = tetris.lines
        let scoreBefore = tetris.score
        // row 1 has O at cols 8..9
        #expect(tetris.grid[8][1] == .o)
        #expect(tetris.grid[9][1] == .o)

        tetris.clear(lines: 0..<1)

        #expect(tetris.lines == linesBefore + 1)
        #expect(tetris.score == scoreBefore + 40)
        #expect(tetris.lowestCompletedLines == nil)

        // old row 1 shifted down to row 0
        #expect(tetris.grid[8][0] == .o)
        #expect(tetris.grid[9][0] == .o)
        // old row 0 content is gone
        #expect(tetris.grid[0][0] == nil)
        #expect(tetris.grid[4][0] == nil)
        // old row 2 (empty) shifted to row 1
        #expect(tetris.grid[8][1] == nil)
    }

    @Test func testWallKickRotateAtLeftWall() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: Array(repeating: .i, count: 10)), startingLevel: 0, allowWallKick: true)

        #expect(tetris.rotate(.counterClockwise))
        #expect(tetris.current?.rotation == 1)

        while tetris.shift(.left) { }
        let leftmostX = tetris.current?.position.x
        #expect(leftmostX != nil)

        #expect(tetris.rotate(.clockwise))
        #expect(tetris.current?.rotation == 0)
        #expect(tetris.current?.position.x == (leftmostX ?? 0) + 2)
    }

    @Test func testWallKickRotateAtRightWall() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: Array(repeating: .i, count: 10)), startingLevel: 0, allowWallKick: true)

        #expect(tetris.rotate(.counterClockwise))
        #expect(tetris.current?.rotation == 1)

        while tetris.shift(.right) {}
        let rightmostX = tetris.current?.position.x
        #expect(rightmostX != nil)

        #expect(tetris.rotate(.clockwise))
        #expect(tetris.current?.rotation == 0)
        #expect(tetris.current?.position.x == (rightmostX ?? 0) - 1)
    }

    @Test func testHardDropLocksAtBottomPieceAndScores() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: [.o]), startingLevel: 0, allowWallKick: false)
        tetris.hardDrop()
        #expect(tetris.current == nil)
        #expect(tetris.score == 36) // O piece spawns at y=19, lands at y=1 = 18 rows, 2 pts/row
        #expect(tetris.grid[4][1] == .o)
        #expect(tetris.grid[5][1] == .o)
        #expect(tetris.grid[4][0] == .o)
        #expect(tetris.grid[5][0] == .o)
        #expect(tetris.stackHeight == 2)
    }

    @Test func testHardDropOnTopOfStack() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: [.o]), startingLevel: 0, allowWallKick: false)
        tetris.hardDrop()  // first O lands at y=1, score = 36
        #expect(tetris.score == 36)
        #expect(tetris.spawn())
        tetris.hardDrop()  // second O lands on top at y=3, score += 32
        #expect(tetris.score == 68)
        #expect(tetris.grid[4][3] == .o)
        #expect(tetris.grid[5][3] == .o)
        #expect(tetris.grid[4][2] == .o)
        #expect(tetris.grid[5][2] == .o)
        #expect(tetris.stackHeight == 4)
    }

    @Test func testStatisticsCountsSpawnedPieces() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: [.o, .i, .t]), startingLevel: 0, allowWallKick: false)
        #expect(tetris.statistics.total == 1)
        #expect(tetris.statistics.count(.o) == 1)

        tetris.hardDrop()
        #expect(tetris.spawn())
        #expect(tetris.statistics.total == 2)
        #expect(tetris.statistics.count(.i) == 1)
        #expect(tetris.statistics.count(.o) == 1)

        tetris.hardDrop()
        #expect(tetris.spawn())
        #expect(tetris.statistics.total == 3)
        #expect(tetris.statistics.count(.t) == 1)
    }

    @Test func testAutoSoftDropDoesNotScore() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: [.o]), startingLevel: 0, allowWallKick: false)
        while tetris.softDrop(manual: false) {
            #expect(tetris.score == 0)
        }
        #expect(tetris.score == 0)
    }

    @Test func testLowestCompletedLinesMultipleContiguousRows() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: [.i, .i, .o, .i, .i, .i]), startingLevel: 0, allowWallKick: false)
        // init: current=.i(shapes[1]), next=.i(shapes[0]), genIndex=2
        // piece 1 (.i): shift left 3x -> cols 0..3, row 0
        for _ in 0..<3 where tetris.shift(.left) {}
        tetris.hardDrop()
        #expect(tetris.spawn())
        // piece 2 (.i): shift right 1x -> cols 4..7, row 0
        for _ in 0..<1 where tetris.shift(.right) {}
        tetris.hardDrop()
        #expect(tetris.spawn())
        // piece 3 (.o): shift right 4x -> cols 8..9, rows 0..1; row 0 complete
        for _ in 0..<4 where tetris.shift(.right) {}
        tetris.hardDrop()
        #expect(tetris.spawn())
        // piece 4 (.i): shift left 3x -> cols 0..3, row 1
        for _ in 0..<3 where tetris.shift(.left) {}
        tetris.hardDrop()
        #expect(tetris.spawn())
        // piece 5 (.i): shift right 1x -> cols 4..7, row 1; row 1 complete
        for _ in 0..<1 where tetris.shift(.right) {}
        tetris.hardDrop()

        #expect(tetris.lowestCompletedLines == 0..<2)
    }

    @Test func testBoardReflectsAllLockedPieces() async throws {
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: [.o, .o, .o]), startingLevel: 0, allowWallKick: false)
        // first O: cols 4..5, rows 0..1
        tetris.hardDrop()
        #expect(tetris.spawn())
        // second O: cols 0..1, rows 0..1
        for _ in 0..<4 where tetris.shift(.left) {}
        tetris.hardDrop()
        #expect(tetris.spawn())
        // third O: cols 8..9, rows 0..1
        for _ in 0..<4 where tetris.shift(.right) {}
        tetris.hardDrop()

        #expect(tetris.grid[4][0] == .o)
        #expect(tetris.grid[5][0] == .o)
        #expect(tetris.grid[0][0] == .o)
        #expect(tetris.grid[1][0] == .o)
        #expect(tetris.grid[8][0] == .o)
        #expect(tetris.grid[9][0] == .o)
        #expect(tetris.grid[2][0] == nil)
        #expect(tetris.grid[6][0] == nil)
    }

    @Test func testFullGameIntegrationPlaysUntilGameOver() async throws {
        // Play through the entire game lifecycle: spawn, drop, lock,
        // line clear, level up, and eventually game over.
        let shapes: [Tetromino.Shape] = [
            .i, .o, .t, .s, .z, .j, .l,
            .i, .o, .t, .s, .z, .j, .l,
            .i, .o, .t, .s, .z, .j, .l,
            .i, .o, .t, .s, .z, .j, .l,
            .i, .o, .t, .s, .z, .j, .l
        ]
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: shapes), startingLevel: 0, allowWallKick: false)

        #expect(tetris.level == 0)
        #expect(tetris.lines == 0)
        #expect(tetris.score == 0)
        #expect(tetris.current != nil)

        var spawned = 1
        var cleared = 0

        while tetris.current != nil {
            // Drop until locked
            while tetris.softDrop(manual: false) { }

            // Clear completed lines
            if let lines = tetris.lowestCompletedLines {
                cleared += lines.count
                tetris.clear(lines: lines)
            }

            guard tetris.spawn() else { break }
            spawned += 1
            #expect(tetris.current != nil)
        }

        #expect(tetris.current == nil)
        #expect(tetris.lines == cleared)
        #expect(spawned > 5)
        #expect(tetris.statistics.total >= spawned)
        #expect(tetris.level >= 0)
        #expect(tetris.level <= Tetris.maxLevel)
        #expect(tetris.score >= 0)
    }

    @Test func testFullGameIntegrationScoreAndLevelProgression() async throws {
        // Fill a single complete row using I (left + right) and O (far right),
        // clear it, then continue dropping pieces until game over.
        // This exercises: line completion, scoring, spawn/drop cycle, game over.

        let shapes: [Tetromino.Shape] = Array(repeating: [.i, .i, .o], count: 15).flatMap { $0 }
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: shapes), startingLevel: 0, allowWallKick: false)
        #expect(tetris.current?.shape == .i)

        // Place I at left (x=2), covers cols 0..3
        for _ in 0..<3 where tetris.shift(.left) {}
        tetris.hardDrop()
        #expect(tetris.spawn())

        // Place I at right (x=6), covers cols 4..7
        for _ in 0..<1 where tetris.shift(.right) {}
        tetris.hardDrop()
        #expect(tetris.spawn())

        // Place O at far right (x=9), covers cols 8..9 at rows y-1 and y
        for _ in 0..<4 where tetris.shift(.right) {}
        tetris.hardDrop()

        // Row 0 should now be complete
        #expect(tetris.lowestCompletedLines != nil)
        let lines = tetris.lowestCompletedLines ?? 0..<0
        #expect(lines.count == 1)

        let expectedScore = 40 * (0 + 1)  // 40 at level 0
        let beforeScore = tetris.score
        tetris.clear(lines: lines)
        #expect(tetris.score == beforeScore + expectedScore)
        #expect(tetris.lines == 1)
        #expect(tetris.level == 0)

        // Continue playing until game over — validates the game loop
        #expect(tetris.spawn())
        var spawned = 3  // we already spawned 3 pieces
        while tetris.current != nil {
            while tetris.softDrop(manual: false) { }
            if let nextLines = tetris.lowestCompletedLines {
                tetris.clear(lines: nextLines)
            }
            guard tetris.spawn() else { break }
            spawned += 1
        }

        #expect(tetris.current == nil)
        #expect(tetris.statistics.total >= spawned)
        #expect(tetris.lines > 0)
    }

    @Test func testFullGameIntegrationGameOver() async throws {
        // Stack O pieces in the same column until the board fills up.
        // O at (5,19) covers cols 4..5 and rows 18..19.
        // Hard drop lands the first O at y=1 (rows 0..1).
        // 10 O pieces fill 10×2=20 rows → 11th spawn fails.
        let shapes: [Tetromino.Shape] = Array(repeating: .o, count: 20)
        let tetris = Tetris(random: StubTetrominoShapeGenerator(shapes: shapes), startingLevel: 0, allowWallKick: false)

        var dropped = 0
        while tetris.current != nil {
            tetris.hardDrop()
            dropped += 1
            guard tetris.spawn() else { break }
        }

        #expect(dropped == 10)
        #expect(tetris.current == nil)

        // Each O drops a decreasing distance: 18, 16, 14, ..., 0 rows.
        // Score = 2 * sum(even 2..18) = 2 * (18+16+14+12+10+8+6+4+2+0) = 180
        // But only the first 9 hard drops add score (the 10th is already at the top).
        #expect(tetris.score == 180)
        #expect(tetris.lines == 0)
        #expect(tetris.statistics.total == 11)
        #expect(tetris.statistics.count(.o) == 11)
    }
}
