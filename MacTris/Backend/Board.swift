//
//  Board.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 12.01.24.
//

import Foundation

class Board {

    let numberOfColumns: Int = 10
    let numberOfRows: Int = 20

    private var data: [[Tetromino.Shape?]]

    init () {
        self.data = Array(repeating: Array(repeating: nil, count: self.numberOfRows), count: self.numberOfColumns)
    }

    private (set) subscript (column: Int, row: Int) -> Tetromino.Shape? {
        get {
            if column >= 0 && column < self.numberOfColumns && row >= 0 && row < self.numberOfRows {
                return self.data[column][row]
            }
            return nil
        }
        set {
            if column >= 0 && column < self.numberOfColumns && row >= 0 && row < self.numberOfRows {
                self.data[column][row] = newValue
            }
        }
    }

    func spawnPosition () -> (Int, Int) {
        return (self.numberOfColumns / 2, self.numberOfRows - 1)
    }

    func clear () {
        for column in 0..<self.numberOfColumns {
            for row in 0..<self.numberOfRows {
                self[column, row] = nil
            }
        }
    }

    func clear (tetronimo: Tetromino?) {
        guard let tetronimo = tetronimo else {
            return
        }
        for (column, row) in tetronimo.points {
            self[column, row] = nil
        }
    }

    func drop (rows: Range<Int>) {
        for row in rows.upperBound..<self.numberOfRows {
            let target = row - (rows.upperBound - rows.lowerBound)
            self.copy(row: row, to: target)
            self.clear(row: row)
        }
    }

    func dissolve (rows: Range<Int>) -> Bool {
        var done = true
        for row in rows {
            for column in (0..<self.numberOfColumns / 2).reversed() where self[column, row] != nil {
                self[column, row] = nil
                done = false
                break
            }
            for column in self.numberOfColumns / 2..<self.numberOfColumns where self[column, row] != nil {
                self[column, row] = nil
                done = false
                break
            }
        }
        return done
    }

    func draw (tetronimo: Tetromino?) {
        guard let tetronimo = tetronimo else {
            return
        }

        for (column, row) in tetronimo.points {
            if row >= 0 && column >= 0 && row < self.numberOfRows && column < self.numberOfColumns {
                self[column, row] = tetronimo.shape
            }
        }
    }

    func completedRows () -> Range<Int>? {
        var start = 0
        while !self.isComplete(row: start) {
            start += 1
            if start == self.numberOfRows {
                return nil
            }
        }

        var end = start
        while self.isComplete(row: end) {
            end += 1
            if end >= self.numberOfRows {
                return Range(uncheckedBounds: (start, self.numberOfRows - 1))
            }
        }

        return Range(uncheckedBounds: (start, end))
    }

    private func clear (row: Int) {
        for column in 0..<self.numberOfColumns {
            self[column, row] = nil
        }
    }

    private func copy (row source: Int, to target: Int) {
        for column in 0..<self.numberOfColumns {
            self[column, target] = self[column, source]
        }
    }

    func collides (tetronimo: Tetromino) -> Bool {
        for (column, row) in tetronimo.points {
            if row > self.numberOfRows {
                continue
            }
            if row < 0 || column < 0 || column >= self.numberOfColumns {
                return true
            }
            if self[column, row] != nil {
                return true
            }
        }
        return false
    }

    private func isComplete(row: Int) -> Bool {
        for column in 0..<self.numberOfColumns where self[column, row] == nil {
            return false
        }
        return true
    }
}
