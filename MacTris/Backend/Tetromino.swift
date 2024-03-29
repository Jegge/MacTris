//
//  Tetronimo.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 02.01.24.
//

import Foundation

struct Tetromino {
    enum Shape: CaseIterable {
        case t, j, z, o, s, l, i

        var points: [[(Int, Int)]] {
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
    let position: (Int, Int)

    var points: [(Int, Int)] {
        return self.shape.points[self.rotation].map { ($0.0 + position.0, $0.1 + position.1) }
    }

    init (shape: Shape, rotation: Int = 0, position: (Int, Int) = (0, 0)) {
        self.shape = shape
        self.rotation = rotation
        self.position = position
    }

    func with (position: (Int, Int)) -> Tetromino {
        return Tetromino(shape: self.shape, rotation: self.rotation, position: position)
    }

    func rotatedCounterClockwise () -> Tetromino {
        return Tetromino(shape: self.shape, rotation: (self.rotation + 1) % self.shape.points.count, position: self.position)
    }

    func rotatedClockwise () -> Tetromino {
        return Tetromino(shape: self.shape, rotation: (self.rotation + self.shape.points.count - 1) % self.shape.points.count, position: self.position)
    }

    func shiftedLeft () -> Tetromino {
        return Tetromino(shape: self.shape, rotation: self.rotation, position: (position.0 - 1, position.1))
    }

    func shiftedRight () -> Tetromino {
        return Tetromino(shape: self.shape, rotation: self.rotation, position: (position.0 + 1, position.1))
    }

    func dropped () -> Tetromino {
        return Tetromino(shape: self.shape, rotation: self.rotation, position: (position.0, position.1 - 1))
    }
}
