//
//  Tetris.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 12.01.24.
//

import OSLog

/// The core Tetris game engine: holds the board state, handles piece movement,
/// rotation, line clearing, scoring, and level progression.
class Tetris {
    /// A 2D grid where each cell either contains a tetromino shape or is empty.
    typealias Grid = [[Tetromino.Shape?]]

    /// Flags used to describe what a collision check should consider.
    private struct CollisionFlags: OptionSet {
        let rawValue: Int
        static let leftWall = CollisionFlags(rawValue: 1 << 0)
        static let rightWall = CollisionFlags(rawValue: 1 << 1)
        static let floor = CollisionFlags(rawValue: 1 << 2)
        static let piece = CollisionFlags(rawValue: 1 << 3)
        static let all = CollisionFlags([.leftWall, .rightWall, .floor, .piece])
    }

    static let maxLevel: Int = 19
    static let numberOfColumns: Int = 10
    static let numberOfRows: Int = 20
    static let spawnPosition: Point = Point(Tetris.numberOfColumns / 2, Tetris.numberOfRows - 1)

    let random: RandomTetrominoShapeGenerator
    let options: TetrisOptions

    private var data: Grid
    private var dropCounter: Int = 0
    private var linesToNextLevel: Int

    private(set) var lines: Int = 0
    private(set) var level: Int = 0
    private(set) var score: Int = 0
    private(set) var next: Tetromino
    private(set) var current: Tetromino?
    private(set) var statistics: Statistics = Statistics()

    init(options: TetrisOptions, random: RandomTetrominoShapeGenerator) {
        self.options = options
        self.random = random
        self.level = options.startingLevel
        self.linesToNextLevel = options.startingLinesToNextLevel
        self.data = Array(repeating: Array(repeating: nil, count: Tetris.numberOfRows), count: Tetris.numberOfColumns)

        let current = Tetromino(shape: self.random.next(), rotation: 0, position: Tetris.spawnPosition)
        self.statistics.add(current.shape)
        self.current = current

        self.next = Tetromino(shape: self.random.next())

        Logger.game.info("Begin game with \(options, privacy: .public)")
        Logger.game.info("Starting level \(self.level), lines to next level \(self.linesToNextLevel)")
    }

    convenience init(options: TetrisOptions) {
        self.init(options: options, random: options.randomGeneratorMode.createGenerator())
    }

    var grid: Grid {
        var result = self.data

        if let tetromino = self.current {
            for point in tetromino.points where point.column >= 0 &&
                point.column < Tetris.numberOfColumns &&
                point.row >= 0 &&
                point.row < Tetris.numberOfRows {
                result[point.column][point.row] = tetromino.shape
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
                return Range(uncheckedBounds: (start, Tetris.numberOfRows))
            }
        }

        return Range(uncheckedBounds: (start, end))
    }

    var stackHeight: Int {
        var result = 0

        for row in 0..<Tetris.numberOfRows {
            for column in 0..<Tetris.numberOfColumns where self[column, row] != nil {
                result += 1
                break
            }
        }
        return result
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

    func clear(lines: Range<Int>) {
        self.drop(lines: lines)
        self.score(lines: lines)
    }

    func spawn() -> Bool {
        let current = self.next.with(position: Tetris.spawnPosition)
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

    func shift(_ direction: Tetromino.Shift) -> Bool {
        if let current = self.current, !self.collides(tetromino: current.shifted(direction), with: .all) {
            self.current = current.shifted(direction)
            return true
        }
        return false
    }

    func rotate(_ rotation: Tetromino.Rotation) -> Bool {
        if !options.wallKick, let current = self.current, !self.collides(tetromino: current.rotated(rotation), with: .all) {
            self.current = current.rotated(rotation)
            return true
        }
        if options.wallKick, var current = self.current, !self.collides(tetromino: current.rotated(rotation), with: [.floor, .piece]) {
            current = self.moveUntilClearFromWall(tetromino: current.rotated(rotation))
            if self.collides(tetromino: current, with: .all) {
                return false
            }
            self.current = current
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

        if let current = self.current {
            self.lock(tetromino: current)
        }
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

    private func score(lines: Range<Int>) {
        let baseScorePerLines = [0, 40, 100, 300, 1200] // classic NES line scores
        let linesScore = baseScorePerLines[lines.count] * (self.level + 1)

        self.score += linesScore
        self.lines += lines.count

        // swiftlint:disable:next line_length
        Logger.game.info("Completing \(lines.count) line(s) at level \(self.level) gives \(linesScore) points: total \(self.lines) lines, \(self.score) points. Next level in \(self.linesToNextLevel) lines.")

        self.linesToNextLevel -= lines.count

        if self.linesToNextLevel <= 0 {
            self.level += 1
            self.linesToNextLevel += 10
            Logger.game.info("Reached level \(self.level), lines to next level \(self.linesToNextLevel)")
        }
    }

    private func drop(lines: Range<Int>) {
        for row in lines.upperBound..<Tetris.numberOfRows {
            let target = row - (lines.upperBound - lines.lowerBound)
            for column in 0..<Tetris.numberOfColumns {
                self[column, target] = self[column, row]
            }

            for column in 0..<Tetris.numberOfColumns {
                self[column, row] = nil
            }
        }
    }

    private func lock(tetromino: Tetromino) {
        for point in tetromino.points {
            self[point.column, point.row] = tetromino.shape
        }
    }

    private func isComplete(row: Int) -> Bool {
        for column in 0..<Tetris.numberOfColumns where self[column, row] == nil {
            return false
        }
        return true
    }

    private func moveUntilClearFromWall(tetromino: Tetromino) -> Tetromino {
        var current = tetromino
        while self.collides(tetromino: current, with: [.leftWall]) {
            current = current.shifted(.right)
        }
        while self.collides(tetromino: current, with: [.rightWall]) {
            current = current.shifted(.left)
        }
        return current
    }

    private func collides(tetromino: Tetromino, with flags: CollisionFlags) -> Bool {
        for point in tetromino.points {
            if flags.contains(.floor) && point.row < 0 {
                return true
            }
            if flags.contains(.leftWall) && point.column < 0 {
                return true
            }
            if flags.contains(.rightWall) && point.column >= Tetris.numberOfColumns {
                return true
            }
            if flags.contains(.piece) && self[point.column, point.row] != nil {
                return true
            }
        }
        return false
    }
}
