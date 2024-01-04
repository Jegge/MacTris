//
//  RandomTetrominoGenerator.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 04.01.24.
//

import Foundation

public class RandomTetrominoGenerator {
    private var random: RandomNumberGenerator
    private var bag: [Tetromino.Shape] = []

    init (random: RandomNumberGenerator) {
        self.random = random
    }

    convenience init () {
        self.init(random: SystemRandomNumberGenerator())
    }

    public func next () -> Tetromino {
        if self.bag.isEmpty {
            self.bag = Tetromino.Shape.allCases.shuffled(using: &self.random)
        }

        let shape = self.bag.popLast()!
        let rotation = Int(truncatingIfNeeded: random.next(upperBound: UInt64(4))) % shape.points.count

        return Tetromino(shape: shape, rotation: rotation, position: (0, 1))
    }
}
