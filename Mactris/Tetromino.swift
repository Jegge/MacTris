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
                return [[(0,  0), (1, 0), (0, 1), (1, 1)]]

            case .s:
                return [[(1,  0), (2, 0), (0, 1), (1, 1)],
                        [(1, -1), (1, 0), (2, 0), (2, 1)]
                       ]
            case .z:
                return [[(0, 0), (1, 0), (1, 1), (2, 1)],
                        [(2,-1), (2, 0), (1, 0), (1, 1)]
                       ]
            case .i:
                return [[(0, 0), (1, 0), (2, 0), (3, 0)],
                        [(1,-1), (1, 0), (1, 1), (1, 2)]
                       ]

            case .j:
                return [[(0, 0), (1, 0), (2, 0), (2, 1)],
                        [(1,-1), (1, 0), (1, 1), (0, 1)],
                        [(0,-1), (0, 0), (1, 0), (2, 0)],
                        [(1,-1), (2,-1), (1, 0), (1, 1)]
                       ]
            case .l:
                return [[(0, 1), (0, 0), (1, 0), (2, 0)],
                        [(0,-1), (1,-1), (1, 0), (1, 1)],
                        [(2,-1), (2, 0), (1, 0), (0, 0)],
                        [(1,-1), (1, 0), (1, 1), (2, 1)]
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
            case .o: return "Red"
            case .s: return "Pink"
            case .z: return "Lightblue"
            case .i: return "Green"
            case .j: return "Orange"
            case .l: return "Blue"
            case .t: return "Yellow"
            }
        }
    }

    let shape: Shape
    let rotation: Int
    let position: (Int, Int)

    var appearance: String {
        return self.shape.appearance
    }

    var points: [(Int, Int)] {
        return self.shape.points[self.rotation].map { ($0.0 + position.0, $0.1 + position.1) }
    }

    init (using random: inout RandomNumberGenerator) {
        self.shape = Shape.allCases.randomElement(using: &random)!
        let r: UInt64 = random.next(upperBound: 4)
        self.rotation = Int(truncatingIfNeeded: r) % self.shape.points.count
        self.position = (0, 1)
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
