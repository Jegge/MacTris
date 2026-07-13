//
//  Statistics.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 20.12.25.
//

struct Statistics {
    private var counts: [Tetromino.Shape: Int] = [:]

    mutating func add(_ shape: Tetromino.Shape) {
        counts[shape] = (counts[shape] ?? 0) + 1
    }

    var total: Int {
        counts.reduce(0) { $0 + $1.value }
    }

    func count(_ shape: Tetromino.Shape) -> Int {
        counts[shape] ?? 0
    }

    func percent(_ shape: Tetromino.Shape) -> Double {
        total > 0 ? (Double(count(shape)) / Double(total)) * 100.0 : 0.0
    }
}

extension Statistics: CustomStringConvertible {
    var description: String {
        Tetromino.Shape
            .allCases
            .map { String(format: "%@ %.04f%% (%d/%d)", String(describing: $0).uppercased(), percent($0), count($0), total) }
            .joined(separator: ", ")
    }
}
