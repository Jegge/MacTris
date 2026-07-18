//
//  Point.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 18.07.26.
//

struct Point {
    let column: Int
    let row: Int

    init (_ column: Int, _ row: Int) {
        self.column = column
        self.row = row
    }

    static let zero = Point(0, 0)
}

extension Point: Equatable {}
