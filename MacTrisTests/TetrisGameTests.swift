//
//  TetrisGameTests.swift
//  MacTrisTests
//
//  Created by Sebastian Boettcher on 20.07.26.
//

import Foundation
import Testing
@testable import MacTris

struct TetrisGameTests {

    private class GameTime {
        var time: TimeInterval = 0
        let step: TimeInterval = 1.0 / 60.0
        private let roundingTolerance: TimeInterval = 1e-9

        func advance(_ game: TetrisGame, frames: Int = 1) {
            if time == 0 {
                time = step
                game.update(time)
            }
            for _ in 0..<frames {
                // Keep each synthetic delta just above one fixed frame despite floating-point rounding.
                time += step + roundingTolerance
                game.update(time)
            }
        }
    }

    /// Drop the current piece via hard drop, then advance enough frames for the
    /// next piece to spawn (gravity countdown + one extra frame for processFrame).
    private func hardDropAndWait(_ game: TetrisGame, time: GameTime, gravityFrames: Int = 49) {
        game.input(down: .hardDrop)
        time.advance(game, frames: 1)
        game.inputClear()
        time.advance(game, frames: gravityFrames)
    }

    /// Shift the current piece to `targetColumn` (relative to spawn at column 5)
    /// and hard-drop it, then wait for the next piece to spawn.
    private func shiftAndDrop(_ game: TetrisGame, time: GameTime, targetColumn: Int) {
        shiftToTarget(game, time: time, targetColumn: targetColumn)
        hardDropAndWait(game, time: time)
    }

    private func shiftToTarget(_ game: TetrisGame, time: GameTime, targetColumn: Int) {
        let shifts = targetColumn - Tetris.spawnPosition.column
        for _ in 0..<abs(shifts) {
            game.input(down: shifts > 0 ? .shiftRight : .shiftLeft)
            time.advance(game, frames: 1)
            game.inputClear()
        }
        // Wait for the key-repeat timer to expire so the hard-drop event is processed.
        time.advance(game, frames: 7)
    }

    private func waitUntil(_ game: TetrisGame, time: GameTime, condition: () -> Bool) {
        for _ in 0..<2_000 where !condition() {
            time.advance(game)
        }
    }

    @Test func testInitialState() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        let stabilizer = FrameRateStabilizer(desiredFps: 60)
        let effects = MockEffectDelegate()
        let game = TetrisGame(tetris: tetris, stabilizer: stabilizer, effects: effects)
        #expect(game.tetris.score == 0)
        #expect(game.tetris.lines == 0)
        #expect(game.tetris.level == 0)
        #expect(game.tetris.current != nil)
        #expect(game.grid.count == Tetris.numberOfColumns)
        #expect(game.grid[0].count == Tetris.numberOfRows)
        #expect(game.duration == 0)
    }

    @Test func testInputUpRemovesEvent() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        let stabilizer = FrameRateStabilizer(desiredFps: 60)
        let effects = MockEffectDelegate()
        let game = TetrisGame(tetris: tetris, stabilizer: stabilizer, effects: effects)
        let time = GameTime()
        game.input(down: .shiftLeft)
        game.input(up: .shiftLeft)
        time.advance(game, frames: 10)
        #expect(game.tetris.current?.position.column == 5)
    }

    @Test func testInputClearRemovesAllEvents() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        let stabilizer = FrameRateStabilizer(desiredFps: 60)
        let effects = MockEffectDelegate()
        let game = TetrisGame(tetris: tetris, stabilizer: stabilizer, effects: effects)
        let time = GameTime()
        game.input(down: .shiftLeft)
        game.input(down: .shiftRight)
        game.input(down: .softDrop)
        game.inputClear()
        time.advance(game, frames: 10)
        #expect(game.tetris.current?.position.column == 5)
    }

    @Test func testGravityPullsPieceDown() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.o]))
        let stabilizer = FrameRateStabilizer(desiredFps: 60)
        let effects = MockEffectDelegate()
        let game = TetrisGame(tetris: tetris, stabilizer: stabilizer, effects: effects)
        let time = GameTime()
        let initialRow = game.tetris.current?.position.row
        time.advance(game, frames: 49)
        let newRow = game.tetris.current?.position.row
        #expect(newRow == (initialRow ?? 0) - 1)
    }

    @Test func testGravityDoesNotFallBeforeInterval() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.o]))
        let stabilizer = FrameRateStabilizer(desiredFps: 60)
        let effects = MockEffectDelegate()
        let game = TetrisGame(tetris: tetris, stabilizer: stabilizer, effects: effects)
        let time = GameTime()
        let initialRow = game.tetris.current?.position.row
        time.advance(game, frames: 48)
        #expect(game.tetris.current?.position.row == initialRow)
    }

    @Test func testShiftLeftInput() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        let stabilizer = FrameRateStabilizer(desiredFps: 60)
        let effects = MockEffectDelegate()
        let game = TetrisGame(tetris: tetris, stabilizer: stabilizer, effects: effects)
        let time = GameTime()
        let col = game.tetris.current?.position.column
        game.input(down: .shiftLeft)
        time.advance(game, frames: 1)
        #expect(game.tetris.current?.position.column == (col ?? 0) - 1)
        #expect(effects.playedEffects.last == .shift)
    }

    @Test func testShiftRightInput() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        let stabilizer = FrameRateStabilizer(desiredFps: 60)
        let effects = MockEffectDelegate()
        let game = TetrisGame(tetris: tetris, stabilizer: stabilizer, effects: effects)
        let time = GameTime()
        let col = game.tetris.current?.position.column
        game.input(down: .shiftRight)
        time.advance(game, frames: 1)
        #expect(game.tetris.current?.position.column == (col ?? 0) + 1)
        #expect(effects.playedEffects.last == .shift)
    }

    @Test func testShiftAtWallNoEffect() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        let stabilizer = FrameRateStabilizer(desiredFps: 60)
        let effects = MockEffectDelegate()
        let game = TetrisGame(tetris: tetris, stabilizer: stabilizer, effects: effects)
        let time = GameTime()
        for _ in 0..<Tetris.numberOfColumns where game.tetris.shift(.left) {}
        game.inputClear()
        effects.playedEffects.removeAll()
        game.input(down: .shiftLeft)
        time.advance(game, frames: 1)
        #expect(!effects.playedEffects.contains(.shift))
    }

    @Test func testRotateClockwiseInput() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.t]))
        let stabilizer = FrameRateStabilizer(desiredFps: 60)
        let effects = MockEffectDelegate()
        let game = TetrisGame(tetris: tetris, stabilizer: stabilizer, effects: effects)
        let time = GameTime()
        game.input(down: .rotateClockwise)
        time.advance(game, frames: 1)
        #expect(effects.playedEffects.last == .rotate)
    }

    @Test func testRotateCounterClockwiseInput() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.t]))
        let stabilizer = FrameRateStabilizer(desiredFps: 60)
        let effects = MockEffectDelegate()
        let game = TetrisGame(tetris: tetris, stabilizer: stabilizer, effects: effects)
        let time = GameTime()
        game.input(down: .rotateCounterClockwise)
        time.advance(game, frames: 1)
        #expect(effects.playedEffects.last == .rotate)
    }

    @Test func testRotateRemovedAfterProcessing() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.t]))
        let stabilizer = FrameRateStabilizer(desiredFps: 60)
        let effects = MockEffectDelegate()
        let game = TetrisGame(tetris: tetris, stabilizer: stabilizer, effects: effects)
        let time = GameTime()
        game.input(down: .rotateClockwise)
        time.advance(game, frames: 1)
        effects.playedEffects.removeAll()
        time.advance(game, frames: 5)
        #expect(!effects.playedEffects.contains(.rotate))
    }

    @Test func testSoftDropInput() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: true)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        let stabilizer = FrameRateStabilizer(desiredFps: 60)
        let effects = MockEffectDelegate()
        let game = TetrisGame(tetris: tetris, stabilizer: stabilizer, effects: effects)
        let time = GameTime()
        let row = game.tetris.current?.position.row
        game.input(down: .softDrop)
        time.advance(game, frames: 1)
        #expect(game.tetris.current?.position.row == (row ?? 0) - 1)
    }

    @Test func testHardDropInputTriggersShakeAndLock() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: true)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        let stabilizer = FrameRateStabilizer(desiredFps: 60)
        let effects = MockEffectDelegate()
        let game = TetrisGame(tetris: tetris, stabilizer: stabilizer, effects: effects)
        let time = GameTime()
        game.input(down: .hardDrop)
        time.advance(game, frames: 1)
        #expect(effects.shakeBoardCount == 1)
        #expect(effects.playedEffects.contains(.lock))
        #expect(game.tetris.current == nil)
    }

    @Test func testHardDropWithoutHardDropOption() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        let stabilizer = FrameRateStabilizer(desiredFps: 60)
        let effects = MockEffectDelegate()
        let game = TetrisGame(tetris: tetris, stabilizer: stabilizer, effects: effects)
        let time = GameTime()
        let row = game.tetris.current?.position.row
        game.input(down: .hardDrop)
        time.advance(game, frames: 1)
        #expect(effects.shakeBoardCount == 0)
        #expect(game.tetris.current?.position.row == row)
    }

    @Test func testHardDropRequiresRepress() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: true)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        let stabilizer = FrameRateStabilizer(desiredFps: 60)
        let effects = MockEffectDelegate()
        let game = TetrisGame(tetris: tetris, stabilizer: stabilizer, effects: effects)
        let time = GameTime()
        game.input(down: .hardDrop)
        time.advance(game, frames: 1)
        #expect(effects.shakeBoardCount == 1)
        #expect(game.tetris.current == nil)
        time.advance(game, frames: 49)
        #expect(game.tetris.current != nil)
        time.advance(game, frames: 1)
        #expect(effects.shakeBoardCount == 1)
    }

    @Test func testDurationMatchesFrameCount() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        let stabilizer = FrameRateStabilizer(desiredFps: 60)
        let effects = MockEffectDelegate()
        let game = TetrisGame(tetris: tetris, stabilizer: stabilizer, effects: effects)
        let time = GameTime()
        let frames = 120
        time.advance(game, frames: frames)
        let expected = (1.0 / 60.0) * Double(frames)
        #expect(abs(game.duration - expected) < 0.02)
    }

    @Test func testLockSoundOnGravityLock() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.o]))
        let stabilizer = FrameRateStabilizer(desiredFps: 60)
        let effects = MockEffectDelegate()
        let game = TetrisGame(tetris: tetris, stabilizer: stabilizer, effects: effects)
        let time = GameTime()
        for _ in 0..<20 {
            game.input(down: .softDrop)
            time.advance(game, frames: 1)
        }
        time.advance(game, frames: 100)
        #expect(effects.playedEffects.contains(.lock))
    }

    @Test func testDropTakesPriorityOverShift() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: true)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        let stabilizer = FrameRateStabilizer(desiredFps: 60)
        let effects = MockEffectDelegate()
        let game = TetrisGame(tetris: tetris, stabilizer: stabilizer, effects: effects)
        let time = GameTime()
        game.input(down: .shiftLeft)
        game.input(down: .hardDrop)
        time.advance(game, frames: 1)
        #expect(effects.shakeBoardCount == 1)
        #expect(game.tetris.current == nil)
    }

    @Test func testShiftTakesPriorityOverRotate() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: true)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        let stabilizer = FrameRateStabilizer(desiredFps: 60)
        let effects = MockEffectDelegate()
        let game = TetrisGame(tetris: tetris, stabilizer: stabilizer, effects: effects)
        let time = GameTime()
        let col = game.tetris.current?.position.column
        game.input(down: .shiftLeft)
        game.input(down: .rotateClockwise)
        time.advance(game, frames: 1)
        #expect(game.tetris.current?.position.column == (col ?? 0) - 1)
    }

    @Test func testKeyRepeatForShift() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: true)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        let stabilizer = FrameRateStabilizer(desiredFps: 60)
        let effects = MockEffectDelegate()
        let game = TetrisGame(tetris: tetris, stabilizer: stabilizer, effects: effects)
        let time = GameTime()
        game.input(down: .shiftLeft)
        time.advance(game, frames: 1)
        let col1 = game.tetris.current?.position.column
        time.advance(game, frames: 7)
        let col2 = game.tetris.current?.position.column
        #expect((col2 ?? 0) < (col1 ?? 0))
    }

    @Test func testSoftDropRepeats() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: true)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        let stabilizer = FrameRateStabilizer(desiredFps: 60)
        let effects = MockEffectDelegate()
        let game = TetrisGame(tetris: tetris, stabilizer: stabilizer, effects: effects)
        let time = GameTime()
        game.input(down: .softDrop)
        time.advance(game, frames: 1)
        let row1 = game.tetris.current?.position.row
        time.advance(game, frames: 3)
        let row2 = game.tetris.current?.position.row
        #expect((row2 ?? 0) < (row1 ?? 0))
    }

    @Test func testGridReturnsRawBoardWhenNoAnimation() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        let stabilizer = FrameRateStabilizer(desiredFps: 60)
        let effects = MockEffectDelegate()
        let game = TetrisGame(tetris: tetris, stabilizer: stabilizer, effects: effects)
        #expect(game.grid == game.tetris.grid)
    }

    @Test func testPieceLockAndSpawnCycle() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: true)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.i, .o, .t, .s, .z, .j, .l]))
        let stabilizer = FrameRateStabilizer(desiredFps: 60)
        let effects = MockEffectDelegate()
        let game = TetrisGame(tetris: tetris, stabilizer: stabilizer, effects: effects)
        let time = GameTime()
        #expect(game.tetris.current?.shape == .i)
        hardDropAndWait(game, time: time)
        #expect(game.tetris.current != nil)
        #expect(effects.playedEffects.contains(.lock))
    }

    @Test func testLineClearing() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: true)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.o, .o, .o, .o, .o, .o]))
        let stabilizer = FrameRateStabilizer(desiredFps: 60)
        let effects = MockEffectDelegate()
        let game = TetrisGame(tetris: tetris, stabilizer: stabilizer, effects: effects)
        let time = GameTime()

        // Place five O-pieces across the board to fill rows 0 and 1:
        //   columns 0-1, 2-3, 4-5, 6-7, 8-9
        shiftAndDrop(game, time: time, targetColumn: 1)
        shiftAndDrop(game, time: time, targetColumn: 3)
        shiftAndDrop(game, time: time, targetColumn: 5)
        shiftAndDrop(game, time: time, targetColumn: 7)
        shiftAndDrop(game, time: time, targetColumn: 9)

        // Two complete lines should have been cleared.
        #expect(game.tetris.lines == 2)
        #expect(game.tetris.score > 0)
        #expect(effects.playedEffects.contains(.success))

        // The rendered grid retains the completed lines while the dissolve animation is active.
        let animationGrid = game.grid
        #expect(animationGrid != game.tetris.grid)
        #expect(animationGrid[0][0] == .o)
        #expect(game.tetris.grid[0][0] == nil)

        // After the initial no-op step and animation delay, the center tiles dissolve first.
        time.advance(game, frames: TetrisOptions.Frames.animation * 2 + 2)
        #expect(game.grid[4][0] == nil)
        #expect(game.grid[3][0] == .o)
    }

    @Test func testGravityLineClearDissolvesAndSpawnsNextPiece() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.o]))
        let stabilizer = FrameRateStabilizer(desiredFps: 60)
        let effects = MockEffectDelegate()
        let game = TetrisGame(tetris: tetris, stabilizer: stabilizer, effects: effects)
        let time = GameTime()
        let targetColumns = [1, 3, 5, 7, 9]

        for (index, targetColumn) in targetColumns.enumerated() {
            shiftToTarget(game, time: time, targetColumn: targetColumn)
            waitUntil(game, time: time) { game.tetris.current == nil }
            #expect(game.tetris.current == nil)

            if index < targetColumns.count - 1 {
                waitUntil(game, time: time) { game.tetris.current != nil }
                #expect(game.tetris.current != nil)
            }
        }

        // The fifth piece completes two lines; wait for the dissolve and spawn delay.
        waitUntil(game, time: time) { game.tetris.lines == 2 }
        waitUntil(game, time: time) { game.tetris.current != nil }

        #expect(game.tetris.lines == 2)
        #expect(game.tetris.current?.shape == .o)
        #expect(effects.playedEffects.contains(.success))
    }

    @Test func testFullGameStacksOutAndPlaysGameOverAnimation() async throws {
        let options = TetrisOptions(startingLevel: 0, autoShift: .fast, randomGeneratorMode: .nes, wallKick: false, hardDrop: true)
        let tetris = Tetris(options: options, random: StubTetrominoShapeGenerator(shapes: [.o]))
        let stabilizer = FrameRateStabilizer(desiredFps: 60)
        let effects = MockEffectDelegate()
        let game = TetrisGame(tetris: tetris, stabilizer: stabilizer, effects: effects)
        let time = GameTime()

        // Stack ten O-pieces in the same columns until the next piece cannot spawn.
        for _ in 0..<10 {
            hardDropAndWait(game, time: time)
        }

        #expect(effects.playedEffects.contains(.lock))
        #expect(effects.playedEffects.contains(.gameOver))
        #expect(effects.gameOverCount == 0)

        let gridBeforeAnimation = game.grid
        time.advance(game, frames: TetrisOptions.Frames.animation + 1)

        // Stack-out fills the rendered grid without changing the underlying board.
        #expect(game.grid != gridBeforeAnimation)
        #expect(game.grid != game.tetris.grid)

        for _ in 0..<20 where effects.gameOverCount == 0 {
            time.advance(game, frames: TetrisOptions.Frames.animation + 1)
        }
        #expect(effects.gameOverCount == 1)
    }
}
