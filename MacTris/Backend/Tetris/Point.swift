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
    /// The column index (horizontal position).
    let column: Int
    /// The row index (vertical position).
    let row: Int

    /// Creates a point with the given column and row.
    init (_ column: Int, _ row: Int) {
        self.column = column
        self.row = row
    }

    /// The origin point (0, 0).
    static let zero = Point(0, 0)
}

extension Point: Equatable {}

extension Point: Hashable {}
