//
//  Tetromino.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 02.01.24.
//

typealias Point = (x: Int, y: Int)

struct Tetromino {
    enum Shape: CaseIterable {
        case t, j, z, o, s, l, i

        /// Each entry represents a rotation, and each rotation has multiple points
        var points: [[Point]] {
            switch self {
            case .o:
                return [[(-1, 0), (0, 0), (-1, -1), (0, -1)]]

            case .s:
                return [[(0, 0), (1, 0), (-1, -1), (0, -1)],
                        [(0, 1), (0, 0), (1, 0), (1, -1)]
                       ]
            case .z:
                return [[(-1, 0), (0, 0), (0, -1), (1, -1)],
                        [(1, 1), (0, 0), (1, 0), (0, -1)]
                       ]
            case .i:
                return [[(-2, 0), (-1, 0), (0, 0), (1, 0)],
                        [(0, 2), (0, 1), (0, 0), (0, -1)]
                       ]

            case .j:
                return [[(-1, 0), (0, 0), (1, 0), (1, -1)],
                        [(0, 1), (1, 1), (0, 0), (0, -1)],
                        [(-1, 1), (-1, 0), (0, 0), (1, 0)],
                        [(0, 1), (0, 0), (-1, -1), (0, -1)]
                       ]
            case .l:
                return [[(-1, 0), (0, 0), (1, 0), (-1, -1)],
                        [(0, 1), (0, 0), (0, -1), (1, -1)],
                        [(1, 1), (-1, 0), (0, 0), (1, 0)],
                        [(-1, 1), (0, 1), (0, 0), (0, -1)]
                       ]

            case .t:
                return [[(-1, 0), (0, 0), (1, 0), (0, -1)],
                        [(0, 1), (0, 0), (1, 0), (0, -1)],
                        [(-1, 0), (0, 0), (1, 0), (0, 1)],
                        [(0, 1), (-1, 0), (0, 0), (0, -1)]
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
        return self.shape.points[self.rotation].map { ($0.x + position.x, $0.y + position.y) }
    }

    init (shape: Shape, rotation: Int = 0, position: Point = (0, 0)) {
        self.shape = shape
        self.rotation = rotation
        self.position = position
    }

    func with(position: Point) -> Tetromino {
        return Tetromino(shape: self.shape, rotation: self.rotation, position: position)
    }

    func rotatedCounterClockwise() -> Tetromino {
        return Tetromino(shape: self.shape, rotation: (self.rotation + 1) % self.shape.points.count, position: self.position)
    }

    func rotatedClockwise() -> Tetromino {
        return Tetromino(shape: self.shape, rotation: (self.rotation + self.shape.points.count - 1) % self.shape.points.count, position: self.position)
    }

    func shiftedLeft() -> Tetromino {
        return Tetromino(shape: self.shape, rotation: self.rotation, position: (position.x - 1, position.y))
    }

    func shiftedRight() -> Tetromino {
        return Tetromino(shape: self.shape, rotation: self.rotation, position: (position.x + 1, position.y))
    }

    func dropped() -> Tetromino {
        return Tetromino(shape: self.shape, rotation: self.rotation, position: (position.x, position.y - 1))
    }
}
