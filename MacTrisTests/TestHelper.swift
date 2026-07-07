//
//  TestHelper.swift
//  MacTrisTests
//
//  Created by Sebastian Boettcher on 07.07.26.
//

@testable import MacTris

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
