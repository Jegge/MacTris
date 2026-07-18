//
//  Tetromino.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 02.01.24.
//

struct Tetromino {
    enum Rotation {
        case clockwise
        case counterClockwise
    }

    enum Shift {
        case left
        case right
    }

    enum Shape: CaseIterable {
        case t, j, z, o, s, l, i

        /// Each entry represents a rotation, and each rotation has multiple points
        /// The points are offsets to the current shape position
        var points: [[Point]] {
            switch self {
            case .o:
                return [[Point(-1, 0), Point(0, 0), Point(-1, -1), Point(0, -1)]]

            case .s:
                return [[Point(0, 0), Point(1, 0), Point(-1, -1), Point(0, -1)],
                        [Point(0, 1), Point(0, 0), Point(1, 0), Point(1, -1)]
                       ]
            case .z:
                return [[Point(-1, 0), Point(0, 0), Point(0, -1), Point(1, -1)],
                        [Point(1, 1), Point(0, 0), Point(1, 0), Point(0, -1)]
                       ]
            case .i:
                return [[Point(-2, 0), Point(-1, 0), Point(0, 0), Point(1, 0)],
                        [Point(0, 2), Point(0, 1), Point(0, 0), Point(0, -1)]
                       ]

            case .j:
                return [[Point(-1, 0), Point(0, 0), Point(1, 0), Point(1, -1)],
                        [Point(0, 1), Point(1, 1), Point(0, 0), Point(0, -1)],
                        [Point(-1, 1), Point(-1, 0), Point(0, 0), Point(1, 0)],
                        [Point(0, 1), Point(0, 0), Point(-1, -1), Point(0, -1)]
                       ]
            case .l:
                return [[Point(-1, 0), Point(0, 0), Point(1, 0), Point(-1, -1)],
                        [Point(0, 1), Point(0, 0), Point(0, -1), Point(1, -1)],
                        [Point(1, 1), Point(-1, 0), Point(0, 0), Point(1, 0)],
                        [Point(-1, 1), Point(0, 1), Point(0, 0), Point(0, -1)]
                       ]

            case .t:
                return [[Point(-1, 0), Point(0, 0), Point(1, 0), Point(0, -1)],
                        [Point(0, 1), Point(0, 0), Point(1, 0), Point(0, -1)],
                        [Point(-1, 0), Point(0, 0), Point(1, 0), Point(0, 1)],
                        [Point(0, 1), Point(-1, 0), Point(0, 0), Point(0, -1)]
                       ]
            }
        }

        /// Used to build the name of the tilegroup
        var appearance: String {
            switch self {
            case .o: return "Yellow"
            case .s: return "Green"
            case .z: return "Red"
            case .i: return "Cyan"
            case .j: return "Blue"
            case .l: return "Orange"
            case .t: return "Purple"
            }
        }
    }

    let shape: Shape
    let rotation: Int
    let position: Point

    var points: [Point] {
        return self.shape.points[self.rotation].map { Point($0.column + position.column, $0.row + position.row) }
    }

    init(shape: Shape, rotation: Int = 0, position: Point = .zero) {
        self.shape = shape
        self.rotation = rotation
        self.position = position
    }

    func with(position: Point) -> Tetromino {
        return Tetromino(shape: self.shape, rotation: self.rotation, position: position)
    }

    func rotated(_ rotation: Rotation) -> Tetromino {
        switch rotation {
        case .clockwise:
            return Tetromino(shape: self.shape, rotation: (self.rotation + self.shape.points.count - 1) % self.shape.points.count, position: self.position)
        case .counterClockwise:
            return Tetromino(shape: self.shape, rotation: (self.rotation + 1) % self.shape.points.count, position: self.position)
        }
    }

    func shifted(_ direction: Shift) -> Tetromino {
        switch direction {
        case .left:
            return Tetromino(shape: self.shape, rotation: self.rotation, position: Point(position.column - 1, position.row))
        case .right:
            return Tetromino(shape: self.shape, rotation: self.rotation, position: Point(position.column + 1, position.row))
        }
    }

    func dropped() -> Tetromino {
        return Tetromino(shape: self.shape, rotation: self.rotation, position: Point(position.column, position.row - 1))
    }
}
