//
//  SKTileMapNode+Tetromino.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 02.01.24.
//

import Foundation
import SpriteKit

extension SKTileMapNode {

    func update (board: Board, appearance: Appearance) {
        for column in 0..<self.numberOfColumns {
            for row in 0..<self.numberOfRows {
                if let shape = board[column, row] {
                    let tileGroup = self.tileSet.tileGroups.first { $0.name == "\(shape.appearance)-\(appearance.rawValue)" }
                    self.setTileGroup(tileGroup, forColumn: column, row: row)
                } else {
                    self.setTileGroup(nil, forColumn: column, row: row)
                }
            }
        }
    }

    func clear () {
        for column in 0..<self.numberOfColumns {
            for row in 0..<self.numberOfRows {
                self.setTileGroup(nil, forColumn: column, row: row)
            }
        }
    }

    func draw (tetronimo: Tetromino?, appearance: Appearance) {
        guard let tetronimo = tetronimo else {
            return
        }

        let tileGroup = self.tileSet.tileGroups.first { $0.name == "\(tetronimo.shape.appearance)-\(appearance.rawValue)" }
        for (column, row) in tetronimo.points {
            if row >= 0 && column >= 0 && row < self.numberOfRows && column < self.numberOfColumns {
                self.setTileGroup(tileGroup, forColumn: column, row: row)
            }
        }
    }
}
