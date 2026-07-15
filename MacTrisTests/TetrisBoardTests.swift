//
//  TetrisTests.swift
//  MacTrisTests
//
//  Created by Sebastian Boettcher on 07.07.26.
//

import Testing
@testable import MacTris

// swiftlint:disable force_unwrapping

struct TetrisBoardTests {
    private func makeTetris(startingLevel: Int = 0, wallKick: Bool = false, shapes: [Tetromino.Shape] = [.i, .o, .t, .s, .z, .j, .l]) -> Tetris {
        Tetris(random: StubTetrominoShapeGenerator(shapes: shapes), startingLevel: startingLevel, allowWallKick: wallKick)
    }

    @Test func testInitialState() async throws {
        let tetris = makeTetris()
        #expect(tetris.score == 0)
        #expect(tetris.lines == 0)
        #expect(tetris.level == 0)
    }

    @Test func testBoardSize() async throws {
        let tetris = makeTetris()
        #expect(tetris.grid.count == Tetris.numberOfColumns)
        #expect(tetris.grid[0].count == Tetris.numberOfRows)
    }

    @Test func testSpawnCreatesCurrentPiece() async throws {
        let tetris = makeTetris()
        #expect(tetris.current != nil)
    }

    @Test func testBoardShowsCurrentPiece() async throws {
        let tetris = makeTetris()
        if let current = tetris.current {
            for (col, row) in current.points {
                if row >= 0, row < Tetris.numberOfRows, col >= 0, col < Tetris.numberOfColumns {
                    #expect(tetris.grid[col][row] == current.shape)
                }
            }
        }
    }

    @Test func testshiftLeft() async throws {
        let tetris = makeTetris()
        let before = tetris.current?.position.x
        #expect(tetris.shift(.left))
        #expect(tetris.current?.position.x == (before ?? 0) - 1)
    }

    @Test func testshiftRight() async throws {
        let tetris = makeTetris()
        let before = tetris.current?.position.x
        #expect(tetris.shift(.right))
        #expect(tetris.current?.position.x == (before ?? 0) + 1)
    }

    @Test func testRotateClockwise() async throws {
        let tetris = makeTetris(shapes: [.t])
        let before = tetris.current?.rotation
        #expect(tetris.rotate(.clockwise))
        let expected = ((before ?? 0) + Tetromino.Shape.t.points.count - 1) % Tetromino.Shape.t.points.count
        #expect(tetris.current?.rotation == expected)
    }

    @Test func testRotateCounterClockwise() async throws {
        let tetris = makeTetris(shapes: [.t])
        let before = tetris.current?.rotation
        #expect(tetris.rotate(.counterClockwise))
        let expected = ((before ?? 0) + 1) % Tetromino.Shape.t.points.count
        #expect(tetris.current?.rotation == expected)
    }

    @Test func testSoftDropManual() async throws {
        let tetris = makeTetris()
        let before = tetris.current?.position.y
        #expect(tetris.softDrop(manual: true))
        #expect(tetris.current?.position.y == (before ?? 0) - 1)
    }

    @Test func testSoftDropAuto() async throws {
        let tetris = makeTetris()
        let before = tetris.current?.position.y
        #expect(tetris.softDrop(manual: false))
        #expect(tetris.current?.position.y == (before ?? 0) - 1)
    }

    @Test func testSoftDropManualScoresOnLock() async throws {
        let tetris = makeTetris()
        while tetris.current != nil {
            if tetris.softDrop(manual: true) {
                continue
            }
        }
        #expect(tetris.score > 0)
    }

    @Test func testLockAndSpawn() async throws {
        let tetris = makeTetris()
        while tetris.current != nil {
            _ = tetris.softDrop(manual: false)
        }
        #expect(tetris.spawn())
        #expect(tetris.current != nil)
    }

    @Test func testGameOver() async throws {
        let shapes: [Tetromino.Shape] = Array(repeating: .o, count: 100)
        let tetris = makeTetris(shapes: shapes)
        while tetris.current != nil {
            _ = tetris.softDrop(manual: false)
        }
        let result = tetris.spawn()
        if !result {
            #expect(tetris.current == nil)
        }
    }

    @Test func testStackHeight() async throws {
        let tetris = makeTetris()
        #expect(tetris.stackHeight == 0)
    }

    @Test func testLowestCompletedLinesNoLines() async throws {
        let tetris = makeTetris()
        #expect(tetris.lowestCompletedLines == nil)
    }

    @Test func testScoreNoLines() async throws {
        let tetris = makeTetris()
        tetris.clear(lines: 0..<0)
        #expect(tetris.score == 0)
        #expect(tetris.lines == 0)
    }

    @Test func testScoreOneLine() async throws {
        let tetris = makeTetris(startingLevel: 0)
        tetris.clear(lines: 3..<4)
        #expect(tetris.score == 40)
        #expect(tetris.lines == 1)
    }

    @Test func testScoreTwoLines() async throws {
        let tetris = makeTetris(startingLevel: 0)
        tetris.clear(lines: 3..<5)
        #expect(tetris.score == 100)
        #expect(tetris.lines == 2)
    }

    @Test func testScoreThreeLines() async throws {
        let tetris = makeTetris(startingLevel: 0)
        tetris.clear(lines: 2..<5)
        #expect(tetris.score == 300)
        #expect(tetris.lines == 3)
    }

    @Test func testScoreFourLines() async throws {
        let tetris = makeTetris(startingLevel: 0)
        tetris.clear(lines: 2..<6)
        #expect(tetris.score == 1200)
        #expect(tetris.lines == 4)
    }

    @Test func testScoreWithLevel() async throws {
        let tetris = makeTetris(startingLevel: 5)
        tetris.clear(lines: 0..<1)
        #expect(tetris.score == 40 * (5 + 1))
    }

    @Test func testLevelUp() async throws {
        let tetris = makeTetris(startingLevel: 0)
        #expect(tetris.level == 0)
        for _ in 0..<10 {
            tetris.clear(lines: 0..<1)
        }
        #expect(tetris.level >= 1)
    }

    @Test func testSpawnSetsNext() async throws {
        let tetris = makeTetris()
        let firstNext = tetris.next
        while tetris.current != nil {
            _ = tetris.softDrop(manual: false)
        }
        #expect(tetris.spawn())
        let secondNext = tetris.next
        #expect(firstNext.shape != secondNext.shape)
    }

    @Test func testCollidesAtLeftWall() async throws {
        let tetris = makeTetris()
        let piece = tetris.current!
        for _ in 0..<Tetris.numberOfColumns where tetris.shift(.left) {
            // empty
        }
        let farLeft = tetris.current!
        #expect(piece.position.x != farLeft.position.x)
    }

    @Test func testCollidesAtRightWall() async throws {
        let tetris = makeTetris()
        let piece = tetris.current!
        for _ in 0..<Tetris.numberOfColumns where tetris.shift(.right) {
            // empty
        }
        let farRight = tetris.current!
        #expect(piece.position.x != farRight.position.x)
    }

    @Test func testRotationCannotSlideThroughLeftWall() async throws {
        let tetris = makeTetris(shapes: [.l])

        #expect(tetris.rotate(.clockwise))
        #expect(tetris.current?.rotation == 3)

        while tetris.shift(.left) {
            // empty
        }

        #expect(tetris.current?.position.x == 1)
        #expect(tetris.current?.position.y == 19)
    }

    @Test func testRotationCannotSlideThroughRightWall() async throws {
        let tetris = makeTetris(shapes: [.l])

        #expect(tetris.rotate(.counterClockwise))
        #expect(tetris.current?.rotation == 1)

        while tetris.shift(.right) {
            // empty
        }

        #expect(tetris.current?.position.x == 8)
        #expect(tetris.current?.position.y == 19)
    }

    @Test func testClearLinesEmptyRangeDoesNotScore() async throws {
        let tetris = makeTetris()
        tetris.clear(lines: 0..<0)
        #expect(tetris.score == 0)
        #expect(tetris.lines == 0)
    }

    @Test func testClearLinesClearsRowAndScores() async throws {
        // Played order from the stub is index1, index0, index2.
        // Two I pieces (1 cell tall) cover cols 0..7; an O at the far right covers cols 8..9.
        let tetris = makeTetris(shapes: [.i, .i, .o])
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

        #expect(tetris.lowestCompletedLines != nil)
        let linesBefore = tetris.lines
        let scoreBefore = tetris.score
        tetris.clear(lines: tetris.lowestCompletedLines!)
        #expect(tetris.lines == linesBefore + 1)
        #expect(tetris.score == scoreBefore + 40)
        #expect(tetris.lowestCompletedLines == nil)
    }

    @Test func testWallKickRotateNormally() async throws {
        let tetris = makeTetris(wallKick: true, shapes: [.t])
        let before = tetris.current?.rotation
        #expect(tetris.rotate(.clockwise))
        let expected = ((before ?? 0) + Tetromino.Shape.t.points.count - 1) % Tetromino.Shape.t.points.count
        #expect(tetris.current?.rotation == expected)
    }

    @Test func testWallKickRotateAtLeftWall() async throws {
        let tetris = makeTetris(wallKick: true, shapes: Array(repeating: .i, count: 10))

        #expect(tetris.rotate(.counterClockwise))
        #expect(tetris.current?.rotation == 1)

        while tetris.shift(.left) {
            // empty
        }
        let leftmostX = tetris.current!.position.x

        #expect(tetris.rotate(.clockwise))
        #expect(tetris.current?.rotation == 0)
        #expect(tetris.current?.position.x == leftmostX + 2)
    }

    @Test func testWallKickRotateAtRightWall() async throws {
        let tetris = makeTetris(wallKick: true, shapes: Array(repeating: .i, count: 10))

        #expect(tetris.rotate(.counterClockwise))
        #expect(tetris.current?.rotation == 1)

        while tetris.shift(.right) {
            // empty
        }
        let rightmostX = tetris.current!.position.x

        #expect(tetris.rotate(.clockwise))
        #expect(tetris.current?.rotation == 0)
        #expect(tetris.current?.position.x == rightmostX - 1)
    }

    @Test func testHardDropLocksPiece() async throws {
        let tetris = makeTetris(shapes: [.o])
        tetris.hardDrop()
        #expect(tetris.current == nil)
    }

    @Test func testHardDropScoresPoints() async throws {
        let tetris = makeTetris(shapes: [.o])
        tetris.hardDrop()
        // O piece spawns at y=19, lands at y=1 = 18 rows, 2 pts/row
        #expect(tetris.score == 36)
    }

    @Test func testHardDropPlacesPieceAtBottom() async throws {
        let tetris = makeTetris(shapes: [.o])
        tetris.hardDrop()
        #expect(tetris.grid[4][1] == .o)
        #expect(tetris.grid[5][1] == .o)
        #expect(tetris.grid[4][0] == .o)
        #expect(tetris.grid[5][0] == .o)
    }

    @Test func testHardDropOnTopOfStack() async throws {
        let tetris = makeTetris(shapes: [.o, .o])
        tetris.hardDrop()  // first O lands at y=1, score = 36
        #expect(tetris.score == 36)
        #expect(tetris.spawn())
        tetris.hardDrop()  // second O lands on top at y=3, score += 32
        #expect(tetris.score == 68)
        #expect(tetris.grid[4][3] == .o)
        #expect(tetris.grid[5][3] == .o)
        #expect(tetris.grid[4][2] == .o)
        #expect(tetris.grid[5][2] == .o)
    }

    @Test func testHardDropWhenNoCurrentPiece() async throws {
        let tetris = makeTetris(shapes: [.o])
        tetris.hardDrop()
        let score = tetris.score
        tetris.hardDrop()
        #expect(tetris.current == nil)
        #expect(tetris.score == score)
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

    @Test func testStatisticsCountsSpawnedPieces() async throws {
        let tetris = makeTetris(shapes: [.i, .o, .t])
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

    @Test func testStackHeightAfterDroppingPiece() async throws {
        let tetris = makeTetris(shapes: [.o])
        #expect(tetris.stackHeight == 0)
        tetris.hardDrop()
        #expect(tetris.stackHeight == 2)
    }

    private func reachGameOver() -> Tetris {
        let shapes: [Tetromino.Shape] = Array(repeating: .o, count: 100)
        let tetris = makeTetris(shapes: shapes)
        while tetris.softDrop(manual: false) {}
        while tetris.spawn() {
            while tetris.softDrop(manual: false) {}
        }
        return tetris
    }

    @Test func testShiftLeftReturnsFalseAfterGameOver() async throws {
        let tetris = reachGameOver()
        #expect(tetris.current == nil)
        #expect(!tetris.shift(.left))
    }

    @Test func testShiftRightReturnsFalseAfterGameOver() async throws {
        let tetris = reachGameOver()
        #expect(tetris.current == nil)
        #expect(!tetris.shift(.right))
    }

    @Test func testRotateClockwiseReturnsFalseAfterGameOver() async throws {
        let tetris = reachGameOver()
        #expect(tetris.current == nil)
        #expect(!tetris.rotate(.clockwise))
    }

    @Test func testRotateCounterClockwiseReturnsFalseAfterGameOver() async throws {
        let tetris = reachGameOver()
        #expect(tetris.current == nil)
        #expect(!tetris.rotate(.counterClockwise))
    }

    @Test func testAutoSoftDropDoesNotScore() async throws {
        let tetris = makeTetris(shapes: [.t])
        while tetris.softDrop(manual: false) {
            #expect(tetris.score == 0)
        }
        #expect(tetris.score == 0)
    }

    @Test func testClearShiftsRowsDownCorrectly() async throws {
        let tetris = makeTetris(shapes: [.i, .i, .o])
        // first I: cols 0..3 at row 0
        for _ in 0..<3 where tetris.shift(.left) {}
        tetris.hardDrop()
        #expect(tetris.spawn())
        // second I: cols 4..7 at row 0
        for _ in 0..<1 where tetris.shift(.right) {}
        tetris.hardDrop()
        #expect(tetris.spawn())
        // O: cols 8..9, rows 0..1
        for _ in 0..<4 where tetris.shift(.right) {}
        tetris.hardDrop()

        #expect(tetris.lowestCompletedLines == 0..<1)
        // row 1 has O at cols 8..9
        #expect(tetris.grid[8][1] == .o)
        #expect(tetris.grid[9][1] == .o)

        tetris.clear(lines: 0..<1)

        // old row 1 shifted down to row 0
        #expect(tetris.grid[8][0] == .o)
        #expect(tetris.grid[9][0] == .o)
        // old row 0 content is gone
        #expect(tetris.grid[0][0] == nil)
        #expect(tetris.grid[4][0] == nil)
        // old row 2 (empty) shifted to row 1
        #expect(tetris.grid[8][1] == nil)
    }

    @Test func testShiftLeftReturnsFalseAtWall() async throws {
        let tetris = makeTetris(shapes: [.i])
        for _ in 0..<Tetris.numberOfColumns where tetris.shift(.left) {}
        #expect(!tetris.shift(.left))
    }

    @Test func testShiftRightReturnsFalseAtWall() async throws {
        let tetris = makeTetris(shapes: [.i])
        for _ in 0..<Tetris.numberOfColumns where tetris.shift(.right) {}
        #expect(!tetris.shift(.right))
    }

    @Test func testSoftDropExactScoreAccumulation() async throws {
        let tetris = makeTetris(shapes: [.t])
        // T piece at y=19 drops to y=1 = 18 manual drops
        for _ in 0..<18 {
            #expect(tetris.softDrop(manual: true))
        }
        #expect(tetris.score == 0)
        // 19th drop locks the piece, score += 18
        #expect(!tetris.softDrop(manual: true))
        #expect(tetris.score == 18)
    }

    @Test func testLowestCompletedLinesMultipleContiguousRows() async throws {
        let tetris = makeTetris(shapes: [.i, .i, .o, .i, .i, .i])
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
        let tetris = makeTetris(shapes: [.o, .o, .o])
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

    // MARK: - Integration: full game simulation

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
        let tetris = makeTetris(startingLevel: 0, wallKick: false, shapes: shapes)

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
        let tetris = makeTetris(startingLevel: 0, wallKick: false, shapes: shapes)

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
        let lines = tetris.lowestCompletedLines!
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
        let tetris = makeTetris(startingLevel: 0, wallKick: false, shapes: shapes)

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

// swiftlint:enable force_unwrapping
