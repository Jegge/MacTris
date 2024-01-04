//
//  Tetronimo.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 02.01.24.
//

import Foundation

public struct Tetromino {

    public enum Shape: CaseIterable {
        case o, s, z, i, j, l, t

        var points: [[(Int, Int)]] {
            switch self {
            case .o:
                return [[(0, 0), (1, 0), (0, 1), (1, 1)]]

            case .s:
                return [[(1, 0), (2, 0), (0, 1), (1, 1)],
                        [(1, -1), (1, 0), (2, 0), (2, 1)]
                       ]
            case .z:
                return [[(0, 0), (1, 0), (1, 1), (2, 1)],
                        [(2, -1), (2, 0), (1, 0), (1, 1)]
                       ]
            case .i:
                return [[(0, 0), (1, 0), (2, 0), (3, 0)],
                        [(1, -1), (1, 0), (1, 1), (1, 2)]
                       ]

            case .j:
                return [[(0, 0), (1, 0), (2, 0), (2, 1)],
                        [(1, -1), (1, 0), (1, 1), (0, 1)],
                        [(0, -1), (0, 0), (1, 0), (2, 0)],
                        [(1, -1), (2, -1), (1, 0), (1, 1)]
                       ]
            case .l:
                return [[(0, 1), (0, 0), (1, 0), (2, 0)],
                        [(0, -1), (1, -1), (1, 0), (1, 1)],
                        [(2, -1), (2, 0), (1, 0), (0, 0)],
                        [(1, -1), (1, 0), (1, 1), (2, 1)]
                       ]

            case .t:
                return [[(1, 0), (0, 1), (1, 1), (2, 1)],
                        [(1, 0), (1, 1), (2, 1), (1, 2)],
                        [(0, 1), (1, 1), (2, 1), (1, 2)],
                        [(1, 0), (0, 1), (1, 1), (1, 2)]
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

    init (shape: Shape, rotation: Int, position: (Int, Int)) {
        self.shape = shape
        self.rotation = rotation
        self.position = position
    }

    public func with (position: (Int, Int)) -> Tetromino {
        return Tetromino(shape: self.shape, rotation: self.rotation, position: position)
    }

    public func rotatedLeft () -> Tetromino {
        return Tetromino(shape: self.shape, rotation: (self.rotation + 1) % self.shape.points.count, position: self.position)
    }

    public func rotatedRight () -> Tetromino {
        return Tetromino(shape: self.shape, rotation: (self.rotation + self.shape.points.count - 1) % self.shape.points.count, position: self.position)
    }

    public func movedLeft () -> Tetromino {
        return Tetromino(shape: self.shape, rotation: self.rotation, position: (position.0 - 1, position.1))
    }

    public func movedRight () -> Tetromino {
        return Tetromino(shape: self.shape, rotation: self.rotation, position: (position.0 + 1, position.1))
    }

    public func movedDown () -> Tetromino {
        return Tetromino(shape: self.shape, rotation: self.rotation, position: (position.0, position.1 - 1))
    }
}
