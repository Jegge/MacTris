//
//  Tetris.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 12.01.24.
//

import Foundation
import OSLog

class Tetris {

    let random: RandomTetrominoShapeGenerator

    private var board: Board = Board()
    private (set) var lines: Int = 0
    private (set) var level: Int = 0
    private (set) var score: Int = 0
    private (set) var duration: TimeInterval = 0

    private (set) var next: Tetromino
    private (set) var current: Tetromino?

    private var dropCounter: Int = 0
    private var linesToNextLevel: Int

    init (random: RandomTetrominoShapeGenerator, startingLevel: Int) {
        self.random = random
        self.level = startingLevel
        self.linesToNextLevel = min(self.level * 10 + 10, max(100, self.level * 10 - 50))
        self.next = Tetromino(shape: self.random.next())
        self.current = Tetromino(shape: self.random.next(), rotation: 0, position: self.board.spawnPosition())

        Logger.game.info("Starting level \(self.level), lines to next level \(self.linesToNextLevel)")
    }

    var boardWithCurrent: Board {
        return self.board.with(tetronimo: self.current)
    }

    var lowestCompletedLines: Range<Int>? {
        return self.board.lowestCompletedLines()
    }

    func addDuration (_ elapsed: TimeInterval) {
        self.duration += elapsed
    }

    func dissolve(completed: Range<Int>) -> Bool {
        if self.board.dissolve(rows: completed) {
            self.board.drop(rows: completed)
            self.score(lines: completed)
            return true
        }
        return false
    }

    func score (lines: Range<Int>) {
        let baseScorePerLines = [40, 100, 300, 1200]
        let linesScore = baseScorePerLines[lines.count - 1] * (self.level + 1)

        self.score += linesScore
        self.lines += lines.count

        Logger.game.info("Completing \(lines.count) line(s) at level \(self.level) gives \(linesScore) points: total \(self.lines) lines, \(self.score) points. Next level in \(self.linesToNextLevel) lines.")

        self.linesToNextLevel -= lines.count

        if self.linesToNextLevel <= 0 {
            self.level += 1
            self.linesToNextLevel += 10
            Logger.game.info("Reached level \(self.level), lines to next level \(self.linesToNextLevel)")
        }
    }

    func spawn () -> Bool {
        self.current = self.next.with(position: self.board.spawnPosition())
        self.next = Tetromino(shape: self.random.next())

        if self.board.collides(tetronimo: self.current!) {
            Logger.game.info("Stacked out with \(self.score) points!")
            self.current = nil
            return false
        }

        return true
    }

    func shiftLeft () -> Bool {
        if let current = self.current, !self.board.collides(tetronimo: current.shiftedLeft()) {
            self.current = current.shiftedLeft()
            return true
        }
        return false
    }

    func shiftRight () -> Bool {
        if let current = self.current, !self.board.collides(tetronimo: current.shiftedRight()) {
            self.current = current.shiftedRight()
            return true
        }
        return false
    }

    func softDrop (manual: Bool) -> Bool {
        if let current = self.current, !self.board.collides(tetronimo: current.dropped()) {
            self.current = current.dropped()
            if manual {
                self.dropCounter += 1
            }
            return true
        }

        if self.dropCounter > 0 {
            self.score += self.dropCounter
            Logger.game.info("Dropping tetromino gives \(self.dropCounter) points: total \(self.score) points.")
        }

        self.board.lock(tetronimo: self.current)
        self.current = nil
        self.dropCounter = 0

        return false
    }

    func rotateLeft () -> Bool {
        if let current = self.current, !self.board.collides(tetronimo: current.rotatedLeft()) {
            self.current = current.rotatedLeft()
            return true
        }
        return false
    }

    func rotateRight () -> Bool {
        if let current = self.current, !self.board.collides(tetronimo: current.rotatedRight()) {
            self.current = current.rotatedRight()
            return true
        }
        return false
    }
}
