//
//  SKTileMapNode+Tetromino.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 02.01.24.
//

import Foundation
import SpriteKit

extension SKTileMapNode {

    func spawnPosition () -> (Int, Int) {
        return (self.numberOfColumns / 2, self.numberOfRows)
    }

    func clear () {
        for column in 0..<self.numberOfColumns {
            for row in 0..<self.numberOfRows {
                self.setTileGroup(nil, forColumn: column, row: row)
            }
        }
    }

    func clear (tetronimo: Tetromino?) {
        guard let tetronimo = tetronimo else {
            return
        }
        for (column, row) in tetronimo.points {
            self.setTileGroup(nil, forColumn: column, row: row)
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
            for column in (0..<self.numberOfColumns / 2).reversed() where self.tileGroup(atColumn: column, row: row) != nil {
                self.setTileGroup(nil, forColumn: column, row: row)
                done = false
                break
            }
            for column in self.numberOfColumns / 2..<self.numberOfColumns where self.tileGroup(atColumn: column, row: row) != nil {
                self.setTileGroup(nil, forColumn: column, row: row)
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

        let tileGroup = self.tileSet.tileGroups.first { $0.name == tetronimo.shape.appearance }
        for (column, row) in tetronimo.points {
            if row >= 0 && column >= 0 && row < self.numberOfRows && column < self.numberOfColumns {
                self.setTileGroup(tileGroup, forColumn: column, row: row)
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

    func apply (tetromino: Tetromino, change: ((Tetromino) -> Tetromino)) -> Tetromino? {
        self.clear(tetronimo: tetromino)

        let changed = change(tetromino)

        if !self.collides(tetronimo: changed) {
            self.draw(tetronimo: changed)
            return changed
        } else {
            self.draw(tetronimo: tetromino)
            return nil
        }
    }

    private func clear (row: Int) {
        for column in 0..<self.numberOfColumns {
            self.setTileGroup(nil, forColumn: column, row: row)
        }
    }

    private func copy (row source: Int, to target: Int) {
        for column in 0..<self.numberOfColumns {
            self.setTileGroup(self.tileGroup(atColumn: column, row: source), forColumn: column, row: target)
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
            if self.tileGroup(atColumn: column, row: row) != nil {
                return true
            }
        }
        return false
    }

    private func isComplete(row: Int) -> Bool {
        for column in 0..<self.numberOfColumns where self.tileGroup(atColumn: column, row: row) == nil {
            return false
        }
        return true
    }
}
