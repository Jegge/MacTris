//
//  SKTileMapNode+Drawing.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 02.01.24.
//

import SpriteKit

/// Draws Tetris grids and tetromino previews onto an `SKTileMapNode`.
extension SKTileMapNode {
    private static var tileGroupCache: [String: SKTileGroup] = [:]

    /// Returns a cached tile group by name, populating the cache on first access.
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

    /// Fills the tile map to represent a full game grid.
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

    /// Renders a single tetromino shape onto the tile map (used for the preview).
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
        for point in tetromino.points {
            if point.row >= 0 && point.column >= 0 && point.row < self.numberOfRows && point.column < self.numberOfColumns {
                self.setTileGroup(tileGroup, forColumn: point.column, row: point.row)
            }
        }
    }
}
