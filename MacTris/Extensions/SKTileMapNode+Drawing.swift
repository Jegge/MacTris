//
//  SKTileMapNode+Drawing.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 02.01.24.
//

import SpriteKit

extension SKTileMapNode {
    private static var tileGroupCache: [String: SKTileGroup] = [:]

    private func tileGroup(named name: String) -> SKTileGroup? {
        if Self.tileGroupCache.isEmpty {
            for group in self.tileSet.tileGroups {
                if let name = group.name {
                    Self.tileGroupCache[name] = group
                }
            }
        }
        return Self.tileGroupCache[name]
    }

    func draw(grid: Tetris.Grid, appearance: Appearance) {
        for column in 0..<self.numberOfColumns {
            for row in 0..<self.numberOfRows {
                if let shape = grid[column][row] {
                    let tileGroup = self.tileGroup(named: "\(shape.appearance)-\(appearance.rawValue)")
                    self.setTileGroup(tileGroup, forColumn: column, row: row)
                } else {
                    self.setTileGroup(nil, forColumn: column, row: row)
                }
            }
        }
    }

    func draw(tetromino: Tetromino?, appearance: Appearance) {
        for column in 0..<self.numberOfColumns {
            for row in 0..<self.numberOfRows {
                self.setTileGroup(nil, forColumn: column, row: row)
            }
        }

        guard let tetromino = tetromino else {
            return
        }

        let tileGroup = self.tileGroup(named: "\(tetromino.shape.appearance)-\(appearance.rawValue)")
        for (column, row) in tetromino.points {
            if row >= 0 && column >= 0 && row < self.numberOfRows && column < self.numberOfColumns {
                self.setTileGroup(tileGroup, forColumn: column, row: row)
            }
        }
    }
}
