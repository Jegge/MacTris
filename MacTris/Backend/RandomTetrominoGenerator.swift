//
//  RandomTetrominoGenerator.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 04.01.24.
//

import Foundation

protocol RandomTetrominoGenerator {
    func next () -> Tetromino
}

class SevenBagTetrominoGenerator: RandomTetrominoGenerator {
    private var random: RandomNumberGenerator
    private var bag: [Tetromino.Shape] = []

    init (random: RandomNumberGenerator) {
        self.random = random
    }

    convenience init () {
        self.init(random: SystemRandomNumberGenerator())
    }

    func next () -> Tetromino {
        if self.bag.isEmpty {
            self.bag = Tetromino.Shape.allCases.shuffled(using: &self.random)
        }
        let shape = self.bag.popLast()!
        let rotation = Int(truncatingIfNeeded: random.next(upperBound: UInt64(4))) % shape.points.count
        return Tetromino(shape: shape, rotation: rotation)
    }
}

class NesTetrominoGenerator: RandomTetrominoGenerator {

    private var random: RandomNumberGenerator
    private var last: Tetromino.Shape?

    init (random: RandomNumberGenerator) {
        self.random = random
    }

    convenience init () {
        self.init(random: SystemRandomNumberGenerator())
    }

    private func randomShape () -> Tetromino.Shape {
        let number: Int = Int(truncatingIfNeeded: self.random.next(upperBound: UInt(10000)))
        if number >= 0 && number < 1473 {
            return .t // 14.73%
        } else if number >= 1473 && number < 2902 {
            return .j // 14.29%
        } else if number >= 2902 && number < 4331 {
            return .z // 14.29%
        } else if number >= 4332 && number < 5760 {
            return .o // 14.29%
        } else if number >= 5860 && number < 7233 {
            return .s // 14.73%
        } else if number >= 7234 && number < 8617 {
            return .l // 13.84%
        } else {
            return .i // 13.84%
        }
    }

    func next () -> Tetromino {
        var shape = self.randomShape()
        while shape == last {
            shape = self.randomShape()
        }
        self.last = shape

        return Tetromino(shape: shape, rotation: 0)
    }
}
