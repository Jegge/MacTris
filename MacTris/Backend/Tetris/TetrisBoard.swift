//
//  TetrisBoard.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 12.01.24.
//

import OSLog

class TetrisBoard {

    static let maxLevel: Int = 19

    private struct CollisionFlags: OptionSet {
        let rawValue: Int
        static let leftWall = CollisionFlags(rawValue: 1 << 0)
        static let rightWall = CollisionFlags(rawValue: 1 << 1)
        static let floor = CollisionFlags(rawValue: 1 << 2)
        static let piece = CollisionFlags(rawValue: 1 << 3)
        static let all = CollisionFlags([.leftWall, .rightWall, .floor, .piece])
    }

    static let numberOfColumns: Int = 10
    static let numberOfRows: Int = 20

    let random: RandomTetrominoShapeGenerator

    private var data: [[Tetromino.Shape?]]
    private var dropCounter: Int = 0
    private var linesToNextLevel: Int
    private var enableWallKick: Bool

    private(set) var lines: Int = 0
    private(set) var level: Int = 0
    private(set) var score: Int = 0
    private(set) var duration: TimeInterval = 0
    private(set) var next: Tetromino
    private(set) var current: Tetromino?

    private(set) var statistics: Statistics = Statistics()

    init (random: RandomTetrominoShapeGenerator, startingLevel: Int, wallKick: Bool) {
        self.random = random
        self.level = startingLevel
        self.enableWallKick = wallKick
        self.linesToNextLevel = min(startingLevel * 10 + 10, max(100, startingLevel * 10 - 50))
        self.next = Tetromino(shape: self.random.next())
        self.data = Array(repeating: Array(repeating: nil, count: TetrisBoard.numberOfRows), count: TetrisBoard.numberOfColumns)

        let current = Tetromino(shape: self.random.next(), rotation: 0, position: self.spawnPosition)
        self.statistics.add(current.shape)
        self.current = current

        Logger.game.info("Starting level \(self.level), lines to next level \(self.linesToNextLevel)")
    }

    convenience init (options: TetrisOptions) {
        Logger.game.info("Begin game with \(options, privacy: .public)")
        self.init(random: options.randomGeneratorMode.createGenerator(), startingLevel: options.startingLevel, wallKick: options.wallKick)
    }

    var grid: [[Tetromino.Shape?]] {
        var result = self.data

        if let tetromino = self.current {
            for (column, row) in tetromino.points {
                if row >= 0 && column >= 0 && row < TetrisBoard.numberOfRows && column < TetrisBoard.numberOfColumns {
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
            if start == TetrisBoard.numberOfRows {
                return nil
            }
        }

        var end = start
        while self.isComplete(row: end) {
            end += 1
            if end >= TetrisBoard.numberOfRows {
                return Range(uncheckedBounds: (start, TetrisBoard.numberOfRows))
            }
        }

        return Range(uncheckedBounds: (start, end))
    }

    var stackHeight: Int {
        var result = 0

        for row in 0..<TetrisBoard.numberOfRows {
            for column in 0..<TetrisBoard.numberOfColumns where self[column, row] != nil {
                result += 1
                break
            }
        }
        return result
    }

    lazy var spawnPosition: (Int, Int) = {
        return (TetrisBoard.numberOfColumns / 2, TetrisBoard.numberOfRows - 1)
    }()

    private subscript (column: Int, row: Int) -> Tetromino.Shape? {
        get {
            if column >= 0 && column < TetrisBoard.numberOfColumns && row >= 0 && row < TetrisBoard.numberOfRows {
                return self.data[column][row]
            }
            return nil
        }
        set {
            if column >= 0 && column < TetrisBoard.numberOfColumns && row >= 0 && row < TetrisBoard.numberOfRows {
                self.data[column][row] = newValue
            }
        }
    }

    func addDuration(_ elapsed: TimeInterval) {
        self.duration += elapsed
    }

    func clear(lines: Range<Int>) {
        self.drop(lines: lines)
        self.score(lines: lines)
    }

    func spawn() -> Bool {
        let current = self.next.with(position: self.spawnPosition)
        self.next = Tetromino(shape: self.random.next())
        self.statistics.add(current.shape)

        if self.collides(tetromino: current, with: .all) {
            Logger.game.info("Stacked out with \(self.score) points!")
            Logger.game.info("Statistics: \(self.statistics.description, privacy: .public)")
            self.current = nil
            return false
        }

        self.current = current
        return true
    }

    func shiftLeft() -> Bool {
        if let current = self.current, !self.collides(tetromino: current.shiftedLeft(), with: .all) {
            self.current = current.shiftedLeft()
            return true
        }
        return false
    }

    func shiftRight() -> Bool {
        if let current = self.current, !self.collides(tetromino: current.shiftedRight(), with: .all) {
            self.current = current.shiftedRight()
            return true
        }
        return false
    }

    func softDrop(manual: Bool) -> Bool {
        if let current = self.current, !self.collides(tetromino: current.dropped(), with: .all) {
            self.current = current.dropped()
            if manual {
                self.dropCounter += 1
            }
            return true
        }

        if self.dropCounter > 0 {
            self.score += self.dropCounter
            Logger.game.info("Soft dropping tetromino gives \(self.dropCounter) points: total \(self.score) points.")
        }

        self.lock(tetromino: self.current)
        self.current = nil
        self.dropCounter = 0

        return false
    }

    func hardDrop() {
        if var current = self.current {
            self.dropCounter = 0
            while !self.collides(tetromino: current.dropped(), with: .all) {
                current = current.dropped()
                self.dropCounter += 1
            }

            if self.dropCounter > 0 {
                self.score += self.dropCounter * 2
                Logger.game.info("Hard dropping tetromino gives \(self.dropCounter * 2) points: total \(self.score) points.")
            }

            self.lock(tetromino: current)
            self.current = nil
            self.dropCounter = 0
        }
    }

    func rotateCounterClockwise() -> Bool {
        if !enableWallKick, let current = self.current, !self.collides(tetromino: current.rotatedCounterClockwise(), with: .all) {
            self.current = current.rotatedCounterClockwise()
            return true
        }
        if enableWallKick, var current = self.current, !self.collides(tetromino: current.rotatedCounterClockwise(), with: [.floor, .piece]) {
            current = self.moveUntilClearFromWall(tetromino: current.rotatedCounterClockwise())
            if self.collides(tetromino: current, with: .all) {
                return false
            }
            self.current = current
            return true
        }
        return false
    }

    func rotateClockwise() -> Bool {
        if !enableWallKick, let current = self.current, !self.collides(tetromino: current.rotatedClockwise(), with: .all) {
            self.current = current.rotatedClockwise()
            return true
        }
        if enableWallKick, var current = self.current, !self.collides(tetromino: current.rotatedClockwise(), with: [.floor, .piece]) {
            current = self.moveUntilClearFromWall(tetromino: current.rotatedClockwise())
            if self.collides(tetromino: current, with: .all) {
                return false
            }
            self.current = current
            return true
        }
        return false
    }

    private func score(lines: Range<Int>) {
        let baseScorePerLines = [0, 40, 100, 300, 1200]
        let linesScore = baseScorePerLines[lines.count] * (self.level + 1)

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

    private func drop(lines: Range<Int>) {
        for row in lines.upperBound..<TetrisBoard.numberOfRows {
            let target = row - (lines.upperBound - lines.lowerBound)
            for column in 0..<TetrisBoard.numberOfColumns {
                self[column, target] = self[column, row]
            }

            for column in 0..<TetrisBoard.numberOfColumns {
                self[column, row] = nil
            }
        }
    }

    private func lock(tetromino: Tetromino?) {
        guard let tetromino = tetromino else {
            return
        }

        for (column, row) in tetromino.points {
            if row >= 0 && column >= 0 && row < TetrisBoard.numberOfRows && column < TetrisBoard.numberOfColumns {
                self[column, row] = tetromino.shape
            }
        }
    }

    private func isComplete(row: Int) -> Bool {
        for column in 0..<TetrisBoard.numberOfColumns where self[column, row] == nil {
            return false
        }
        return true
    }

    private func moveUntilClearFromWall(tetromino: Tetromino) -> Tetromino {
        var current = tetromino
        while self.collides(tetromino: current, with: [.leftWall]) {
            current = current.shiftedRight()
        }
        while self.collides(tetromino: current, with: [.rightWall]) {
            current = current.shiftedLeft()
        }
        return current
    }

    private func collides(tetromino: Tetromino, with flags: CollisionFlags) -> Bool {
        for (column, row) in tetromino.points {
            if flags.contains(.floor) && row < 0 {
                return true
            }
            if flags.contains(.leftWall) && column < 0 {
                return true
            }
            if flags.contains(.rightWall) && column >= TetrisBoard.numberOfColumns {
                return true
            }
            if flags.contains(.piece) && self[column, row] != nil {
                return true
            }
        }
        return false
    }
}
