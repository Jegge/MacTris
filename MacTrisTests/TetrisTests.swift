//
//  TetrisTests.swift
//  MacTrisTests
//
//  Created by Sebastian Boettcher on 07.07.26.
//

import Testing
@testable import MacTris

struct TetrisTests {
    private func shift(_ horizontalShift: Int, in tetris: Tetris) {
        let direction: Tetromino.Shift = horizontalShift < 0 ? .left : .right
        for _ in 0..<abs(horizontalShift) {
            #expect(tetris.shift(direction))
        }
    }

    @Test func testInitialState() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
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

        for point in tetris.current?.points ?? [] {
            if point.row >= 0, point.row < Tetris.numberOfRows, point.column >= 0, point.column < Tetris.numberOfColumns {
                #expect(tetris.grid[point.column][point.row] == tetris.current?.shape)
            }
        }
    }

    @Test func testShiftLeft() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        let before = tetris.current?.position.column
        #expect(tetris.shift(.left))
        #expect(tetris.current?.position.column == (before ?? 0) - 1)
    }

    @Test func testShiftRight() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        let before = tetris.current?.position.column
        #expect(tetris.shift(.right))
        #expect(tetris.current?.position.column == (before ?? 0) + 1)
    }

    @Test func testRotateClockwise() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.t]))
        let before = tetris.current?.rotation
        #expect(tetris.rotate(.clockwise))
        let expected = ((before ?? 0) + Tetromino.Shape.t.points.count - 1) % Tetromino.Shape.t.points.count
        #expect(tetris.current?.rotation == expected)
    }

    @Test func testRotateCounterClockwise() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.t]))
        let before = tetris.current?.rotation
        #expect(tetris.rotate(.counterClockwise))
        let expected = ((before ?? 0) + 1) % Tetromino.Shape.t.points.count
        #expect(tetris.current?.rotation == expected)
    }

    @Test func testSoftDropManual() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        let before = tetris.current?.position.row
        #expect(tetris.softDrop(manual: true))
        #expect(tetris.current?.position.row == (before ?? 0) - 1)
    }

    @Test func testSoftDropAuto() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        let before = tetris.current?.position.row
        #expect(tetris.softDrop(manual: false))
        #expect(tetris.current?.position.row == (before ?? 0) - 1)
    }

    @Test func testSoftDropManualScoresOnLock() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        #expect(tetris.score == 0)
        while tetris.current != nil {
            if tetris.softDrop(manual: true) {
                continue
            }
        }
        #expect(tetris.score > 0)
    }

    @Test func testLockAndSpawn() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        while tetris.current != nil {
            _ = tetris.softDrop(manual: false)
        }
        #expect(tetris.spawn())
        #expect(tetris.current != nil)
    }

    @Test func testGameOver() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: Array(repeating: .o, count: 100)))
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
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        tetris.clear(lines: 0..<0)
        #expect(tetris.score == 0)
        #expect(tetris.lines == 0)
    }

    @Test func testClearIncompleteLinesDoesNothing() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        tetris.clear(lines: 3..<4)
        #expect(tetris.score == 0)
        #expect(tetris.lines == 0)
    }

    @Test func testClearMoreThanFourLinesDoesNothing() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        tetris.clear(lines: 0..<5)
        #expect(tetris.score == 0)
        #expect(tetris.lines == 0)
        #expect(tetris.level == 0)
    }

    @Test func testClearOutOfBoundsLinesDoesNothing() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        tetris.clear(lines: -1..<0)
        tetris.clear(lines: Tetris.numberOfRows..<(Tetris.numberOfRows + 1))
        #expect(tetris.score == 0)
        #expect(tetris.lines == 0)
        #expect(tetris.level == 0)
    }

    @Test func testCollidesAtLeftWall() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        let piece = tetris.current
        for _ in 0..<Tetris.numberOfColumns where tetris.shift(.left) {
        }
        let moved = tetris.current
        #expect(piece != nil)
        #expect(moved != nil)
        #expect(piece?.position.column != moved?.position.column)
        #expect(!tetris.shift(.left))
    }

    @Test func testCollidesAtRightWall() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        let piece = tetris.current
        for _ in 0..<Tetris.numberOfColumns where tetris.shift(.right) { }
        let moved = tetris.current
        #expect(piece != nil)
        #expect(moved != nil)
        #expect(piece?.position.column != moved?.position.column)
        #expect(!tetris.shift(.right))
    }

    @Test func testRotationCannotSlideThroughLeftWall() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.l]))
        #expect(tetris.rotate(.clockwise))
        #expect(tetris.current?.rotation == 3)

        while tetris.shift(.left) { }

        #expect(tetris.current?.position.column == 1)
        #expect(tetris.current?.position.row == 19)
    }

    @Test func testRotationCannotSlideThroughRightWall() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.l]))
        #expect(tetris.rotate(.counterClockwise))
        #expect(tetris.current?.rotation == 1)

        while tetris.shift(.right) { }

        #expect(tetris.current?.position.column == 8)
        #expect(tetris.current?.position.row == 19)
    }

    @Test func testClearLinesClearsRowShiftsDownAndScores() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        // Played order from the stub is index1, index0, index2.
        // Two I pieces (1 cell tall) cover cols 0..7; an O at the far right covers cols 8..9.
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .i, .o]))
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
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: true, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: Array(repeating: .i, count: 10)))

        #expect(tetris.rotate(.counterClockwise))
        #expect(tetris.current?.rotation == 1)

        while tetris.shift(.left) { }
        let leftmostX = tetris.current?.position.column
        #expect(leftmostX != nil)

        #expect(tetris.rotate(.clockwise))
        #expect(tetris.current?.rotation == 0)
        #expect(tetris.current?.position.column == (leftmostX ?? 0) + 2)
    }

    @Test func testWallKickRotateAtRightWall() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: true, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: Array(repeating: .i, count: 10)))

        #expect(tetris.rotate(.counterClockwise))
        #expect(tetris.current?.rotation == 1)

        while tetris.shift(.right) {}
        let rightmostX = tetris.current?.position.column
        #expect(rightmostX != nil)

        #expect(tetris.rotate(.clockwise))
        #expect(tetris.current?.rotation == 0)
        #expect(tetris.current?.position.column == (rightmostX ?? 0) - 1)
    }

    @Test func testWallKickNotPossibleIfBlockedByOther() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: true, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.o, .o, .o, .o, .o, .i]))
        // build a tower from o 1 space from the left
        for _ in 0..<5 {
            #expect(tetris.shift(.left))
            tetris.hardDrop()
            #expect(tetris.spawn())
        }

        // drop a vertical the i inbetween the wall and the tower
        #expect(tetris.rotate(.counterClockwise))
        for _ in 0..<4 {
            #expect(tetris.shift(.left))
        }
        for _ in 0..<13 {
            #expect(tetris.softDrop(manual: true))
        }

        #expect(!tetris.rotate(.clockwise))
        #expect(!tetris.rotate(.counterClockwise))
    }

    @Test func testHardDropLocksAtBottomPieceAndScores() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.o]))
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
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.o]))
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
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.o, .i, .t]))
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
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.o]))
        while tetris.softDrop(manual: false) {
            #expect(tetris.score == 0)
        }
        #expect(tetris.score == 0)
    }

    @Test func testClearTwoLinesScoresAndDropsRows() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .i, .o, .i, .i, .i]))
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

        let scoreBefore = tetris.score
        tetris.clear(lines: 0..<2)

        #expect(tetris.score == scoreBefore + 100)
        #expect(tetris.lines == 2)
        #expect(tetris.level == 0)
        #expect(tetris.lowestCompletedLines == nil)
    }

    @Test func testClearThreeLinesUsesLevelMultiplier() async throws {
        let options = TetrisOptions(startingLevel: 1, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let shapes: [Tetromino.Shape] = [.o, .o, .o, .o, .o, .i, .i, .o]
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: shapes))

        // Fill rows 0 and 1 with O pieces in five two-column sections.
        for horizontalShift in [-4, -2, 0, 2, 4] {
            shift(horizontalShift, in: tetris)
            tetris.hardDrop()
            #expect(tetris.spawn())
        }

        // Two I pieces fill row 2 from the left; the O fills its right side.
        for _ in 0..<3 {
            #expect(tetris.shift(.left))
        }
        tetris.hardDrop()
        #expect(tetris.spawn())
        #expect(tetris.shift(.right))
        tetris.hardDrop()
        #expect(tetris.spawn())
        for _ in 0..<4 {
            #expect(tetris.shift(.right))
        }
        tetris.hardDrop()

        #expect(tetris.lowestCompletedLines == 0..<3)
        let scoreBefore = tetris.score
        tetris.clear(lines: 0..<3)

        #expect(tetris.score == scoreBefore + 600)
        #expect(tetris.lines == 3)
        #expect(tetris.level == 1)
    }

    @Test func testClearFourLinesUsesTetrisScore() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: Array(repeating: .o, count: 12)))
        let horizontalShifts = [-4, -2, 0, 2, 4]

        // Stack two rows of O pieces twice, creating four completed rows.
        var dropped = 0
        for _ in 0..<2 {
            for horizontalShift in horizontalShifts {
                shift(horizontalShift, in: tetris)
                tetris.hardDrop()
                dropped += 1
                if dropped < 10 {
                    #expect(tetris.spawn())
                }
            }
        }

        #expect(tetris.lowestCompletedLines == 0..<4)
        let scoreBefore = tetris.score
        tetris.clear(lines: 0..<4)

        #expect(tetris.score == scoreBefore + 1200)
        #expect(tetris.lines == 4)
        #expect(tetris.level == 0)
    }

    @Test func testClearTenLinesAdvancesLevel() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: Array(repeating: .o, count: 30)))
        let horizontalShifts = [-4, -2, 0, 2, 4]

        // Clear five sets of two rows to reach the next level.
        var dropped = 0
        for _ in 0..<5 {
            for horizontalShift in horizontalShifts {
                shift(horizontalShift, in: tetris)
                tetris.hardDrop()
                dropped += 1
                if dropped % 5 != 0 {
                    #expect(tetris.spawn())
                }
            }

            let scoreBefore = tetris.score
            tetris.clear(lines: 0..<2)
            #expect(tetris.score == scoreBefore + 100)
            #expect(tetris.lines == (dropped / 5) * 2)
            if dropped < 25 {
                #expect(tetris.spawn())
            }
        }

        #expect(tetris.lines == 10)
        #expect(tetris.level == 1)
    }

    @Test func testBoardReflectsAllLockedPieces() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.o, .o, .o]))
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

    @Test func testFullGameIntegrationWithLineClear() async throws {
        // Fill a single complete row using I (left + right) and O (far right),
        // clear it, then continue dropping pieces until game over.
        // This exercises: line completion, scoring, spawn/drop cycle, game over.

        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let shapes: [Tetromino.Shape] = Array(repeating: [.i, .i, .o], count: 15).flatMap { $0 }
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: shapes))
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

    @Test func testFullGameIntegrationStackToGameOver() async throws {
        // Stack O pieces in the same column until the board fills up.
        // O at (5,19) covers cols 4..5 and rows 18..19.
        // Hard drop lands the first O at y=1 (rows 0..1).
        // 10 O pieces fill 10×2=20 rows → 11th spawn fails.
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let shapes: [Tetromino.Shape] = Array(repeating: .o, count: 20)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: shapes))

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
