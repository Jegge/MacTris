//
//  TestHelper.swift
//  MacTrisTests
//
//  Created by Sebastian Boettcher on 07.07.26.
//

import Foundation
@testable import MacTris

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}

class StubTetrominoShapeGenerator: RandomTetrominoShapeGenerator {
    private var shapes: [Tetromino.Shape]
    private var index: Int = 0

    init(shapes: [Tetromino.Shape] = [.i, .o, .t, .s, .z, .j, .l]) {
        self.shapes = shapes
    }

    func next() -> Tetromino.Shape {
        let shape = shapes[index % shapes.count]
        index += 1
        return shape
    }
}
