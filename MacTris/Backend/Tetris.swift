//
//  Tetris.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 12.01.24.
//

import Foundation

class Tetris {
    let random: RandomTetrominoShapeGenerator
    var board: Board = Board()
    var score: Int = 0
    var lines: Int = 0
    var level: Int = 0

    var next: Tetromino
    var current: Tetromino?

    var linesToNextLevel: Int

    init (random: RandomTetrominoShapeGenerator, level: Int) {
        self.random = random
        self.level = level
        self.linesToNextLevel = min(self.level * 10 + 10, max(100, self.level * 10 - 50))
        self.next = Tetromino(shape: self.random.next())
        self.current = Tetromino(shape: self.random.next(), rotation: 0, position: self.board.spawnPosition())
    }
}
