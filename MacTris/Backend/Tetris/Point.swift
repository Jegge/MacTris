//
//  Point.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 18.07.26.
//

/// A two-dimensional coordinate on the game board.
/// The origin (0, 0) is at the bottom-left, with column increasing to the right
/// and row increasing upward.
struct Point {
    let column: Int
    let row: Int

    init (_ column: Int, _ row: Int) {
        self.column = column
        self.row = row
    }

    /// The origin point (0, 0).
    static let zero = Point(0, 0)
}

extension Point: Equatable {}

extension Point: Hashable {}
