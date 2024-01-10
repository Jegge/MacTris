//
//  RandomTetrominoGenerator.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 04.01.24.
//

import Foundation

protocol RandomTetrominoShapeGenerator {
    func next () -> Tetromino.Shape
}

class SevenBagTetrominoShapeGenerator: RandomTetrominoShapeGenerator {
    private var random: RandomNumberGenerator
    private var bag: [Tetromino.Shape] = []

    init (random: RandomNumberGenerator) {
        self.random = random
    }

    convenience init () {
        self.init(random: SystemRandomNumberGenerator())
    }

    func next () -> Tetromino.Shape {
        if self.bag.isEmpty {
            self.bag = Tetromino.Shape.allCases.shuffled(using: &self.random)
        }
        return self.bag.popLast()!
    }
}

class NesTetrominoShapeGenerator: RandomTetrominoShapeGenerator {
    private var random: RandomNumberGenerator
    private var last: Tetromino.Shape?

    init (random: RandomNumberGenerator) {
        self.random = random
    }

    convenience init () {
        self.init(random: SystemRandomNumberGenerator())
    }

    func next () -> Tetromino.Shape {
        var shape: Tetromino.Shape?

        while shape == last {
            let number: Int = Int(truncatingIfNeeded: self.random.next(upperBound: UInt(10000)))
            if number < 1473 {
                shape = .t // 14.73%
            } else if number >= 1473 && number < 2902 {
                shape = .j // 14.29%
            } else if number >= 2902 && number < 4331 {
                shape = .z // 14.29%
            } else if number >= 4332 && number < 5760 {
                shape = .o // 14.29%
            } else if number >= 5860 && number < 7233 {
                shape = .s // 14.73%
            } else if number >= 7234 && number < 8617 {
                shape = .l // 13.84%
            } else {
                shape = .i // 13.84%
            }
        }
        self.last = shape

        return self.last!
    }
}
