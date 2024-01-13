//
//  Tetris.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 12.01.24.
//

import Foundation
import OSLog

class Tetris {

    static let numberOfColumns: Int = 10
    static let numberOfRows: Int = 20
    static let spawnPosition: (Int, Int) = (Tetris.numberOfColumns / 2, Tetris.numberOfRows - 1)

    let random: RandomTetrominoShapeGenerator

    private var data: [[Tetromino.Shape?]]
    private var dropCounter: Int = 0
    private var linesToNextLevel: Int

    private (set) var lines: Int = 0
    private (set) var level: Int = 0
    private (set) var score: Int = 0
    private (set) var duration: TimeInterval = 0
    private (set) var next: Tetromino
    private (set) var current: Tetromino?

    init (random: RandomTetrominoShapeGenerator, startingLevel: Int) {
        self.random = random
        self.level = startingLevel
        self.linesToNextLevel = min(self.level * 10 + 10, max(100, self.level * 10 - 50))
        self.next = Tetromino(shape: self.random.next())
        self.current = Tetromino(shape: self.random.next(), rotation: 0, position: Tetris.spawnPosition)
        self.data = Array(repeating: Array(repeating: nil, count: Tetris.numberOfRows), count: Tetris.numberOfColumns)

        Logger.game.info("Starting level \(self.level), lines to next level \(self.linesToNextLevel)")
    }

    var board: [[Tetromino.Shape?]] {

        var result = self.data

        if let tetromino = self.current {
            for (column, row) in tetromino.points {
                if row >= 0 && column >= 0 && row < Tetris.numberOfRows && column < Tetris.numberOfColumns {
                    result[column][row] = tetromino.shape
                }
            }
        }

        return result
    }

    var lowestCompletedLines: Range<Int>? {
        var start = 0
        while !self.isComplete(row: start) {
            start += 1
            if start == Tetris.numberOfRows {
                return nil
            }
        }

        var end = start
        while self.isComplete(row: end) {
            end += 1
            if end >= Tetris.numberOfRows {
                return Range(uncheckedBounds: (start, Tetris.numberOfRows - 1))
            }
        }

        return Range(uncheckedBounds: (start, end))
    }

    private subscript (column: Int, row: Int) -> Tetromino.Shape? {
        get {
            if column >= 0 && column < Tetris.numberOfColumns && row >= 0 && row < Tetris.numberOfRows {
                return self.data[column][row]
            }
            return nil
        }
        set {
            if column >= 0 && column < Tetris.numberOfColumns && row >= 0 && row < Tetris.numberOfRows {
                self.data[column][row] = newValue
            }
        }
    }

    func addDuration (_ elapsed: TimeInterval) {
        self.duration += elapsed
    }

    func dissolve (completed: Range<Int>) -> Bool {
        var done = true

        for row in completed {
            for column in (0..<Tetris.numberOfColumns / 2).reversed() where self[column, row] != nil {
                self[column, row] = nil
                done = false
                break
            }
            for column in Tetris.numberOfColumns / 2..<Tetris.numberOfColumns where self[column, row] != nil {
                self[column, row] = nil
                done = false
                break
            }
        }

        if done {
            self.drop(rows: completed)
            self.score(lines: completed)
        }

        return done
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
        self.current = self.next.with(position: Tetris.spawnPosition)
        self.next = Tetromino(shape: self.random.next())

        if self.collides(tetronimo: self.current!) {
            Logger.game.info("Stacked out with \(self.score) points!")
            self.current = nil
            return false
        }

        return true
    }

    func shiftLeft () -> Bool {
        if let current = self.current, !self.collides(tetronimo: current.shiftedLeft()) {
            self.current = current.shiftedLeft()
            return true
        }
        return false
    }

    func shiftRight () -> Bool {
        if let current = self.current, !self.collides(tetronimo: current.shiftedRight()) {
            self.current = current.shiftedRight()
            return true
        }
        return false
    }

    func softDrop (manual: Bool) -> Bool {
        if let current = self.current, !self.collides(tetronimo: current.dropped()) {
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

        self.lock(tetronimo: self.current)
        self.current = nil
        self.dropCounter = 0

        return false
    }

    func rotateCounterClockwise () -> Bool {
        if let current = self.current, !self.collides(tetronimo: current.rotatedCounterClockwise()) {
            self.current = current.rotatedCounterClockwise()
            return true
        }
        return false
    }

    func rotateClockwise () -> Bool {
        if let current = self.current, !self.collides(tetronimo: current.rotatedClockwise()) {
            self.current = current.rotatedClockwise()
            return true
        }
        return false
    }

    private func drop (rows: Range<Int>) {
        for row in rows.upperBound..<Tetris.numberOfRows {
            let target = row - (rows.upperBound - rows.lowerBound)
            for column in 0..<Tetris.numberOfColumns {
                self[column, target] = self[column, row]
            }

            for column in 0..<Tetris.numberOfColumns {
                self[column, row] = nil
            }
        }
    }

    private func lock (tetronimo: Tetromino?) {
        guard let tetronimo = tetronimo else {
            return
        }

        for (column, row) in tetronimo.points {
            if row >= 0 && column >= 0 && row < Tetris.numberOfRows && column < Tetris.numberOfColumns {
                self[column, row] = tetronimo.shape
            }
        }
    }

    private func isComplete (row: Int) -> Bool {
        for column in 0..<Tetris.numberOfColumns where self[column, row] == nil {
            return false
        }
        return true
    }

    private func collides (tetronimo: Tetromino) -> Bool {
        for (column, row) in tetronimo.points {
            if row > Tetris.numberOfRows {
                continue
            }
            if row < 0 || column < 0 || column >= Tetris.numberOfColumns {
                return true
            }
            if self[column, row] != nil {
                return true
            }
        }
        return false
    }
}
