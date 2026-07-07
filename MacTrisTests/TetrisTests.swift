//
//  TetrisTests.swift
//  MacTrisTests
//
//  Created by Sebastian Boettcher on 07.07.26.
//

import Testing
@testable import MacTris

struct TetrisTests {
    private func makeTetris(startingLevel: Int = 0, shapes: [Tetromino.Shape] = [.i, .o, .t, .s, .z, .j, .l]) -> Tetris {
        Tetris(random: StubTetrominoShapeGenerator(shapes: shapes), startingLevel: startingLevel)
    }

    @Test func testInitialState() async throws {
        let tetris = makeTetris()
        #expect(tetris.score == 0)
        #expect(tetris.lines == 0)
        #expect(tetris.level == 0)
        #expect(tetris.duration == 0)
    }

    @Test func testBoardSize() async throws {
        let tetris = makeTetris()
        let board = tetris.board
        #expect(board.count == 10)
        #expect(board[0].count == 20)
    }

    @Test func testSpawnCreatesCurrentPiece() async throws {
        let tetris = makeTetris()
        #expect(tetris.current != nil)
    }

    @Test func testSpawnPosition() async throws {
        let tetris = makeTetris()
        #expect(tetris.spawnPosition.0 == 5)
        #expect(tetris.spawnPosition.1 == 19)
    }

    @Test func testBoardShowsCurrentPiece() async throws {
        let tetris = makeTetris()
        let board = tetris.board
        if let current = tetris.current {
            for (col, row) in current.points {
                if row >= 0, row < 20, col >= 0, col < 10 {
                    #expect(board[col][row] == current.shape)
                }
            }
        }
    }

    @Test func testShiftLeft() async throws {
        let tetris = makeTetris()
        let before = tetris.current?.position.x
        let result = tetris.shiftLeft()
        #expect(result)
        #expect(tetris.current?.position.x == (before ?? 0) - 1)
    }

    @Test func testShiftRight() async throws {
        let tetris = makeTetris()
        let before = tetris.current?.position.x
        let result = tetris.shiftRight()
        #expect(result)
        #expect(tetris.current?.position.x == (before ?? 0) + 1)
    }

    @Test func testRotateClockwise() async throws {
        let tetris = makeTetris(shapes: [.t])
        let before = tetris.current?.rotation
        let result = tetris.rotateClockwise()
        #expect(result)
        let expected = ((before ?? 0) + Tetromino.Shape.t.points.count - 1) % Tetromino.Shape.t.points.count
        #expect(tetris.current?.rotation == expected)
    }

    @Test func testRotateCounterClockwise() async throws {
        let tetris = makeTetris(shapes: [.t])
        let before = tetris.current?.rotation
        let result = tetris.rotateCounterClockwise()
        #expect(result)
        let expected = ((before ?? 0) + 1) % Tetromino.Shape.t.points.count
        #expect(tetris.current?.rotation == expected)
    }

    @Test func testSoftDropManual() async throws {
        let tetris = makeTetris()
        let before = tetris.current?.position.y
        let result = tetris.softDrop(manual: true)
        #expect(result)
        #expect(tetris.current?.position.y == (before ?? 0) - 1)
    }

    @Test func testSoftDropAuto() async throws {
        let tetris = makeTetris()
        let before = tetris.current?.position.y
        let result = tetris.softDrop(manual: false)
        #expect(result)
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
        let spawned = tetris.spawn()
        #expect(spawned)
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

    @Test func testAddDuration() async throws {
        let tetris = makeTetris()
        tetris.addDuration(5.5)
        #expect(tetris.duration == 5.5)
        tetris.addDuration(2.5)
        #expect(tetris.duration == 8.0)
    }

    @Test func testLowestCompletedLinesNoLines() async throws {
        let tetris = makeTetris()
        #expect(tetris.lowestCompletedLines == nil)
    }

    @Test func testScoreNoLines() async throws {
        let tetris = makeTetris()
        tetris.score(lines: 0..<0)
        #expect(tetris.score == 0)
        #expect(tetris.lines == 0)
    }

    @Test func testScoreOneLine() async throws {
        let tetris = makeTetris(startingLevel: 0)
        tetris.score(lines: 3..<4)
        #expect(tetris.score == 40)
        #expect(tetris.lines == 1)
    }

    @Test func testScoreTwoLines() async throws {
        let tetris = makeTetris(startingLevel: 0)
        tetris.score(lines: 3..<5)
        #expect(tetris.score == 100)
        #expect(tetris.lines == 2)
    }

    @Test func testScoreThreeLines() async throws {
        let tetris = makeTetris(startingLevel: 0)
        tetris.score(lines: 2..<5)
        #expect(tetris.score == 300)
        #expect(tetris.lines == 3)
    }

    @Test func testScoreFourLines() async throws {
        let tetris = makeTetris(startingLevel: 0)
        tetris.score(lines: 2..<6)
        #expect(tetris.score == 1200)
        #expect(tetris.lines == 4)
    }

    @Test func testScoreWithLevel() async throws {
        let tetris = makeTetris(startingLevel: 5)
        tetris.score(lines: 0..<1)
        #expect(tetris.score == 40 * (5 + 1))
    }

    @Test func testLevelUp() async throws {
        let tetris = makeTetris(startingLevel: 0)
        #expect(tetris.level == 0)
        for _ in 0..<10 {
            tetris.score(lines: 0..<1)
        }
        #expect(tetris.level >= 1)
    }

    @Test func testSpawnSetsNext() async throws {
        let tetris = makeTetris()
        let firstNext = tetris.next
        while tetris.current != nil {
            _ = tetris.softDrop(manual: false)
        }
        _ = tetris.spawn()
        let secondNext = tetris.next
        #expect(firstNext.shape != secondNext.shape)
    }

    @Test func testCollidesAtWall() async throws {
        let tetris = makeTetris()
        let piece = tetris.current!
        for _ in 0..<20 where tetris.shiftLeft() {
            // empty
        }
        let farLeft = tetris.current!
        #expect(piece.position.x != farLeft.position.x)
    }

    @Test func testDissolveEmptyRangeDoesNotScore() async throws {
        let tetris = makeTetris()
        let result = tetris.dissolve(completed: 0..<0)
        #expect(result)
        #expect(tetris.score == 0)
        #expect(tetris.lines == 0)
    }
}
